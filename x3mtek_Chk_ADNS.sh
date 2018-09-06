#!/bin/sh
####################################################################################################
# Written By: Xentrk
# Name: x3mtek_Chk_ADNS.sh
# Version 1.2
#
# Description:
#   Display WAN and OpenVPN Interfaces and their connectivity status
#   Determine if the router uses Diversion.  If so, examine OpenVPN client settings
#   If Accept DNS Exclusive set to Exlusive and Redirect Internet Traffic is set to Policy Rules or
#   Policy Rules (Strict), intruct user that Diversion will not work over the VPN tunnel and 
#   provide instructios for work-around solution.
#
####################################################################################################
# Uncomment the line below for debugging
#set -x

COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[0m'
COLOR_GREEN='\e[0;32m'

listifaces () {
# Process OpenVPN Client 1 Information
OVPNC1_ADDR=$(nvram get vpn_client1_addr)
OVPNC1_DESC=$(nvram get vpn_client1_desc)
OVPNC1_STATE=$(nvram get vpn_client1_state)
case "$OVPNC1_STATE" in
 0) OVPNC1_STATE_DESC="Stopped" ;;
 1) OVPNC1_STATE_DESC="Connecting..." ;;
 2) OVPNC1_STATE_DESC="Connected" ;;
 *) OVPNC1_STATE_DESC="Unknown State" ;;
esac
OVPNNC1_DNS_CONFIG=$(nvram get vpn_client1_adns)
case "$OVPNNC1_DNS_CONFIG" in
 0) OVPNC1_DNS_CONFIG_DESC="Disabled" ;;
 1) OVPNC1_DNS_CONFIG_DESC="Relaxed" ;;
 2) OVPNC1_DNS_CONFIG_DESC="Strict" ;;
 3) OVPNC1_DNS_CONFIG_DESC="Exclusive" ;;
esac

# Process OpenVPN Client 2 Information
OVPNC2_ADDR=$(nvram get vpn_client2_addr)
OVPNC2_DESC=$(nvram get vpn_client2_desc)
OVPNC2_STATE=$(nvram get vpn_client2_state)

case "$OVPNC2_STATE" in
 0) OVPNC2_STATE_DESC="Stopped" ;;
 1) OVPNC2_STATE_DESC="Connecting..." ;;
 2) OVPNC2_STATE_DESC="Connected" ;;
 *) OVPNC2_STATE_DESC="Unknown State" ;;
esac
OVPNNC2_DNS_CONFIG=$(nvram get vpn_client2_adns)
case "$OVPNNC2_DNS_CONFIG" in
 0) OVPNC2_DNS_CONFIG_DESC="Disabled" ;;
 1) OVPNC2_DNS_CONFIG_DESC="Relaxed" ;;
 2) OVPNC2_DNS_CONFIG_DESC="Strict" ;;
 3) OVPNC2_DNS_CONFIG_DESC="Exclusive" ;;
esac

# Process OpenVPN Client 3 Information
OVPNC3_ADDR=$(nvram get vpn_client3_addr)
OVPNC3_DESC=$(nvram get vpn_client3_desc)
OVPNC3_STATE=$(nvram get vpn_client3_state)

case "$OVPNC3_STATE" in
 0) OVPNC3_STATE_DESC="Stopped" ;;
 1) OVPNC3_STATE_DESC="Connecting..." ;;
 2) OVPNC3_STATE_DESC="Connected" ;;
 *) OVPNC3_STATE_DESC="Unknown State" ;;
esac
OVPNNC3_DNS_CONFIG=$(nvram get vpn_client3_adns)
case "$OVPNNC3_DNS_CONFIG" in
 0) OVPNC3_DNS_CONFIG_DESC="Disabled" ;;
 1) OVPNC3_DNS_CONFIG_DESC="Relaxed" ;;
 2) OVPNC3_DNS_CONFIG_DESC="Strict" ;;
 3) OVPNC3_DNS_CONFIG_DESC="Exclusive" ;;
esac

# Process OpenVPN Client 4 Information
OVPNC4_ADDR=$(nvram get vpn_client4_addr)
OVPNC4_DESC=$(nvram get vpn_client4_desc)
OVPNC4_STATE=$(nvram get vpn_client4_state)
case "$(nvram get vpn_client4_state)" in
 0) OVPNC4_STATE_DESC="Stopped" ;;
 1) OVPNC4_STATE_DESC="Connecting..." ;;
 2) OVPNC4_STATE_DESC="Connected" ;;
 *) OVPNC4_STATE_DESC="Unknown State" ;;
