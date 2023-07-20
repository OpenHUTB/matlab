function createManifestJsonFiles(modelName,apiObj)











    if isempty(which('linux.RuntimeManager.open'))

        error(message('MATLAB:hwstubs:general:spkgNotInstalled',...
        'Embedded Coder Support Package For Linux Applications',...
        'ECLINUX'));
    end

    buildDir=RTW.getBuildDir(modelName);


    autosar.internal.adaptive.manifest.ManifestUtilities.syncManifestMetaModelWithAutosarDictionary(modelName);


    autosar.internal.adaptive.manifest.createExecutionManifest(buildDir,apiObj,modelName);


    autosar.internal.adaptive.manifest.createServiceInstanceManifest(modelName,buildDir);


    autosar.internal.adaptive.manifest.createPersistencyDefaultValues(modelName,buildDir,apiObj);
end

