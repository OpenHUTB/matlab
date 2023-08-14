function this=utAddSignal(this,...
    bpath,portIdx,bLog,...
    bDecimate,decimation,...
    bLimitPts,maxPts,...
    bCustName,customName,...
    sub_path,...
    signal_name)




    narginchk(12,12);


    sig=Simulink.SimulationData.SignalLoggingInfo;
    sig.outputPortIndex_=portIdx;
    sig.blockPath_=Simulink.BlockPath(bpath);
    sig.loggingInfo_.dataLogging_=bLog;
    sig.loggingInfo_.decimateData_=bDecimate;
    sig.loggingInfo_.decimation_=decimation;
    sig.loggingInfo_.limitDataPoints_=bLimitPts;
    sig.loggingInfo_.maxPoints_=maxPts;
    sig.loggingInfo_.nameMode_=bCustName;
    sig.loggingInfo_.loggingName_=customName;
    sig.blockPath_.SubPath=sub_path;
    sig.signalName_=signal_name;


    this=this.setSettingsForSignal(sig);
end
