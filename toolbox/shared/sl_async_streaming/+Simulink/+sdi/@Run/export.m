function ds=export(this,varargin)




    inputResults=Simulink.sdi.internal.parseExportOptions(varargin{:});
    inputResults.runID=this.id;
    Simulink.HMI.synchronouslyFlushWorkerQueue(this.Repo);
    if strcmpi(inputResults.to,'variable')

        exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
        ds=exportRun(exporter,this.Repo,this.id,false);
    else

        bCmdLine=true;
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        try
            fw.exportToFile(inputResults,bCmdLine);
        catch me
            me.throwAsCaller();
        end
    end
end
