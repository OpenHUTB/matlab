function deleteModelRestorePoint(model)






    restorePathFinderStrategy=restorepoint.internal.delete.FindModelRestorePoint;

    deletorObj=restorepoint.internal.Deletor(restorePathFinderStrategy);
    deletorObj.run(model);
end


