DRIVER="/sys/class/power_supply/CMB0/charge_control_end_threshold"

OLD_DRIVER="/sys/devices/platform/lg-laptop/battery_care_limit"

# Lets check the kernel version
# https://github.com/torvalds/linux/commit/07f5ed0eee011f2b76ee01a4939f3ff1d34ac5e3
function driver_path_check() {
  CURRENT_KERNEL_VERSION=$(uname --kernel-release | cut --delimiter="." --fields=1-2)
  CURRENT_KERNEL_MAJOR_VERSION=$(echo "${CURRENT_KERNEL_VERSION}" | cut --delimiter="." --fields=1)
  CURRENT_KERNEL_MINOR_VERSION=$(echo "${CURRENT_KERNEL_VERSION}" | cut --delimiter="." --fields=2)
  if [ "${CURRENT_KERNEL_MAJOR_VERSION}" -lt "5" ]; then
    DRIVER=$OLD_DRIVER
  fi

  if [ "${CURRENT_KERNEL_MAJOR_VERSION}" == "5" ]; then
    if [ "${CURRENT_KERNEL_MINOR_VERSION}" -lt "18" ]; then
      DRIVER=$OLD_DRIVER
    fi
  fi
}

driver_path_check

ACPI_PATH="\_SB.PCI0.LPCB.H_EC"

if [ ! -f "$DRIVER" ]; then
  if [ -e /proc/acpi/call ]; then
    echo "LG driver file not found. Falling back to acpi_call."
    USE_ACPI_CALL=1
  else
    echo "LG driver file not found and acpi_call is not installed"
    exit -1
  fi
fi

TURN_ON=1
if [ $# -eq 0 ]; then
  if [ "$USE_ACPI_CALL" == 1 ]; then
    PREV_HEX=$(echo "$ACPI_PATH.ECRX 0xBC" | sudo tee /proc/acpi/call > /dev/null && sudo cat /proc/acpi/call)
    # 0x50 is 80, 0x64 is 100
    if [[ "$PREV_HEX" == "0x50" ]]; then
      TURN_ON=0
    fi
  else
    PREV_VAL=`cat $DRIVER`
    if [[ $PREV_VAL == 80 ]]; then
      TURN_ON=0
    fi
  fi
else
  if [ "$1" == "off" ]; then
    TURN_ON=0
  fi
fi

if [[ $TURN_ON == 1 ]]; then
  echo "Changing battery limit to 80%"
  if [ "$USE_ACPI_CALL" == 1 ]; then
    echo "$ACPI_PATH.ECWX 0xBC 0x50" | sudo tee /proc/acpi/call > /dev/null
  else
    sudo bash -c "echo 80 > $DRIVER"
  fi
else
  echo "Changing battery limit to 100%"
  if [ "$USE_ACPI_CALL" == 1 ]; then
    echo "$ACPI_PATH.ECWX 0xBC 0x64" | sudo tee /proc/acpi/call > /dev/null
  else
    sudo bash -c "echo 100 > $DRIVER"
  fi
fi
