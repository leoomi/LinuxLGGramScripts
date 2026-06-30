#!/usr/bin/env bash

PATH="/usr/sbin:/usr/bin:/sbin:/bin"

DRIVERS=(
  "/sys/class/power_supply/CMB0/charge_control_end_threshold"
  "/sys/devices/platform/lg-laptop/battery_care_limit"
)
ACPI_PATH="\_SB.PCI0.LPCB.H_EC"

function as_root_write() {
  local value="$1"
  local path="$2"

  if [ "$(id -u)" -eq 0 ]; then
    printf '%s\n' "$value" > "$path"
  else
    sudo bash -c "printf '%s\n' '$value' > '$path'"
  fi
}

function acpi_call() {
  local value="$1"

  if [ "$(id -u)" -eq 0 ]; then
    printf '%s\n' "$value" > /proc/acpi/call
    cat /proc/acpi/call
  else
    printf '%s\n' "$value" | sudo tee /proc/acpi/call > /dev/null
    sudo cat /proc/acpi/call
  fi
}

function have_sysfs_driver() {
  local driver

  for driver in "${DRIVERS[@]}"; do
    if [ -f "$driver" ]; then
      return 0
    fi
  done

  return 1
}

for _ in {1..30}; do
  if have_sysfs_driver || [ -e /proc/acpi/call ]; then
    break
  fi
  sleep 1
done

TURN_ON=1
if [ $# -eq 0 ]; then
  for driver in "${DRIVERS[@]}"; do
    if [ -f "$driver" ] && [ "$(cat "$driver")" = "80" ]; then
      TURN_ON=0
      break
    fi
  done

  if ! have_sysfs_driver && [ -e /proc/acpi/call ]; then
    PREV_HEX=$(acpi_call "$ACPI_PATH.ECRX 0xBC")
    # 0x50 is 80, 0x64 is 100
    if [[ "$PREV_HEX" == "0x50" ]]; then
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
  TARGET=80
  ACPI_TARGET="0x50"
else
  echo "Changing battery limit to 100%"
  TARGET=100
  ACPI_TARGET="0x64"
fi

SYSFS_ATTEMPTED=0
SYSFS_SUCCEEDED=0
for driver in "${DRIVERS[@]}"; do
  if [ ! -f "$driver" ]; then
    continue
  fi

  SYSFS_ATTEMPTED=1
  if as_root_write "$TARGET" "$driver" && [ "$(cat "$driver")" = "$TARGET" ]; then
    SYSFS_SUCCEEDED=1
  else
    echo "Failed to set $driver to $TARGET"
  fi
done

if [ "$SYSFS_SUCCEEDED" == 1 ]; then
  exit 0
fi

if [ -e /proc/acpi/call ]; then
  if [ "$SYSFS_ATTEMPTED" == 1 ]; then
    echo "Sysfs write failed. Falling back to acpi_call."
  else
    echo "LG driver file not found. Falling back to acpi_call."
  fi
  acpi_call "$ACPI_PATH.ECWX 0xBC $ACPI_TARGET" > /dev/null
elif [ "$SYSFS_ATTEMPTED" == 0 ]; then
  echo "LG driver file not found and acpi_call is not installed"
  exit 1
else
  exit 1
fi
