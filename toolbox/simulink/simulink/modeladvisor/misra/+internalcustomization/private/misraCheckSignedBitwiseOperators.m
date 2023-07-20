








function misraCheckSignedBitwiseOperators

    rec=ModelAdvisor.Check(...
    'mathworks.misra.CompliantCGIRConstructions');
    rec.Title=misraMessage('SignedBitwiseOperators','Title');
    rec.TitleTips=misraMessage('SignedBitwiseOperators','TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.CompliantCGIRConstructions';

    rec.setCallbackFcn(@checkCallback,'CGIR','StyleOne');

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.SignedBitwiseOperators(...
    SYSTEM,'RTW:misra:SignedBitwiseOperators_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

