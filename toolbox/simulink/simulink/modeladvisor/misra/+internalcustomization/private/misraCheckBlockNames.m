function misraCheckBlockNames

    checkId='mathworks.misra.BlockNames';

    rec=ModelAdvisor.internal.EdittimeCheck(checkId);
    rec.Title=DAStudio.message('RTW:misra:BlockNames_Title');
    rec.TitleTips=DAStudio.message('RTW:misra:BlockNames_TitleTips');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.BlockNames';
    rec.SupportsEditTime=true;

    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');

end

