function jmaab_na_0010







    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.na_0010_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.na_0010_b';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.na_0010_c';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.na_0010_d';


    rec=slcheck.Check('mathworks.jmaab.na_0010',SubCheckCfg,{sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    rec.setDefaultInputParams();

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.register();

end

function ents=getRelevantEntity(system,FollowLinks,LookUnderMasks)



    ents=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'type','block');
    if~ismember(system,ents)
        ents{end+1}=system;
    end

end
