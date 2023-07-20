function jmaab_jc_0626




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0626_a';
    SubCheckCfg(1).subcheck.InitParams.CheckName='jc_0626_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0626_b';
    SubCheckCfg(2).subcheck.InitParams.CheckName='jc_0626_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0626',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});
    rec.setDefaultInputParams();
    rec.LicenseString={styleguide_license};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)



    lookupTableList=find_system(system,'FollowLinks',FollowLinks,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks,'BlockType','Lookup_n-D');



    dynamicLookUpTableList=find_system(system,'FollowLinks',FollowLinks,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks,'BlockType','S-Function',...
    'MaskType','Lookup Table Dynamic');
    entities=[lookupTableList;dynamicLookUpTableList];
end
