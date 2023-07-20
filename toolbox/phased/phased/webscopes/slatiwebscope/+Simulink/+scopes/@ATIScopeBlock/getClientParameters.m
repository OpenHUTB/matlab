function obsParams=getClientParameters(this,obsParams,varargin)






    dataProcStrategy='mv_composite_strategy';



    obsParams.TimeBased=true;
    this.IsTimeBased=true;



    obsParams.DataProcStrategy=dataProcStrategy;

    obsParams.filterImpls={'webscope_datastorage_filter',...
    'webscope_deinterleave_filter',...
    'ati_waterfall_scope_filter',...
    'mv_transformdata_filter',...
    'matrix_thinner_filter',...
    };
    blk=get_param(this.FullPath,'ScopeConfiguration');

    if strcmp(blk.TimeSpanSource,'Auto')
        parent_system=bdroot(this.FullPath);

        stop_time=evalin('base',get_param(parent_system,'StopTime'));
        yData=[0,stop_time];
        timeSpan=stop_time;
    else
        yData=[0,blk.TimeSpan];
        timeSpan=blk.TimeSpan;
    end

    if strcmp(blk.TimeResolutionSource,'Auto')
        default_timeRes=get_param(this.FullPath,'CompiledSampleTime');
        timeRes=default_timeRes(1);
    else
        timeRes=blk.TimeResolution;
    end
    MatrixLength=round((timeSpan-min(yData))/timeRes+1);

    propertyArray=obsParams.clientProperties;
    numSignals=varargin{5};



    propertyArray=this.addCustomProperties(propertyArray,'sampleTime',ones(1,numSignals),'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'offset',zeros(1,numSignals),'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'timeBased',true,'bool',false);
    propertyArray=this.addCustomProperties(propertyArray,'magPhaseData',false,'bool',true);
    propertyArray=this.addCustomProperties(propertyArray,'startTime',0,'double',false);
    propertyArray=this.addCustomProperties(propertyArray,'dataProcessingStrategy',dataProcStrategy,'string',false);

    propertyArray=this.addCustomProperties(propertyArray,'PlotType','Rectangular','string',false);
    propertyArray=this.addCustomProperties(propertyArray,'ColorLimits',[],'double',false);
    propertyArray=this.addCustomProperties(propertyArray,'MatrixLength',int32(MatrixLength),'integer',false);
    propertyArray=this.addCustomProperties(propertyArray,'IsBlock',true,'bool',false);

    obsParams.clientProperties=propertyArray;
end
