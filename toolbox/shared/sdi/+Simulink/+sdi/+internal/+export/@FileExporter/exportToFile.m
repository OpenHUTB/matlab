function this=exportToFile(this,runIDs,signalIDs,activeApp,eng,fileName,overwrite,exportToFileOptions,bCmdLine)



    appName='sdi';
    message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
    tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));


    Simulink.SimulationData.utValidSignalOrCompositeData([],true);
    tmp2=onCleanup(@()Simulink.SimulationData.utValidSignalOrCompositeData([],false));


    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.isImportCancelled(0);
    fw.beginCancellableOperation();
    tmp3=onCleanup(@()fw.endCancellableOperation());
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    wksParser.IsImportCancelled=false;


    this.validateRunAndSignalIDs(eng,runIDs,signalIDs);
    this.FileName=fileName;



    if Simulink.sdi.enableSDIVideo()>1
        this.registerFileExporter('Simulink.sdi.internal.export.WebMFileExporter');
    end


    this.createPendingExporters();

    [~,shortFilename,extension]=fileparts(fileName);


    if isempty(extension)
        extension='.mat';
        fileName=[fileName,extension];
    end
    exporter=this.getExporter(extension);
    exporter.setFileName(fileName);


    if bCmdLine||~exporter.supportsCancel()
        exporter.ProgressTracker=[];
    else
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        exporter.ProgressTracker=fw.createProgressTrackerForExport(shortFilename,runIDs,signalIDs);
    end


    try
        exporter.export(runIDs,signalIDs,activeApp,eng,overwrite,...
        exportToFileOptions,bCmdLine);
    catch me
        if~wksParser.IsImportCancelled
            me.throwAsCaller();
        end
    end


    if wksParser.IsImportCancelled
        s=warning('off','MATLAB:DELETE:FileNotFound');
        sw=onCleanup(@()warning(s));
        delete(fileName);
    end
    wksParser.IsImportCancelled=false;
    exporter.ProgressTracker=[];
end
