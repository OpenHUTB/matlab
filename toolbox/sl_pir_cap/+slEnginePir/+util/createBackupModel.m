




function backupModel = createBackupModel( topModel, backupPrefix )
R36
topModel
backupPrefix = 'backup_'
end 
backupModelManager = slEnginePir.util.BackupModelManager( topModel, backupPrefix );
backupModel = backupModelManager.createBackupModel(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQL2V94.p.
% Please follow local copyright laws when handling this file.

