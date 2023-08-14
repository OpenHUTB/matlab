function defineSLXFileCompressionCheck()




    ensureResaveCheck=ModelAdvisor.Check('mathworks.design.CheckSLXFileCompressionLevel');
    ensureResaveCheck.Title=DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:CheckTitle');
    ensureResaveCheck.TitleTips=DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:CheckTitleTips');
    ensureResaveCheck.setCallbackFcn(@checkCompression,'None','StyleOne');
    ensureResaveCheck.CSHParameters.MapKey='ma.simulink';
    ensureResaveCheck.CSHParameters.TopicID='UpgradeAdvisorSLXFileCompressionLevelCheck';

    ensureResaveCheck.Visible=true;
    ensureResaveCheck.Enable=true;
    ensureResaveCheck.Value=true;
    ensureResaveCheck.SupportLibrary=true;


    ensureResaveAction=ModelAdvisor.Action;
    ensureResaveAction.setCallbackFcn(@actionUpdateCompression);
    ensureResaveAction.Name=DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:Button');
    ensureResaveAction.Description=DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:Description');
    ensureResaveAction.Enable=false;
    ensureResaveCheck.setAction(ensureResaveAction);



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(ensureResaveCheck);

end


function b=savedInSLXFile(filepath)
    [~,~,e]=fileparts(filepath);
    b=strcmp(e,'.slx');
end

function b=underSourceControl(filepath)
    b=false;
    lastFolder=filepath;
    currentFolder=fileparts(filepath);
    while~b&&~strcmp(currentFolder,lastFolder)
        lastFolder=currentFolder;
        b=(exist(fullfile(currentFolder,'.git'),'dir')==7);
        currentFolder=fileparts(currentFolder);
    end
end


function results=checkCompression(system)
    model=bdroot(system);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');

    filepath=get_param(model,'FileName');
    if isempty(filepath)
        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:NotSavedMessage'));
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
        ft.setSubBar(0);
        results={ft};
        return
    end

    if~savedInSLXFile(filepath)
        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:NotInSLXFile'));
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    elseif~underSourceControl(filepath)
        ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:NotUnderSourceControl'));
        ft.setSubResultStatus('pass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    else
        [~,~,currentExtension]=fileparts(filepath);
        switch currentExtension
        case '.mdl'

            ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:MdlCanBeUpdatedLater'));
            ft.setSubResultStatus('warn');
            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setActionEnable(true);

        case '.slx'

            currentCompression=get_param(system,'SLXCompressionType');
            if strcmpi(currentCompression,'none')

                ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:NoCompression'));
                ft.setSubResultStatus('pass');
                mdladvObj.setCheckResultStatus(true);
                mdladvObj.setActionEnable(false);
            else

                ft.setSubResultStatusText(DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:SlxCanBeUpdated'));
                ft.setSubResultStatus('warn');
                mdladvObj.setCheckResultStatus(false);
                mdladvObj.setActionEnable(true);
            end

        otherwise
            DAStudio.error('SimulinkUpgradeAdvisor:slxCompressionCheck:UnrecognisedFileFormat',currentExtension)
        end
    end

    ft.setSubBar(0);
    results={ft};
end


function result=actionUpdateCompression(taskObj)
    result=ModelAdvisor.Paragraph();
    mdladvObj=taskObj.MAObj;
    modelName=get_param(bdroot(mdladvObj.System),'name');
    filepath=get_param(modelName,'FileName');
    [~,~,currentExtension]=fileparts(filepath);
    if strcmp(currentExtension,'.slx')
        set_param(modelName,'SLXCompressionType','none')
        msgStr=ModelAdvisor.Text(...
        DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:UpdatedSuccessfully'),...
        {'pass'});
    else
        msgStr=ModelAdvisor.Text(...
        DAStudio.message('SimulinkUpgradeAdvisor:slxCompressionCheck:StillMDL'),...
        {'pass'});
    end
    result.addItem(msgStr);
end

