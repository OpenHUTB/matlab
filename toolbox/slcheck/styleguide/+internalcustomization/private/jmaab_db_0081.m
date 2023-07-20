function jmaab_db_0081




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.db_0081_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.db_0081_b';

    rec=slcheck.Check('mathworks.jmaab.db_0081',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();
    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)



    entities=num2cell(find_system(system,'FindAll','on','Regexp','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
    'type','block|line'));
end
