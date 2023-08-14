






function securityCheckCodeGenSettings()

    checkID='mathworks.security.CodeGenSettings';

    dataFile=fullfile(matlabroot,'toolbox','simulink','simulink',...
    'modeladvisor','security','+internalcustomization','private',...
    'securityCheckCodeGenSettings.xml');

    act=ModelAdvisor.Action;
    act.Name=securityText('CodeGenSettings_Action_Name');
    act.Description=securityText('CodeGenSettings_Action_Description');
    act.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));

    rec=ModelAdvisor.Check(checkID);
    rec.Title=securityText('CodeGenSettings_Title');
    rec.TitleTips=securityText('CodeGenSettings_TitleTips');
    rec.CSHParameters.MapKey=securityCshMapKey();
    rec.CSHParameters.TopicID='mathworks.security.CodeGenSettings';
    rec.Value=true;
    rec.HasANDLicenseComposition=false;
    rec.setCallbackFcn(@(system)(Advisor.authoring.CustomCheck.checkCallback(...
    system,dataFile)),'None','StyleOne');
    rec.setLicense([securityLicense(),{'Stateflow'}]);
    rec.setAction(act)

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

