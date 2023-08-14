function jmaab_jc_0795



    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(1).subcheck.InitParams.CheckName='jc_0795_a';
    SubCheckCfg(1).subcheck.InitParams.RegValue='^_';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(2).subcheck.InitParams.CheckName='jc_0795_b';
    SubCheckCfg(2).subcheck.InitParams.RegValue='_$';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(3).subcheck.InitParams.CheckName='jc_0795_c';
    SubCheckCfg(3).subcheck.InitParams.RegValue='[_][_]';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.IsAKeyWord';
    SubCheckCfg(4).subcheck.InitParams.CheckName='jc_0795_d';


    rec=slcheck.Check('mathworks.jmaab.jc_0795',...
    SubCheckCfg,{sg_jmaab_group,sg_maab_group});

    rec.LicenseString={styleguide_license,'Stateflow'};

    rec.relevantEntities=@getRelevantEntity;

    rec.setDefaultInputParams();
    rec.register();

end

function entities=getRelevantEntity(system,FollowLinks,LookUnderMasks)


    allSFData=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{'-isa','Stateflow.Data'},false);

    systemObj=get_param(bdroot(system),'object');

    allSfObjs=systemObj.find('-isa','Stateflow.Data','SSIdNumber',0);


    entities=num2cell(unique([cell2mat(allSFData);allSfObjs]));
end