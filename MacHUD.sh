#!/bin/sh
#functions
cd "$(dirname $0)"

printBars() {
  num=$1
  retVal=$(printf "%-${num}s" "|")
  echo "${retVal// /|}"
}
#Insert find line number function to find line number of element.

#Disk Space Calculations
usedSpace=$(df -hl | grep '/dev/disk1' | awk '{sub("%","");print $5}')
sed -i'' -e  "9s/.*/$usedSpace%/" MacHUD.html
numUsedBars=$(($usedSpace/5))
usedBars="$(printBars $numUsedBars)"
numFreeBars=$((20-$numUsedBars))
freeBars="$(printBars $numFreeBars)"
sed -i '' -e "11s/.*/<barsUsed>$usedBars<\/barsUsed><barsFree>$freeBars<\/barsFree>/" MacHUD.html


#Find External IP
#Print IP and  provider
extAddyJson="$(curl -s http://ip-api.com/json)"
isp="$(echo $extAddyJson | awk 'BEGIN { FS = ":" } ; { print $6 }' | sed 's/\"//g' | sed 's/,lat//g')"
extAddy="$(echo $extAddyJson | awk 'BEGIN { FS = ":" } ; { print $10 }' | sed 's/\"//g' | sed 's/,region//g')"
sed -i'' -e  "16s/.*/$extAddy/" MacHUD.html
sed -i'' -e  "18s/.*/$isp/" MacHUD.html

#FUTURE: Find Active Network Adapter(s)
#Print IP, subnet mask, gateway, DNS servers, and domain suffix
wiFiAddy="$(ifconfig en0 | awk '{ print $2}' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")"

#Get hexadecimal value of subnet mask
hexMask="$(ifconfig en0 | awk '{ print $4}' | grep 0x)"
#Generate Array of Mask Octets
maskArray=$(echo $hexMask | sed 's/../0x& /g' | tr ' ' '\n')
#Trim first OxOx entry
maskArray=${maskArray[@]:5}
#Convert hex Octets to dotted decimal notation
netMask=$(printf "%d." $maskArray | sed 's/.$//')

#find gateway address
gateway=$(netstat -nr | grep default | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

resolvers=$(scutil --dns)
dnsServer=$(echo $resovlers | awk 'BEGIN { FS = "\n" } ; { print $3 }')



sed -i'' -e  "22s/.*/<br>IP: $wiFiAddy<br>Mask: $netMask<br>Gateway: $gateway<br>/" MacHUD.html
