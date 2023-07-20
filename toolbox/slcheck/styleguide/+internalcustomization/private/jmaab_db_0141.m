function jmaab_db_0141

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.db_0141_a';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.db_0141_b';

    rec=slcheck.Check('mathworks.jmaab.db_0141',SubCheckCfg,{sg_jmaab_group,sg_maab_group});

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    serviceOptions.FollowLinks=FollowLinks;
    serviceOptions.LookUnderMasks=LookUnderMasks;

    slcheck.services.GraphService.getInstance.init(system,serviceOptions);

    entities=slcheck.services.GraphService.getCanvasSubsystems(system,FollowLinks,LookUnderMasks);
    entities=num2cell(unique([entities{:}]));
end