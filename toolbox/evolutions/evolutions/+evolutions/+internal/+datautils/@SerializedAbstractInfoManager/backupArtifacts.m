function backupArtifacts(obj)




    dm=obj.getDependentManager;
    if~isempty(dm)
        dm.backupArtifacts;
    end

    evolutions.internal.classhandler.ClassHandler.BackupObject(obj.Infos);

end
