#!/bin/sh
# This script will create a conversion file

LOCAL_REPO=/jffs/scripts/x3mRouting

# This is the old nat-start file that contains references to the prior version of x3mRouting scripts
NAT_START=/jffs/scripts/nat-start

# This is the conversion file. After running this script, review the file, make any necessary edits, save, and run to create the new nat-start file
# and routing rules
CONV_FILE=/jffs/scripts/x3mRouting/x3mRouting_Conversion.sh

# START: Functions
Conversion_Msg() {
  {
    echo "# Source File====> $FILE"
    echo "# Original Entry=> $LINE"
    echo "$LINE4"
    echo
  } >> "$CONV_FILE"
}

Warning_Msg() {
  {
    echo "# If the source VPN Client you want to bypass is '1', then no changes are required."
    echo "# Otherwise, edit the '1' to be a valid VPN Client number '1-5'"
  }>> "$CONV_FILE"
}

Process_File() {

  FILE=$1
  if [ "$(grep -c "load_" "$FILE")" -gt 0 ]; then
    grep "load_" "$FILE" | while read -r LINE; do

    # Skip comment lines
    LINETYPE=$(echo "$LINE" | awk  '{ string=substr($0, 1, 1); print string;}')
    if [ "$LINETYPE" = "#" ]; then
      continue
    fi
    # AMAZON
    if [ "$(echo "$LINE" | grep  -c load_AMAZON_ipset_iface.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_AMAZON_ipset_iface.sh/x3mRouting.sh/' | sed 's/ 1/ ALL 1/' | sed 's/ 2/ ALL 2/' | sed 's/ 3/ ALL 3/' | sed 's/ 4/ ALL 4/'| sed 's/ 5/ ALL 5/' | sed 's/ 0/ 1 0/')
      AWS_REGION=$(echo "$LINE2" | awk '{ print substr( $0, length($0) - 1, length($0) ) }')
      [ "$AWS_REGION" = "AL" ] && AWS_REGION=GLOBAL
      LINE3=$(echo "$LINE2" | awk '{print $1, $2, $3, $4, $5}')
      LINE4="$LINE3 aws_region=$AWS_REGION"
      if [ "$(echo "$LINE4" | grep  -c "1 0")" -ge 1 ]; then
        Warning_Msg
      fi
      Conversion_Msg
      continue
    fi

    if [ "$(echo "$LINE" | grep  -c load_AMAZON_ipset.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_AMAZON_ipset.sh/x3mRouting.sh/')
      IPSET=$(echo "$LINE2" | awk '{print $3}' )
      AWS_REGION=$(echo "$LINE2" | awk '{ print substr( $0, length($0) - 1, length($0) ) }')
      LINE3=$(echo "$LINE2" | awk '{print $1, $2}')
      LINE4="$LINE3 ipset_name=$IPSET aws_region=$AWS_REGION"
      Conversion_Msg
      continue
    fi
    # ASN
    if [ "$(echo "$LINE" | grep  -c load_ASN_ipset_iface.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_ASN_ipset_iface.sh/x3mRouting.sh/' | sed 's/ 1/ ALL 1/' | sed 's/ 2/ ALL 2/' | sed 's/ 3/ ALL 3/' | sed 's/ 4/ ALL 4/'| sed 's/ 5/ ALL 5/' | sed 's/ 0/ 1 0/')
      ASNUM=$(echo "$LINE2" | sed -ne 's/^.*AS//p')
      ASN="AS${ASNUM}"
      LINE3=$(echo "$LINE2" | awk '{print $1, $2, $3, $4, $5}')
      LINE4="$LINE3 asnum=$ASN"
      if [ "$(echo "$LINE4" | grep  -c "1 0")" -ge 1 ]; then
        Warning_Msg
      fi
      Conversion_Msg
      continue
    fi
    if [ "$(echo "$LINE" | grep  -c load_ASN_ipset.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_ASN_ipset.sh/x3mRouting.sh/')
      IPSET=$(echo "$LINE2" | awk '{print $3}')
      ASNUM=$(echo "$LINE2" | sed -ne 's/^.*AS//p')
      ASN="AS${ASNUM}"
      LINE3=$(echo "$LINE2" | awk '{print $1, $2}')
      LINE4="$LINE3 ipset_name=$IPSET asnum=$ASN"
      Conversion_Msg
      continue
    fi

    # DNSMASQ
    if [ "$(echo "$LINE" | grep  -c load_DNSMASQ_ipset_iface.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_DNSMASQ_ipset_iface.sh/x3mRouting.sh/' | sed 's/ 1/ ALL 1/' | sed 's/ 2/ ALL 2/' | sed 's/ 3/ ALL 3/' | sed 's/ 4/ ALL 4/'| sed 's/ 5/ ALL 5/' | sed 's/ 0/ 1 0/')
      IPSET=$(echo "$LINE2" | awk '{print $5}' )
      DNSMASQ=$(echo "$LINE2" | awk '{print $6}' )
      LINE3=$(echo "$LINE2" | awk '{print $1, $2, $3, $4, $5}')
      LINE4="$LINE3 dnsmasq=$DNSMASQ"
      if [ "$(echo "$LINE4" | grep  -c "1 0")" -ge 1 ]; then
        Warning_Msg
      fi
      Conversion_Msg
      continue
    fi
    if [ "$(echo "$LINE" | grep  -c load_DNSMASQ_ipset.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_DNSMASQ_ipset.sh/x3mRouting.sh/')
      IPSET=$(echo "$LINE2" | awk '{print $3}' )
      DNSMASQ=$(echo "$LINE2" | awk '{print $4}' )
      LINE3=$(echo "$LINE2" | awk '{print $1, $2}')
      LINE4="$LINE3 ipset_name=$IPSET dnsmasq=$DNSMASQ"
      Conversion_Msg
      continue
    fi

    # MANUAL
    if [ "$(echo "$LINE" | grep  -c load_MANUAL_ipset_iface.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_MANUAL_ipset_iface.sh/x3mRouting.sh/' | sed 's/ 1/ ALL 1/' | sed 's/ 2/ ALL 2/' | sed 's/ 3/ ALL 3/' | sed 's/ 4/ ALL 4/'| sed 's/ 5/ ALL 5/' | sed 's/ 0/ 1 0/')
      LINE3=$(echo "$LINE2" | awk '{print $1, $2, $3, $4, $5}')
      LINE4="$LINE3"
      if [ "$(echo "$LINE4" | grep  -c "1 0")" -ge 1 ]; then
        Warning_Msg
      fi
      Conversion_Msg
      continue
    fi
    if [ "$(echo "$LINE" | grep  -c load_MANUAL_ipset.sh)" -ge 1 ]; then
      LINE2=$(echo "$LINE" | sed 's/load_MANUAL_ipset.sh/x3mRouting.sh/')
      IPSET=$(echo "$LINE2" | awk '{print $3}')
      LINE3=$(echo "$LINE2" | awk '{print $1, $2}')
      LINE4="$LINE3 ipset_name=$IPSET"
      Conversion_Msg
      continue
    fi

    done
  fi

}
# END: Functions
# START: Process Conversion
# If a previous version of the conversion file exists, back it up to prevent overwrite as a second run may corrupt it
if [ -s "$LOCAL_REPO/x3mRouting_Conversion.sh" ]; then
  TIMESTAMP=$(date +"%Y-%m-%d-%H.%M.%S")
  if ! cp "$LOCAL_REPO/x3mRouting_Conversion.sh" "$LOCAL_REPO/x3mRouting_Conversion.sh.$TIMESTAMP"; then
    echo
    printf '\nBackup of the prior %s file could not be made.\n' "$LOCAL_REPO/x3mRouting_Conversion.sh"
    printf 'Exiting...\n'
    exit 0
  else
    echo
    printf '%s%b%s%b%s\n' "Existing " "$COLOR_GREEN" "$LOCAL_REPO/x3mRouting_Conversion.sh" "$COLOR_WHITE" " file found."
    printf '%s%b%s%b\n' "Backup file saved to " "$COLOR_GREEN" "$LOCAL_REPO/x3mRouting_Conversion.sh.$TIMESTAMP" "$COLOR_WHITE"
    true > "$CONV_FILE" && chmod 755 "$CONV_FILE"
  fi
else
  true > "$CONV_FILE" && chmod 755 "$CONV_FILE"
fi

Process_File "$NAT_START"

# add shebang to the first line before exiting
if [ -s "$CONV_FILE" ]; then
  sed -i '1s~^~#!/bin/sh\n~' "$CONV_FILE"
  echo
  printf '%s%b%s%b%s\n' "Created " "$COLOR_GREEN" "$CONV_FILE" "$COLOR_WHITE" " script to assist with the conversion."
  printf '%s%b%s%b%s\n' "Please review the "  "$COLOR_GREEN" "$CONV_FILE" "$COLOR_WHITE" " script before running"
else
  printf '%b%s%b%s%b%s%b%s\n' "$COLOR_GREEN" "$CONV_FILE" "$COLOR_WHITE" " script not created. No valid x3mRouting entries found in" "$COLOR_GREEN" "$NAT_START"  "$COLOR_WHITE" " or vpnclientX- route-up files."
  rm "$CONV_FILE"
fi
