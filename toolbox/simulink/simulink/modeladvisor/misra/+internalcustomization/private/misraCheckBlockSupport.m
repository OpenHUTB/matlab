function misraCheckBlockSupport
    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.misra.BlkSupport');
    rec.Title=DAStudio.message('RTW:misra:BlockSupport_Title');
    rec.TitleTips=DAStudio.message('RTW:misra:BlockSupport_TitleTips');
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.BlkSupport';

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;
    rec.SupportsEditTime=true;

    rec.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});


    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');
end
