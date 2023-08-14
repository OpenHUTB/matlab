function success=refreshExclusionUI(modelName)









    success=false;

    service=Advisor.ExclusionEditorUIService.getInstance;
    if service.isKey(modelName)
        exclusionEditorWin=service.getExclusionEditor(modelName);
        exclusionEditorWin.Controller.setTableStale(true);
        exclusionEditorWin.Controller.getTableData();
        exclusionEditorWin.Controller.refreshUI();
        success=true;
    end

end

