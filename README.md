# Asuswrt-Merlin-Linux-Shell-Scripts
Miscellaneous Linux Shell Scripts developed for Asuswrt-Merlin firmware

The repository includes the following scripts:

**profile.add**

**x3mtek_Chk_ADNS**

More scripts will added in the future.

### profile.add
profile.add adds environment variables when a user logs in over an SSH session.  This is a good location for custom commands or short cuts that you can run from an SSH command line.

##### Short Cuts
```
logdir - cd /opt/var/log

js - cd /jffs/scripts

jc - cd /jffs/configs
```


##### Custom Commands
```
Clients - list active LAN Clients

MatchIP - Check IP against ipset lists to see if it exists
          Usage: MactchIP 111.222.333.444

liststats - List number of entries in each IPSET list

listiface - List status of WAN and OpenVPN interfaces

purge_routes - Purge OpenVPN and ip rule routes
```
### x3mtek_Chk_ADNS.sh

Display WAN and OpenVPN Interfaces and their connectivity status.  In addition, the script will check if the router uses the ad blocking software called [Diversion](https://diversion.ch).  If Diversion is installed, the script will examine the Accept DNS Configuration OpenVPN client setting for active OpenVPN clients.

If **Accept DNS Exclusive** is set to **Exlusive** and **Redirect Internet Traffic** is set to **Policy Rules** or
**Policy Rules (Strict)**, instruct the user that Diversion will not work over the VPN tunnel and provide instructions for the work-around solution.
