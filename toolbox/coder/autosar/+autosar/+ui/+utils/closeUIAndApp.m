function uiCleanupObj=closeUIAndApp(modelName,saveState)










    uiCleanupObj={};
    arExplorer=autosar.ui.utils.findExplorerForModel(modelName);
    if~isempty(arExplorer)

        autosar_ui_close(modelName);
        if saveState
            uiCleanupObj{end+1}=onCleanup(@()autosar_ui_launch(modelName));
        end
    end

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if cp.isInPerspective(modelName)
        editors=GLUE2.Util.findAllEditors(modelName);
        for ii=1:numel(editors)
            simulinkcoder.internal.CodePerspective.getInstance.togglePerspective(editors(ii));
            if saveState
                uiCleanupObj{end+1}=...
                onCleanup(@()simulinkcoder.internal.CodePerspective.getInstance.togglePerspective(editors(ii)));%#ok<AGROW>
            end
        end
    end

end


