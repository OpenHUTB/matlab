function export(proj,archivePath,varargin)

    results=matlab.internal.project.util.validateExportArguments(proj,archivePath,varargin{:});

    archivePath=matlab.internal.project.util.getAbsoluteExistingPath(archivePath);

    metadataManagerName="";
    if~isempty(results.definitionType)
        metadataManagerName=results.definitionType.getFactoryByIndex(results.version);
    end

    matlab.internal.project.api.exportProject(proj,...
    archivePath,results.archiveReferences,results.preventExportWithMissingFiles,metadataManagerName,results.definitionFolder,results.specifiedFilesOnly);
end
