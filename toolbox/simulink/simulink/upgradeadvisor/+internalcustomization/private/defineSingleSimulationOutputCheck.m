function defineSingleSimulationOutputCheck()




    ensureSingleOutput=ModelAdvisor.Check('mathworks.design.CheckSingleSimulationOutput');
    ensureSingleOutput.Title=DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:CheckTitle');
    ensureSingleOutput.TitleTips=DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:CheckTitleTips');
    ensureSingleOutput.setCallbackFcn(@checkIfUpdateReturnWorkspaceOutputs,'None','StyleOne');
    ensureSingleOutput.CSHParameters.MapKey='ma.simulink';
    ensureSingleOutput.CSHParameters.TopicID='CheckSingleSimulationOutput';

    ensureSingleOutput.Visible=true;
    ensureSingleOutput.Enable=true;
    ensureSingleOutput.Value=true;
    ensureSingleOutput.SupportLibrary=false;


    ensureSingleOutputAction=ModelAdvisor.Action;
    ensureSingleOutputAction.setCallbackFcn(@actionFlagForReturnWorkspaceOutputs);
    ensureSingleOutputAction.Name=DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:Button');
    ensureSingleOutputAction.Description=DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:Description');
    ensureSingleOutputAction.Enable=false;
    ensureSingleOutput.setAction(ensureSingleOutputAction);



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(ensureSingleOutput);

end


function results=checkIfUpdateReturnWorkspaceOutputs(system)
    model=bdroot(system);


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');

    paramOn=strcmp(get_param(model,'ReturnWorkspaceOutputs'),'on');
    if paramOn
        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:PassMessage'));
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    else
        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:FailMessage'));
        ft.setSubResultStatus('fail');
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    end

    ft.setSubBar(0);
    results={ft};
end


function result=actionFlagForReturnWorkspaceOutputs(taskObj)
    result=ModelAdvisor.Paragraph();
    mdladvObj=taskObj.MAObj;
    model=bdroot(mdladvObj.System);

    try
        set_param(model,'ReturnWorkspaceOutputs','on');
        msgStr=ModelAdvisor.Text(...
        DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:ParamSetSuccessfully'),...
        {'pass'});
    catch E
        msgStr=ModelAdvisor.Text(...
        DAStudio.message('SimulinkUpgradeAdvisor:singleSimulationOutput:ParamSetFailed',E.message),...
        {'fail'});
    end
    result.addItem(msgStr);
end

