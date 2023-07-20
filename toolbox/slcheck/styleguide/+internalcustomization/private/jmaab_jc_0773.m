function jmaab_jc_0773

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0773_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0773_b';


    rec=slcheck.Check('mathworks.jmaab.jc_0773',SubCheckCfg,{sg_maab_group,sg_jmaab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys...
    (system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Transition','-or',...
    '-isa','Stateflow.Junction'},true);
end