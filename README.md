# Asuswrt-Merlin-Linux-Shell-Scripts
Miscellaneous Linux Shell Scripts developed for Asuswrt-Merlin firmware

# profile.add

profile.add adds environment variables when a user logs in over an SSH session.  This is a good place to create command line short cuts or custom commands that you can run from an SSH command line.

#### Command Line Short Cuts
```
logdir - cd /opt/var/log

js - cd /jffs/scripts

jc - cd /jffs/configs
```

#### Custom Commands
```
Clients - list active LAN Clients

MatchIP - Check IP against ipset lists to see if it exists
          Usage: MactchIP 111.222.333.444

liststats - List number of entries in each IPSET list

listiface - List status of WAN and OpenVPN interfaces

purge_routes - Purge OpenVPN and ip rule routes
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

### ChK_ADNS.sh Installation
````
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/Xentrk/Asuswrt-Merlin-Linux-Shell-Scripts/master/ChK_ADNS.sh" -o "/jffs/scripts/ChK_ADNS.sh" && chmod 755 /jffs/scripts/ChK_ADNS.sh && sh /jffs/scripts/ChK_ADNS.sh
````

# dhcpstaticlist.sh

Helpful utility to:

1. Save dhcp_staticlist nvram values to **/opt/tmp/dhcp_staticlist.txt**. This will allow you to restore the values after performing a factory reset.

2. Restore dhcp_staticlist nvram values from **/opt/tmp/dhcp_staticlist.txt**

3. Preview nvram dhcp_staticlist in dnsmasq.conf format

4. Append output of dhcp_staticlist to **/jffs/configs/dnsmasq.conf.add** in dnsmasq format and disable **Manual Assignment** in the WAN GUI. You will then be prompted to reboot the router to have the settings take effect.

5. Disable DHCP Manual Assignment in the LAN GUI

6. Enable DHCP Manual Assignment in the LAN GUI

7. Save nvram dhcp_staticlist to **/opt/tmp/dhcp_staticlist.txt** and delete the DHCP Manual Assignment nvram values from dhcp_staticlist

### dhcpstaticlist.sh Installation
````
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/Xentrk/Asuswrt-Merlin-Linux-Shell-Scripts/master/dhcpstaticlist.sh" -o "/jffs/scripts/dhcpstaticlist.sh" && chmod 755 /jffs/scripts/dhcpstaticlist.sh && sh /jffs/scripts/dhcpstaticlist.sh
````
