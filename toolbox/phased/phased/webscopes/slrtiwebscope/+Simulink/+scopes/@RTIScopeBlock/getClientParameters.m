function obsParams=getClientParameters(this,obsParams,varargin)






    dataProcStrategy='mv_composite_strategy';



    obsParams.TimeBased=true;
    this.IsTimeBased=true;



    obsParams.DataProcStrategy=dataProcStrategy;

    obsParams.filterImpls={'webscope_datastorage_filter',...
    'webscope_deinterleave_filter',...
    'waterfall_scope_filter',...
    'mv_transformdata_filter',...
    'matrix_thinner_filter',...
    };
    blk=get_param(this.FullPath,'ScopeConfiguration');
    yData=[0,blk.TimeSpan];
    MatrixLength=round((blk.TimeSpan-min(yData))/blk.TimeResolution+1);

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
