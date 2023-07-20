function customizationCoderTarget()





    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineCoderTargetUpgradeChecks);
    cm.addModelAdvisorTaskAdvisorFcn(@defineCoderTargetUpgradeTasks);
end



function defineCoderTargetUpgradeChecks

    if dig.isProductInstalled('Simulink Coder')

        check=ModelAdvisor.Check('mathworks.codegen.codertarget.check');
        check.Title=DAStudio.message('codertarget:build:UpgradeAdvisorCheckTitle');
        check.TitleTips=DAStudio.message('codertarget:setup:UARealtime2CoderTarget_taskDescription');
        check.Visible=true;
        check.CSHParameters.MapKey='ma.rtw';
        check.CSHParameters.TopicID='UpgradeToUseCoderTarget';
        check.setCallbackFcn(@i_coderTargetCallbackFunction,'None','StyleOne');


        modifyAction=ModelAdvisor.Action;
        modifyAction.Name=DAStudio.message('codertarget:setup:UARealtime2CoderTarget_actionButton');
        modifyAction.Description=DAStudio.message('codertarget:setup:UARealtime2CoderTarget_actionButton');
        modifyAction.Enable=true;
        modifyAction.setCallbackFcn(@saveUpgradedModel);
        check.setAction(modifyAction);


        modelAdvisor=ModelAdvisor.Root;
        modelAdvisor.register(check);
    end
end



function defineCoderTargetUpgradeTasks

    if dig.isProductInstalled('Simulink Coder')

        task=ModelAdvisor.Task('mathworks.codegen.codertarget.task');
        task.DisplayName=DAStudio.message('codertarget:build:UpgradeAdvisorTaskTitle');
        task.Description=DAStudio.message('codertarget:build:UpgradeAdvisorTaskDescription');
        task.CSHParameters.MapKey='ma.rtw';
        task.CSHParameters.TopicID='UpgradeToUseCoderTarget';
        task.setCheck('mathworks.codegen.codertarget.check');
        mdlAdvisor=ModelAdvisor.Root;
        mdlAdvisor.register(task);
        upgAdvisor=UpgradeAdvisor;
        upgAdvisor.addTask(task);
    end
end



function result=i_coderTargetCallbackFunction(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    stf=get_param(system,'SystemTargetFile');
    isIDELinkModel=isequal(stf,'idelink_ert.tlc')||isequal(stf,'idelink_grt.tlc');
    isRealtimeModel=isequal(get_param(system,'SystemTargetFile'),'realtime.tlc');
    status='pass';
    otherMsgs=[];
    if isRealtimeModel
        result=checkModelUsingDeprecatedTargetHardware(system);
        return;
    elseif isIDELinkModel
        h=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
        try
            fcnHandle=h.getUpdateToERTSTFFcn(get_param(system,'AdaptorName'));
            if isempty(fcnHandle)
                statusMsg=DAStudio.message('codertarget:build:UpgradeAdvisorNonConversionNeeded');
            else
                [status,otherMsgs]=fcnHandle(system);
                if isequal(status,'pass')
                    statusMsg=DAStudio.message('codertarget:build:UpgradeAdvisorPass');
                else
                    statusMsg=DAStudio.message('codertarget:build:UpgradeAdvisorFail');
                end
            end
        catch e
            status='fail';
            statusMsg=[DAStudio.message('codertarget:build:UpgradeAdvisorFail'),'. ',e.message];
        end
    else
        statusMsg=DAStudio.message('codertarget:setup:UARealtime2CoderTarget_modelCompliant');
    end

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setInformation(DAStudio.message('codertarget:build:UpgradeAdvisorTaskDescription'));
    ft.setSubResultStatusText(statusMsg);
    ft.setSubResultStatus(status);
    ft.setSubBar(0);
    result{1}=ft;
    if~isempty(otherMsgs)
        p=ModelAdvisor.Paragraph();
        for i=1:numel(otherMsgs)
            p.addItem(ModelAdvisor.LineBreak);
            p.addItem(otherMsgs{i});
        end
        result{end+1}=p;
    end
    mdladvObj.setCheckResultStatus(isequal(status,'pass'));
    mdladvObj.setActionEnable(true);
end


function results=checkModelUsingDeprecatedTargetHardware(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    system=codertarget.utils.getModelForBlock(system);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(false);
    output=true;
    exMsg='';
    msg=DAStudio.message('codertarget:setup:UARealtime2CoderTarget_modelCompliant');
    setEA=false;
    setRA=ModelAdvisor.Text(DAStudio.message('codertarget:setup:UARealtime2CoderTarget_noActionNeeded'));
    cs=getActiveConfigSet(system);
    if~isempty(cs.getComponent('Run on Hardware'))
        cc=cs.getComponent('Run on Hardware');
        deprecationObj=realtime.internal.TargetHardware.getTargetHardwareDeprecationInfo(cc.TargetExtensionPlatform);
        if~isempty(deprecationObj)
            try
                deprecationObj.run(cs,'f');
                setEA=true;
                msg=DAStudio.message('codertarget:setup:UARealtime2CoderTarget_successfullyUpdated');
                setRA=ModelAdvisor.Text(DAStudio.message('codertarget:setup:UARealtime2CoderTarget_saveModel'));
            catch ex
                output=false;
                exMsg=ex.getReport;
            end
        end
    end

    if output
        ft.setSubResultStatus('pass');
        p1=ModelAdvisor.Text(msg);
        ft.setSubResultStatusText(p1);
        r1=setRA;
        ft.setRecAction(r1);
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(setEA);
    else
        ft.setSubResultStatus('Fail');
        ft.setSubResultStatusText(DAStudio.message('codertarget:setup:UARealtime2CoderTarget_modelUpgradeError',exMsg));
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(false);
    end

    results=ft;

end


function result=saveUpgradedModel(taskobj)

    mdladvObj=taskobj.MAObj;
    result=ModelAdvisor.Paragraph;
    system=codertarget.utils.getModelForBlock(getfullname(mdladvObj.System));
    set_param(system,'dirty','on');
    save_system(system);
    mdladvObj.setActionEnable(true);

end
