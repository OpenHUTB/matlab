function updateHighlight(modelName,paraName,status)

    MAObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
    if strcmp(status,'on')
        if strcmp(paraName,'exclusion')
            MAObj.MEMenus.ShowExclusionsGUI.on='on';
        else
            MAObj.MEMenus.ShowCheckResultsGUI.on='on';
        end
    else
        if strcmp(paraName,'exclusion')
            MAObj.MEMenus.ShowExclusionsGUI.on='off';
        else
            MAObj.MEMenus.ShowCheckResultsGUI.on='off';
        end
    end
end