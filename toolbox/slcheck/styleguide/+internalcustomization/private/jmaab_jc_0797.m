function jmaab_jc_0797

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0797_a';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0797_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0797',SubCheckCfg,{sg_maab_group,sg_jmaab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    [entities,charts]=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.Transition','-or','-isa','Stateflow.State','-or','-isa','Stateflow.Junction','-or','-isa','Stateflow.SimulinkBasedState'},true);
    cellfun(@(x)sf('CheckChartAtEditTime',x.Id),charts);
end