function jmaab_jc_0760




    config.SFETMsgCataloguePrefix='jc_0760_a';
    config.checkID='mathworks.jmaab.jc_0760';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end
