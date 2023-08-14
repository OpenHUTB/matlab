function deleteAllRestorePoints






    restorePathFinderStrategy=restorepoint.internal.delete.FindAllRestorePaths;

    deletorObj=restorepoint.internal.Deletor(restorePathFinderStrategy);
    deletorObj.run;
end


