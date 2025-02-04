#!/bin/bash -e
#--------------------------------------------------------------
#   Script: launch_shoreside.sh                                    
#  Mission: legrun_heron
#   Author: Mike Benjamin
#   LastEd: Oct 2022
#--------------------------------------------------------------  
#  Part 1: Set global variables
#--------------------------------------------------------------
ME=`basename "$0"`
GRN=$(tput setaf 2) # Green 
NC=$(tput setaf 0)  # Reset

TIME_WARP=1
JUST_MAKE="no"
VERBOSE=""
AUTO_LAUNCHED="no"
CMD_ARGS=""
XMODE="M300"

REGION="pavlab"
IP_ADDR="localhost"
MOOS_PORT="9000"
PSHARE_PORT="9200"
FORCE_IP=""
#VNAMES="abe:ben:deb:eve:fin:max:oak"
VNAMES="abe:deb:oak"

#--------------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#--------------------------------------------------------------
for ARGI; do
    CMD_ARGS+="${ARGI} "
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME: [OPTIONS] [time_warp]                       " 
	echo "                                                 "
	echo "Options:                                         "
        echo "  --help, -h                                     "
        echo "    Display this help message                    "
	echo "  --just_make, -j                                " 
	echo "    Just make target files. Do not launch.       "
        echo "  --verbose, -v                                  "
        echo "    Increase verbosity                           "
        echo "  --auto, -a                                     "
        echo "     Auto-launched by a script.                  "
        echo "     Will not launch uMAC as the final step.     "
	echo "                                                 "
	echo "  --region=<region>                              " 
	echo "    Name of the region of operation              "
	echo "                                                 "
	echo "  --ip=<localhost>                               " 
	echo "    Force pHostInfo to use this IP Address       "
	echo "    Shortcut: --sip same as --ip=192.168.1.37    "
	echo "  --mport=<9000>                                 "
	echo "    Port number of this vehicle's MOOSDB port    "
	echo "  --pshare=<9200>                                " 
	echo "    Port number of this vehicle's pShare port    "
	echo "  --vnames=<vname:vname:vname>                   " 
	echo "    List of anticipated vehicle names            "
	echo "                                                 "
	echo "  --sim, -s: This is simultion not robot         "
	exit 0;
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then 
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ]; then
	JUST_MAKE="yes"
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--auto" -o "${ARGI}" = "-a" ]; then
        AUTO_LAUNCHED="yes"

    elif [ "${ARGI:0:5}" = "--ip=" ]; then
        IP_ADDR="${ARGI#--ip=*}"
	FORCE_IP="yes"
    elif [ "${ARGI}" = "-sip" -o "${ARGI}" = "--sip" ]; then
        IP_ADDR="192.168.1.37"
	FORCE_IP="yes"
    elif [ "${ARGI:0:7}" = "--mport" ]; then
	MOOS_PORT="${ARGI#--mport=*}"
    elif [ "${ARGI:0:9}" = "--pshare=" ]; then
        PSHARE_PORT="${ARGI#--pshare=*}"
    elif [ "${ARGI:0:9}" = "--region=" ]; then
        REGION="${ARGI#--region=*}"
    elif [ "${ARGI:0:9}" = "--vnames=" ]; then
        VNAMES="${ARGI#--vnames=*}"
    elif [ "${ARGI}" = "--sim" -o "${ARGI}" = "-s" ]; then
        XMODE="SIM"
    else 
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#---------------------------------------------------------------
#  Part 3: If verbose, show vars and confirm before launching
#---------------------------------------------------------------
if [ "${VERBOSE}" = "yes" ]; then 
    echo "======================================================"
    echo "        launch_shoreside.sh SUMMARY                   "
    echo "======================================================"
    echo "$ME"
    echo "CMD_ARGS =      [${CMD_ARGS}]      "
    echo "TIME_WARP =     [${TIME_WARP}]     "
    echo "AUTO_LAUNCHED = [${AUTO_LAUNCHED}] "
    echo "JUST_MAKE =     [${JUST_MAKE}]     "
    echo "---------------------------------- "
    echo "IP_ADDR =       [${IP_ADDR}]       "
    echo "MOOS_PORT =     [${MOOS_PORT}]     "
    echo "PSHARE_PORT =   [${PSHARE_PORT}]   "
    echo "---------------------------------- "
    echo "XMODE =         [${XMODE}]         "
    echo "REGION =        [${REGION}]        "
    echo "VNAMES =        [${VNAMES}]        "
    echo -n "Hit any key to continue with launching SHORESIDE"
    read ANSWER
fi


#--------------------------------------------------------------
#  Part 4: Create the .moos and .bhv files using nsplug
#--------------------------------------------------------------
nsplug meta_shoreside.moos targ_shoreside.moos -i -f WARP=$TIME_WARP \
       IP_ADDR=$IP_ADDR       PSHARE_PORT=$PSHARE_PORT        \
       MOOS_PORT=$MOOS_PORT   REGION=$REGION                  \
       FORCE_IP=$FORCE_IP     VNAMES=$VNAMES                  \
       XMODE=$XMODE

if [ ${JUST_MAKE} = "yes" ]; then
    echo "Files assembled; nothing launched; exiting per request."
    exit 0
fi

#--------------------------------------------------------------
#  Part 5: Launch the processes
#--------------------------------------------------------------
echo "$GRN Launching Shoreside MOOS Community. WARP=$TIME_WARP $RST"
pAntler targ_shoreside.moos >& /dev/null &
echo "$GRN Done Launching Shoreside Community $RST"

#---------------------------------------------------------------
#  Part 6: If launched from script, we're done, exit now
#---------------------------------------------------------------
if [ "${AUTO_LAUNCHED}" = "yes" ]; then
    exit 0
fi

#---------------------------------------------------------------
# Part 7: Launch uMAC until the mission is quit
#---------------------------------------------------------------
uMAC targ_shoreside.moos
kill -- -$$

