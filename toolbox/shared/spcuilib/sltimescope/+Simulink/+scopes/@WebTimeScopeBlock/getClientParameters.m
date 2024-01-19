function obsParams=getClientParameters(this,obsParams,varargin)
    dataProcStrategy='slwebscope_time_data_strategy';
    obsParams.TimeBased=true;
    this.IsTimeBased=true;
    obsParams.DataProcStrategy=dataProcStrategy;
    obsParams.filterImpls={'webscope_datastorage_filter',...
    'webscope_deinterleave_filter',...
    'sl_simulation_meta_data_filter',...
    'timescope_thinner_filter',...
    'magnitude_phase_filter',...
    'dsp_webscope_measurements_data_cache_filter',...
    'bilevel_measurements_filter',...
    'time_signal_statistics_filter',...
    'time_peak_finder_filter',...
'trigger_filter'...
    };

    clientID=this.ClientID;
    wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
    block=wsBlock.FullPath;
    magPhaseData=get_param(block,'PlotAsMagnitudePhase');
    if isequal(magPhaseData,'off')
        magPhaseData=false;
    else
        magPhaseData=true;
    end

    propertyArray=obsParams.clientProperties;
    numSignals=varargin{5};
    propertyArray=this.addCustomProperties(propertyArray,'sampleTime',ones(1,numSignals),'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'offset',zeros(1,numSignals),'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'timeBased',true,'bool',false);
    propertyArray=this.addCustomProperties(propertyArray,'magPhaseData',logical(magPhaseData.*ones(1,numSignals)),'bool',true);
    propertyArray=this.addCustomProperties(propertyArray,'startTime',0,'double',false);
    propertyArray=this.addCustomProperties(propertyArray,'dataProcessingStrategy',dataProcStrategy,'string',false);
    propertyArray=this.addCustomProperties(propertyArray,'PlotType','Stem','string',false);
    propertyArray=this.addCustomProperties(propertyArray,'needsInterleavedComplex',true,'bool',false);

    obsParams.clientProperties=propertyArray;
end
