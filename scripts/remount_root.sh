#!/bin/bash

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
