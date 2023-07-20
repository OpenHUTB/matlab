









function sigTimeSeries=exportSignalToTimeSeries(this,signalID,varargin)




    sigTimeSeries=this.sigRepository.safeTransaction(...
    @helperExportSignalToTimeSeries,this,signalID,varargin{:});
end

function sigTimeSeries=helperExportSignalToTimeSeries(eng,signalID,createEnums,varargin)

    if isempty(signalID)||~eng.isValidSignalID(signalID)
        sigTimeSeries=timeseries.empty();
        return;
    end
    if nargin<3
        createEnums=true;
    end



    if nargin<4
        Simulink.sdi.internal.flushStreamingBackend();
        if eng.sigRepository.getSignalIsActivelyStreaming(signalID)
            error(message('SDI:sdi:ExportWhileStreaming'));
        end
    end

    p=inputParser;
    p.addParameter('SigProps',[],@isstruct);
    p.addParameter('StartTime',-inf,@isnumeric);
    p.addParameter('EndTime',inf,@isnumeric);
    p.addParameter('AddEndTime',false,@islogical);
    p.parse(varargin{:});
    res=p.Results;

    assert(res.StartTime<=res.EndTime,'SDI:sdi:InvalidArguments',"StartTime should be less then EndTime.");
    fixedTimeRange=(res.StartTime~=-inf)||(res.EndTime~=inf);


    s=Simulink.sdi.Signal(eng,signalID);
    signalID=s.getIDForData();


    if fixedTimeRange
        sigData=eng.sigRepository.getSignalDataValues(...
        signalID,createEnums,res.StartTime,res.EndTime);
    else
        sigData=eng.getSignalDataValues(signalID,createEnums,false);
    end

    if isempty(sigData)
        dataVals=[];
        timeVals=[];
    else
        dataVals=reshape(sigData.Data,length(sigData.Data),1);
        timeVals=reshape(sigData.Time,length(sigData.Time),1);
    end


    sigProps=res.SigProps;
    if isempty(sigProps)
        sigProps.HasDuplicateTimes=eng.sigRepository.getSignalHasDuplicateTimes(signalID);
        sigProps.Units=eng.sigRepository.getUnit(signalID);
        sigProps.Name=eng.sigRepository.getSignalLabel(signalID);
        sigProps.Interp=eng.sigRepository.getSignalInterpMethod(signalID);
    end


    if res.AddEndTime&&~isempty(timeVals)
        lastTime=eng.sigRepository.getSignalNeedsAddedEndTime(signalID);
        if~isnan(lastTime)&&lastTime>timeVals(end)
            timeVals(end+1)=lastTime;
            dataVals(end+1)=dataVals(end);
        end
    end


    if isstring(dataVals)&&isscalar(dataVals)

        sigTimeSeries=timeseries(...
        dataVals,...
        'Name',sigProps.Name);
        sigTimeSeries.Time=timeVals;
    else
        sigTimeSeries=timeseries(...
        dataVals,...
        timeVals,...
        'Name',sigProps.Name);
    end
    sigTimeSeries=setinterpmethod(sigTimeSeries,sigProps.Interp);
    if~isempty(sigProps.Units)
        sigTimeSeries.DataInfo.Units=Simulink.SimulationData.Unit(sigProps.Units);
    end
end