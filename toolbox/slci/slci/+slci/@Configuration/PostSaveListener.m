function PostSaveListener(aBlockDiagramObj,aEventData,aObj)%#ok





    oldName=aObj.getModelName;
    newName=aBlockDiagramObj.Name;
    if~strcmp(oldName,newName)
        map=slci.Configuration.ModelToDialogMap();
        dlg=map(oldName);
        map(newName)=dlg;
        map(oldName)=[];%#ok
        aObj.setModelName(newName);
        aObj.fDialogHandle.setTitle(aObj.CreateDialogTitle());
    end
end
