#/bin/bash 

PRODUCT="$1"
OUTDIR="../out/target/product/$PRODUCT"
NOW=$(date +"%Y%m%d")

if ( [ $PRODUCT == "captivate" ] || [ $PRODUCT == "galaxys" ] || [ $PRODUCT == "galaxysb" ] || [ $PRODUCT == "vibrant" ] )
then

	rm -rf temp/
	mkdir temp
	mkdir temp/system

	echo "Copying /system ..."
	cp -R $OUTDIR/system/ temp/

	echo "Copying tools for otapackage ..."
	cp -R initial-tools/$PRODUCT/* temp/

	echo "Copying zImage ..."
	cp $OUTDIR/kernel_build/arch/arm/boot/zImage temp/zImage

	echo "Copying kernel modules ..."
	cp -R $OUTDIR/kernel_build/drivers/net/wireless/bcm4329/bcm4329.ko temp/system/modules/
	cp -R $OUTDIR/kernel_build/drivers/net/tun.ko temp/system/modules/
	cp -R $OUTDIR/kernel_build/fs/cifs/cifs.ko temp/system/modules/

	echo "Removing .git files"
	find temp/ -name '.git' -exec rm -r {} \;

	echo "Compressing otapackage ..."
	pushd temp
	zip -r ../$OUTDIR/cm7-$PRODUCT-initial-unsigned.zip ./
	popd

	echo "Signing otapackage ..."
	java -jar SignApk/signapk.jar SignApk/certificate.pem SignApk/key.pk8 $OUTDIR/cm7-$PRODUCT-initial-unsigned.zip $OUTDIR/cm7-$PRODUCT-initial-$NOW.zip

	echo "Creating initial kernel archive for odin ..."
	pushd $OUTDIR/kernel_build/arch/arm/boot
	tar -cvf ../../../../cm7-$PRODUCT-initial-kernel.tar zImage
	popd

	rm $OUTDIR/cm7-$PRODUCT-initial-unsigned.zip
	rm -rf temp/

	echo "cm7-$PRODUCT-initial-$NOW.zip is at $OUTDIR"
	echo "cm7-$PRODUCT-initial-kernel.tar is at $OUTDIR"
	echo "Done."
else
	echo "Usage: $0 DEVICE"
	echo "Example: ./initial.sh galaxys"
	echo "Supported Devices: captivate, galaxys, galaxysb, vibrant"
fi
