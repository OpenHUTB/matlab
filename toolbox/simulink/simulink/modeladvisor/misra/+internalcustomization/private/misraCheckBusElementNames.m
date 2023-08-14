









function misraCheckBusElementNames

    checkId='mathworks.misra.BusElementNames';

    rec=ModelAdvisor.Check(checkId);
    rec.Title=TEXT('Title');
    rec.TitleTips=TEXT('TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.SupportExclusion=false;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.BusElementNames';

    rec.setCallbackFcn(@checkCallback,'PostCompile','StyleOne');

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

function string=TEXT(id,varargin)
    prefix='RTW:misra:BusElementNames_';
    messageId=[prefix,id];
    string=DAStudio.message(messageId,varargin{:});
end

function RESULT=checkCallback(SYSTEM)
    checkObject=ModelAdvisor.Common.CodingStandards.BusElementNames(...
    SYSTEM,'RTW:misra:BusElementNames_');
    checkObject.algorithm();
    checkObject.report();
    checkObject.setCheckResultStatus();
    RESULT=checkObject.getReportObjects();
end

