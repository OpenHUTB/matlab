function rec=styleguide_db_0142()




    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.maab.db_0142');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db_0142_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:db_0142_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:db_0142_tip')];


    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0142Title';

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end
