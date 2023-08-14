function ds=exportRun(runID,varargin)

























    eng=Simulink.sdi.Instance.engine;
    try
        inputResults=Simulink.sdi.internal.parseExportOptions(varargin{:});
    catch ex
        throwAsCaller(MException(ex.identifier,ex.message));
    end
    inputResults.runID=runID;
    Simulink.sdi.internal.flushStreamingBackend();
    try
        if strcmpi(inputResults.to,'variable')

            validateattributes(runID,{'numeric'},{'scalar'},'exportRun',...
            'runID',1);
            ds=exportRun(eng,runID,false);
        else

            bCmdLine=true;
            exportToFile(eng,inputResults,bCmdLine);
        end
    catch me
        throwAsCaller(me);
    end
end