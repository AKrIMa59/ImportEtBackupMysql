# BackupSQL

Script de backup SQL paramétrable, avec différentes options de configuration pour la gestion des backups et personnalisation des dumps effectués

Exemple d'exectution : ./main.sh <host> <user> <password>

Les bases de données que l'ont souhaite sauvegarder doivent être indiqué dans le fichier databases (1 ligne > 1 base)


---Variables---
absolutepath : Chemin absolu où se trouvera les sauvegardes ainsi que les logs d'execution du script
tarBackup : Nommage de la backup (ex : $(date +%Y-%m-%d) = 2021-08-25 )
out : Nommage du fichier output de l'execution du script
error : Nommage du fichier d'erreur de l'execution du script
singleTransaction : Permet d'effectuer un backup en production
replace : Remplace les actions SELECT par REPLACE 

---Code Erreur---

100 : Problème de droit pour la création du dossier 
101 : Argument SQL invalide

# ImportSQL
Import SQL autonome

Variable necessaire : 
- Hôte de la base de données
- Utilisateur de la base de données
- Mot de passe de la base de données
- Chemin du dossier d'import
