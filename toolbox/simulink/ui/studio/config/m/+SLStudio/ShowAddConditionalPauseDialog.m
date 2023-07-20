function ShowAddConditionalPauseDialog(modelH,portH)






    portMap=SLStudio.GetAddConditionalPauseDialogPortMap();

    if~portMap.isKey(portH)
        portMap(portH)=SLStudio.AddConditionalPauseDialog(modelH,portH);
        obj=get_param(modelH,'slobject');
        obj.isConditionalPauseDialogOpened=true;
    end

    obj=portMap(portH);
    obj.showAddConditionalPauseDialog;



    Simulink.addBlockDiagramCallback(modelH,...
    'PreClose','ConditionalPauseDialogs',...
    @()slprivate('removeModelPortsFromConditionalPauseDialog',modelH),...
    true);
end


