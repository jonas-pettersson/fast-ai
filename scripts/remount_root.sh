#!/bin/bash

#============================================================
#    FILE:  remount_root.sh
#
#    USAGE:  sudo ./remount_root.sh
#
#    DESCRIPTION: executes on new spot instance to swap root volume
#                 to another mounted volume
#                 Called from setup_aws_spot_w_root.sh
#                 Essentially copied from:
#                 https://github.com/slavivanov/ec2-spotter/blob/master/ec2spotter-remount-root
#                 and
#                 https://github.com/atramos/ec2-spotter
#                 All credits to https://github.com/slavivanov and
#                 https://github.com/atramos
#
#    PREREQUISITES:
#    - existing aws volume mounted
#
#    PLEASE NOTE:
#    - Swapping the root volume is a potentially dangerous operation!
#    - Please test the script on a non-critical volume before using
#      for critical data
#
#    AUTHOR:  Jonas Pettersson, j.g.f.pettersson@gmail.com
#    CREATED:  26/02/2017
#============================================================

DEVICE=/dev/xvdf1
NEWMNT=/permaroot
OLDMNT=old-root
e2label $DEVICE permaroot
tune2fs $DEVICE -U `uuidgen`
mkdir $NEWMNT

#
# point of no return... 
# modify /sbin/init on the ephemeral volume to chain-load from the persistent EBS volume, and then reboot.
#
mv /sbin/init /sbin/init.backup
cat > /sbin/init << EOF11
#!/bin/sh
mount $DEVICE $NEWMNT
[ ! -d $NEWMNT/$OLDMNT ] && mkdir -p $NEWMNT/$OLDMNT
cd $NEWMNT
pivot_root . ./$OLDMNT
for dir in /dev /proc /sys /run; do
    echo "Moving mounted file system ${OLDMNT}\${dir} to \$dir."
    mount --move ./${OLDMNT}\${dir} \${dir}
done
exec chroot . /sbin/init
EOF11
chmod +x /sbin/init
shutdown -r now
