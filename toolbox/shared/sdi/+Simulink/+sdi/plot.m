function varargout=plot(varargin)



















    narginchk(0,2);
    [varargin{:}]=convertStringsToChars(varargin{:});


    for idx=nargout:-1:1
        varargout{idx}=[];
    end


    if nargin==1&&isstruct(varargin{1})
        varargin{2}=inputname(1);
    end


    dataToImport=[];
    runName='';
    if length(varargin)==1
        dataToImport=varargin{1};
    elseif length(varargin)==2
        if ischar(varargin{2})
            dataToImport=varargin{1};
            runName=varargin{2};
        else
            dataToImport=timeseries(varargin{:});
            runName=dataToImport.Name;
        end
    end


    runIDs=[];
    sigIDs=[];
    if~isempty(dataToImport)


        if isempty(runName)
            if isscalar(dataToImport)&&isobject(dataToImport)&&isprop(dataToImport,'Name')
                runName=dataToImport.Name;
            else
                runName=inputname(1);
            end
        end


        if isempty(runName)
            runName='unnamed';
        end


        runIDs=Simulink.sdi.internal.getRunIDfromLoggedData(dataToImport);
        if runIDs
            sigIDs=locGetSignalIDsForExistingRun(runIDs);
        else

            [runIDs,sigIDs]=locCreateRuns(runName,dataToImport);
        end
    end


    sigToSelect=locPlotSignals(sigIDs);


    varargout{1}=Simulink.sdi.Run.empty;
    for idx=1:length(runIDs)
        varargout{1}=[varargout{1},Simulink.sdi.getRun(runIDs(idx))];
    end


    if~sigToSelect
        sigToSelect=locFindSignalToSelect(varargout{1});
    end


    Simulink.sdi.view(Simulink.sdi.GUITabType.InspectSignals,sigToSelect);
    locWaitForSDI();
end


function sigIDs=locGetSignalIDsForExistingRun(runIDs)

    eng=Simulink.sdi.Instance.engine();
    sigIDs=eng.getAllSignalIDs(runIDs(1),'leaf');
end


function[runIDs,sigIDs]=locCreateRuns(runName,dataToImport)
    if iscell(dataToImport)
        runNames=cell(size(dataToImport));
        runNames{1}=runName;
        for idx=2:length(runNames)
            runNames{idx}=sprintf('%s%d',runName,idx);
        end
        [runIDs,~,sigIDs]=Simulink.sdi.createRun(runName,'namevalue',runNames,dataToImport);
    else
        [runIDs,~,sigIDs]=Simulink.sdi.createRun(runName,'namevalue',{runName},{dataToImport});
    end
end


function sigToSelect=locPlotSignals(sigIDs)


    sigToSelect=0;
    MAX_SIGNALS_TO_PLOT=8;
    if~isempty(sigIDs)&&length(sigIDs)<=MAX_SIGNALS_TO_PLOT

        Simulink.sdi.clearAllSubPlots();
        Simulink.sdi.setSubPlotLayout(length(sigIDs),1);



        sdi_visuals.removeAllVisuals();


        for idx=1:length(sigIDs)
            sig=Simulink.sdi.getSignal(sigIDs(idx));
            sig.plotOnSubPlot(idx,1,true);
        end


        sigToSelect=sigIDs(1);
    else
        Simulink.sdi.clearAllSubPlots();
        sdi_visuals.removeAllVisuals();
        Simulink.sdi.setSubPlotLayout(1,1);
    end
end


function sigToSelect=locFindSignalToSelect(runs)
    sigToSelect=0;
    for idx=1:length(runs)
        if runs(idx).SignalCount
            sig=runs(idx).getSignalByIndex(1);
            sig.Checked=true;
            sigToSelect=sig.ID;
            return
        end
    end
end


function locWaitForSDI()
    MAX_TRIES=20;
    PAUSE_TIME=0.2;
    for idx=1:MAX_TRIES
        pause(PAUSE_TIME);
drawnow

        try
            clients=Simulink.sdi.WebClient.getAllClients('sdi');
            for idx2=1:length(clients)
                if strcmpi(clients(idx).Status,'connected')
                    return
                end
            end
        catch me %#ok<NASGU>

        end
    end
end
