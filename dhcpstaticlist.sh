#!/bin/sh
####################################################################################################
# Script: dhcpstaticlist.sh
# Original Author: Xentrk
# Last Updated Date: 4-January-2019
# Compatible with 384.14
# Version 2.0.7
#
# Description:
#  Helpful utility to
#  1) Save nvram dhcp_staticlist and dhcp_hostnames to /opt/tmp. This will allow you to restore the values after performing a factory reset.
#  2) Restore nvram dhcp_staticlist and dhcp_hostnames from /opt/tmp/.
#  3) PPreview dhcp_staticlist and dhcp_hostnames in dnsmasq format
#  4) Append Output DHCP Static List to /jffs/configs/dnsmasq.conf.add & Disable Manual Assignment in the WAN GUI. You will then be prompted to reboot the router to have the settings take effect.
#  5) Disable DHCP Manual Assignment
#  6) Enable DHCP Manual Assignment
#  7) Backup nvram dhcp_staticlist and dhcp_hostnames to /opt/tmp/ and clear nvram values.
#  8) Display character size of dhcp_staticlist and dhcp_hostnames
#
####################################################################################################

# Uncomment for debugging
#set -x

COLOR_WHITE='\033[0m'
COLOR_GREEN='\e[0;32m'
DHCP_STATICLIST="/opt/tmp/dhcp_staticlist.txt"
DHCP_HOSTNAMES="/opt/tmp/dhcp_hostnames.txt"
MODEL=$(nvram get model)

Menu_DHCP_Staticlist() {

  clear

  while true; do
    printf '\n\nUse this utility to save or restore dhcp_staticlist and dhcp_hostnames nvram values\n\n'
    printf '%b[1]%b - Save nvram dhcp_staticlist and dhcp_hostnames to /opt/tmp/\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[2]%b - Restore nvram dhcp_staticlist and dhcp_hostnames from /opt/tmp/\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[3]%b - Preview dhcp_staticlist and dhcp_hostnames in dnsmasq format\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[4]%b - Append dhcp_staticlist and dhcp_hostnames to dnsmasq.conf.add & Disable DHCP Manual Assignment\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[5]%b - Disable DHCP Manual Assignment\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[6]%b - Enable DHCP Manual Assignment\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[7]%b - Backup nvram dhcp_staticlist and dhcp_hostnames to /opt/tmp/ and clear nvram values\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[8]%b - Display character size of dhcp_staticlist and dhcp_hostnames (2999 is the limit)\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[e]%b - Exit\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    echo
    printf "==> "
    read -r option
    echo
    case "$option" in
    1)
      Save_DHCP_Staticlist
      Save_DHCP_Hostnames
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    2)
      Restore_DHCP_Staticlist
      Restore_DHCP_Hostnames
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    3)
      Save_Dnsmasq_Format
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    4)
      printf '\n' #add return in case no blank line exists at end of file
      echo " " >>/jffs/configs/dnsmasq.conf.add
      Save_Dnsmasq_Format >>/jffs/configs/dnsmasq.conf.add
      nvram set dhcp_static_x=0
      nvram commit
      echo "In order for the DHCP static reservations to take affect"
      echo "you must reboot the router. Do so now?"
      echo
      echo "[y] - Yes"
      echo "[n] - No"
      echo
      printf "==> "
      read -r menu_option

      case "$menu_option" in
      y)
        reboot
        ;;
      n)
        break
        ;;
      *)
        echo "[*] $option Isn't An Option!"
        ;;
      esac

      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    5)
      nvram set dhcp_static_x=0
      nvram commit
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    6)
      nvram set dhcp_static_x=1
      nvram commit
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    7)
      Save_DHCP_Staticlist
      Save_DHCP_Hostnames
      nvram unset dhcp_staticlist
      nvram unset dhcp_hostnames
      nvram set dhcp_static_x=0
      nvram commit
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    8)
      if [ -s /jffs/nvram/dhcp_staticlist ]; then # HND Routers store here
        wc_staticlist=$(wc -m /jffs/nvram/dhcp_staticlist | awk '{print $1}')
        # wc appears to count line return or extra line?
        wc_staticlist=$((wc_staticlist - 1))
      else
        wc_staticlist=$(nvram get dhcp_staticlist | wc -m)
        # wc appears to count line return or extra line?
        wc_staticlist=$((wc_staticlist - 1))
      fi

      echo
      echo "The current character size of dhcp_staticlist is: $wc_staticlist"
      echo

      if [ -s /jffs/nvram/dhcp_hostnames ]; then # HND Routers store here
        wc_hostnames=$(wc -m /jffs/nvram/dhcp_hostnames | awk '{print $1}')
        # wc appears to count line return or extra line?
        wc_hostnames=$((wc_hostnames - 1))
      else
        wc_hostnames=$(nvram get dhcp_hostnames | wc -m)
        # wc appears to count line return or extra line?
        wc_hostnames=$((wc_hostnames - 1))
      fi

      echo
      echo "The current character size of dhcp_hostnames is: $wc_hostnames"
      echo
      echo "Press enter to continue"
      read -r

      Menu_DHCP_Staticlist
      break
      ;;

    e)
      exit 0
      ;;
    *)
      printf '\nOption choice %b%s%b is not a valid option!\n' "${COLOR_GREEN}" "$option" "${COLOR_WHITE}"
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      ;;
    esac
  done
}

