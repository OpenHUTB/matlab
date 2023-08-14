function jmaab_jc_0770

    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='jc_0770_a';
    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.subcheck_jc_0770';
    SubCheckCfg(1).subcheck(1).InitParams.Name='jc_0770_a1';
    SubCheckCfg(1).subcheck(1).InitParams.Position=0;
    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.subcheck_jc_0770';
    SubCheckCfg(1).subcheck(2).InitParams.Name='jc_0770_a2';
    SubCheckCfg(1).subcheck(2).InitParams.Position=1;

    rec=slcheck.Check('mathworks.jmaab.jc_0770',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{'-isa','Stateflow.Transition'},true);
    if iscell(entities)
        entities=entities(cellfun(@(x)~isa(getParent(x),'Stateflow.TruthTable'),entities));
    end
end
