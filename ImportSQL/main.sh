#!/bin/bash
#Created by Luc Bourbiaux
#Last edited by Luc Bourbiaux, 24/08/2021
#Description : Script principal d'import de base de données

#Connexion BDD cible
dbhost=$1
dbuser=$2
dbpass=$3

#Bases selectionnées (fichier liste)
baseSelect=`cat /home/info/ImportSQL/databases`

#Chemin absolu du projet (log et dossier temporaire)
pathProjet='/home/info/ImportSQL'
#Chemin absolu du dossier des sauvegardes
pathSave='/home/info/BackupSQL/save'
ignoreTable_file=table_ignore

#Nommage des fichiers de logs
out=out.$(date +%m-%d).log
error=error.$(date +%m-%d).log

#Importation de la structure
structImport=TRUE

forceMode=TRUE

#Supression automatique après X jours
automaticRemove=TRUE
afterNbDay=4

function ignoreTableStruct () {
    if [ -z $1 ] || [ -z $2 ]
    then
        echo -e "Necessite le nom de la base et de la table souhaité"
        exit 0
    fi

    #Premier arg
    local baseName
    baseName=$1
    #Deuxième arg
    local tableName
    tableName=$2

    lineStart=$(grep -n "DROP TABLE IF EXISTS \`$tableName\`" $pathProjet/temp/$baseName/$baseName-structure.sql | awk -F: '{print $1}')

    if [ ! -z $lineStart ]
    then
        echo "$(grep -n "DROP TABLE IF EXISTS" $pathProjet/temp/$baseName/$baseName-structure.sql | awk -F: '{print $1}')" > /tmp/lineStop.txt

        for line in $(cat /tmp/lineStop.txt)
        do
            if (( $line > $lineStart ))
            then
                lineStop=$line
                break 
            fi
        done

        rm /tmp/lineStop.txt

        sed -i $lineStart,$lineStop"d" $pathProjet/temp/$baseName/$baseName-structure.sql
        echo "Structure de la table $tableName de la base $baseName ignoré lors de l'importation"
    else
        echo -e "La structure de la table n'existe pas ou a déjà été ignorée..."
    fi
    
}

function ignoreTableData () {
    if [ -z $1 ] || [ -z $2 ]
    then
        echo -e "Necessite le nom de la base et de la table souhaité"
        exit 0
    fi

    #Premier arg
    local baseName
    baseName=$1
    #Deuxième arg
    local tableName
    tableName=$2

    lineStart=$(grep -n "Dumping data for table \`$tableName\`" $pathProjet/temp/$baseName/$baseName-data.sql | awk -F: '{print $1}')
    if [ ! -z $lineStart ]
    then
        echo "$(grep -n "Dumping data for table" $pathProjet/temp/$baseName/$baseName-data.sql | awk -F: '{print $1}')" > /tmp/lineStop.txt
        for line in $(cat /tmp/lineStop.txt)
        do
            if (( $line > $lineStart ))
            then
                lineStop=$line
                break 
            fi
        done

        lineStop=$(($lineStop-1))
        rm /tmp/lineStop.txt


        sed -i $lineStart,$lineStop"d" $pathProjet/temp/$baseName/$baseName-data.sql
        echo "Data de la table $tableName de la base $baseName ignoré lors de l'importation"       
    else
        echo "La data de la table n'existe pas ou a déjà été ignorée..."
    fi
}

function selectIgnoreTables () {
    for line in $(cat table_ignore)
    do
        base=$(echo $line | awk -F";" '{print $1}')
        table=$(echo $line | awk -F";" '{print $2}')
        ignoreTableStruct $base $table
        ignoreTableData $base $table
    done
}

#Vérification si paramètres remplis
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]
then
    echo "Paramètre vide"
    exit 102
fi

#Vérification de l'existence du repertoire de LOGS
if [ ! -d $pathProjet/log ]
then
    mkdir $pathProjet/log
    if [ ! -d $pathProjet/log ]
    then
        exit 100
    fi
fi

#Mise en place des fichiers de logs
exec 1>$pathProjet/log/$out
exec 2>$pathProjet/log/$error

#Vérification de l'existence du repertoire SAVE source
if [ ! -d $pathSave ]
then
    exit 100
else
    if [ `ls -got $pathSave | awk '{print $2}' | head -1` -gt 0 ] 
    then
        lastSave=`ls -got $pathSave| grep \.tar.gz$ | awk '{print $7}' | head -1`
        echo "Dernière sauvegarde trouvé"
    else
        echo "il n'y a pas de fichier de sauvegarde"
    fi
fi

#Création du repertoire temporaire d'extraction de la sauvegarde pour l'import
if [ ! -d $pathProjet/temp ]
then
    mkdir $pathProjet/temp
    if [ ! -d $pathProjet/temp ]
    then
        exit 100
    fi
fi

#Décompression de l'archive de sauvegarde dans le dossier temporaire
echo -e "Début de la décompression de la dernière sauvegarde trouvé : $lastSave"
start=$(date +"%s")
tar -xzf $pathSave/$lastSave -C $pathProjet/temp
end=$(date +"%s")
timeExec=$(($end-$start))
echo -e "Décompression terminé dans le dossier $pathProjet/temp en $timeExec"

#Ignore Table select in file table_ignore
selectIgnoreTables

#Importation des structures si activé
if [ $structImport = TRUE ] 
then
    for database in $baseSelect
    do
        echo -e "Début de l'import des structures de bases souhaitées"
        if [ -d $pathProjet/temp/$database ] 
        then
            echo -e "Import de la structure de \"$database\""
            start=$(date +"%s")
            if [ $forceMode = TRUE ] 
            then
                mysql -h$dbhost -u$dbuser -p$dbpass -f $database < $pathProjet/temp/$database/$database-structure.sql
            else
                mysql -h$dbhost -u$dbuser -p$dbpass $database < $pathProjet/temp/$database/$database-structure.sql
            fi
            end=$(date +"%s")
            timeExec=$(($end-$start))
            echo -e "Fin de l'import de \"$database\" en $timeExec\n"
        else
            echo -e "Sauvergarde non présente pour la base $database, passage à la prochaine base..\n"
        fi
    done   
fi

#Importation des datas
for database in $baseSelect
    do
        echo -e "Début de l'import des datas de bases souhaitées"
        if [ -d $pathProjet/temp/$database ] 
        then
            echo -e "Import de la data de \"$database\""
            start=$(date +"%s")
            if [ $forceMode = TRUE ] 
            then
                mysql -h$dbhost -u$dbuser -p$dbpass -f $database< $pathProjet/temp/$database/$database-data.sql
            else
                mysql -h$dbhost -u$dbuser -p$dbpass $database< $pathProjet/temp/$database/$database-data.sql
            fi
            end=$(date +"%s")
            timeExec=$(($end-$start))
            echo -e "Fin de l'import de \"$database\" en $timeExec\n"
        else
            echo -e "Sauvergarde non présente pour la base $database, passage à la prochaine base..\n"
        fi
    done

    rm -r $pathProjet/temp

#Suppression automatique
if [ $automaticRemove = TRUE ]
then
    find $pathProjet/log/* -mtime +$afterNbDay -exec rm {} \;
fi
    
echo -e "IMPORTATION TERMINE !"
