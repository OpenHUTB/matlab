












function jmaab_jc_0531

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0531_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0531_b';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.jc_0531_c';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.jc_0531_d';
    SubCheckCfg(5).Type='Normal';
    SubCheckCfg(5).subcheck.ID='slcheck.jmaab.jc_0531_e';
    SubCheckCfg(6).Type='Normal';
    SubCheckCfg(6).subcheck.ID='slcheck.jmaab.jc_0531_f';
    SubCheckCfg(7).Type='Normal';
    SubCheckCfg(7).subcheck.ID='slcheck.jmaab.jc_0531_g';

    rec=slcheck.Check('mathworks.jmaab.jc_0531',SubCheckCfg,{sg_jmaab_group,sg_maab_group});
    rec.relevantEntities=@getRelevantBlocks;
    rec.LicenseString={styleguide_license,'Stateflow'};

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.setDefaultInputParams();
    rec.register();
end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)

    entities=[{bdroot(system)};Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{...
    '-isa','Stateflow.Chart','-or',...
    '-isa','Stateflow.State'},true)];
end