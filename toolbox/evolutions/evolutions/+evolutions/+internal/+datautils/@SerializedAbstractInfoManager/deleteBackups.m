function deleteBackups(obj)




    dm=obj.getDependentManager;
    if~isempty(dm)
        dm.deleteBackups;
    end

    evolutions.internal.classhandler.ClassHandler.DeleteObjectBackup(obj.Infos);

end