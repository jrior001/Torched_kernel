## Script for building kernel
## Adapted from script designed by Rohan Mathur

CROSS_COMPILE=toolchain/arm-cortex_a15-linux-gnueabihf-linaro_4.9.1/bin/arm-gnueabi-
#RAMDISK=ramdisk.img
KERNEL_NAME=Torched-LP
KERNEL_VNUMBER=Build1.3-F2FS
CONFIG_FILE=torched_elite_defconfig
#MOD_DIR=${CURRENT_DIR}/out/system/lib/modules
#export LOCALVERSION="-Torched-KK.B4.4"
#export KBUILD_BUILD_VERSION="4"

# DO NOT MODIFY BELOW THIS LINE
CURRENT_DIR=`pwd`
NB_CPU=`grep processor /proc/cpuinfo | wc -l`
let NB_CPU+=1
if [[ -z $CONFIG_FILE ]]
then
  echo "No configuration file defined"
	exit 1

else 
	if [[ ! -e "${CURRENT_DIR}/arch/arm/configs/$CONFIG_FILE" ]]
	then
		echo "Configuration file $CONFIG_FILE not found"
		exit 1
	fi
	CONFIG=$CONFIG_FILE
fi

rm -rf release/*
make clean -j$NB_CPU
make $CONFIG_FILE
echo "***********************************************************************"
echo "* Building ${KERNEL_NAME}.${KERNEL_VNUMBER} with configuration $CONFIG     *"
echo "***********************************************************************"
echo "make using -j$NB_CPU"
make ARCH=arm -j$NB_CPU CROSS_COMPILE=$CROSS_COMPILE


echo "***********************************************************************"
echo "*                            Compile done!                            *"
echo "***********************************************************************"

# Copy zimage over to /out
cp arch/arm/boot/zImage out/kernel/zImage


echo "***********************************************************************"
echo "*                              Making zip                             *"
echo "***********************************************************************"

#if [[ ! -e $MOD_DIR ]]; then
#    mkdir -p $MOD_DIR
#elif [[ ! -d $MOD_DIR ]]; then
#    echo "$MOD_DIR already exists but is not a directory" 1>&2
#fi

#cp drivers/staging/prima/prima_wlan.ko out/system/lib/modules/prima_wlan.ko
#cp drivers/scsi/scsi_wait_scan.ko out/system/lib/modules/scsi_wait_scan.ko
#cp drivers/media/radio/radio-iris-transport.ko out/system/lib/modules/radio-iris-transport.ko
#cp drivers/crypto/msm/qcrypto.ko out/system/lib/modules/qcrypto.ko
#cp drivers/crypto/msm/qcedev.ko out/system/lib/modules/qcedev.ko
#cp drivers/crypto/msm/qce40.ko out/system/lib/modules/qce40.ko

cd out/
zip -r temp.zip *
cd ..
cp out/temp.zip release/${KERNEL_NAME}.${KERNEL_VNUMBER}.zip
echo "***********************************************************************"
echo "*                      Done with regular version!                     *"
echo "***********************************************************************"


make clean -j$NB_CPU
KERNEL_NAME=Torched-LP-noOC-noVC
KERNEL_VNUMBER=Build1.3-F2FS
CONFIG_FILE2=torched_noOC-noVC-elite_defconfig
#MOD_DIR=${CURRENT_DIR}/out/system/lib/modules
#export LOCALVERSION="-Torched-KK.B4.4-noOC-noVC"
#export KBUILD_BUILD_VERSION="4"

# DO NOT MODIFY BELOW THIS LINE
CURRENT_DIR=`pwd`
NB_CPU=`grep processor /proc/cpuinfo | wc -l`
let NB_CPU+=1
if [[ -z $CONFIG_FILE ]]
then
  echo "No configuration file defined"
	exit 1

else 
	if [[ ! -e "${CURRENT_DIR}/arch/arm/configs/$CONFIG_FILE" ]]
	then
		echo "Configuration file $CONFIG_FILE not found"
		exit 1
	fi
	CONFIG=$CONFIG_FILE
fi


make $CONFIG_FILE2
echo "***********************************************************************"
echo "* Building ${KERNEL_NAME}.${KERNEL_VNUMBER} with configuration $CONFIG*"
echo "***********************************************************************"
make ARCH=arm -j$NB_CPU CROSS_COMPILE=$CROSS_COMPILE


echo "***********************************************************************"
echo "*                            Compile done!                            *"
echo "***********************************************************************"

# Copy zimage over to /out
cp arch/arm/boot/zImage out/kernel/zImage


echo "***********************************************************************"
echo "*                              Making zip                             *"
echo "***********************************************************************"


cd out/
zip -r temp.zip *
cd ..
cp out/temp.zip release/${KERNEL_NAME}.${KERNEL_VNUMBER}.zip
cd release/
scp Torched* jrior001@node1-c6100.codefi.re:downloads/Torched-kernel/
echo "***********************************************************************"
echo "*                                 Done!                               *"
echo "***********************************************************************"

