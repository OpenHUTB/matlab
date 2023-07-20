function customizationSimulinkRequirements()




    cm=DAStudio.CustomizationManager;
    if dig.isProductInstalled('Requirements Toolbox')

        cm.addModelAdvisorCheckFcn(@defineModelAdvisorChecks);
        cm.addModelAdvisorTaskFcn(@defineModelAdvisorTasks);
    end
end

function taskCellArray=defineModelAdvisorTasks

    taskCellArray={};

    task=Simulink.MdlAdvisorTask;
    task.Title=DAStudio.message('Slvnv:consistency:taskTitle');
    task.TitleID='Requirement consistency checking';
    task.TitleTips=DAStudio.message('Slvnv:consistency:taskTips');
    task.CheckTitleIDs={...
'mathworks.req.Documents'...
    ,'mathworks.req.Identifiers'...
    ,'mathworks.req.Labels'...
    ,'mathworks.req.Paths'...
    };
    if ispc&&rmi.settings_mgr('get','isDoorsSetup')
        task.CheckTitleIDs{end+1}='mathworks.req.Doors';
    end
    taskCellArray{end+1}=task;
end

function defineModelAdvisorChecks

    recordCellArray={};


    rec=ModelAdvisor.Check('mathworks.req.Documents');
    rec.Title=DAStudio.message('Slvnv:consistency:checkDocumentTitle');
    rec.TitleTips=DAStudio.message('Slvnv:consistency:checkDocumentTips');
    rec.CSHParameters.MapKey='ma.reqconsistency';
    rec.CSHParameters.TopicID='checkDocumentTitle';
    rec.CallbackHandle=@rmicheck.rmicheckdoc;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.PreCallbackHandle=@rmicheck.rmicheckdoc_pre;
    rec.PostCallbackHandle=@rmicheck.rmicheck_post;
    rec.SupportExclusion=true;
    rec.LicenseName={'Simulink_Requirements'};
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('mathworks.req.Identifiers');
    rec.Title=DAStudio.message('Slvnv:consistency:checkIdTitle');
    rec.TitleTips=DAStudio.message('Slvnv:consistency:checkIdTips');
    rec.CSHParameters.MapKey='ma.reqconsistency';
    rec.CSHParameters.TopicID='checkIdTitle';
    rec.CallbackHandle=@rmicheck.rmicheckid;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.PreCallbackHandle=@rmicheck.rmicheckitem_pre;
    rec.PostCallbackHandle=@rmicheck.rmicheck_post;
    rec.SupportExclusion=true;
    rec.LicenseName={'Simulink_Requirements'};
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('mathworks.req.Labels');
    rec.Title=DAStudio.message('Slvnv:consistency:checkLabelTitle');
    rec.TitleTips=DAStudio.message('Slvnv:consistency:checkLabelTips');
    rec.CSHParameters.MapKey='ma.reqconsistency';
    rec.CSHParameters.TopicID='checkLabelTitle';
    rec.CallbackHandle=@rmicheck.rmichecklabel;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.PreCallbackHandle=@rmicheck.rmicheckitem_pre;
    rec.PostCallbackHandle=@rmicheck.rmicheck_post;
    rec.SupportExclusion=true;
    rec.LicenseName={'Simulink_Requirements'};
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('mathworks.req.Paths');
    if ispc
        rec.Title=DAStudio.message('Slvnv:consistency:checkPathTitle');
        rec.TitleTips=DAStudio.message('Slvnv:consistency:checkPathTips');
    else
        rec.Title=DAStudio.message('Slvnv:consistency:checkPathTitleNonPC');
        rec.TitleTips=DAStudio.message('Slvnv:consistency:checkPathTipsNonPC');
    end
    rec.CSHParameters.MapKey='ma.reqconsistency';
    rec.CSHParameters.TopicID='checkPathTitle';
    rec.CallbackHandle=@rmicheck.rmicheckpath;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.SupportExclusion=true;
    rec.LicenseName={'Simulink_Requirements'};
    recordCellArray{end+1}=rec;

    if ispc&&rmi.settings_mgr('get','isDoorsSetup')

        rec=ModelAdvisor.Check('mathworks.req.Doors');
        rec.Title=DAStudio.message('Slvnv:consistency:checkDoorsTitle');
        rec.TitleTips=DAStudio.message('Slvnv:consistency:checkDoorsTips');
        rec.CSHParameters.MapKey='ma.reqconsistency';
        rec.CSHParameters.TopicID='checkDoorsTitle';
        rec.CallbackHandle=@rmidoors.maCheck;
        rec.CallbackContext='None';
        rec.CallbackStyle='StyleThree';
        rec.PreCallbackHandle=@rmicheck.rmicheckdoc_pre;
        rec.PostCallbackHandle=@rmicheck.rmicheck_post;
        rec.SupportExclusion=true;
        rec.LicenseName={'Simulink_Requirements'};
        recordCellArray{end+1}=rec;
        includeDoors=true;
    else
        includeDoors=false;
    end


    Group=sprintf('%s|%s','Requirements Toolbox',DAStudio.message('Slvnv:consistency:groupEntry'));
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(recordCellArray{1},Group);
    mdladvRoot.publish(recordCellArray{2},Group);
    mdladvRoot.publish(recordCellArray{3},Group);
    mdladvRoot.publish(recordCellArray{4},Group);
    if includeDoors
        mdladvRoot.publish(recordCellArray{5},Group);
    end
end