esac
OVPNNC4_DNS_CONFIG=$(nvram get vpn_client4_adns)
case "$OVPNNC4_DNS_CONFIG" in
 0) OVPNC4_DNS_CONFIG_DESC="Disabled" ;;
 1) OVPNC4_DNS_CONFIG_DESC="Relaxed" ;;
 2) OVPNC4_DNS_CONFIG_DESC="Strict" ;;
 3) OVPNC4_DNS_CONFIG_DESC="Exclusive" ;;
esac

# Process OpenVPN Client 5 Information
OVPNC5_ADDR=$(nvram get vpn_client5_addr)
OVPNC5_DESC=$(nvram get vpn_client5_desc)
OVPNC5_STATE=$(nvram get vpn_client5_state)
case "$(nvram get vpn_client5_state)" in
 0) OVPNC5_STATE_DESC="Stopped" ;;
 1) OVPNC5_STATE_DESC="Connecting..." ;;
 2) OVPNC5_STATE_DESC="Connected" ;;
 *) OVPNC5_STATE_DESC="Unknown State" ;;
esac
OVPNNC5_DNS_CONFIG=$(nvram get vpn_client5_adns)
case "$OVPNNC5_DNS_CONFIG" in
 0) OVPNC5_DNS_CONFIG_DESC="Disabled" ;;
 1) OVPNC5_DNS_CONFIG_DESC="Relaxed" ;;
 2) OVPNC5_DNS_CONFIG_DESC="Strict" ;;
 3) OVPNC5_DNS_CONFIG_DESC="Exclusive" ;;
esac

# WAN Interface Information
WAN_IP=$(nvram get wan0_ipaddr)
WAN_GW_IFNAME=$(nvram get wan0_gw_ifname)
WAN_IFNAME=$(nvram get wan0_ifname)
case "$(nvram get wan0_state_t)" in
 0) WAN0_STATE_DESC="Stopped" ;;
 1) WAN0_STATE_DESC="Connecting..." ;;
 2) WAN0_STATE_DESC="Connected" ;;
 *) WAN0_STATE_DESC="Unknown State" ;;
esac
case "$(nvram get wan1_state_t)" in
 0) WAN1_STATE_DESC="Stopped" ;;
 1) WAN1_STATE_DESC="Connecting..." ;;
 2) WAN1_STATE_DESC="Connected" ;;
 4) WAN1_STATE_DESC="Unknown State" ;;
esac


printf '\n' 
printf '********************************************************************************************\n'
printf '*                                   WAN Interfaces                                         *\n'
printf '********************************************************************************************\n'
printf '%-6s %-13s %-15s %-4s %-6s\n' "WAN IF " "Status" "Address" "GW" "IFNAME"
printf '%-6s %-13s %-15s %-4s %-6s\n' "------ " "-------------" "---------------" "----" "------"
printf '%-6s %-13s %-15s %-4s %-6s\n' "WAN0:  " "$WAN0_STATE_DESC" "$(nvram get wan0_ipaddr)" "$(nvram get wan0_gw_ifname)" "$(nvram get wan0_ifname)"
printf '%-6s %-13s %-15s %-4s %-6s\n' "WAN1:  " "$WAN1_STATE_DESC" "$(nvram get wan1_ipaddr)" "$(nvram get wan1_gw_ifname)" "$(nvram get wan1_ifname)"
printf '\n' 
printf '********************************************************************************************\n'
printf '*                                   VPN Interfaces                                         *\n'
printf '********************************************************************************************\n'
printf '%+89s\n' "Accept"
printf '%+86s\n' "DNS"
printf '%-7s %-13s %-35s %-24s %-13s\n' "Client" "Status" "Address" "Description" "Configuration"
printf '%-7s %-13s %-35s %-24s %-13s\n' "-------" "-------------" "-----------------------------------" "------------------------" "-------------"
printf '%-7s %-13s %-35s %-24s %-13s\n' "OVPNC1:" "$OVPNC1_STATE_DESC" "$OVPNC1_ADDR" "$OVPNC1_DESC" "$OVPNC1_DNS_CONFIG_DESC"
printf '%-7s %-13s %-35s %-24s %-13s\n' "OVPNC2:" "$OVPNC2_STATE_DESC" "$OVPNC2_ADDR" "$OVPNC2_DESC" "$OVPNC2_DNS_CONFIG_DESC"
printf '%-7s %-13s %-35s %-24s %-13s\n' "OVPNC3:" "$OVPNC3_STATE_DESC" "$OVPNC3_ADDR" "$OVPNC3_DESC" "$OVPNC3_DNS_CONFIG_DESC"
printf '%-7s %-13s %-35s %-24s %-13s\n' "OVPNC4:" "$OVPNC4_STATE_DESC" "$OVPNC4_ADDR" "$OVPNC4_DESC" "$OVPNC4_DNS_CONFIG_DESC"
printf '%-7s %-13s %-35s %-24s %-13s\n' "OVPNC5:" "$OVPNC5_STATE_DESC" "$OVPNC5_ADDR" "$OVPNC5_DESC" "$OVPNC5_DNS_CONFIG_DESC"
printf '\n'
}
listifaces

