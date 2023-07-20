function setEndToEndProtectionMethodToProtectionWrapper(modelName)




    mapObj=autosar.api.getSimulinkMapping(modelName);
    mapObj.setDataDefaults('InportsOutports','EndToEndProtectionMethod','ProtectionWrapper');
