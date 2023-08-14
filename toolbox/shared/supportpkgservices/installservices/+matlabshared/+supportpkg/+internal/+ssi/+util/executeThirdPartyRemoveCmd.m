function executeThirdPartyRemoveCmd(spBaseCode)















    allPluginMetaClasses=matlabshared.supportpkg.internal.findAllRegistryPlugins;
    if isempty(allPluginMetaClasses)
        return;
    end

    pluginMetaClass=matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.findSpPkgPluginForBaseCode(spBaseCode,allPluginMetaClasses);
    if isempty(pluginMetaClass)
        return;
    end

    pluginObj=matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase.constructPluginClasses(pluginMetaClass);

    compNamesFromPlugin=pluginObj.getTpCompNames();


    baseCodesMap=matlabshared.supportpkg.internal.ssi.util.getInstrSetCompToBaseCodeMap(allPluginMetaClasses);
    for i=1:numel(compNamesFromPlugin)




        compName=compNamesFromPlugin{i};
        if(numel(baseCodesMap(compName))>1)



            continue;
        end
        assert(strcmp(baseCodesMap(compName),spBaseCode),...
        'The 3p component to basecode map returned by getInstrSetCompToBaseCodeMap is not correct');
        try
            fcnHandle=pluginObj.getRemoveCmdForComponent(compName);
            if~isempty(fcnHandle)
                fcnHandle();
            end
        catch ex


            warning(message('supportpkgservices:installservices:ExecuteRemoveCmdError',spBaseCode,ex.message));
        end

    end
end