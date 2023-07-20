








function misraCheckSwitchDefault
    rec=ModelAdvisor.Check(...
    'mathworks.misra.SwitchDefault');
    rec.Title=TEXT('SwitchDefault_Title');
    rec.TitleTips=TEXT('SwitchDefault_TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.SwitchDefault';
    rec.setCallbackFcn(@checkCallback,'None','StyleOne');
    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;
    rec.SupportsEditTime=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');
end

function string=TEXT(ID)
    string=DAStudio.message(['RTW:misra:',ID]);
end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.SwitchDefault(...
    SYSTEM,'RTW:misra:SwitchDefault_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

