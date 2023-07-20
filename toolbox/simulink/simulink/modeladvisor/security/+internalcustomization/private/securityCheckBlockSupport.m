
function securityCheckBlockSupport()

    checkId='mathworks.security.BlockSupport';

    rec=ModelAdvisor.internal.EdittimeCheck(checkId);
    rec.Title=securityText('BlockSupport_Title');
    rec.TitleTips=securityText('BlockSupport_TitleTips');
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.CSHParameters.MapKey=securityCshMapKey();
    rec.CSHParameters.TopicID='mathworks.security.BlockSupport';

    rec.setLicense(securityLicense());
    rec.HasANDLicenseComposition=false;
    rec.SupportsEditTime=true;

    rec.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

