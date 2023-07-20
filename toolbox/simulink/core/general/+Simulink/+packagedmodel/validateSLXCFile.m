function result=validateSLXCFile(aFile)




    if~ischar(aFile)||isempty(aFile)
        DAStudio.error('Simulink:cache:clInvalidSLXCFile');
    end

    [~,name,ext]=fileparts(aFile);
    if isempty(name)||~strcmp(ext,Simulink.packagedmodel.getPackagedModelExtension())
        DAStudio.error('Simulink:cache:clInvalidSLXCFile');
    end

    if~isfile(aFile)

        origFile=aFile;
        aFile=which(aFile);
        if~isfile(aFile)
            DAStudio.error('Simulink:cache:unableToFindSimulinkCacheFile',origFile);
        end
    end


    if~slInternal('verifyPackagedModelReadPermissions',aFile)
        DAStudio.error('Simulink:cache:noReadPermissionsForReport',aFile);
    end


    Simulink.packagedmodel.checkSLXCCompatibility(aFile);

    result=true;
end