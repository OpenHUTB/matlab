

function styleguide_na_0034()

    msgPrefix='ModelAdvisor:styleguide:';

    rec=ModelAdvisor.Check('mathworks.maab.na_0034');
    rec.Title=DAStudio.message([msgPrefix,'Himl0002_Title']);
    rec.TitleTips=DAStudio.message([msgPrefix,'Himl0002_TitleTips']);
    rec.SupportExclusion=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na_0034';
    rec.SupportLibrary=true;
    rec.Value=true;
    rec.setCallbackFcn(@execCheck,'None','StyleThree');

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function[resultDescription,resultHandles]=execCheck(system)

    msgPrefix='ModelAdvisor:styleguide:';
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    checkSize=true;
    [bResultStatus,resultDescription,resultHandles]=...
    ModelAdvisor.Common.modelAdvisorCheck_Mfb_StrongDataTyping(...
    system,checkSize,msgPrefix);

    mdladvObj.setCheckResultStatus(bResultStatus);

end

