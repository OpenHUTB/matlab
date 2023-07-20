function rec=styleguide_db_0123





    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0123Title');
    rec.TitleID='mathworks.maab.db_0123';
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0123Tip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@db_0123_StyleOneCallback;
    rec.CallbackContext='PostCompile';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=false;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license,'Stateflow'};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0123Title';
    rec.SupportExclusion=true;
end

function ResultDescription=db_0123_StyleOneCallback(system)

    ResultDescription={};

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    xlateTagPrefix='ModelAdvisor:styleguide:';
    [bResult,aliasResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_SFPortNames(system,xlateTagPrefix);
    aliasResultDescription{end}.setSubBar(0);
    aliasResultDescription{end}.setSubTitle({''});
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': db_0123'];

    ResultDescription=[ResultDescription,aliasResultDescription];



    modelAdvisorObject.setCheckResultStatus(bResult);
end
