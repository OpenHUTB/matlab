function jmaab_jc_0627




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0627_a';
    SubCheckCfg(1).subcheck.InitParams.CheckName='jc_0627_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0627_b';
    SubCheckCfg(2).subcheck.InitParams.CheckName='jc_0627_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0627',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});
    rec.setDefaultInputParams();
    rec.LicenseString={styleguide_license};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)


    entities=find_system(system,'FollowLinks',FollowLinks,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks,'BlockType','DiscreteIntegrator');
end
