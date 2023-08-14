function jmaab_jc_0774

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0774_a';


    rec=slcheck.Check('mathworks.jmaab.jc_0774',SubCheckCfg,{sg_maab_group,sg_jmaab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys...
    (system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Transition'},true);
end