Make_Backup() {

  FILE="$1"
  TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
  BACKUP_FILE="${FILE}.${TIMESTAMP}"

  if [ -s "$FILE" ]; then
    if ! mv "$FILE" "$BACKUP_FILE" >/dev/null 2>&1; then
      printf 'Error backing up existing %b%s%b to %b%s%b\n' "$COLOR_GREEN" "$FILE" "$COLOR_WHITE" "$COLOR_GREEN" "$BACKUP_FILE" "$COLOR_WHITE"
      printf 'Exiting %s\n' "$(basename "$0")"
      exit 1
    else
      printf 'Existing %b%s%b found\n' "$COLOR_GREEN" "$FILE" "$COLOR_WHITE"
      printf '%b%s%b backed up to %b%s%b\n' "$COLOR_GREEN" "$FILE" "$COLOR_WHITE" "$COLOR_GREEN" "$BACKUP_FILE" "$COLOR_WHITE"
    fi
  fi
}

Save_DHCP_Staticlist() {
  if [ -s "$DHCP_STATICLIST" ]; then
    Make_Backup "$DHCP_STATICLIST"
  fi

  if [ -s /jffs/nvram/dhcp_staticlist ]; then #HND Routers store dhcp_staticlist in the file /jffs/nvram/dhcp_staticlist and the nvram variable dhcp_staticlist. They are the same format so only need to save one of them
    cp /jffs/nvram/dhcp_staticlist "$DHCP_STATICLIST" && echo "dhcp_staticlist nvram values successfully stored in $DHCP_STATICLIST" || echo "Unknown error occurred trying to save $DHCP_STATICLIST"
  else
    nvram get dhcp_staticlist >"$DHCP_STATICLIST" && echo "dhcp_staticlist nvram values successfully stored in $DHCP_STATICLIST" || echo "Unknown error occurred trying to save $DHCP_STATICLIST"
  fi
}

Save_DHCP_Hostnames() {
  if [ -s "$DHCP_HOSTNAMES" ]; then
    Make_Backup "$DHCP_HOSTNAMES"
  fi

  if [ -s /jffs/nvram/dhcp_hostnames ]; then #HND Routers store hostnames in a file
    cp /jffs/nvram/dhcp_hostnames "$DHCP_HOSTNAMES" && echo "dhcp_hostnames nvram values successfully stored in $DHCP_HOSTNAMES" || echo "Unknown error occurred trying to save $DHCP_HOSTNAMES"
  else
    nvram get dhcp_hostnames >"$DHCP_HOSTNAMES" && echo "dhcp_hostnames nvram values successfully stored in $DHCP_HOSTNAMES" || echo "Unknown error occurred trying to save $DHCP_HOSTNAMES"
  fi
}

Restore_DHCP_Staticlist_nvram() {
  nvram set dhcp_staticlist="$(cat /opt/tmp/dhcp_staticlist.txt)"
  nvram commit
  sleep 1
  if [ -n "$(nvram get dhcp_staticlist)" ]; then
    echo "dhcp_staticlist successfully restored"
  else
    echo "Unknown error occurred trying to restore dhcp_staticlist"
  fi
}

Restore_DHCP_Staticlist() {
  if [ "$MODEL" = "RT-AC86U" ] || [ "$MODEL" = "RT-AX88U" ]; then #HND Routers store hostnames in the file /jffs/nvram/dhcp_staticlist and the nvram variable dhcp_staticlist
    cp "$DHCP_STATICLIST" /jffs/nvram/dhcp_staticlist && echo "dhcp_staticlist nvram values successfully stored in $DHCP_STATICLIST" || echo "Unknown error occurred trying to save $DHCP_STATICLIST"
    if [ -s "/jffs/nvram/dhcp_staticlist" ]; then
      echo "dhcp_staticlist successfully restored"
    else
      echo "Unknown error occurred trying to restore dhcp_staticlist"
    fi
    Restore_DHCP_Staticlist_nvram
  else
    Restore_DHCP_Staticlist_nvram
  fi
}

