function propertiesAndFiles=saveLayerPropertiesToFile(layer,networkName,buildDirectory)







    fileExtension='.coderdata';
    layerProperties=properties(layer);
    numProperties=numel(layerProperties);

    propertiesAndFiles={};


    if dlcoderfeature('RuntimeLoad')

        parameterSizeThreshold=100;

        for iProp=1:numProperties
            propertyName=layerProperties{iProp};
            propertyValue=layer.(propertyName);
            if isnumeric(propertyValue)&&...
                numel(propertyValue)>parameterSizeThreshold



                fileName=dltargets.internal.getUniqueFileName(...
                dltargets.internal.utils.LayerToCompUtils.sanitizeName([networkName,'_'...
                ,layer.Name,'_',layerProperties{iProp}]),fileExtension,buildDirectory);

                dltargets.internal.utils.SaveLayerFilesUtils.checkForWindowsLongPath(fileName);

                coder.internal.write(fileName,propertyValue);
                [propertiesAndFiles{1:2,end+1}]=deal(layerProperties{iProp},fileName);%#ok
            end
        end
    end

end
