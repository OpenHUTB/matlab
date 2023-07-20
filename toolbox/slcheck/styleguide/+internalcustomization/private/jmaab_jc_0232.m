function jmaab_jc_0232



    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(1).subcheck.InitParams.CheckName='jc_0232_a';
    SubCheckCfg(1).subcheck.InitParams.CompileMode='PostCompile';
    SubCheckCfg(1).subcheck.InitParams.RegValue='[^a-z_A-Z_0-9]';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(2).subcheck.InitParams.CheckName='jc_0232_b';
    SubCheckCfg(2).subcheck.InitParams.CompileMode='PostCompile';
    SubCheckCfg(2).subcheck.InitParams.RegValue='^[0-9]';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(3).subcheck.InitParams.CheckName='jc_0232_c';
    SubCheckCfg(3).subcheck.InitParams.CompileMode='PostCompile';
    SubCheckCfg(3).subcheck.InitParams.RegValue='^_';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(4).subcheck.InitParams.CheckName='jc_0232_d';
    SubCheckCfg(4).subcheck.InitParams.CompileMode='PostCompile';
    SubCheckCfg(4).subcheck.InitParams.RegValue='_$';
    SubCheckCfg(5).Type='Normal';
    SubCheckCfg(5).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(5).subcheck.InitParams.CheckName='jc_0232_e';
    SubCheckCfg(5).subcheck.InitParams.CompileMode='PostCompile';
    SubCheckCfg(5).subcheck.InitParams.RegValue='[_][_]';
    SubCheckCfg(6).Type='Normal';
    SubCheckCfg(6).subcheck.ID='slcheck.jmaab.IsAKeyWord';
    SubCheckCfg(6).subcheck.InitParams.CheckName='jc_0232_f';
    SubCheckCfg(6).subcheck.InitParams.CompileMode='PostCompile';


    rec=slcheck.Check('mathworks.jmaab.jc_0232',...
    SubCheckCfg,...
    {sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;
    rec.SupportLibrary=false;
    rec.relevantEntities=@getRelevantEntity;

    rec.setDefaultInputParams();
    rec.register();

end

function entities=getRelevantEntity(system,FollowLinks,LookUnderMasks)

    parameters=Advisor.Utils.Simulink.findVars(system,FollowLinks,LookUnderMasks,'SearchMethod','cached');
    users=arrayfun(@(x)Advisor.Utils.Naming.filterUsersInShippingLibraries(x.Users),parameters,'UniformOutput',false);
    users=arrayfun(@(x)~isempty(x{:}),users);
    entities=num2cell(parameters(users));
end