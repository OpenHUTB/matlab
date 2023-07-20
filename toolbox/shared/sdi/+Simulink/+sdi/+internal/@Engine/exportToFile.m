function exportToFile(this,exportOpts,bCmdLine)

    exportToFileOptions=struct();
    exportToFileOptions.shareTimeColumn=exportOpts.sharetimecolumn;
    exportToFileOptions.overwrite=exportOpts.overwrite;
    for metadataIdx=1:length(exportOpts.metadata)
        currMetadata=exportOpts.metadata(metadataIdx);
        if~isempty(char(currMetadata))
            exportToFileOptions.metadata.(currMetadata)=true;
        end
    end
    if isfield(exportOpts,'signalOpts')
        if isfield(exportOpts.signalOpts,'startTime')&&...
            isfield(exportOpts.signalOpts,'endTime')
            exportToFileOptions.startTime=exportOpts.signalOpts.startTime;
            exportToFileOptions.endTime=exportOpts.signalOpts.endTime;
        end
        this.FileExporter.exportToFile([],exportOpts.signalOpts.sigID,...
        'SDI',this,exportOpts.filename,true,exportToFileOptions,...
        bCmdLine);
    elseif isfield(exportOpts,'runID')
        this.FileExporter.exportToFile(...
        exportOpts.runID,[],'SDI',this,exportOpts.filename,true,...
        exportToFileOptions,bCmdLine);
    end
end