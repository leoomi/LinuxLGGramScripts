# Linux LG Gram Scripts
A set of scripts to facilitate the usage of Linux drivers for LG Gram laptops. The driver might be available on kernels 4.20 and above.
This has only been tested on the 15Z980 model and likely works with other Z980 models as well. 14Z90 reportedly did not work with Ubuntu 20.04.
For more information on the LG Gram Linux driver and how these scripts work, visit [this link](https://www.kernel.org/doc/html/latest/admin-guide/laptops/lg-laptop.html)

## Installation
Clone this repository in a directory and add it to your PATH. Alternatively, copy all the .sh files to a directory already in your path. Also make sure the scripts are executable, if not or unsure, run:

```sh
chmod +x *.sh
```
## Usage
These scripts use sudo, so your password might be needed.
All scripts can be used to toggle on and off its respective feature. Alternatively, **on** and **off** can be used as a parameter for setting the features.
Example:

```sh
lgbatterylimit.sh on
```

The following scripts are available:
* lgbatterylimit.sh - If turned on it limits the battery charge to 80%. This might help extend the battery's life.
* lgfamode.sh - Used to activate silent fan mode.
* lgfnlock.sh - Turn on FN lock. If on, the special functions on F keys are going to be activated without the need of holding the FN key.
* lgreadermode.sh - Turns on the reader mode LED on the keyboard and activates reader mode. This should help with reducing eye strain by reducing the amount of blue light being emitted by the display. The actual reader mode did not work for me, but the LED part did work.
* lgtouchpadled.sh - Turns the touchpad LED on the keyboard on and off. Does not affect the actual touchpad.
* lgusbcharge.sh - Turns on and off powering USB devices while the laptop is off.

The keyboard backlight function could be adjusted by scripts, but it works fine with the FN shortcut for me and I was lazy to implement it would be a little bit different from the other scripts. If you need this script, it should be pretty easy to implement though.

## Tips
My main intent for making these scripts was to activate the battery limit mode easily. At boot, all these configurations will be reset, so I would advise turning on/off whatever you need in your root's cron file:

```sh
sudo crontab -e
```

As an example:

```
@reboot /home/USER/opt/bin/lgbatterylimit.sh on
```
If this doesn't you might need to add the bash command:
```
@reboot bash /home/USER/opt/bin/lgbatterylimit.sh on
```

For any suggestions and improvements feel free to open an issue or a pull request!
Also if you tested this or the LG Gram Linux drivers in models that are not the 15Z980 feel free to open an issue so we can know the compatibility.
