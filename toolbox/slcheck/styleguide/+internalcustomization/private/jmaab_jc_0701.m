function jmaab_jc_0701

    SubChecksCfg(1).Type='Group';
    SubChecksCfg(1).GroupName='jc_0701';
    SubChecksCfg(1).subcheck(1).ID='slcheck.jmaab.jc_0701_subchecks';
    SubChecksCfg(1).subcheck(1).InitParams=struct('Name','jc_0701_a1','Index','0');
    SubChecksCfg(1).subcheck(2).ID='slcheck.jmaab.jc_0701_subchecks';
    SubChecksCfg(1).subcheck(2).InitParams=struct('Name','jc_0701_a2','Index','1');

    rec=slcheck.Check('mathworks.jmaab.jc_0701',SubChecksCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;
    rec.setDefaultInputParams();
    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.Data'},true);
end
