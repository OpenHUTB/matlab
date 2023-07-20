









function misraCheckModelFunctionInterface
    checkID='mathworks.misra.ModelFunctionInterface';
    rec=ModelAdvisor.Check(checkID);
    rec.Title=DAStudio.message('RTW:misra:ModelFunctionInterface_Title');
    rec.TitleTips=DAStudio.message('RTW:misra:ModelFunctionInterface_TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=false;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.ModelFunctionInterface';
    rec.setCallbackFcn(@checkCallback,'PostCompile','StyleOne');
    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');
end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.ModelFunctionInterface(...
    SYSTEM,'RTW:misra:ModelFunctionInterface_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

