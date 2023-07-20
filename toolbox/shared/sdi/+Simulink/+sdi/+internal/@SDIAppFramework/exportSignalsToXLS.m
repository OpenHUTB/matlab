function exportSignalsToXLS(this,varargin)


    sigIDs=varargin{1};
    fname=varargin{2};
    opts=varargin{3};

    exporter=Simulink.sdi.internal.export.XLFileExporter;
    exporter.FileName=fname;
    bCmdLine=false;
    runIDs=int32.empty();
    exporter.export(runIDs,sigIDs,'sdi',this.Engine_,fname,opts,bCmdLine);
end
