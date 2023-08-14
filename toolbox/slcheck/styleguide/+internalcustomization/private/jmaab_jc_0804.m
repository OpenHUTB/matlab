function jmaab_jc_0804

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0804_a';

    rec=slcheck.Check('mathworks.jmaab.jc_0804',SubCheckCfg,{sg_maab_group,sg_jmaab_group});
    rec.relevantEntities=@getRelevantBlocks;
    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.setRowSpan([2,2]);
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0804_input_param_calls_inside_graphical_function');
    inputParamList{end}.Type='Bool';
    inputParamList{end}.Value=true;
    inputParamList{end}.Visible=false;

    rec.setInputParametersLayoutGrid([3,4]);
    rec.setInputParameters(inputParamList);

    rec.setReportStyle('ModelAdvisor.Report.GroupStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.GroupStyle'});
    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end
function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Chart'},true);
end