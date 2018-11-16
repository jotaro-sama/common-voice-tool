#!/bin/bash

# Tool creato per agevolare il lavoro con le stringhe di common voice.
# 
# Reach me on GitHub - github.com/dag7dev
# Email: dag7@protonmail.com

#   Copyright (C) 2018 dag7

#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.


function printHelp(){
	echo "common-voice-tool"
	echo "-----------------"
	echo "Copyright (C) 2018 dag7"
	echo "-----------------"
	echo "utilizzo: ./common-voice-tool <options>"
	echo "   -h or -help"
	echo "       Mostra questo messaggio"
	echo "   -range or -chkLen"
	echo "      Controlla se la lunghezza della stringa è in un range."
	echo "   -trim"
	echo "      Elimina gli spazi bianchi ' ' alla fine di ogni riga."
	echo "   -chkPoint"
	echo "      Controlla se ogni riga di un file termina con un punto"
	echo "      (non lo sostituisce, controlla e basta!)"
	echo "   -ac"
	echo "      Aggiunge un punto se il file non termina con un punto."
	echo "   -no-empty"
	echo "      Elimina tutte le righe vuote."
}


function main() {
	echo "Benvenuto in common-voice-tool!"
	echo "-------------------------------"
	echo

	ls -l
	read -e -p "Seleziona il tuo file:" fileN

	# controlla se il file non esiste
	if [[ ! -f $fileN ]]; then
			echo "File non esistente!"
		exit 1
	fi

	# sfruttando wc si ricava il numero delle stringhe
	rows=`wc -l $fileN | cut -d ' ' -f1`

	# stampa le informazioni "da conoscere"
	echo
	echo "Numero di righe: " "$rows"
	pressEnter

	setDefaultValues
	
	echo
}

# dato numero di stringa  in input ricava la lunghezza della stringa
# ritorna la lunghezza della stringa
function strLen () {
	str=`sed "$1q;d" $fileN`

	len=${#str}
	
	return $len
}

# data lunghezza in input
# controlla che la stringa risulti essere nel range
# stampa se la riga è troppo lunga o corta, il numero di caratteri superiori
# o inferiori al range e il numero di riga
function checkLen () {
	if [ $1 -gt $3 ]; then
		echo " - Riga: $i - " "Stringa troppo lunga! Caratteri superiori al massimo consentito:" $(( $1-$3 ))
	else
		if [ $1 -lt $2 ];then
			echo " - Riga: $i - " "Stringa troppo lunga! Caratteri inferiori al massimo consentito:" $(( $2-$1 ))
		fi
	fi
}

# dato il numero di stringhe, per ogni stringa del file controlla se è nel range
function areStrsInRange() {
	for ((i=1;$i<=$1;i++)){
		# controlla lunghezza delle frasi
		strLen $i
		checkLen $len $carMin $carMax
	}
}

# acquisisce un carattere e mostra "premi invio per continuare"
# pulisce la console dopo aver premuto enter
function pressEnter() {
	read -p "Premi [INVIO] per continuare"
	clear
}

# imposta il valore del range ai valori di default
function setDefaultValues() {
	carMin=1
	carMax=125
}

if [ $# -gt 3 ]; then
	echo "Sintassi errata!"
    echo "eseguire: ./common-voice-tool -h"
    exit 1
fi

if [ -z "$1" -o "$1" == "-h" -o "$1" == "-help" ];then
	printHelp
	exit 1
fi

function promptMaxMinUser() {
	rangeOk=false

	read -p "Vuoi utilizzare i valori di default? [S/N]: " ris

	if [ "$ris" != "S" -a "$ris" != "s" -a -n "$ris" ];then
		while [ "$rangeOk" = false ] ; do
			carMin=""
			carMax=""
######################################################
			while [[ $carMin -lt 1 || -z $carMin ]]
			do
				read -p "Digita il valore minimo del range: " carMin
			done
			while [[ $carMax -lt 1 || -z $carMax ]]
			do
				read -p "Digita il valore massimo del range: " carMax
			done
######################################################
			if [ $carMin -ge $carMax -o $carMin == $carMax ] ; then
				clear
				echo "Valori inseriti non validi!"
			else
				rangeOk=true
			fi
		done
	else
		echo "I valori del range saranno impostati ai valori di default! (1-125)"
		setDefaultValues
        pressEnter
	fi
}

# Dato in input il carattere da gestire in eccezione
# Se il secondo parametro e' -ac (autocorreggi)
# si provvede ad aggiungere il punto, altrimenti
# si stampano ultimo  carattere e nRiga della frase
function chkPoint() {
	# definizione del carattere
	car="$1"

	echo
	echo -n "Opzione autocorreggi: "
	if [ "$2" == "-ac" ];then
		echo "ON"
	else
		echo "OFF"
	fi

	echo 

	echo -e "Il punto deve essere aggiunto alla:"


	# controlla ogni frase.
	for ((i=1;i<=$rows;i++)) {
		strLen $i
		
		if [ $len -lt $carMax ];then

			case "${str: -1}" in
				'?'|'!'|'.'|'\ ')
					;;
				*)
					echo "- Riga: $i -"

					# Se non presente il punto a fine frase lo aggiunge.
					if [ "$2" == "-ac" ];then
						echo " Aggiungo..."
						sed -i "${i}s/$/./" "$fileN"
					fi

					;;
			esac
		fi
	}
}

# dato nome di un file trimma gli spazi bianchi alla fine di ogni riga
function trim () {
	if [ "$1" == "-no-empty" ];then
		# trim righe vuote
		sed -i '/^$/d' $fileN
	else
		# trim spazi fine frase
		sed -i 's/\s*$//' $fileN
	fi
}

#######################
# LAUNCHER PRINCIPALE #
#######################
clear

# acquisisce file da processare
# memorizza in alcune variabili alcune info importanti
# stampa informazioni utili
main

# a seconda degli argomenti passati effettua le diverse operazioni
for var in "$@"
do
    case $var in
    	# stringhe sono nel range
    	"-range"|"-chkLen")
			echo "RANGE"
			echo "--------"
			promptMaxMinUser
			echo "Sono nel range?:"
			areStrsInRange $rows;
			echo
		;;
		
		# eliminare spazi a fine riga
		"-trim")
			echo "TRIM"
			echo "--------"
			trim $fileN
			echo "Spazi a fine riga eliminati correttamente!"
			echo
		;;
		
		"-no-empty")
			echo "NO-EMPTY"
			echo "--------"
			trim $fileN $var
			echo "Righe vuote eliminate correttamente!"
			echo
		;;

		# controllare il punto a fine frase
		"-chkPoint")
			echo "CHKPOINT"
			echo "--------"
			chkPoint .
			echo
    	;;
    	
    	# autoCorrezionePunto: aggiunge il punto
    	"-ac")
			echo "AUTOCORREZIONE"
			echo "---------------"
			chkPoint . "$var"
			echo
		;;

		*)
		;;
    esac

    pressEnter
done

echo "Grazie per aver utilizzato common-voice-tool! ;)"
echo "Visita la pagina del progetto github.com/dag7dev/common-voice-tool"

exit 0
