

function exportToXlFile(sigIDsToRecord,xlArgs)

    import Simulink.sdi.internal.streamOutRecorder.*
    import Simulink.sdi.internal.export.XLFileExporter;
    sdi_engine=Simulink.sdi.Instance.engine;
    xlExporter=Simulink.sdi.internal.export.XLFileExporter;
    xlExporter.FileName=xlArgs.fileName;
    bCmdLine=false;


    exportToFileOptions=struct();
    exportToFileOptions.overwrite='file';
    exportToFileOptions.shareTimeColumn='on';
    if strcmp(xlArgs.excelTime,'INDIVIDUALCOLUMNS')
        exportToFileOptions.shareTimeColumn='off';
    end
    metadata=struct();
    metadata.dataType=xlArgs.isDataTypeRequired;
    metadata.units=xlArgs.isUnitsRequired;
    metadata.interp=xlArgs.isInterpolationRequired;
    metadata.blockPath=xlArgs.isBlockPathRequired;
    metadata.portIndex=xlArgs.isPortIndexRequired;
    exportToFileOptions.metadata=metadata;

    runIDs=[];
    xlExporter.export(runIDs,sigIDsToRecord,'sdi',sdi_engine,...
    xlArgs.fileName,exportToFileOptions,bCmdLine);
end