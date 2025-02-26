# Check if the folder is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <mission-folder>"
    exit 1
fi

mission_folder="$1"

rm -rf $mission_folder/**/**.blog $mission_folder/**/**.ylog $mission_folder/**/**.slog

deletions="\
    DB_EVENT \
    DB_CLIENTS \
    DB_UPTIME \
    DB_TIME \
    LOGGER_DIRECTORY \
    APPCAST \
    PSHARE_INPUT_SUMMARY \
    PSHARE_OUTPUT_SUMMARY \
    APPCAST_REQ \
    ACK_MESSAGE \
    ACK_MESSAGE_LOCAL \
    OPR_TRAJECTORY_PERIM_ETA \
    UMH_SUMMARY_MSGS \
    NODE_PSHARE_VARS \
    APP_LOG \
    PROC_WATCH_TIME_WARP \
    PROC_WATCH_EVENT \
    PROC_WATCH_ALL_OK \
    PROC_WATCH_SUMMARY \
    PROC_WATCH_FULL_SUMMARY \
    IVPHELM_LOOP_CPU \
    IVPHELM_CREATE_CPU \
    IVPHELM_ITER \
    IVPHELM_TOTAL_PCS_CACHED \
    IVPHELM_TOTAL_PCS_FORMED \
    IVPHELM_IPF_CNT \
    IVPHELM_SUMMARY \
    HELM_MAP_CLEAR \
    PNODEREPORTER_PID \
    UFLDNODEBROKER_PID \
    PSHARE_CMD \
    LOGGER_DIRECTORY \
    PID_REPORT \
    UMH_SUMMARY_MSGS \
    NODE_BROKER_ACK \
    NODE_PSHARE_VARS \
    MISSION_HASH \
    HELM_MAP_CLEAR \
    REALMCAST_CHANNELS \
    IVPHELM_REGISTER \
    CONTACTS_RECAP \
    CONTACT_RANGES \
    PCONTACTMGRV20_PID \
    IVPHELM_CPU \
    PNR_EXTRAP_POS_GAP \
    PNR_EXTRAP_HDG_GAP \
    BHV_IPF \
    BHV_EVENT \
    OPR_SECS_IN_POLY \
    OPR_DEBUG \
    OPR_TRAJECTORY_PERIM_DIST \
    COMMS_POLICY \
    PLOGGER_CMD \
    TM_ALERT_REQUEST \
    BCM_ALERT_REQUEST \
    MOOS_DEBUG \
    VIEW_POINT \
    TAIL_SIZE \
    HM_SIZE \
    MEDIATED_MESSAGE \
    MEDIATED_MESSAGE* \
    MEDIATED_MESSAGE_LOCAL \
    NAV_HEADING_OVER_GROUND \
    NAV_LAT \
    NAV_LONG \
    HIT_MARKER \
    IVPHELM_UPDATE_RESULT \
    PNR_POST_GAP \
    OPR_ABSOLUTE_PERIM_DIST \
    OPR_ABSOLUTE_PERIM_ETA \
    ALERT_VERBOSE \
    VIEW_COMMS_PULSE \
    UFSB_BRIDGE_VARS \
    *_ITER_LEN \
    *_ITER_GAP \
    DB_QOS \
    ACK_MESSAGE_* \
    PHOSTINFO_ITER_GAP \
    PHOSTINFO_ITER_LEN \
    UPROCESSWATCH_ITER_GAP \
    UPROCESSWATCH_ITER_LEN \
    UFLDSHOREBROKER_ITER_GAP \
    UFLDSHOREBROKER_ITER_LEN \
    NODE_BROKER_PING \
    PREALM_ITER_GAP \
    PREALM_ITER_LEN \
    UFLDTASKMONITOR_ITER_GAP \
    UFLDTASKMONITOR_ITER_LEN \
    UXMS_838_ITER_GAP \
    UXMS_838_ITER_LEN \
    UFLDCOLLISIONDETECT_ITER_GAP \
    UFLDCOLLISIONDETECT_ITER_LEN \
    "

for DIR in $mission_folder/*; do
    for alog in $DIR/*.alog; do 
        mv $alog ${alog}-old
        alogrm -f -q ${alog}-old $deletions $alog
        rm ${alog}-old
    done 
done