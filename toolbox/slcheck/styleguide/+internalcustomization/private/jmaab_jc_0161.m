function jmaab_jc_0161






    subchecks(1).Type='Normal';
    subchecks(1).subcheck.ID='slcheck.jmaab.jc_0161_a';
    subchecks(2).Type='Normal';
    subchecks(2).subcheck.ID='slcheck.jmaab.jc_0161_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0161',...
    subchecks,...
    {sg_maab_group,sg_jmaab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    rec.setDefaultInputParams();
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    rec.register();

end

function dataStoreBlocks=getRelevantEntity(system,FL,LUM)


    dataStoreBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FL,'LookUnderMasks',LUM,'regexp','on','BlockType','DataStoreMemory');
end
