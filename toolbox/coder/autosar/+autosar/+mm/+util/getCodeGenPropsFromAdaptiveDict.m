function[portNameVec,interfaceNameVec,namespaceVec,instanceIdentifierVec,...
    instanceSpecifierVec,serviceDiscoveryModeVec,identifyServiceInstanceSetting]=...
    getCodeGenPropsFromAdaptiveDict(modelH)















    portNameVec=autosar.mm.util.PortToInterfaceNamespaceHelper.getMappedARServicePortNames(modelH);
    [interfaceNameVec,namespaceVec]=...
    autosar.mm.util.PortToInterfaceNamespaceHelper.getInterfaceNamesAndNamespacesForPortNames(modelH,portNameVec);
    modelName=get_param(modelH,'Name');
    dirtiness=get_param(modelName,'Dirty');
    autosar.internal.adaptive.manifest.ManifestUtilities.syncManifestMetaModelWithAutosarDictionary(modelName);
    set_param(modelName,'Dirty',dirtiness);
    [instanceIdentifierVec,instanceSpecifierVec,identifyServiceInstanceSetting]=...
    autosar.internal.adaptive.manifest.ManifestUtilities.getManifestAttributes(modelH,portNameVec);
    serviceDiscoveryModeVec=autosar.mm.util.ServiceDiscoveryUtils.getServiceDiscoveryModeForPortVec(modelH,portNameVec);
end


