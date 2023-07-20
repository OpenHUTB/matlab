function refreshCreateOrLinkToInterfaceDictionary(cbinfo,action)




    import autosar.dictionary.internal.DictionaryLinkUtils

    modelName=SLStudio.Utils.getModelName(cbinfo);


    action.enabled=~DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(modelName);
