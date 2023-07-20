function obsParams=getClientParameters(this,obsParams,varargin)




    dataProcStrategy='dsp_webscope_frame_data_strategy';


    obsParams.TimeBased=false;
    this.IsTimeBased=false;



    obsParams.DataProcStrategy=dataProcStrategy;


    obsParams.filterImpls={'webscope_deinterleave_filter',...
    'simulation_meta_data_filter',...
    'webscope_datastorage_filter',...
    'webscope_thinner_filter',...
    'magnitude_phase_filter',...
    'signal_statistics_filter',...
    'peak_finder_filter',...
    };

    clientID=this.ClientID;
    wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
    block=wsBlock.FullPath;
    sampleIncrement=evalin('base',get_param(block,'SampleIncrement'));
    xOffset=evalin('base',get_param(block,'XOffset'));
    magPhaseData=utils.onOffToLogical(get_param(block,'PlotAsMagnitudePhase'));

    propertyArray=obsParams.clientProperties;
    numSignals=varargin{5};

    propertyArray=this.addCustomProperties(propertyArray,'sampleTime',...
    sampleIncrement.*ones(1,numSignals),'double',true);

    propertyArray=this.addCustomProperties(propertyArray,'offset',...
    xOffset.*ones(1,numSignals),'double',true);

    propertyArray=this.addCustomProperties(propertyArray,'timeBased',...
    false,'bool',false);

    propertyArray=this.addCustomProperties(propertyArray,'magPhaseData',...
    logical(magPhaseData.*ones(1,numSignals)),'bool',true);

    propertyArray=this.addCustomProperties(propertyArray,'startTime',...
    0,'double',false);

    propertyArray=this.addCustomProperties(propertyArray,'dataProcessingStrategy',...
    dataProcStrategy,'string',false);

    propertyArray=this.addCustomProperties(propertyArray,'PlotType',...
    'Stem','string',false);

    obsParams.clientProperties=propertyArray;
end
