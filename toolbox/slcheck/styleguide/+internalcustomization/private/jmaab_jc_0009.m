function jmaab_jc_0009




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0009_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0009_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0009',SubCheckCfg,{sg_maab_group,sg_jmaab_group});
    rec.SupportLibrary=false;
    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();
    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)



    blkList=find_system(system,'Regexp','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
    'Type','block','BlockType','SubSystem');

    blkList=Advisor.Utils.Naming.filterUsersInShippingLibraries(blkList);



    lineSegList=num2cell(find_system(system,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
    'Type','line'));
    entities=[blkList;lineSegList];
end
