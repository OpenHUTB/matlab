

function styleguide_na_0024()

    msgGroup='ModelAdvisor:styleguide:';

    rec=ModelAdvisor.Check('mathworks.maab.na_0024');
    rec.Title=DAStudio.message([msgGroup,'Himl0005_Title']);
    rec.TitleTips=DAStudio.message([msgGroup,'Himl0005_TitleTips']);
    rec.SupportExclusion=false;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0024';
    rec.SupportLibrary=true;
    rec.Value=true;
    rec.setCallbackFcn(@execCheck,'none','StyleThree');

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function[resultDescription,resultHandles]=execCheck(system)

    msgGroup='ModelAdvisor:styleguide:';
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    checkParameter.xlateTagPrefix=msgGroup;

    [bResultStatus,resultDescription,resultHandles]=...
    ModelAdvisor.Common.modelAdvisorCheck_Mfb_GlobalVariables(...
    system,checkParameter);

    mdladvObj.setCheckResultStatus(bResultStatus);

end

