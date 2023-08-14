function success=refreshEdittimeExclusions(modelName)









    success=true;

    service=Advisor.ExclusionEditorUIService.getInstance;

    exclusionEditor=service.getExclusionEditor(modelName);
    exclusionEditor.Controller.refreshExclusions;

end

