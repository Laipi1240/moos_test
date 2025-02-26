#!/bin/bash
#---------------------------------------------------------------
#   Script: launch.sh
#  Mission: legrun_heron
#   Author: Mike Benjamin
#   LastEd: Oct 2022
#-------------------------------------------------------------- 
#  Part 1: Define a convenience function for producing terminal
#          debugging/status output depending on the verbosity.
#-------------------------------------------------------------- 
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }

#---------------------------------------------------------------
#  Part 2: Set global var defaults
#---------------------------------------------------------------
ME=`basename "$0"`
TIME_WARP=1
JUST_MAKE=""
VERBOSE=""
VNAME1="abe"
REGION="pavlab"
CLEAN="no"
CMD_ARGS=""
RND_SPD=""
LOC="north"
AUX_SHARE_CONFIG="192.168.1.16:9250"
SHARE_AUX="no"

RANDSTART="true"
AMT=1

VLAUNCH_ARGS=" --auto --region=$REGION --sim --vname=$VNAME1 --index=1 "
SLAUNCH_ARGS=" --auto --region=$REGION "

#---------------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#---------------------------------------------------------------
for ARGI; do
    CMD_ARGS+="${ARGI} "
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [SWITCHES] [time_warp]                                 "
	echo "  --help, -h         Show this help message                "
	echo "  --just_make, -j    Just make targ files, no launch       "
	echo "  --verbose, -v      Verbose output, confirm before launch "
	echo "  --clean, -cc       Run clean.sh and ktm prior to launch  "
	echo "  --norand                                                 " 
	echo "    Do not randomly generate files vpositions.txt. Just    "
	echo "    re-use the previous versions if they exist.            "
	echo "  --rndspd,          Set speed of leg run randomly         "
	echo "  --aux=<192.168.1.16:9250> ip and port of auxilary        "
	echo "    computer for reachabilty analysis.  If used in this    "
	echo "    script, all vehicles will send information to the same "
	echo "    aux computer                                           "
	exit 0
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ]; then
	JUST_MAKE=$ARGI
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE=$ARGI
    elif [ "${ARGI}" = "--clean" -o "${ARGI}" = "-cc" ]; then
	CLEAN="yes"
    elif [ "${ARGI:0:6}" = "--amt=" ]; then
        AMT="${ARGI#--amt=*}"
	if [ ! $AMT -ge 1 ]; then
	    echo "$ME: Vehicle amount must be >= 1."
	    exit 1
	fi
    elif [ "${ARGI:0:8}" = "--rndspd" ]; then
        RND_SPD="--rndspd"
    elif [ "${ARGI:0:6}" = "--aux=" ]; then
	AUX_SHARE_CONFIG="${ARGI#--aux=*}"
	SHARE_AUX="yes"
    else
	
        echo "$ME: Bad arg:" $ARGI "Exit Code 1."
        exit 1
    fi
done

VLAUNCH_ARGS+=" $VERBOSE $JUST_MAKE $TIME_WARP "
SLAUNCH_ARGS+=" $VERBOSE $JUST_MAKE $TIME_WARP $RND_SPD"


#---------------------------------------------------------------
#  Part 4: If verbose, show vars and confirm before launching
#---------------------------------------------------------------
if [ "${VERBOSE}" != "" ]; then 
    echo "======================================================"
    echo "              launch.sh SUMMARY                       "
    echo "======================================================"
    echo "$ME"
    echo "CMD_ARGS =       [${CMD_ARGS}]      "
    echo "TIME_WARP =      [${TIME_WARP}]     "
    echo "AUTO_LAUNCHED =  [${AUTO_LAUNCHED}] "
    echo "AMT =            [${AMT}]           "
    echo -n "Hit the RETURN key to continue with launching"
    read ANSWER
fi

#-------------------------------------------------------------
# Part 5A: If Cleaning enabled, clean first
#-------------------------------------------------------------
vecho "Running ./clean.sh and ktm prior to launch"
if [ "${CLEAN}" = "yes" ]; then
    ./clean.sh; ktm
fi

#-------------------------------------------------------------
# Part 5B: Generate random starting positions, speeds and vnames
#-------------------------------------------------------------
#vecho "Picking vehicle starting positions."
#if [ "${RANDSTART}" = "true" -o  ! -f "vpositions.txt" ]; then
#    ./pickpos.sh $AMT
#fi

# vehicle names and colors are always deterministic
pickpos --amt=$AMT --vnames  > vnames.txt
pickpos --amt=$AMT --colors  > vcolors.txt

VEHPOS=(`cat vpositions.txt`)
VNAMES=(`cat vnames.txt`)
COLORS=(`cat vcolors.txt`)

#-------------------------------------------------------------
# Part 5C: Launch the vehicles
#-------------------------------------------------------------
for INDEX in `seq 1 $AMT`;
do
    sleep 0.2
    ARRAY_INDEX=`expr $INDEX - 1`
    START=${VEHPOS[$ARRAY_INDEX]}
    VNAME=${VNAMES[$ARRAY_INDEX]}
    COLOR=${COLORS[$ARRAY_INDEX]}

    if [ $((ARRAY_INDEX%2)) -eq 0 ];
    then
	VLAUNCH_ARGS+=" --loc=north"
    else
	VLAUNCH_ARGS+=" --loc=south"
    fi

    if (( $AMT > 1)); then
        VLAUNCH_ARGS+=" --2V"
    fi   


    if [ "${SHARE_AUX}" = "yes" ]; then
	VLAUNCH_ARGS+="  --aux=$AUX_SHARE_CONFIG   "	
    fi

    VLAUNCH_ARGS+=" $NOCONFIRM "
    IX_VLAUNCH_ARGS=$VLAUNCH_ARGS
    IX_VLAUNCH_ARGS+=" --index=$INDEX --start=$START     "
    IX_VLAUNCH_ARGS+=" --maxspd=$MAXIMUM_SPD             "
    IX_VLAUNCH_ARGS+=" --speed=$TRANSIT_SPD              " 
    IX_VLAUNCH_ARGS+=" --color=$COLOR                    " 
    IX_VLAUNCH_ARGS+=" --vname=$VNAME  --shore=localhost "

    ./launch_vehicle.sh $IX_VLAUNCH_ARGS	
done

#---------------------------------------------------------------
#  Part 6: Launch the shoreside
#---------------------------------------------------------------
echo "$ME: Launching Shoreside ..."
./launch_shoreside.sh $SLAUNCH_ARGS

#---------------------------------------------------------------
#  Part 7: If launched from script, we're done, exit now
#---------------------------------------------------------------
if [ "${AUTO_LAUNCHED}" = "yes" -o "${JUST_MAKE}" != "" ]; then
    exit 0
fi

#---------------------------------------------------------------
# Part 8: Launch uMAC until the mission is quit
#---------------------------------------------------------------
uMAC targ_shoreside.moos
kill -- -$$

