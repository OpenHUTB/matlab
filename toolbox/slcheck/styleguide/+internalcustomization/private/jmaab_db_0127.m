function jmaab_db_0127



    config.SubCheckCfg(1).Type='Group';
    config.SubCheckCfg(1).GroupName='db_0127_a';

    config.SubCheckCfg(1).subcheck(1).ID='slcheck.SFEditTimeCheck';
    config.SubCheckCfg(1).subcheck(1).InitParams.SFETMsgCataloguePrefix='db_0127_a1';
    config.SubCheckCfg(1).subcheck(1).InitParams.MAMsgCataloguePrefix='db_0127_a1';
    config.SubCheckCfg(1).subcheck(1).InitParams.Strict='1';


    config.SubCheckCfg(1).subcheck(2).ID='slcheck.SFEditTimeCheck';
    config.SubCheckCfg(1).subcheck(2).InitParams.SFETMsgCataloguePrefix='db_0127_a2';
    config.SubCheckCfg(1).subcheck(2).InitParams.MAMsgCataloguePrefix='db_0127_a2';
    config.SubCheckCfg(1).subcheck(2).InitParams.Strict='0';

    config.checkID='mathworks.jmaab.db_0127';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    CheckObj.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});
    CheckObj.register();
end

