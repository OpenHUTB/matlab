function jmaab_jc_0702

    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.jc_0702_a';


    rec=slcheck.Check('mathworks.jmaab.jc_0702',SubChecksCfg,{sg_maab_group,sg_jmaab_group});
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.Transition','-or','-isa','Stateflow.State'},true);
end