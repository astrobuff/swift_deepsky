#!/usr/bin/env bash
set -u

event_files(){
  DATA_ARCHIVE="$1"
  OBS_ADDR_LIST="$2"

  SWIFT_OBS_ARCHIVE="${DATA_ARCHIVE}/swift/data/obs"

  echo "# Event files"
  for ln in `cat $OBS_ADDR_LIST`
  do
    OIFS=$IFS
    IFS='/' read -ra FLDS <<< $ln
    IFS=$OIFS
    DATADIR="${SWIFT_OBS_ARCHIVE}/${FLDS[0]}/${FLDS[1]}"
    [ -d $DATADIR ] || continue
    XRTDIR=${DATADIR}/xrt
    EVTDIR=${XRTDIR}/event
    ls ${EVTDIR}/*pc*po_cl.evt.gz
  done
}

exposure_maps() {
  DATA_ARCHIVE="$1"
  OBS_ADDR_LIST="$2"

  SWIFT_OBS_ARCHIVE="${DATA_ARCHIVE}/swift/data/obs"

  echo "# Event files"
  for ln in `cat $OBS_ADDR_LIST`
  do
    OIFS=$IFS
    IFS='/' read -ra FLDS <<< $ln
    IFS=$OIFS
    DATADIR="${SWIFT_OBS_ARCHIVE}/${FLDS[0]}/${FLDS[1]}"
    [ -d $DATADIR ] || continue
    XRTDIR=${DATADIR}/xrt
    EXPDIR=${XRTDIR}/products
    ls ${EXPDIR}/*pc*ex.img.gz
  done
}

# create_obsfilelist() {
#   DATADIR="$1"
#   OBSTIMELIST="$2"
#   EVENTSFILE="$3"
#   EXMAPSFILE="$4"
#
#   echo "# OBJECT event files" > $EVENTSFILE
#   echo "#OBJECT exposure maps" > $EXMAPSFILE
#   for ln in `cat $OBSTIMELIST`
#   do
#       OIFS=$IFS
#       IFS='/' read -ra FLDS <<< $ln
#       IFS=$OIFS
#       datadir="${DATADIR}/swift/data/obs/${FLDS[0]}/${FLDS[1]}"
#       [ -d $datadir ] || continue
#       echo "Checking ${FLDS[*]}"
#       xrtdir=${datadir}/xrt
#       evtdir=${xrtdir}/event
#       ls ${evtdir}/*pc*po_cl.evt.gz  | tee -a $EVENTSFILE
#       expodir=${xrtdir}/products
#       ls ${expodir}/*pc*ex.img.gz  | tee -a $EXMAPSFILE
#   done
# }

create_xselect_script() {
  NAME="$1"
  IMGLIST="$2"
  RESULT="$3"

  NAME=$(echo $NAME | tr -c "[:alnum:]\n" "_")

  read -a IMAGES <<< `grep -v "^#" $IMGLIST`
  NUMIMAGES=${#IMAGES[@]}

  echo "xsel"
  i=0
  _FILE=${IMAGES[$i]##*/}
  cp ${IMAGES[$i]} "${TMPDIR}/${_FILE}"
  echo "read ev $_FILE"
  echo "${TMPDIR}/"
  echo "yes"
  for ((i=1; i<$NUMIMAGES; i++)); do
    _FILE=${IMAGES[$i]##*/}
    cp ${IMAGES[$i]} "${TMPDIR}/${_FILE}"
    echo "read ev $_FILE"
    if [ $i -ge 20 ]; then
      echo 'yes'
    fi
  done
  echo 'extract ev'
  echo "save ev $RESULT"
  echo "yes"
  echo "quit"
  echo "no"
}

create_ximage_script() {
  NAME="$1"
  IMGLIST="$2"
  RESULT="$3"

  NAME=$(echo $NAME | tr -c "[:alnum:]\n" "_")

  echo "cpd  ${NAME}_sum.gif/gif"
  read -a IMAGES <<< `grep -v "^#" $IMGLIST`
  NUMIMAGES=${#IMAGES[@]}
  i=0
  echo "read/size=1024  ${IMAGES[$i]}"
  for ((i=1; i<$NUMIMAGES; i++)); do
    echo "read/size=1024  ${IMAGES[$i]}"
    echo 'sum_image'
    echo 'save_image'
  done
  echo "display"
  echo "write_ima/template=all/file='$RESULT'"
  echo "exit"
}

# EVENTSFILE='object_events.txt'
# EXMAPSFILE='object_exmaps.txt'
# create_obsfilelist $PWD 'object_observations.csv' $EVENTSFILE $EXMAPSFILE
# script_xselect_sum 'object' $EVENTSFILE 'events_sum.xco' 'evts'
# script_ximage_sum 'object' $EXMAPSFILE 'exmaps_sum.xco' 'expo'