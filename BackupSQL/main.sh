#!/bin/bash
#Created by Luc Bourbiaux
#Last edited by Luc Bourbiaux, 24/08/2021
#Description : Script principal de backup de base de données

#Connexion BDD source
dbhost=$1
dbuser=$2
dbpass=$3

#Bases selectionnées (fichier liste)
baseSelect=`cat /home/info/BackupSQL/databases`

#Chemin absolu des dossiers logs et backup
absolutepath='/home/info/BackupSQL'

#Nommage des sauvegardes
tarBackup=$(date +%Y-%m-%d).tar.gz

#Nommage des fichiers de logs
out=out.$(date +%m-%d).log
error=error.$(date +%m-%d).log

#Argument SQL dump
singleTransation=TRUE
replace=TRUE

#Supression automatique après X jours
automaticRemove=TRUE
afterNbDay=15

#Affichage de la taille des fichiers dans les logs
sizeFile=TRUE

#Vérification si paramètres remplis
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]
then
    echo "Paramètre vide"
    exit 102
fi

#Vérification de l'existence du repertoire de LOGS
if [ ! -d $absolutepath/log ]
then
    mkdir $absolutepath/log
    if [ ! -d $absolutepath/log ]
    then
        exit 100
    fi
fi

#Mise en place des fichiers de logs
exec 1>$absolutepath/log/$out
exec 2>$absolutepath/log/$error

#Vérification de l'existence du repertoire SAVE
if [ ! -d $absolutepath/save ]
then
    mkdir $absolutepath/save
    if [ ! -d $absolutepath/save ]
    then
        exit 100
    fi
fi

#Création du repertoire temporaire de la sauvegarde du jour
if [ ! -d $absolutepath/save/temp ]
then
    mkdir $absolutepath/save/temp
    if [ ! -d $absolutepath/save/temp ]
    then
        exit 100
    fi
fi

if [ $singleTransation = TRUE ] && [ $replace = TRUE ] 
then
    for database in $baseSelect
    do
        if [ ! -d $absolutepath/save/temp/$database ]
        then
            mkdir $absolutepath/save/temp/$database
            if [ ! -d $absolutepath/save/temp/$database ]
            then
                exit 100
            fi
        fi
        echo -e "Début backup STRUCTURE de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost -d --single-transaction --quick -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-structure.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-structure.sql`
        fi
        echo -e "Fin backup STRUCTURE de \"$database\" en $timeExec seconde(s)"

        echo -e "Début backup DATA de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost --no-create-info --no-create-db --replace --single-transaction --quick -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-data.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-data.sql`
        fi
        echo -e "Fin backup DATA de \"$database\" en $timeExec seconde(s)\n"
    done
elif [ $singleTransation = FALSE ] && [ $replace = FALSE ]  
then
    for database in $baseSelect
    do
        if [ ! -d $absolutepath/save/temp/$database ]
        then
            mkdir $absolutepath/save/temp/$database
            if [ ! -d $absolutepath/save/temp/$database ]
            then
                exit 100
            fi
        fi
        echo -e "Début backup STRUCTURE de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost -d -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-structure.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-structure.sql`
        fi
        echo -e "Fin backup STRUCTURE de \"$database\" en $timeExec seconde(s)"

        echo -e "Début backup DATA de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost --no-create-info --no-create-db -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-data.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-data.sql`
        fi
        echo -e "Fin backup DATA de \"$database\" en $timeExec seconde(s)\n"
    done
elif [ $singleTransation = TRUE ] && [ $replace = FALSE ] 
then
    for database in $baseSelect
    do
        if [ ! -d $absolutepath/save/temp/$database ]
        then
            mkdir $absolutepath/save/temp/$database
            if [ ! -d $absolutepath/save/temp/$database ]
            then
                exit 100
            fi
        fi
        echo -e "Début backup STRUCTURE de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost -d --single-transaction --quick -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-structure.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-structure.sql`
        fi
        echo -e "Fin backup STRUCTURE de \"$database\" en $timeExec seconde(s)"

        echo -e "Début backup DATA de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost --no-create-info --no-create-db --single-transaction --quick -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-data.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-data.sql`
        fi
        echo -e "Fin backup DATA de \"$database\" en $timeExec seconde(s)\n"
    done
elif [ $singleTransation = FALSE && $replace = TRUE ]
then
    for database in $baseSelect
    do
        if [ ! -d $absolutepath/save/temp/$database ]
        then
            mkdir $absolutepath/save/temp/$database
            if [ ! -d $absolutepath/save/temp/$database ]
            then
                exit 100
            fi
        fi
        echo -e "Début backup STRUCTURE de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost -d -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-structure.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-structure.sql`
        fi
        echo -e "Fin backup STRUCTURE de \"$database\" en $timeExec seconde(s)"

        echo -e "Début backup DATA de \"$database\""
        start=$(date +"%s")
        mysqldump -h$dbhost --no-create-info --no-create-db --replace -u$dbuser -p$dbpass $database > $absolutepath/save/temp/$database/$database-data.sql
        end=$(date +"%s")
        timeExec=$(($end-$start))
        if [ $sizeFile=TRUE ] 
        then
            echo `du -h $absolutepath/save/temp/$database/$database-data.sql`
        fi
        echo -e "Fin backup DATA de \"$database\" en $timeExec seconde(s)\n"
    done   
else
    exit 101
fi

echo -e "Début de la compression dans le fichier \"$tarBackup\""
start=$(date +"%s")
cd $absolutepath/save/temp
tar -czf ../$tarBackup *
end=$(date +"%s")
timeExec=$(($end-$start))
if [ $sizeFile=TRUE ] 
then
    echo `du -h $absolutepath/save/$tarBackup`
fi
echo -e "Fin de la compression dans le fichier \"$tarBackup\" en $timeExec seconde(s)\n"

#suppression du dossier temporaire
rm -rf $absolutepath/save/temp
echo -e "Dossier Temporaire supprimé"


#Suppression automatique
if [ $automaticRemove = TRUE ]
then
    find $absolutepath/save/* -mtime +$afterNbDay -exec rm {} \;
    find $absolutepath/log/* -mtime +$afterNbDay -exec rm {} \;
fi
