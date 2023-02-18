# another-rpi-cluster

## pirouter

One Raspberry Pi serves as wireless access point for the other devices. It is connected to the main router via Ethernet and broadcasts a secondary Wifi network. The setup closely follows the [official documentation on how to set up a Raspberry Pi as routed wireless access point](https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-routed-wireless-access-point). The `channel` is set to 6 instead of 7, though, and 
```
ieee80211n=1
wmm_enabled=1
```
to obtain better network stability.
