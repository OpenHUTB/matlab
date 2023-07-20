function jmaab_jc_0723




    config.SFETMsgCataloguePrefix='jc_0723_a';
    config.checkID='mathworks.jmaab.jc_0723';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end
