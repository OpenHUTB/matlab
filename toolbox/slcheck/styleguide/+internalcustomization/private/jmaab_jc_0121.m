function jmaab_jc_0121











    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0121_a';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0121_b';

    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.jc_0121_c';

    rec=slcheck.Check('mathworks.jmaab.jc_0121',SubCheckCfg,{sg_jmaab_group,sg_maab_group});

    rec.relevantEntities=@getRelevantBlocks;
    rec.setDefaultInputParams();
    rec.LicenseString=styleguide_license;
    rec.register();
end

function sumBlocks=getRelevantBlocks(system,FollowLinks,LookUnderMasks)


    sumBlocks=num2cell(find_system(get_param(system,'handle'),...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
    'BlockType','Sum'));

    serviceOptions.FollowLinks=FollowLinks;
    serviceOptions.LookUnderMasks=LookUnderMasks;
    slcheck.services.GraphService.getInstance.init(system,serviceOptions);
end
