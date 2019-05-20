#!/bin/sh
####################################################################################################
# Script: dhcpstaticlist.sh
# Original Author: Xentrk
# Last Updated Date: 20-May-2019
# Version 1.0.0
#
# Description:
#  Helpful utility to
#  1) Save dhcp_staticlist nvram values to /opt/tmp/dhcp_staticlist.txt. This will allow you to restore the values after performing a factory reset.
#  2) Restore dhcp_staticlist nvram values from /opt/tmp/dhcp_staticlist.txt after a factory reset
#  3) Preview current nvram dhcp static list in dnsmasq.conf format
#  4) Append Output DHCP Static List to /jffs/configs/dnsmasq.conf.add & Disable Manual Assignment in the WAN GUI. You will then be prompted to reboot the router to have the settings take effect.
#  5) Disable DHCP Manual Assignment
#  6) Enable DHCP Manual Assignment
#  7) Save nvram dhcp_staticlist to /opt/tmp/dhcp_staticlist.txt and clear the DHCP Manual Assignment nvram values from dhcp_staticlist
#  8) Display the character count of dhcp_staticlist
#
####################################################################################################

# Uncomment for debugging
#set -x

COLOR_WHITE='\033[0m'
COLOR_GREEN='\e[0;32m'
FILE="/opt/tmp/dhcp_staticlist.txt"

Menu_DHCP_Staticlist() {

  clear

  while true; do
    printf '\n\nUse this utility to save or restore dhcp static list nvram values\n\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[1]%b - Save nvram dhcp static list to /opt/tmp/dhcp_staticlist.txt\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[2]%b - Restore nvram dhcp static list from /opt/tmp/dhcp_staticlist.txt\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[3]%b - Preview DHCP Static List in dnsmasq format\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[4]%b - Append DHCP Static List to dnsmasq.conf.add & Disable DHCP Manual Assignment\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[5]%b - Disable DHCP Manual Assignment\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[6]%b - Enable DHCP Manual Assignment\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[7]%b - Save nvram dhcp_staticlist to /opt/tmp/dhcp_staticlist.txt and clear dhcp_staticlist\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[8]%b - Display character size of dhcp_staticlist (2999 is the limit)\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    printf '%b[e]%b - Exit\n' "${COLOR_GREEN}" "${COLOR_WHITE}"
    echo
    printf "==> "
    read -r "menu_update_current_installation"
    echo
    case "$menu_update_current_installation" in
    1)
      Save_DHCP_Staticlist
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    2)
      Restore_DHCP_Staticlist
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
      nvram set dhcp_staticlist=""
      nvram commit
      echo
      echo "Press enter to continue"
      read -r
      Menu_DHCP_Staticlist
      break
      ;;
    8)
      word_count=$(nvram get dhcp_staticlist | wc -m)
      echo
      echo "The current character size of dhcp_staticlist is: $word_count"
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
      echo "[*] $menu_update_installer Isn't An Option!"
      ;;
    esac
  done
}

Make_Backup() {

  FILE="$1"
  TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
  BACKUP_FILE_NAME="${FILE}.${TIMESTAMP}"

  if [ -s "$FILE" ]; then
    if ! mv "$FILE" "$BACKUP_FILE_NAME" >/dev/null 2>&1; then
      printf 'Error backing up existing %b%s%b to %b%s%b\n' "$COLOR_GREEN" "$FILE" "$COLOR_WHITE" "$COLOR_GREEN" "$BACKUP_FILE_NAME" "$COLOR_WHITE"
      printf 'Exiting %s\n' "$(basename "$0")"
      exit 1
    else
      printf 'Existing %b%s%b found\n' "$COLOR_GREEN" "$FILE" "$COLOR_WHITE"
      printf '%b%s%b backed up to %b%s%b\n' "$COLOR_GREEN" "$FILE" "$COLOR_WHITE" "$COLOR_GREEN" "$BACKUP_FILE_NAME" "$COLOR_WHITE"
    fi
  fi
}

Save_DHCP_Staticlist() {
  if [ -s "$FILE" ]; then
    Make_Backup "$FILE"
  fi

  nvram get dhcp_staticlist >"$FILE" && echo "dhcp_staticlist nvram values successfully stored in $FILE" || echo "Unknown error occurred trying to save $FILE"
}

Restore_DHCP_Staticlist() {

  nvram set dhcp_staticlist="$(cat $FILE)"
  nvram commit
  if [ -n $(nvram get dhcp_staticlist >/dev/null 2>&1) ]; then
    echo "dhcp_staticlist successfully restored"
  else
    echo "Unknown error occurred trying to restore dhcp_staticlist"
  fi
}

Save_Dnsmasq_Format() {

  nvram get dhcp_staticlist | sed 's/</\n/g' | grep ":" | awk -F">" '{ print "<"$2">"$1">"$3; }' | \
  sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | awk -F">" '{ print "dhcp-host="$2","$1","$3; }' | sed s/\<//
}

clear
Menu_DHCP_Staticlist
