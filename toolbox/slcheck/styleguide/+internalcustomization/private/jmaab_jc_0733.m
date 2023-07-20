function jmaab_jc_0733

    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.jc_0733_a';
    SubChecksCfg(2).Type='Normal';
    SubChecksCfg(2).subcheck.ID='slcheck.jmaab.jc_0733_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0733',SubChecksCfg,{sg_maab_group,sg_jmaab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FL,LUM)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FL,LUM,{'-isa','Stateflow.State'},true);
end