function defineResaveInCurrentVersionCheck()




    ensureResaveCheck=ModelAdvisor.Check('mathworks.design.CheckSavedInCurrentVersion');
    ensureResaveCheck.Title=DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:CheckTitle');
    ensureResaveCheck.TitleTips=DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:CheckTitleTips');
    ensureResaveCheck.setCallbackFcn(@checkIfResaveNeeded,'None','StyleOne');
    ensureResaveCheck.CSHParameters.MapKey='ma.simulink';
    ensureResaveCheck.CSHParameters.TopicID='UpgradeAdvisorResaveCheck';

    ensureResaveCheck.Visible=true;
    ensureResaveCheck.Enable=true;
    ensureResaveCheck.Value=true;
    ensureResaveCheck.SupportLibrary=true;


    ensureResaveAction=ModelAdvisor.Action;
    ensureResaveAction.setCallbackFcn(@actionFlagForResave);
    ensureResaveAction.Name=DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:Button');
    ensureResaveAction.Description=DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:Description');
    ensureResaveAction.Enable=false;
    ensureResaveCheck.setAction(ensureResaveAction);



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(ensureResaveCheck);

end


function results=checkIfResaveNeeded(system)
    model=bdroot(system);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');

    filepath=get_param(model,'FileName');
    if isempty(filepath)
        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:NotSavedMessage'));
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    else
        modelVersion=simulink_version(Simulink.MDLInfo(filepath).SimulinkVersion);





        if(modelVersion==simulink_version)
            ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:PassMessage'));
            ft.setSubResultStatus('pass');
            mdladvObj.setCheckResultStatus(true);
            mdladvObj.setActionEnable(false);
        else
            ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:FailMessage',modelVersion.release));
            ft.setSubResultStatus('warn');
            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setActionEnable(true);
        end
    end

    ft.setSubBar(0);
    results={ft};
end


function result=actionFlagForResave(taskObj)
    result=ModelAdvisor.Paragraph();
    mdladvObj=taskObj.MAObj;
    modelName=get_param(bdroot(mdladvObj.System),'name');
    try
        save_system(bdroot(modelName))
        msgStr=ModelAdvisor.Text(...
        DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:SavedSuccessfully',modelName),...
        {'pass'});
    catch E
        msgStr=ModelAdvisor.Text(...
        DAStudio.message('SimulinkUpgradeAdvisor:resavecheck:SaveFailed',modelName,E.message),...
        {'fail'});
    end
    result.addItem(msgStr);
end

