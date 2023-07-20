function jmaab_db_0097




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.db_0097_a';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.db_0097_b';

    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.db_0097_c';

    rec=slcheck.Check('mathworks.jmaab.db_0097',SubCheckCfg,{sg_maab_group,sg_jmaab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.setReportStyle('ModelAdvisor.Report.StandardStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.StandardStyle'});

    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)


    entities=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll',true,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'type','line');
    entities=num2cell(entities(arrayfun(@(x)~(Stateflow.SLUtils.isChildOfStateflowBlock(x)),entities)));
    serviceOptions.FollowLinks=FollowLinks;
    serviceOptions.LookUnderMasks=LookUnderMasks;

    slcheck.services.PositionalMapService.instance.init(system,serviceOptions);
end
