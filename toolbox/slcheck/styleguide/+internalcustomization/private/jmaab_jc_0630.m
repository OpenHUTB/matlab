function jmaab_jc_0630

    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.jmaab.jc_0630');

    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0630_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0630_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0630_tip')];
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.jmaab.jc_0630';
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=false;
    rec.SupportsEditTime=true;
    rec.setLicense({styleguide_license});

    rec.CallbackContext='PostCompile';

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0630_a:',DAStudio.message('ModelAdvisor:jmaab:jc_0630_a_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0630_b:',DAStudio.message('ModelAdvisor:jmaab:jc_0630_b_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0630_c:',DAStudio.message('ModelAdvisor:jmaab:jc_0630_c_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[4,4];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[4,4];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([3,4]);
    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end