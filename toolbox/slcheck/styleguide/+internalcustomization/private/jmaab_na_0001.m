function jmaab_na_0001

    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.na_0001_a';

    SubChecksCfg(2).Type='Group';
    SubChecksCfg(2).GroupName='na_0001_b';

    SubChecksCfg(2).subcheck(1).ID='slcheck.jmaab.na_0001_b';
    SubChecksCfg(2).subcheck(1).InitParams=struct('Name','na_0001_b1','operator',{'!=','<>'});

    SubChecksCfg(2).subcheck(2).ID='slcheck.jmaab.na_0001_b';
    SubChecksCfg(2).subcheck(2).InitParams=struct('Name','na_0001_b2','operator',{'~=','<>'});

    SubChecksCfg(2).subcheck(3).ID='slcheck.jmaab.na_0001_b';
    SubChecksCfg(2).subcheck(3).InitParams=struct('Name','na_0001_b3','operator',{'!=','~='});

    SubChecksCfg(3).Type='Normal';
    SubChecksCfg(3).subcheck.ID='slcheck.jmaab.na_0001_c';

    rec=slcheck.Check('mathworks.jmaab.na_0001',SubChecksCfg,{sg_jmaab_group,sg_maab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function chartArray=getRelevantBlocks(system,FL,LUM)


    chartArray=Advisor.Utils.Stateflow.sfFindSys(system,FL,LUM,{'-isa','Stateflow.Chart'});

end