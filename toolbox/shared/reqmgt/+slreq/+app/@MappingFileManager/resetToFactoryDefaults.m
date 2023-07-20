
function resetToFactoryDefaults(this)
    mappingDir=slreq.app.MappingFileManager.getInstalledMappingsDir();
    this.installMappingFiles(mappingDir);
end