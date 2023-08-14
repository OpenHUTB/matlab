function jmaab_jc_0802









    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.sfImplicitTypeCasting';
    SubCheckCfg(1).subcheck.InitParams.Name='jc_0802_a';

    rec=slcheck.Check('mathworks.jmaab.jc_0802',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(...
    system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
end