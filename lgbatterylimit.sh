DRIVER="/sys/devices/platform/lg-laptop/battery_care_limit"
if [ ! -f $DRIVER ]; then
  echo "LG driver file not found"
  exit -1
fi

TURN_ON=1
if [ $# -eq 0 ]; then
  PREV_VAL=`cat $DRIVER`

  if [[ $PREV_VAL == 80 ]]; then
    TURN_ON=0
  fi
else
  if [ "$1" == "off" ]; then
    TURN_ON=0
  fi
fi

if [[ $TURN_ON == 1 ]]; then
  echo "Changing battery limit to 80%"
  sudo bash -c "echo 80 > $DRIVER"
else
  echo "Changing battery limit to 100%"
  sudo bash -c "echo 100 > $DRIVER"
fi
