DRIVER="/sys/devices/platform/lg-laptop/usb_charge"
if [ ! -f $DRIVER ]; then
  echo "LG driver file not found"
  exit -1
fi

TURN_ON=1
if [ $# -eq 0 ]; then
  PREV_VAL=`cat $DRIVER`

  if [[ $PREV_VAL == 1 ]]; then
    TURN_ON=0
  fi
else
  if [ "$1" == "off" ]; then
    TURN_ON=0
  fi
fi

if [[ $TURN_ON == 1 ]]; then
  echo "Turning on usb charge"
  sudo bash -c "echo 1 > $DRIVER"
else
  echo "Turning off usb charge"
  sudo bash -c "echo 0 > $DRIVER"
fi
