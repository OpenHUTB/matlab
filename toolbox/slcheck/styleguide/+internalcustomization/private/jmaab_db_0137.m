function jmaab_db_0137



    config.SFETMsgCataloguePrefix='db_0137_a';
    config.checkID='mathworks.jmaab.db_0137';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};
    config.inputParam='default';

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end

