function jmaab_jc_0775

    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='jc_0775_a';
    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.jc_0775_subCheck';
    SubCheckCfg(1).subcheck(1).InitParams.Name='jc_0775_a1';
    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.jc_0775_subCheck';
    SubCheckCfg(1).subcheck(2).InitParams.Name='jc_0775_a2';

    rec=slcheck.Check('mathworks.jmaab.jc_0775',SubCheckCfg,{sg_maab_group,sg_jmaab_group});
    rec.setReportStyle('ModelAdvisor.Report.TableStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});
    rec.relevantEntities=@getRelevantBlocks;
    rec.setDefaultInputParams();
    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,...
    FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Chart',...
    '-or','-isa','Stateflow.State',...
    '-or','-isa','Stateflow.AtomicBox',...
    '-or','-isa','Stateflow.AtomicSubchart',...
    '-or','-isa','Stateflow.SLFUnction',...
    '-or','-isa','Stateflow.Function',...
    '-or','-isa','Stateflow.Box'...
    });

end




