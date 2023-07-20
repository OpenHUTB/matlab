function smc=ConfigurationSet()





    smc=simmechanics.ConfigurationSet;


    configTree=simmechanics.sli.internal.getConfigParamTree();



    schemaVis=simmechanics.sli.internal.ConfigSetSchemaVisitor('simmechanics','SLConfigurationSetBase');
    schemaVis.generateSchema(configTree);


    smc.attachSubComponents();


    smc.attachPropertyListeners();


    smc.loadComponentDataModel();
