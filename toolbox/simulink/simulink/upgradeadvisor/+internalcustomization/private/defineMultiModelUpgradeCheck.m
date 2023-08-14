function defineMultiModelUpgradeCheck()





    check=ModelAdvisor.Check(UpgradeAdvisor.UPGRADE_HIERARCHY_ID);
    check.Title=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTaskTitle');
    check.setCallbackFcn(@i_CheckModelHierarchy,'None','StyleOne');
    check.TitleTips=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTaskTitle');
    check.Visible=true;
    check.Enable=true;
    check.Value=true;
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='UpgradeModelHierarchy';
    check.SupportLibrary=true;


    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@i_ActionAnalyzeNextModel);
    modifyAction.Name=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTaskModifyActionName');
    modifyAction.Description=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTaskModifyActionDesc');
    modifyAction.Enable=false;
    check.setAction(modifyAction);



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end


function results=i_CheckModelHierarchy(modelName)



    ft=ModelAdvisor.FormatTemplate('ListTemplate');


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
    mdladvObj.setCheckResultStatus(false);

    loopingStatus=UpgradeAdvisor.internal.LoopingStatus(modelName);

    if loopingStatus.isChildless

        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperNoChildren'));
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
        ft.setSubBar(0);
    end

    if~loopingStatus.isLooping


        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText([...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperEndOfLoop'),...
        loopingStatus.getHTMLReferenceTree]);
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    end

    if loopingStatus.isLooping
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperMoreChecks'));
        ft.setSubBar(0);

        html=[...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperRecActionChildren'),...
        loopingStatus.getHTMLReferenceTree,...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperStopLooping'),...
        '<a href="matlab:UpgradeAdvisor.UpgradeLooper.clearCurrentSession;"> ',...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperStopLoopingClick'),'</a>'...
        ];
        ft.setRecAction(html);
    end

    html=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperChildrenFoundIntroCompact');
    ft.setInformation(html);
    ft.setSubBar(0);
    results={ft};
end


function result=i_ActionAnalyzeNextModel(taskObj)

    result=ModelAdvisor.Paragraph();
    mdladvObj=taskObj.MAObj;

    modelName=get_param(bdroot(mdladvObj.System),'name');
    if~ischar(modelName)

        fileName=get_param(bdroot(mdladvObj.System),'filename');
        [~,modelName,~]=fileparts(fileName);
    end

    thisLoopingStatus=UpgradeAdvisor.internal.LoopingStatus(modelName);


    if~thisLoopingStatus.isNextSameModel&&bdIsDirty(modelName)
        question=DAStudio.message(...
        'SimulinkUpgradeAdvisor:tasks:LooperSaveBeforeContinueQuestion',...
        modelName);
        yes=DAStudio.message('Simulink:editor:DialogYes');
        no=DAStudio.message('Simulink:editor:DialogNo');
        title=...
        DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperSaveBeforeContinueTitle');
        response=questdlg(question,title,yes,no,yes);




        switch response
        case no


        case yes
            try
                save_system(modelName)
            catch E
                uiwait(errordlg(E.message,title,'modal'));
                return
            end
        end
    end





    ID='com.mathworks.Simulink.UpgradeAdvisor.UpgradeModelHierarchy';
    t=mdladvObj.getTaskObj(ID,'-type','CheckID');
    kk=0;
    while kk<numel(t)
        kk=kk+1;
        if~isempty(t{kk}.ParentObj)&&...
            strcmp(t{kk}.ParentObj.ID,...
            'com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor')

            t{kk}.reset;
            break
        end
    end


    thisLoopingStatus.openNextModelinSequence;

end
