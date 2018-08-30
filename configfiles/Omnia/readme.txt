Flashing the Turris Omnia
-------------------------

From factory to ROOter

- Copy the ROOter 'upgrade.img.gz' file and the 'omnia-medkit-turris-omnia-initramfs.tar.gz' file to the root of a
USB flash drive formatted with FAT32.

- Rename the ROOter upgrade file to 'upgrade.img.gz'.

- Disconnect other USB devices from the Omnia and connect the flash drive to either USB port.

- Power on the Omnia while holding down the rear reset button and hold it until 4 LEDs are
illuminated, then release.

- Wait approximately 2 minutes for the Turris Omnia to flash itself with the temporary image, 
during which time the LEDs will change multiple times.

- Connect a computer to a LAN port of the Turris Omnia. It may need to have a static IP of 192.168.1.2

- Use Putty to access 192.168.1.1 using SSH.

- At the command line enter the following lines :

	mount /dev/sda1 /mnt
	sysupgrade /mnt/upgrade.img.gz
	
- Wait another minute for the final OpenWrt image to be flashed. The Turris Omnia will reboot itself and
you can remove the flash drive.