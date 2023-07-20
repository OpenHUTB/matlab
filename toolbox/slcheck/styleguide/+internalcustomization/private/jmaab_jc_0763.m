function jmaab_jc_0763

    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='jc_0763_a';
    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.jc_0763_a1';
    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.jc_0763_a2';

    rec=slcheck.Check('mathworks.jmaab.jc_0763',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.State'},true);
end
