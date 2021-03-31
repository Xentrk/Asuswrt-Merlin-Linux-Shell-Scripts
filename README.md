# Asuswrt-Merlin-Linux-Shell-Scripts
Miscellaneous Linux Shell Scripts developed for Asuswrt-Merlin firmware

# profile.add

profile.add adds environment variables when a user logs in over an SSH session.  This is a good place to create command line short cuts or custom commands that you can run from an SSH command line.

#### Command Line Short Cuts
Usage: ```help```

```
Command List:

Chk_ADNS      List OpenVPN DNS Settings
clients       List hostname, IP address and MAC address for LAN clients
js            cd /jffs/scripts
jc            cd /jffs/configs
ld            cd /opt/var/log
liststats     List number of entries in each IPSET list
listiface     List status of WAN and OpenVPN interfaces
MatchIP       Check IP against IPSET lists to see if the IP address exists
              Usage: MactchIP 111.222.333.444
purge_routes  Purge policy routing rules
routes        Alternative to 'ip routes' command
tree          Similar to the Unix 'tree' command to list directories
ltree         List directories and files in each directory
```

### profile.add Installation
````
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/Xentrk/Asuswrt-Merlin-Linux-Shell-Scripts/master/profile.add" -o "/jffs/configs/profile.add"
````
You must open up a new SSH session to run the commands.

# Chk_ADNS.sh

Displays WAN and OpenVPN Interfaces and their connectivity status.  In addition, the script will check if the router uses the ad blocking software called [Diversion](https://diversion.ch). If Diversion is installed, the script will examine the **Accept DNS Configuration** OpenVPN client setting for active OpenVPN clients.

If **Accept DNS Exclusive** is set to **Exclusive** and **Redirect Internet Traffic** is set to **Policy Rules** or
**Policy Rules (Strict)**, instruct the user that Diversion will not work over the VPN tunnel and provide instructions for the work-around solution.

### Chk_ADNS.sh Installation
````
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/Xentrk/Asuswrt-Merlin-Linux-Shell-Scripts/master/Chk_ADNS.sh" -o "/jffs/scripts/Chk_ADNS.sh" && chmod 755 /jffs/scripts/Chk_ADNS.sh && sh /jffs/scripts/Chk_ADNS.sh
````

# dhcpstaticlist.sh

The 384 code base limits the total length of dhcp_staticlist to 2999 characters. As a result, the update of dhcp_staticlist will fail if it exceeds the 2999 character limit. A workaround to the size limit is to manually configure dhcp static leases in dnsmasq instead of using the Web GUI. Or, do that for just a few to reduce the 2999 character limit used by the Web GUI. In Ausswrt-Merlin, add the dhcp static leases to **/jffs/configs/dnsmasq.conf.add**. The format is below.

````
dhcp-host=49:EF:0C:24:7F:16,D-Link-AP,192.168.2.10,1440
dhcp-host=11:20:AE:5E:86:63,Security-Camera-DVR,192.168.2.200,1440
dhcp-host=94:C9:B2:5D:F5:04,D-Link_Switch,192.168.2.201,1440
````

1440 minutes is the default lease time. Make sure to disable **Manual Assignment** of DHCP leases on the LAN page. Then, reboot the router for the settings to take effect.

**dhcpstaticlist.sh** is a helpful utility script to manage DHCP static leases. The script displays a menu with the following functions:

1. Save nvram dhcp_staticlist and dhcp_hostnames to /opt/tmp. This will allow you to restore the values after performing a factory reset.

2. Restore nvram dhcp_staticlist and dhcp_hostnames from /opt/tmp/.

3. Preview dhcp_staticlist and dhcp_hostnames in dnsmasq format.

4. Append Output DHCP Static List to /jffs/configs/dnsmasq.conf.add & Disable Manual Assignment in the WAN GUI. You will then be prompted to reboot the router to have the settings take effect.

5. Disable DHCP Manual Assignment.

6. Enable DHCP Manual Assignment.

7. Backup nvram dhcp_staticlist and dhcp_hostnames to /opt/tmp/ and clear nvram values.

8. Display character size of dhcp_staticlist and dhcp_hostnames.

### dhcpstaticlist.sh Installation
````
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/Xentrk/Asuswrt-Merlin-Linux-Shell-Scripts/master/dhcpstaticlist.sh" -o "/jffs/scripts/dhcpstaticlist.sh" && chmod 755 /jffs/scripts/dhcpstaticlist.sh && sh /jffs/scripts/dhcpstaticlist.sh
````
# wan-event script
Firmware version 384.15 introduced the /jffs/scripts/wan-event script.

The first parameter passed to **wan-event** will be the WAN unit (0 for first WAN, 1 for secondary). The second parameter passed to **wan-event** will be a string describing the type of event (init, connected, etc...). A wan-event of type "connected" will be identical to when the original wan-start script was being run. **wan-start** should be considered deprecated and will be removed in a future release.

```
wan-event {0 | 1} {connecting | connected | disconnected | init | stopped | stopping }
```
Example script names run by wan-event:

wan0-stopping, wan0-stopped, wan0-connected, wan0-disconnected, wan0-init, wan0-stopped, wan0-stopping

### wan-event Installation
````
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/Xentrk/Asuswrt-Merlin-Linux-Shell-Scripts/master/wan-event" -o "/jffs/scripts/wan-event" && chmod 755 /jffs/scripts/wan-event
````

# Contributors

* Xentrk
* James Olsen samej71
