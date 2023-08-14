function CloseListener(aEventSrc,aEventData,aObj)%#ok




    map=slci.Configuration.ModelToDialogMap();
    if~isempty(aObj.fDialogHandle)
        aObj.fDialogHandle.delete;
        aObj.fDialogHandle=[];
    end
    map(aObj.getModelName)=[];%#ok
end
