function applyManifestProperties(modelName,m3iPort,dialog,tag)




    apiObj=autosar.api.getAUTOSARProperties(modelName);

    switch tag
    case 'instanceSpecifierEdit'
        propertyName='InstanceSpecifier';
    case 'instanceIdentifierEdit'
        propertyName='InstanceIdentifier';
    otherwise
        assert(false,'Unexpected dialog tag');
    end
    propertyValue=dialog.getWidgetValue(tag);

    [error,serviceInstance]=autosar.internal.adaptive.manifest.ManifestUtilities.validateServiceInstance(propertyValue,propertyName);

    if error
        errordlg(DAStudio.message('autosarstandard:validation:errorIdentifyServiceInstance',modelName,propertyName),...
        autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
    else
        setManifestProperty(tag,apiObj,serviceInstance,m3iPort,modelName,dialog);
    end
end

function setManifestProperty(tag,apiObj,serviceInstance,m3iPort,modelName,dialog)
    switch tag
    case 'instanceSpecifierEdit'
        apiObj.set(autosar.api.Utils.getQualifiedName(m3iPort),'InstanceSpecifier',serviceInstance);
    case 'instanceIdentifierEdit'
        autosar.internal.adaptive.manifest.ManifestUtilities.setInstanceIdentifier(modelName,m3iPort,serviceInstance);
    end
    dialog.apply();
end


