function jmaab_jc_0711

    SubChecksCfg(1).Type='Group';
    SubChecksCfg(1).GroupName='jc_0711';
    SubChecksCfg(1).subcheck(1).ID='slcheck.jmaab.subcheck_jc_0711';
    SubChecksCfg(1).subcheck(1).InitParams=struct('Name','jc_0711_a1','Strict',true);
    SubChecksCfg(1).subcheck(2).ID='slcheck.jmaab.subcheck_jc_0711';
    SubChecksCfg(1).subcheck(2).InitParams=struct('Name','jc_0711_a2','Strict',false);


    rec=slcheck.Check('mathworks.jmaab.jc_0711',SubChecksCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{'-isa','Stateflow.Transition','-or',...
    '-isa','Stateflow.State'},true);
end