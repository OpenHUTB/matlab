function jmaab_jc_0110
    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.jmaab.jc_0110');

    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0110_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0110_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0110_tip')];
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.jmaab.jc_0110';
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.setLicense({styleguide_license});


    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end