function title=getExplorerTitle(modelName)



    explorerName=[' ',modelName];
    if autosar.api.Utils.autosarlicensed()
        readOnlyStr='';
    else
        readOnlyStr=' [Read Only View]';
    end

    if autosar.composition.Utils.isModelInCompositionDomain(modelName)
        titlePrefix=[autosar.ui.metamodel.PackageString.Preferences,':'];
    else

        titlePrefix=autosar.ui.configuration.PackageString.UITitle;
    end

    title=[titlePrefix,explorerName,readOnlyStr];
end
