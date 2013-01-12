#!/bin/bash
lineseparator="---------------------------------------------------------------------"

# Devuelve la duracion en formato HH:MM:SS:MMSS
# duracion=$(ffmpeg -i trailer1080.mp4.mp4  2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//)
# echo "Duracion:" $duracion

#Recibimos como segundo parametro el tamaño de cada trozo
duracionsegundostrozo=$2

for file in *.mp4;
do
	echo $lineseparator
	echo Procesando $file
	duration=$(ffmpeg -i $file 2>&1 | sed -n "s/.* Duration: \([^,]*\), start: .*/\1/p")
	fps=$(ffmpeg -i $file 2>&1 | sed -n "s/.*, \(.*\) tb.*/\1/p")

	hours=$(echo $duration | cut -d":" -f1)
	minutes=$(echo $duration | cut -d":" -f2)
	seconds=$(echo $duration | cut -d":" -f3)

	frames=$(echo "($hours*3600+$minutes*60+$seconds)*$fps" | bc | cut -d"." -f1)
	durationinseconds=$(echo "($hours*3600+$minutes*60+$seconds)" | bc | cut -d"." -f1)
	echo Frame number: $frames
	echo Duration: $duration
	echo Duration secs: $durationinseconds

	if [ $durationinseconds -le 300 ]; then
		DURACIONTROZO='10'
		echo Haremos trozos de $DURACIONTROZO segundos

		#Bucle troceado del video
		N='1'
		OFFSET='0'
		while [ "$OFFSET" -lt "$durationinseconds" ]; do 
			let "COMPROBAR_QUITAR_ULTIMO_TROZO=OFFSET+DURACIONTROZO"
			if [ "$COMPROBAR_QUITAR_ULTIMO_TROZO" -lt "$durationinseconds" ]; then
				FICHEROSALIDA=$(printf "$file.$N.mp4")
				echo $FICHEROSALIDA
				echo "Trozo $N empieza en $OFFSET sec. y terminará en $COMPROBAR_QUITAR_ULTIMO_TROZO secs."
				ffmpeg -i $file -vcodec copy -acodec copy -ss $OFFSET -t $DURACIONTROZO $FICHEROSALIDA 			
			fi
			let "N = N + 1"
			let "OFFSET = OFFSET + DURACIONTROZO"
		done
	fi

done
	echo $lineseparator

