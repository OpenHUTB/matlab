function jmaab_jc_0624






    subchecks(1).Type='Normal';
    subchecks(1).subcheck.ID='slcheck.jmaab.jc_0624_a';
    subchecks(2).Type='Normal';
    subchecks(2).subcheck.ID='slcheck.jmaab.jc_0624_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0624',...
    subchecks,...
    {sg_maab_group,sg_jmaab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    rec.setDefaultInputParams();
    rec.setReportStyle('ModelAdvisor.Report.GroupStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.GroupStyle'});

    rec.register();

end

function ents=getRelevantEntity(system,FL,LUM)



    ents=get_param(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FL,'LookUnderMasks',LUM,'BlockType','SubSystem','MaskType',''),'handle');
    sysHandle=get_param(system,'handle');


    if isempty(ents)||~ismember(sysHandle,cell2mat(ents))
        ents=[ents;sysHandle];
    end
end
