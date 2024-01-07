function modelCleanUp(model)
    appHandle=serdes.internal.findMgrWithTag(model,'serdes.utilities.apps.sparameterfitter.sParameterFitter');
    if~isempty(appHandle)&&isvalid(appHandle)
        appHandle.delete;
    end
    appHandle=serdes.internal.findMgrWithTag(model,'IbisAmiManager');
    if~isempty(appHandle)&&isvalid(appHandle)
        appHandle.salida;
    end
    siLinkName=[getString(message('serdes:silink:AppName')),' - ',model];
    figure=findall(groot,'Name',siLinkName);
    if~isempty(figure)
        close(figure);
    end
    serdesStatPanelTag=['SimulinkStatPlotPanel',model];
    serdesTDPanelTag=['SimulinkTDPlotPanel',model];
    serdesStatPanel=findobj(groot,'Tag',serdesStatPanelTag);
    serdesTDPanel=findobj(groot,'Tag',serdesTDPanelTag);
    if~isempty(serdesStatPanel)
        close(serdesStatPanel.Parent);
    elseif~isempty(serdesTDPanel)
        close(serdesTDPanel.Parent);
    end

    openModels=Simulink.allBlockDiagrams('model');

    if~isempty(openModels)
        return
    end
    mws=get_param(model,'ModelWorkspace');
    trees={'TxTree','RxTree'};
    for treeIdx=1:length(trees)
        if~isempty(mws)&&mws.hasVariable(trees{treeIdx})
            tree=mws.getVariable(trees{treeIdx});
            baseWSVariables=tree.BaseWorkspaceVariables;
            if~isempty(baseWSVariables)&&serdes.utilities.canWriteWorkSpace('base')
                for baseWSVariableIdx=1:length(baseWSVariables)
                    evalin('base',"clear "+baseWSVariables{baseWSVariableIdx});
                end
            end
        end
    end
end

