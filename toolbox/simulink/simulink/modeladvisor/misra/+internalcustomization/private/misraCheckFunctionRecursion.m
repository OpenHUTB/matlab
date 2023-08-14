








function misraCheckFunctionRecursion

    rec=ModelAdvisor.Check(...
    'mathworks.misra.RecursionCompliance');
    rec.Title=misraMessage('FunctionRecursion','Title');
    rec.TitleTips=misraMessage('FunctionRecursion','TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.RecursionCompliance';

    rec.setCallbackFcn(@checkCallback,'CGIR','StyleOne');

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.FunctionRecursion(...
    SYSTEM,'RTW:misra:FunctionRecursion_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

