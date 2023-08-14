function refreshOpenInterfaceDictionary(cbinfo,action)




    import autosar.dictionary.internal.DictionaryLinkUtils


    modelName=SLStudio.Utils.getModelName(cbinfo);
    [isLinked,interfaceDicts]=...
    DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(modelName);
    action.enabled=isLinked&&(numel(interfaceDicts)==1);
