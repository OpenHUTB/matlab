function hasPoint=hasValidPoint(model)









    restorePath=...
    restorepoint.internal.utils.getExistingRestorePointDirectoryForModel(model);
    hasPoint=~isempty(restorePath);
end
