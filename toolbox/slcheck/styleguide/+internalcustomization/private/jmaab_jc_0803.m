function jmaab_jc_0803





    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='jc_0803_a';
    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(1).subcheck(1).InitParams.Name='jc_0803_a1';
    SubCheckCfg(1).subcheck(1).InitParams.Mode=11;
    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(1).subcheck(2).InitParams.Name='jc_0803_a2';
    SubCheckCfg(1).subcheck(2).InitParams.Mode=12;

    SubCheckCfg(2).Type='Group';
    SubCheckCfg(2).GroupName='jc_0803_b';
    SubCheckCfg(2).subcheck(1).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(2).subcheck(1).InitParams.Name='jc_0803_b1';
    SubCheckCfg(2).subcheck(1).InitParams.Mode=21;
    SubCheckCfg(2).subcheck(2).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(2).subcheck(2).InitParams.Name='jc_0803_b2';
    SubCheckCfg(2).subcheck(2).InitParams.Mode=22;

    SubCheckCfg(3).Type='Group';
    SubCheckCfg(3).GroupName='jc_0803_c';
    SubCheckCfg(3).subcheck(1).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(3).subcheck(1).InitParams.Name='jc_0803_c1';
    SubCheckCfg(3).subcheck(1).InitParams.Mode=31;
    SubCheckCfg(3).subcheck(2).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(3).subcheck(2).InitParams.Name='jc_0803_c2';
    SubCheckCfg(3).subcheck(2).InitParams.Mode=32;

    SubCheckCfg(4).Type='Group';
    SubCheckCfg(4).GroupName='jc_0803_d';
    SubCheckCfg(4).subcheck(1).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(4).subcheck(1).InitParams.Name='jc_0803_d1';
    SubCheckCfg(4).subcheck(1).InitParams.Mode=41;
    SubCheckCfg(4).subcheck(2).ID='slcheck.jmaab.jc_0803';
    SubCheckCfg(4).subcheck(2).InitParams.Name='jc_0803_d2';
    SubCheckCfg(4).subcheck(2).InitParams.Mode=42;


    rec=slcheck.Check('mathworks.jmaab.jc_0803',SubCheckCfg,{sg_maab_group,sg_jmaab_group});

    rec.relevantEntities=@getStateflowData;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();
end

function stateflowEntities=getStateflowData(system,FollowLinks,LookUnderMasks)
    stateflowEntities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Transition','-or','-isa','Stateflow.State'});
end