function jmaab_jc_0231
    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.jmaab.jc_0231');

    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0231_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0231_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0231_tip')];
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.jmaab.jc_0231';
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.setLicense({styleguide_license});


    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0231_a:',DAStudio.message('ModelAdvisor:jmaab:jc_0231_a_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0231_b:',DAStudio.message('ModelAdvisor:jmaab:jc_0231_b_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0231_c:',DAStudio.message('ModelAdvisor:jmaab:jc_0231_c_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0231_d:',DAStudio.message('ModelAdvisor:jmaab:jc_0231_d_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[4,4];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0231_e:',DAStudio.message('ModelAdvisor:jmaab:jc_0231_e_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[5,5];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0231_f:',DAStudio.message('ModelAdvisor:jmaab:jc_0231_f_description')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[6,6];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[7,7];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[7,7];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([7,4]);
    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end