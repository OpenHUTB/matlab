function CloseCB(aObj)





    map=slci.Configuration.ModelToDialogMap();
    map(aObj.getModelName())=[];%#ok
    aObj.fDialogHandle=[];
end

