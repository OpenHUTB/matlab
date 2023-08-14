function jmaab_jc_0602




    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.jc_0602_a';

    rec=slcheck.Check('mathworks.jmaab.jc_0602',SubChecksCfg,{sg_maab_group,sg_jmaab_group});
    rec.relevantEntities=@getRelevantBlocks;

    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.ColSpan=[1,2];
    entries={DAStudio.message('ModelAdvisor:jmaab:jc_0602_prefix'),DAStudio.message('ModelAdvisor:jmaab:jc_0602_suffix')};
    paramBlkCombination=Advisor.Utils.getInputParam_Enum('ModelAdvisor:jmaab:jc_0602_consistent_naming',[2,2],[1,2],entries);

    paramInConsistencyTag=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:jc_0602_in_consistency_tag',[3,3],[1,2],DAStudio.message('ModelAdvisor:jmaab:jc_0602_in_consistency_tag_default'));
    paramInConsistencyTag.Enable=true;

    paramOutConsistencyTag=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:jc_0602_out_consistency_tag',[4,4],[1,2],DAStudio.message('ModelAdvisor:jmaab:jc_0602_out_consistency_tag_default'));
    paramOutConsistencyTag.Enable=true;

    rec.setInputParametersLayoutGrid([4,1]);
    rec.setInputParameters({paramLookUnderMasks,paramBlkCombination,paramInConsistencyTag,paramOutConsistencyTag});

    rec.LicenseString=styleguide_license;
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});
    rec.register();

end

function entities=getRelevantBlocks(system,~,LookUnderMasks)


    entities=num2cell(find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on',...
    'FollowLinks','off',...
    'LookUnderMasks',LookUnderMasks,...
    'Type','line',...
    'SegmentType','trunk'));
end
