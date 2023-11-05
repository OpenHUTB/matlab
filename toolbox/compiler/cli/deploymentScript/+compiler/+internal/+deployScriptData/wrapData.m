function dataObj=wrapData(rawData)
    if(compiler.internal.validators.isProjectConfiguration(rawData))
        dataObj=compiler.internal.deployScriptData.ProjectData(rawData);
    elseif(isstring(rawData)&&isscalar(rawData))||ischar(rawData)
        dataObj=compiler.internal.deployScriptData.LegacyProjectData(rawData);
    else
        error(message("Compiler:deploymentscript:badDataSource"))
    end
end

