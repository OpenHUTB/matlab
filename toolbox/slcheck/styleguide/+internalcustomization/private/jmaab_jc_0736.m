function jmaab_jc_0736

    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.jc_0736_a';
    SubChecksCfg(2).Type='Normal';
    SubChecksCfg(2).subcheck.ID='slcheck.jmaab.jc_0736_b';
    SubChecksCfg(3).Type='Normal';
    SubChecksCfg(3).subcheck.ID='slcheck.jmaab.jc_0736_c';

    rec=slcheck.Check('mathworks.jmaab.jc_0736',SubChecksCfg,{sg_maab_group,sg_jmaab_group});
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.relevantEntities=@getRelevantBlocks;

    inputParamList=rec.setDefaultInputParams(false);





    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');

    inputParamList{end}.RowSpan=[4,4];


    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[4,4];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.setRowSpan([5,5]);
    inputParamList{end}.setColSpan([1,2]);
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0736_InputMessage');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='1';
    inputParamList{end}.Visible=false;
    rec.setInputParameters(inputParamList);

    rec.LicenseString={styleguide_license,'Stateflow'};

    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)

    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.State'...
    ,'-or','-isa','Stateflow.Transition'},true);
end


