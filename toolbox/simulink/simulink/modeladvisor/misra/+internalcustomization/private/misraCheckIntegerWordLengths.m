








function misraCheckIntegerWordLengths
    rec=ModelAdvisor.Check('mathworks.misra.IntegerWordLengths');
    rec.Title=DAStudio.message('RTW:misra:IntegerWordLengths_Title');
    rec.TitleTips=DAStudio.message('RTW:misra:IntegerWordLengths_TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.IntegerWordLengths';
    rec.setCallbackFcn(@checkCallback,'CGIR','StyleOne');
    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');
end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.IntegerWordLengths(...
    SYSTEM,'RTW:misra:IntegerWordLengths_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

