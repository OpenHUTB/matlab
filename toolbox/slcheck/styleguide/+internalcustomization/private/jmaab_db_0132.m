function jmaab_db_0132




    config.SubCheckCfg(1).Type='Normal';
    config.SubCheckCfg(1).subcheck.ID='slcheck.SFEditTimeCheck';
    config.SubCheckCfg(1).subcheck.InitParams.SFETMsgCataloguePrefix='db_0132_a';
    config.SubCheckCfg(1).subcheck.InitParams.MAMsgCataloguePrefix='db_0132_a';

    config.SubCheckCfg(2).Type='Normal';
    config.SubCheckCfg(2).subcheck.ID='slcheck.SFEditTimeCheck';
    config.SubCheckCfg(2).subcheck.InitParams.SFETMsgCataloguePrefix={'db_0132_b_ConditionType',...
    'db_0132_b_ConditionActionType',...
    'db_0132_b_ConditionActionCombinationType'};
    config.SubCheckCfg(2).subcheck.InitParams.MAMsgCataloguePrefix='db_0132_b';

    config.checkID='mathworks.jmaab.db_0132';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end