if [ -d "/opt/share/diversion" ]; then
    printf 'Diversion installation detected\n'
    printf 'Checking for potential conflicts with active OpenVPN Clients\n'
    printf '\n'

# For clients that are in a connected state, see if ADNS=3 (Exclusive)
# If Accept DNS Cofiguration = "Exclusive", give warning message about DNSMASQ 
# being bypassed which prevents Diversion from working  
  
for OPENVPN_CLIENT in 1 2 3 4 5
    do
        if [ "$(nvram get vpn_client${OPENVPN_CLIENT}_state)" -ne "2" ]; then
            printf 'OpenVPN Client %s is not in a connected state. Skipping check for OpenVPN Client %s\n\n' "$OPENVPN_CLIENT" "$OPENVPN_CLIENT"
        elif [ "$(nvram get vpn_client${OPENVPN_CLIENT}_state)" -eq "2" ] && [ "$(nvram get vpn_client${OPENVPN_CLIENT}_adns)" -eq "3" ] && [ "$(nvram get vpn_client${OPENVPN_CLIENT}_rgw)" -eq "3" ] || [ "$(nvram get vpn_client${OPENVPN_CLIENT}_rgw)" -eq "4" ]; then
            printf 'Warning! Potential configuration conflict found with OpenVPN Client %s\n\n' "$OPENVPN_CLIENT"
            printf '%bAccept DNS Configuration%b setting is set to %bExclusive%b\n' "$COLOR_GREEN" "$COLOR_WHITE" "$COLOR_GREEN" "$COLOR_WHITE"
            printf 'When %bAccept DNS Configuration%b is set to %bExclusive%b and %bRedirect Internet Traffic%b is set to\n%bPolicy Rules%b or %bPolicy Rules (Strict)%b DNSMASQ is bypassed which will prevent Diversion from working\n' "$COLOR_GREEN" "$COLOR_WHITE" "$COLOR_GREEN" "$COLOR_WHITE" "$COLOR_GREEN" "$COLOR_WHITE" "$COLOR_GREEN" "$COLOR_WHITE" "$COLOR_GREEN" "$COLOR_WHITE"
            printf '\n'
            printf 'The work-around solution is to set %bAccept DNS Configuration%b to %bStrict%b AND\n' "$COLOR_GREEN" "$COLOR_WHITE"  "$COLOR_GREEN" "$COLOR_WHITE"
            printf 'in the %bCustom Config Section%b add the entry: %bdhcp-option DNS dns.server.ip.address%b\n' "$COLOR_GREEN" "$COLOR_WHITE" "$COLOR_GREEN" "$COLOR_WHITE"
            printf 'where %bdns.server.ip.address%b is a DNS server of your choice\n' "$COLOR_GREEN" "$COLOR_WHITE"
            printf 'e.g. dhcp-option DNS 9.9.9.9\n' 
            printf 'This will result in DNS leaking.  But it will allow Diversion to work over the VPN tunnel\n'
            printf 'To learn more about the issue, see\n' 
            printf '%bhttps://x3mtek.com/torguard-openvpn-2-4-client-setup-for-asuswrt-merlin-firmware/%b\n' "$COLOR_GREEN" "$COLOR_WHITE"
            printf 'and navigate to the section %bDNSmasq and OpenVPN DNS%b\n\n' "$COLOR_GREEN" "$COLOR_WHITE"
        else
            printf 'Good news! No configuration conflicts found with OpenVPN Client %s\n\n' "$OPENVPN_CLIENT"
        fi    
    done                              
fi    