Restore_DHCP_Hostnames() {
  if [ "$MODEL" = "RT-AC86U" ] || [ "$MODEL" = "RT-AX88U" ]; then #HND Routers store hostnames in a file
    cp "$DHCP_HOSTNAMES" /jffs/nvram/dhcp_hostnames
    if [ -s /jffs/nvram/dhcp_hostnames ]; then
      echo "dhcp_hostnames successfully restored"
    else
      echo "Unknown error occurred trying to restore dhcp_hostnames"
    fi
  else
    nvram set dhcp_hostnames="$(cat /opt/tmp/dhcp_hostnames.txt)"
    nvram commit
    sleep 1
    if [ -n "$(nvram get dhcp_hostnames)" ]; then
      echo "dhcp_hostnames successfully restored"
    else
      echo "Unknown error occurred trying to restore dhcp_hostnames"
    fi
  fi
}

Parse_Hostnames() {

  true >/tmp/hostnames.$$
  OLDIFS=$IFS
  IFS="<"

  for ENTRY in $HOSTNAME_LIST; do
    if [ "$ENTRY" = "" ]; then
      continue
    fi
    MACID=$(echo "$ENTRY" | cut -d ">" -f 1)
    HOSTNAME=$(echo "$ENTRY" | cut -d ">" -f 2)
    echo "$MACID $HOSTNAME" >>/tmp/hostnames.$$
  done

  IFS=$OLDIFS
}

Save_Dnsmasq_Format() {

  # Obtain MAC and IP address from dhcp_staticlist and exclude DNS field by filtering using the first three octets of the lan_ipaddr
  if [ -s /jffs/nvram/dhcp_staticlist ]; then #HND Routers store dhcp_staticlist in a file
    awk '{print $0}' /jffs/nvram/dhcp_staticlist | grep -oE "((([0-9a-fA-F]{2})[ :-]){5}[0-9a-fA-F]{2})|(([0-9a-fA-F]){6}[:-]([0-9a-fA-F]){6})|([0-9a-fA-F]{12})" >/tmp/static_mac.$$
    awk '{print $0}' /jffs/nvram/dhcp_staticlist | grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | grep "$(nvram get lan_ipaddr | grep -Eo '([0-9]{1,3}\.[0-9]{1,3}(\.[0-9]{1,3}))')" >/tmp/static_ip.$$
  else # non-HND Routers store dhcp_staticlist in nvram
    nvram get dhcp_staticlist | grep -oE "((([0-9a-fA-F]{2})[ :-]){5}[0-9a-fA-F]{2})|(([0-9a-fA-F]){6}[:-]([0-9a-fA-F]){6})|([0-9a-fA-F]{12})" >/tmp/static_mac.$$
    nvram get dhcp_staticlist | grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | grep "$(nvram get lan_ipaddr | grep -Eo '([0-9]{1,3}\.[0-9]{1,3}(\.[0-9]{1,3}))')" >/tmp/static_ip.$$
  fi

  # output /tmp/static_mac.$$ and /tmp/static_ip.$$ to /tmp/staticlist.$$ in two columns side by side
  #https://www.unix.com/shell-programming-and-scripting/161826-how-combine-2-files-into-1-file-2-columns.html
  awk 'NR==FNR{a[i++]=$0};{b[x++]=$0;};{k=x-i};END{for(j=0;j<i;) print a[j++],b[k++]}' /tmp/static_mac.$$ /tmp/static_ip.$$ >/tmp/staticlist.$$

  # some users reported <undefined in nvram..need to remove
  if [ -s /jffs/nvram/dhcp_hostnames ]; then #HND Routers store hostnames in a file
    HOSTNAME_LIST=$(awk '{print $0}' /jffs/nvram/dhcp_hostnames | sed 's/>undefined//')
  else
    HOSTNAME_LIST=$(nvram get dhcp_hostnames | sed 's/>undefined//')
  fi

  # Have to parse by internal field separator since hostnames are not required
  Parse_Hostnames

  # Join the /tmp/hostnames.$$ and /tmp/staticlist.$$ files together to form one file containing MAC, IP, HOSTNAME
  awk '
    NR==FNR { k[$1]=$2; next }
    { print $0, k[$1] }
  ' /tmp/hostnames.$$ /tmp/staticlist.$$ >/tmp/MACIPHOSTNAMES.$$

  # write dhcp-host entry in /jffs/configs/dnsmasq.conf.add format
  sort -t . -k 3,3n -k 4,4n /tmp/MACIPHOSTNAMES.$$ | awk '{ print "dhcp-host="$1","$2","$3""; }' | sed 's/,$//'

  rm -rf /tmp/static_mac.$$
  rm -rf /tmp/static_ip.$$
  rm -rf /tmp/staticlist.$$
  rm -rf /tmp/hostnames.$$
  rm -rf /tmp/MACIPHOSTNAMES.$$
}

clear
Menu_DHCP_Staticlist
