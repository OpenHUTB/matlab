function jmaab_jc_0753

    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='jmaab_jc_0753_a';
    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.subcheck_jc_0753';
    SubCheckCfg(1).subcheck(1).InitParams.Name='jc_0753_a1';
    SubCheckCfg(1).subcheck(1).InitParams.Strict=1;
    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.subcheck_jc_0753';
    SubCheckCfg(1).subcheck(2).InitParams.Name='jc_0753_a2';
    SubCheckCfg(1).subcheck(2).InitParams.Strict=0;

    rec=slcheck.Check('mathworks.jmaab.jc_0753',SubCheckCfg,{sg_maab_group,sg_jmaab_group});
    rec.relevantEntities=@getRelevantBlocks;
    rec.setDefaultInputParams();

    rec.setReportStyle('ModelAdvisor.Report.TableStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{'-isa','Stateflow.Chart','-or',...
    '-isa','Stateflow.Transition'},true);
end
