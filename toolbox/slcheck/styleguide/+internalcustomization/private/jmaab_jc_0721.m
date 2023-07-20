function jmaab_jc_0721




    config.SFETMsgCataloguePrefix='jc_0721_a';
    config.checkID='mathworks.jmaab.jc_0721';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end
