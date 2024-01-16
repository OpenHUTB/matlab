function compMap=getInstrSetCompToBaseCodeMap(pluginMetaClasses)

    validateattributes(pluginMetaClasses,{'meta.class'},{'nonempty'});

    allPluginObjects=matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.constructPluginClasses(pluginMetaClasses);
    assert(isa(allPluginObjects,'matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase'),...
    'Expected the meta classes to be of the matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase type');
    compMap=allPluginObjects.getTpCompNameToBaseCodeMap();
end