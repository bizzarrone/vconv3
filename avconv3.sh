#!/bin/bash
# CHANGELOG
# ---------------------------
# 2017-10-27 v3.0
# Nuova versione di vconv
# ---------------------------

service apache2 start

function lettura_parametri
{
 file="/vconv3/parametri.txt"
 while read line
 do
	ver=$line
	read line
	vbitrate=$line
	read line
	abitrate=$line
	read line
	rate=$line
	read line
	preset=$line
	read line
	sub=$line
 done <"$file" 
 
}

function codifica
{
 # options: ultrafast, superfast, veryfast, faster, fast, medium (default), slow and veryslow
 #preset=medium
 profile=baseline
 #vbitrate=5000k
 #abitrate=128000
 #rate=30
 #echo avconv -i $IN/$nomefile -loglevel error -vcodec libx264 -preset $preset -profile:v $profile  -level 30  -r $rate -f mpegts -b:v $vbitrate -acodec aac -b:a $abitrate -strict experimental  -threads 0   $OUT/basename $nomefile $estensione.ts -y
 echo "# ELABORAZIONE .."
 # avconv -i BAB_2254.MOV  -i 06_Logo.png -filter_complex 'overlay' out.mkv
 avconv -i $IN/"$nomefile" -i $LOGO_DA_AGGANCIARE -filter_complex 'overlay' -loglevel error -vcodec libx264 -preset $preset -profile:v $profile  -level 30  -r $rate -f mpegts -b:v $vbitrate -acodec aac -b:a $abitrate -ar 44100 -strict experimental  -threads 0   $OUT/`basename "$nomefile" $estensione`.mp4 -y
}

# =======================================================================
while true
do
 lettura_parametri
 #echo "# Controllo video ORIGINALI"
 video_IN="/CONDIVISA/video-IN"
 video_OUT="/CONDIVISA/video-OUT"
 logo_IN="/CONDIVISA/logo-IN"
 
 cd $logo_IN
 find -name "* *" -type f | rename 's/ /_/g'
 cd $video_IN
 # rinomino i file eliminando spazi (se in uso non ci sono problemi, samba continua a scriverci)
 find -name "* *" -type f | rename 's/ /_/g'
 for f  in  *.MOV
 do
  nomefile=`basename $f`
  if [ "$nomefile" != "*.MOV" ]
  then
   smbstatus | grep -i ".mov" > /dev/null
   if [ $? = "1"  ]
    then
	# rimuovo spazi dal file ORIG
 	find -name "* *" -type f | rename 's/ /_/g'
        echo "# VIDEO: nuovo video input          : $nomefile"
#        echo "# VIDEO: video input in elaborazione       : $nomefile"
	estensione=".MOV"
	KEY_INTRO=`echo $nomefile | cut -f 2 -d "."`
#	echo "# VIDEO: ricerco LOGO con CODICE    : $KEY_INTRO"
	# mettere controllo. se keyintro ="" allora esci segnalando errore
	#OUT_INTRO="/CONDIVISA/INTRO-completed"
	LOGO_DA_AGGANCIARE=`ls $logo_IN/*$KEY_INTRO*`
        echo "# LOGO : logo teorico da agganciare : $LOGO_DA_AGGANCIARE"

	# se non trova LOGO da agganciare da errore ed esce
	if [ -f $logo_IN/*$KEY_INTRO* ]
  	then
         echo "# LOGO: logo trovato"	
	 IN=$video_IN
	 OUT=$video_OUT
         echo "# VIDEO: Elaborazione del video con logo"
	 codifica
         echo "# VIDEO: elimino video-in gia elaborato"
#        cancellare il video in dopo averlo elaborato
         rm $nomefile

#	 avconv -i "concat:$INTRO_DA_AGGANCIARE|$ORIG_DA_AGGANCIARE" -c copy  -bsf:a aac_adtstoasc -y  "$FINAL/$NOME_FINALE"
	 # entro in cartella FINAL
	 cd $video_OUT
	 #parte di SOTTOCARTELLA
	 if [ $sub = "on"  ] 
	 then
		echo "# OUT: Opzione sottocartella rilevata"
		SOTTOCARTELLA_temp=`echo $nomefile | cut -f 1 -d "."`
	 	SOTTOCARTELLA_temp2=${SOTTOCARTELLA_temp//_/' '}
		# rimuovo ultimo spazio finale
		SOTTOCARTELLA=`echo "${SOTTOCARTELLA_temp2::-1}"`
		echo "# OUT: creazione sottocartella $SOTTOCARTELLA"	
		mkdir "$SOTTOCARTELLA"
		chmod 777 "$SOTTOCARTELLA"
		mv -f "$video_OUT/$NOME_FINALE"  "$video_OUT/$SOTTOCARTELLA"
		chmod 777 "$video_OUT/$SOTTOCARTELLA"
		cd "$SOTTOCARTELLA"
		echo "# OUT: creazione sottocartella $SOTTOCARTELLA"	
	 fi
	 #rinomino il file togleindo underscore
         find -name "*_*" -type f | rename -f 's/_/ /g'
	 cd -
	 # find -name "* *" -type f | rename 's/ /_/g'
	 # codifica join
     else
         echo "# ERRORE: file LOGO non trovato per questo VIDEO"
     fi
    else
        echo "# VIDEO: nuovo video-in presente. Attendo sia libero :  $nomefile  "
    fi
   break
   # interrompo, perchè mi limito a elaborare il primo file trovato. vedo se arrivano altri file INTRO
  fi
 done

 sleep 4
 echo "# AVconv V$ver  | ar $abitrate | vr $vbitrate | fps $rate | preset $preset | sub $sub | LOOP #"
done

