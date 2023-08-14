function copyFromBackup(obj)




    dm=obj.getDependentManager;
    if~isempty(dm)
        dm.copyFromBackup;
    end

    evolutions.internal.classhandler.ClassHandler.CopyFromBackup(obj.Infos);

end