
function misraCodeGenSettings















































    dataFilePath=[matlabroot,filesep,'toolbox',filesep,...
    'simulink',filesep,'simulink',filesep,'modeladvisor',filesep,...
    'misra',filesep,'+internalcustomization',filesep,...
    'private',filesep];

    rec=ModelAdvisor.Check('mathworks.misra.CodeGenSettings');
    rec.Title=DAStudio.message('RTW:misra:misraCodeGenSettingsMATitle');
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.codegensettings';



    rec.setCallbackFcn(@(system,CheckObj,xmlfile)Advisor.authoring.CustomCheck.newStyleCheckCallback(system,CheckObj,[dataFilePath,'misraCodeGenSettings.xml']),'None','DetailStyle');
    rec.setReportCallbackFcn(@Advisor.authoring.CustomCheck.newStyleReportCallback);
    rec.TitleTips=DAStudio.message('RTW:misra:misraCodeGenSettingsMATip');
    rec.Value=true;

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    act=ModelAdvisor.Action;
    act.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));
    act.Name=DAStudio.message('RTW:misra:ModifySettings');
    act.Description=DAStudio.message('RTW:misra:CodeGenSettingsModifyTip');
    rec.setAction(act)

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

