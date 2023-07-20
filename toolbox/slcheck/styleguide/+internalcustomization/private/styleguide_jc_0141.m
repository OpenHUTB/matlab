function styleguide_jc_0141()

    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.maab.jc_0141');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc_0141_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:jc_0141_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:jc_0141_tip')];


    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=false;
    rec.SupportsEditTime=true;
    rec.CallbackContext='PostCompile';
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0141Title';

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,4]);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end
