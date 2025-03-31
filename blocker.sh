#!/bin/bash
BLOCKLIST_URL="https://raw.githubusercontent.com/khantzawhein/torrent-tracker-ips/refs/heads/main/extracted_ips.txt"
PREVIOUS_BLOCKLIST="./previous_blocklist.txt"
CURRENT_BLOCKLIST="./torrent-tracker-ips.txt"
IPTABLES="/sbin/iptables"
IPSET="/sbin/ipset"
BLOCKLIST_SET_NAME="torrent-trackers"
NETFILTER_PERSISTENT="/sbin/netfilter-persistent"
# Download the current blocklist
curl -s $BLOCKLIST_URL -o $CURRENT_BLOCKLIST
touch $PREVIOUS_BLOCKLIST
# Create the ipset set if it does not exist
$IPSET list -n | grep -q $BLOCKLIST_SET_NAME || $IPSET create $BLOCKLIST_SET_NAME hash:ip
# Add new IPs to the blocklist
comm -13 <(sort $PREVIOUS_BLOCKLIST | sort | uniq) <(sort $CURRENT_BLOCKLIST | sort | uniq) | while read -r IP; do
  $IPSET add $BLOCKLIST_SET_NAME $IP
done
# Remove outdated IPs from the blocklist
comm -23 <(sort $PREVIOUS_BLOCKLIST | sort | uniq) <(sort $CURRENT_BLOCKLIST | sort | uniq) | while read -r IP; do
  $IPSET del $BLOCKLIST_SET_NAME $IP
done
# Ensure the IPtables rule is in place
$IPTABLES -C OUTPUT -m set --match-set $BLOCKLIST_SET_NAME dst -j DROP 2>/dev/null || $IPTABLES -I OUTPUT -m set --match-set $BLOCKLIST_SET_NAME dst -j DROP
# Save the iptables rules
$NETFILTER_PERSISTENT save
# Save the current blocklist as the previous one for the next run
cp $CURRENT_BLOCKLIST $PREVIOUS_BLOCKLIST