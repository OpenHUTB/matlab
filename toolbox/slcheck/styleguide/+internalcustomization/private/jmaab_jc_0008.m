function jmaab_jc_0008

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jc_0008',false,@ModelAdvisor.internal.checkSignalLabels,'None');

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:engine:Standard');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Value='JMAAB 5.0';
    inputParamList{end}.Entries={'JMAAB 5.0','Custom'};
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[2,10];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0008_input_param1');
    inputParamList{end}.Type='BlockType';
    inputParamList{end}.Value=ModelAdvisor.Common.getDefaultBlockList_na_0008_output;
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[2,10];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0008_input_param2');
    inputParamList{end}.Type='BlockType';
    inputParamList{end}.Value=ModelAdvisor.Common.getDefaultBlockList_na_0008_input;
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=false;

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[11,11];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[11,11];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([11,4]);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@ModelAdvisor.Common.blkTypeList_MAAB_InputParamCB);

    rec.setLicense({styleguide_license});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

