#!/system/bin/sh
#
# Spaget init script
#
# Written to hijack GSI-specific props
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Coded by @corsicanu && modified by @ananjase1211 @xda-developers.com
#
# Few things that need to be set even if unrooted
#
PATH=/sbin:/system/sbin:/system/bin:/system/xbin:/helios
export PATH
RUN=/sbin/busybox;
LOGFILE=/data/helios/boot.log
REBOOTLOGFILE=/data/helios/reboot.log

log_print() {
  echo "$1"
  echo "$1" >> $LOGFILE
}

log_print "Creat logging Dirs"

if [ ! -e /data/helios ]; then
  mkdir -p /data/helios
  chown -R root.root /data/helios
  chmod -R 755 /data/helios
fi


log_print "Hijack system props"

# set nuked path
nuked=/system/nuked
# if system wasn't nuked already, let's nuke it now 
if [ ! -e $nuked ];then
  # mount system rw to play with it
    mount -o remount,rw /system
  
  #we are on samsung so we must nuke something on rw-system.sh to avoid bootlooping
    sed -i -- '/mount -o bind \/system\/phh\/empty \/vendor\/bin\/hw\/android\.hardware\.power@1\.0-service/d' /system/bin/rw-system.sh
  
  # live patch of the system, only at first boot of current gsi
  # add needed system patches in /vendor/patch (eg: /vendor/patch/lib64 -> /system/lib64)
  if [ -d /vendor/patch ];then
    cp -r /vendor/patch/* /system
  fi
  
    # safetynet patching
    # grep vendor fingerprint
    fp=$(cat /vendor/build.prop | tr '=' ' ' | grep ro.vendor.build.fingerprint | while read a b; do echo $b; done)
    
    # remove all fingerprints + previous leftovers
    
    sed -i -- '/ananjaser1211/d' /system/etc/prop.default
    sed -i -- '/ro\.bootimage\.build\.fingerprint/d' /system/etc/prop.default
    sed -i -- '/ro\.build\.fingerprint/d' /system/etc/prop.default
    sed -i -- '/ananjaser1211/d' /system/build.prop
    sed -i -- '/ro\.bootimage\.build\.fingerprint/d' /system/build.prop
    sed -i -- '/ro\.build\.fingerprint/d' /system/build.prop
    # Remove pre-defined device codenames
    sed -i -- '/ro\.product\.model/d' /system/build.prop
    sed -i -- '/ro\.product\.brand/d' /system/build.prop
    sed -i -- '/ro\.product\.name/d' /system/build.prop
    sed -i -- '/ro\.product\.device/d' /system/build.prop
    sed -i -- '/ro\.product\.manufacturer/d' /system/build.prop

    
    # echo new fingerprints from vendor fingerprint
    echo "# prop replaced at first boot to pass safetynet and certification @ananjaser1211 " >> /system/etc/prop.default
    echo "ro.bootimage.build.fingerprint=$fp" >> /system/etc/prop.default
    echo "ro.build.fingerprint=$fp" >> /system/etc/prop.default
    echo "" >> /system/etc/prop.default
    echo "# prop replaced at first boot to pass safetynet and certification @ananjaser1211"  >> /system/build.prop
    echo "ro.build.fingerprint=$fp" >> /system/build.prop
    echo ""  >> /system/build.prop
    
    # set the flag for system being nuked already
    echo "nuked" > /system/nuked
    
    # mount back as ro for security reasons
    mount -o remount,ro /system
  
  # last but not least, reboot for best experience
  reboot
fi


