#!/usr/bin/env bash

kernel(){
	path=/tmp/kernelver
	mkdir $path
	touch	$path/main.txt
	touch	$path/my.txt
	curl -sS "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/Makefile?h=linux-3.18.y" \
	| grep "SUBLEVEL = " \
	| cut -d' ' -f3 >> $path/main.txt && v_main=$(cat $path/main.txt) 

	curl -sS "https://raw.githubusercontent.com/jadilson12/kernel_motorola_msm8953/android-9.0-eas/Makefile" \
	| grep "SUBLEVEL = " \
	| cut -d' ' -f3 >> $path/my.txt && v_my=$(cat $path/my.txt) 

	if [  v_main == v_my  ] ; then
		echo "nova atualização"
	else
		echo "nenhuma atualização" 
		
	fi
	rm -rf $path
	mTITLE="##### Havoc-OS 2.2  Unofficial Build #####\n"
	mDATE="Motorola Moto G5splues Update $(date +%Y-%m-%d)\n"
	mBUILD="*BUILD BY:* Jadilson \n"
	mCHANGELOG="*Changelog:*"

	mDOW="*Download Link:*"
	cd $mOUT
	mFILE="*FILE:*$(ls -f Ha*.zip)"
	#. ~/scripts/bot/telegram-notify --title Havoc-OS-v2.2 --text  "$mDATE \n$mDEVICEN \n$mTIPE \n$mBUILD"
	. ~/scripts/bot/telegram-notify --text  "$mTITLE \n$mDATE \n$mBUILD \n$mCHANGELOG  \n$mDOW \n$mFILE"


}

rom_update(){
	cd ~/$mROM
	#repo sync -c -f -q --force-sync --no-clone-bundle  -j32 --no-tags --force-broken
	repo sync -f --force-sync  --no-tags  --force-broken 

		MSG="Source updated"
		mensagem
}

rom_make(){
		cd ~/$mROM
		#. build/envsetup.sh && brunch havoc_sanders-userdebug
	  . build/envsetup.sh && lunch havoc_sanders-userdebug &&  mka bacon -j16
		MSG="Build call you attencion"
		mensagem
}
rom_upload() {
	cd $mOUT
	echo -e "Upload to cloud "$mROM" \n"
	echo -e ${ylw}"0 - BACK | 1- sourceforce | 2- MEGA | 3- AFH"${txtrst}
	read ask
	case ${ask} in
	 q) exit ${exitCode} ;;
	 0) clear ; Menu ;;
     1) scp $mBUILDZIP jadilson12@frs.sourceforge.net:/home/frs/project/sanders/HAVOC-Pie/;;
     2) rmega-up $mBUILDZIP -u 'jadilson12@gmail.com';;
     3) curl -T $mBUILDZIP ftp://uploads.androidfilehost.com --user j144df:minhasenha;;
	  	*) 'Opcao desconhecida.' ;;
	esac
	MSG="File uploaded"
	mensagem
}
rom_clear(){
	cd $mROM
	echo -e "Clean build on "$mROM" \n"
	echo -e ${ylw}" | 1- clean full | 2- dirty"${txtrst}
	read ask
	if [ $ask == 1 ] ; then
			make clean
			echo "Clean full selected"
	fi
	if [ $ask == 2 ] ; then
		rm -rf "$mOUT/combinedroot";
		rm -rf "$mOUT/data";
		rm -rf "$mOUT/root";
		rm -rf "$mOUT/system";
		rm -rf "$mOUT/utilities";
		rm -rf "$mOUT/boot"*;
		rm -rf "$mOUT/combined"*;
		rm -rf "$mOUT/kernel";
		rm -rf "$mOUT/ramdisk"*;
		rm -rf "$mOUT/recovery"*;
		rm -rf "$mOUT/system"*;
		rm -rf "$mOUT/obj/ETC/system_build_prop_intermediates";
		rm -rf "$mOUT/obj/PACKAGING/target_files_intermediates";
		rm -rf "$mOUT/vendor";
		rm -rf "$mOUT/obj/KERNEL_OBJ";
		rm -rf "$mOUT/obj/PACKAGING/apkcerts_intermediates";
		rm -rf "$mOUT/ota_temp/RECOVERY/RAMDISK";
		rm -rf "$mOUT/symbols";
		rm -rf "$mOUT/*.*";
		echo "Clean dirty"

	fi
}

enviar_alteracoes() {
    nomeDev=novidades
    if [ -d $modirDev/$nomeDev  ] ; then
      echo -e ${ylw}"\n ▼$nomeDev \n"${txtrst}
      cd $modirDev/$nomeDev
      cp -a -R  ~/rr/CHANGELOG.mkdn  $modirDev/$nomeDev/MotoG5sPlus.xml
      git add -A
      echo "OTA Update for RR $DEVICE $(date +%Y%m%d) Build" > /tmp/rrota
      git commit -as -F /tmp/rrota
      git push origin master
      cd -
      rm -fv /tmp/rrota
    else
      git clone https://github.com/devx12/changelogs -b master $modirDev/$nomeDev
    fi
}

mROM_killjava(){
	kill all java
}
extras_atualizar() {
	modirDev=~/apps/devx12/rr
	nomeDev=android_build
	if [ -d $modirDev/$nomeDev ] ; then
		echo -e ${ylw}"\n ▼$nomeDev \n"${txtrst}
		cd $modirDev/$nomeDev
		git pull https://github.com/ResurrectionRemix/android_build oreo
		git push origin oreo
	else
		git clone https://github.com/devx12/android_build -b oreo $modirDev/$nomeDev
	fi

}

mensagem(){
	curl --silent --output /dev/null \
  --data-urlencode "chat_id=$chat_id" \
	--data-urlencode "text=$MSG" \
	--data-urlencode "parse_mode=Markdown" \
	"https://api.telegram.org/bot$token/sendMessage"
}

merge_up_extras(){
		DIREXT=/home/jadilson/etc/documentos/havoc
		
		# BUILD		
		echo -e ${ylw}"\n ▼UPDATE BUILD \n"${txtrst}
		cd $DIREXT/build
		git fetch --all
		git merge origin/pie
		git push jadilson12 pie 

		# VENDOR		
		echo -e ${ylw}"\n ▼UPDATE VENDOR \n"${txtrst}
		cd $DIREXT/vendor
		git fetch --all
		git merge origin/pie
		git push jadilson12 pie 

		# updates		
		echo -e ${ylw}"\n ▼UPDATE updates\n"${txtrst}
		cd $DIREXT/updates
		git fetch --all
		git merge origin/pie
		git push jadilson12 pie 

		echo -e ${ylw}"\n ▼ALL UPDATED\n"${txtrst}
}

auto(){
	rom_update
	rom_make
}