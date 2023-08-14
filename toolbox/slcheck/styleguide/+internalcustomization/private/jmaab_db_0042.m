function jmaab_db_0042




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.IOPortPositionSubcheck';
    SubCheckCfg(1).subcheck.InitParams.Name='db_0042_a';
    SubCheckCfg(1).subcheck.InitParams.Mode='source';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.IOPortPositionSubcheck';
    SubCheckCfg(2).subcheck.InitParams.Name='db_0042_b';
    SubCheckCfg(2).subcheck.InitParams.Mode='sink';

    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.db_0042_c';

    rec=slcheck.Check('mathworks.jmaab.db_0042',SubCheckCfg,{sg_jmaab_group,sg_maab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)


    entities=num2cell(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll',true,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'Regexp','on','BlockType','Inport|Outport'));

    serviceOptions.FollowLinks=FollowLinks;
    serviceOptions.LookUnderMasks=LookUnderMasks;
    serviceOptions.BlocksOnly=false;

    slcheck.services.PositionalMapService.instance.init(system,serviceOptions);
end
