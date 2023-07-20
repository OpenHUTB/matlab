





function defineCheckSystemObjectUpdate()
    check=ModelAdvisor.Check('mathworks.design.CheckSystemObjectUpdate');
    check.Title=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_title');
    check.TitleTips=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_tip');

    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='CheckSystemObjectupdate';
    check.setCallbackFcn(@checkSystemObjectUpdate,'None','StyleOne');

    check.SupportExclusion=true;
    check.SupportLibrary=false;

    action=ModelAdvisor.Action;
    action.setCallbackFcn(@actionSystemObjectUpdate);
    action.Name=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_rec_action');
    action.Description=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_des_action');
    check.setAction(action);
    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);
end

function result=actionSystemObjectUpdate(taskobj)

    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    result={};

    sysObjBlocks=systemblock.queryUniqueSystemObject(system);

    passedMessages={};
    failedMessages={};
    success=true;
    for i=1:length(sysObjBlocks)
        [res,msg]=systemblock.updateSystemObject(sysObjBlocks{i});
        success=success&&res;
        if res
            passedMessages{end+1}=msg;
        else
            failedMessages{end+1}=msg;
        end
    end

    result=generateActionMessage(passedMessages,failedMessages);
    mdladvObj.setActionResultStatus(success);
    mdladvObj.setActionEnable(success);
end

function result=checkSystemObjectUpdate(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    result={};


    [sysObjBlocks,skippedBlocks]=systemblock.queryUniqueSystemObject(system);

    if isempty(sysObjBlocks)
        result=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_emptyinput');
        mdladvObj.setCheckResultStatus(true);
        return;
    end


    mainHeader=ModelAdvisor.FormatTemplate('TableTemplate');
    mainHeader.setSubBar(false);
    mainHeader.setSubTitle(DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_title'));
    mainHeader.setInformation(DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_des_action'));
    mainHeader.RefLink{end+1}={systemblock.generateHyperLink('matlab:doc sysobjupdate','sysobjupdate')};
    mainHeader.RefLink{end+1}={systemblock.generateHelpViewLink('ma.simulink','CheckSystemObjectupdate',...
    DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_title'))};
    result{end+1}=mainHeader;


    if~isempty(skippedBlocks)
        skippedSysObjTemplate=ModelAdvisor.FormatTemplate('TableTemplate');
        skippedObjectsStr=[DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_skippedobject'),'<br>'];
        for i=1:length(skippedBlocks)
            className=get_param(skippedBlocks{i},'system');
            link=Advisor.Utils.getHyperlinkToBlockParameter(skippedBlocks{i},className);
            className=systemblock.generateHyperLink(link.Hyperlink,className);
            skippedObjectsStr=[skippedObjectsStr...
            ,className...
            ,'<br>'];
        end
        setSubResultStatusText(skippedSysObjTemplate,skippedObjectsStr);
        result{end+1}=skippedSysObjTemplate;
    end

    passed=true;
    for i=1:length(sysObjBlocks)
        [res,diff]=systemblock.systemObjectUpdateRequired(sysObjBlocks{i});
        className=get_param(sysObjBlocks{i},'system');
        classPath=which(className);

        link=Advisor.Utils.getHyperlinkToBlockParameter(sysObjBlocks{i},className);
        className=systemblock.generateHyperLink(link.Hyperlink,className);
        subTitle='';
        if res
            subTitle=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_needupdate',className,classPath);
            diff=systemblock.generateShowDiffLink(classPath,diff);
        else
            if~isempty(diff)
                subTitle=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_updatefailed',className);
            else
                subTitle=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_uptodate',className,classPath);
            end
        end
        passed=passed&&~res;
        result{end+1}=generateCheckReport(subTitle,diff);
    end

    if passed
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    else
        mdladvObj.setActionEnable(true);
    end
end

function[template]=generateCheckReport(subTitle,diff)
    template=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(template,subTitle);
    if isempty(diff)
        setSubResultStatus(template,'Pass');
        setSubResultStatusText(template,DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_pass'));
    else
        setInformation(template,DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_title'));
        setSubResultStatus(template,'Warn');
        setSubResultStatusText(template,diff);
    end
end

function[template]=generateActionMessage(passedMessage,failedMessage)
    template=ModelAdvisor.FormatTemplate('ListTemplate');
    setSubResultStatus(template,'Pass');
    setSubTitle(template,DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_done'));
    msg='';
    if~isempty(failedMessage)
        setSubResultStatus(template,'Warn');
        setSubTitle(template,DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_warn'));
        for i=1:length(failedMessage)
            if~isempty(failedMessage{i})
                msg=[msg,failedMessage{i},'<br>'];
            end
        end
    end

    for i=1:length(passedMessage)
        if~isempty(passedMessage{i})
            msg=[msg,passedMessage{i},'<br>'];
        end
    end
    setSubResultStatusText(template,msg);
end







