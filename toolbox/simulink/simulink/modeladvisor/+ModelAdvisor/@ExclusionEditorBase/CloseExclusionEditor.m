function CloseExclusionEditor(aObj)




    map=ModelAdvisor.ExclusionEditorBase.ModelToDialogMap();
    map(aObj.getModelName())=[];%#ok
    aObj.fDialogHandle=[];
end

