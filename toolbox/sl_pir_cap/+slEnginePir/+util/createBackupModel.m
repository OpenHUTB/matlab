function backupModel = createBackupModel( topModel, backupPrefix )
arguments
    topModel
    backupPrefix = 'backup_'
end
backupModelManager = slEnginePir.util.BackupModelManager( topModel, backupPrefix );
backupModel = backupModelManager.createBackupModel(  );
end

