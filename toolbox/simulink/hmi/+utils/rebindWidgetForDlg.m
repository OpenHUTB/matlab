function rebindWidgetForDlg(obj)



    if locIsCoreBlock(obj.getBlock())
        rebindCoreBlock(obj);
    else
        rebindLegacy(obj);
    end
end


function ret=locIsCoreBlock(hBlk)
    ret=~strcmpi(get(hBlk,'BlockType'),'SubSystem');
end


function rebindCoreBlock(obj)
    hBlk=get(obj.blockObj,'handle');
    Simulink.HMI.applyRebindingRules(hBlk);
end


function rebindLegacy(obj)
    hBlk=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(hBlk),'Name');
    hMdl=get_param(mdl,'handle');
    simStatus=get_param(mdl,'SimulationStatus');
    webhmi=Simulink.HMI.WebHMI.getWebHMI(hMdl);
    if~isempty(webhmi)&&~webhmi.IsInModelReference&&strcmpi(simStatus,'stopped')
        webhmi.applyRebindingRulesForWidget(obj.widgetId);
    end
end