function openInterfaceDictionary(cbinfo)




    modelName=SLStudio.Utils.getModelName(cbinfo);
    Simulink.interface.dictionary.internal.SLModelUtils.showLinkedInterfaceDictionary(modelName);
