function[rec]=styleguide_jc_0081()










    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.maab.jc_0081','hasFix',true);
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc_0081_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:styleguide:jc_0081_guideline'),newline,newline,DAStudio.message('ModelAdvisor:styleguide:jc_0081_tip')];


    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0081Title';

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end



