function wrapperObj=getWrapperForArchElement(zcID,modelName)





    if Simulink.internal.isArchitectureModel(modelName,'Architecture')
        archElement=sysarch.resolveZCElement(zcID,modelName);
        wrapperObj=systemcomposer.internal.getWrapperForImpl(archElement);
    elseif Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture')
        archElement=sysarch.resolveZCElement(zcID,modelName);
        slHdl=systemcomposer.utils.getSimulinkPeer(archElement);

        wrapperObj=autosar.arch.Utils.getArchElementForSlHandle(slHdl(1));
    end