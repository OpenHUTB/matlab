








function misraCheckCompareFloatEquality
    checkID='mathworks.misra.CompareFloatEquality';
    rec=ModelAdvisor.Check(checkID);
    rec.Title=DAStudio.message('RTW:misra:CompareFloatEquality_Title');
    rec.TitleTips=DAStudio.message('RTW:misra:CompareFloatEquality_TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.CompareFloatEquality';

    rec.setCallbackFcn(@checkCallback,'CGIR','StyleOne');

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.CompareFloatEquality(...
    SYSTEM,'RTW:misra:CompareFloatEquality_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

