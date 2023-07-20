function highlight(modelName,status,highlightExclusion,highlightCheckResults)



    MAObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
    MAObj.MAExplorer.hide;
    if strcmp(status,'on')
        MAObj.MEMenus.ShowInformerGUI.on='on';
    else
        MAObj.MEMenus.ShowInformerGUI.on='off';
    end

    if strcmp(highlightExclusion,'on')
        MAObj.MEMenus.ShowExclusionsGUI.on='on';
    else
        MAObj.MEMenus.ShowExclusionsGUI.on='off';
    end

    if strcmp(highlightCheckResults,'on')
        MAObj.MEMenus.ShowCheckResultsGUI.on='on';
    else
        MAObj.MEMenus.ShowCheckResultsGUI.on='off';
    end

end