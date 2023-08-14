function jmaab_jc_0790




    config.MAMsgCataloguePrefix='jc_0790_a';
    config.SFETMsgCataloguePrefix={'jc_0790_a_charts','jc_0790_a_truthTable'};
    config.checkID='mathworks.jmaab.jc_0790';
    config.checkGroup={sg_maab_group,sg_jmaab_group};
    config.license={styleguide_license};

    CheckObj=ModelAdvisor.sfEdittimeCheck(config);
    CheckObj.register();

end
