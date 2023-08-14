function jmaab_db_0125

    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.db_0125_subCheck';
    SubChecksCfg(1).subcheck.InitParams.Name='db_0125_a';

    SubChecksCfg(2).Type='Normal';
    SubChecksCfg(2).subcheck.ID='slcheck.jmaab.db_0125_subCheck';
    SubChecksCfg(2).subcheck.InitParams.Name='db_0125_b';

    SubChecksCfg(3).Type='Normal';
    SubChecksCfg(3).subcheck.ID='slcheck.jmaab.db_0125_subCheck';
    SubChecksCfg(3).subcheck.InitParams.Name='db_0125_c';

    SubChecksCfg(4).Type='Normal';
    SubChecksCfg(4).subcheck.ID='slcheck.jmaab.db_0125_d';
    SubChecksCfg(4).subcheck.InitParams.Name='db_0125_d';

    rec=slcheck.Check('mathworks.jmaab.db_0125',SubChecksCfg,{sg_jmaab_group,sg_maab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams(true);
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    rec.LicenseString={styleguide_license};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    m=get_param(bdroot(system),'Object');

    machine=m.find('-isa','Stateflow.Machine');

    entities1=[];
    if~isempty(machine)


        entities1=num2cell(machine.find('-isa','Stateflow.Data',...
        '-depth',1));
    end

    entities2=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{'-isa','Stateflow.Chart','-or','-isa','Stateflow.StateTransitionTableChart'});

    entities=[entities1;entities2];
end
