function jmaab_jc_0501



















    config.SFETMsgCataloguePrefix='jc_0501_a';
    config.checkID='mathworks.jmaab.jc_0501';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end
