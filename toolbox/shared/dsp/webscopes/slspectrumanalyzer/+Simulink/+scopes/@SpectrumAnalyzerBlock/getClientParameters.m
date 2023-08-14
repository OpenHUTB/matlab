function obsParams=getClientParameters(this,obsParams,varargin)




    dataProcStrategy='sl_dsp_webscope_frequency_data_strategy';


    obsParams.TimeBased=true;
    this.IsTimeBased=true;



    obsParams.DataProcStrategy=dataProcStrategy;


    obsParams.filterImpls={...
    'webscope_datastorage_filter',...
    'webscope_deinterleave_filter',...
    'sl_simulation_meta_data_filter',...
    'sl_input_port_parameters_handler_filter',...
    'sl_spectrum_estimator_filter',...
    'distortion_measurements_filter',...
    'frequency_peak_finder_filter',...
    'spectral_mask_tester_filter',...
    'channel_measurements_filter',...
    'sl_spectrum_data_aggregator_filter',...
    };

    clientID=this.ClientID;

    numSignals=varargin{5};
    dataTypeInfo=jsondecode(getDataTypeInfo(this));
    [inputDataType,inputRange]=getInputDataTypeAndRange(numSignals,dataTypeInfo);
    wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
    block=wsBlock.FullPath;
    inputSampleRate=getInputDataSampleRate(block);
    propertyArray=obsParams.clientProperties;

    propertyArray=this.addCustomProperties(propertyArray,'sampleTime',...
    (1/10000).*ones(1,numSignals),'double',true);

    propertyArray=this.addCustomProperties(propertyArray,'offset',...
    zeros(1,numSignals),'double',true);

    propertyArray=this.addCustomProperties(propertyArray,'frequencyOffset',...
    zeros(1,numSignals),'double',true);

    propertyArray=this.addCustomProperties(propertyArray,'timeBased',...
    true,'bool',false);

    propertyArray=this.addCustomProperties(propertyArray,'magPhaseData',...
    false(1,numSignals),'bool',true);

    propertyArray=this.addCustomProperties(propertyArray,'startTime',...
    0,'double',false);

    propertyArray=this.addCustomProperties(propertyArray,'dataProcessingStrategy',...
    dataProcStrategy,'string',false);

    propertyArray=this.addCustomProperties(propertyArray,'PlotType',...
    'Line','string',false);

    propertyArray=this.addCustomProperties(propertyArray,'needsInterleavedComplex',...
    true,'bool',false);

    propertyArray=this.addCustomProperties(propertyArray,'inputDataType',...
    inputDataType,'string',true);

    propertyArray=this.addCustomProperties(propertyArray,'inputRange',...
    inputRange,'double',true);
    if isfinite(inputSampleRate)&&inputSampleRate~=0
        propertyArray=this.addCustomProperties(propertyArray,'sampleRate',...
        inputSampleRate,'double',false);
    end

    customWindowMode=strcmpi(get_param(block,'Window'),'Custom');
    if(customWindowMode)
        propertyArray=this.addCustomProperties(propertyArray,'customWindow',...
        getCustomWindowValue(block,inputSampleRate),'double',true);
    end

    propertyArray=this.addCustomProperties(propertyArray,'useWelchForFilterBankTransient',...
    false,'bool',false);
    obsParams.clientProperties=propertyArray;
end

function[inputDataType,inputRange]=getInputDataTypeAndRange(numSignals,dataTypeInfo)
    inputDataType=cell(1,numSignals);
    inputDataType(:)={'double'};
    inputDataType=string(inputDataType);
    inputRange=zeros(1,numSignals);
    if numel(dataTypeInfo)==numSignals
        for idx=0:numSignals-1
            dtInfo=dataTypeInfo.(['x',num2str(idx)]);
            if dtInfo.isBus
                dtInfo=dataTypeInfo.(['x',num2str(idx)]);
            end


            dt=dtInfo.DataType;
            isfixpt=dtInfo.isFixedPoint;
            inputDataType(1,idx+1)=dt;
            if(any(strcmpi(dt,{'uint8','int8','uint16','int16','uint32','int32','uint64','int64'})))


                inputRange(idx+1)=double(intmax(dt));
            elseif isfixpt


                fixptInfo=dtInfo.FixedPointInfo;
                inputRange(idx+1)=double((2^(fixptInfo.wordLength-fixptInfo.isSigned)-1)*2^(-fixptInfo.fractionLength));
            end
        end
    end
end

function sampleRate=getInputDataSampleRate(block)
    sampleRateSource=get_param(block,'SampleRateSource');
    if strcmpi(sampleRateSource,'Inherited')
        sampleTime=get_param(block,'CompiledSampleTime');
        sampleTime=sampleTime(1);
    else
        sampleRate=slResolve(get_param(block,'SampleRate'),block);
        return;
    end
    inputPortDims=get_param(block,'CompiledPortDimensions');
    frameSize=inputPortDims(1).Inport(2);
    numDims=inputPortDims(1).Inport(1);
    if numDims==1
        frameSize=inputPortDims(1).Inport(1);
    end
    sampleRate=frameSize/sampleTime;
end

function rbw=getRBW(block,Fs)
    if strcmpi(get_param(block,'RBWSource'),'Auto')
        rbw=getSpan(block,Fs)/1024;
    else
        rbw=str2double(get_param(block,'RBW'));
    end
end

function span=getSpan(block,Fs)
    [Fstart,Fstop]=getStartAndStopFrequencies(block,Fs);
    span=Fstop-Fstart;
end

function[Fstart,Fstop]=getStartAndStopFrequencies(block,Fs)
    freqSpan=get_param(block,'FrequencySpan');
    Fc=str2double(get_param(block,'CenterFrequency'));
    span=str2double(get_param(block,'Span'));
    Fstart=str2double(get_param(block,'StartFrequency'));
    Fstop=str2double(get_param(block,'StopFrequency'));

    twoSidedSpectrum=utils.onOffToLogical(get_param(block,'PlotAsTwoSidedSpectrum'));
    if strcmpi(freqSpan,'Full')
        Fstart=-Fs/2*twoSidedSpectrum;
        Fstop=Fs/2;
    elseif strcmpi(freqSpan,'Span and center frequency')
        if~twoSidedSpectrum&&Fc==0
            Fstart=0;
            Fstop=span;
        else
            Fstart=Fc-span/2;
            Fstop=Fc+span/2;
        end
    end
end

function customWindow=getCustomWindowValue(block,Fs)
    customWindow=dsp.webscopes.SpectrumAnalyzerBaseWebScope.evaluateCustomWindow(get_param(block,'CustomWindow'),...
    struct('sampleRate',Fs,...
    'rbw',getRBW(block,Fs),...
    'method',get_param(block,'Method'),...
    'window',get_param(block,'Window'),...
    'sidelobeAttenuation',str2double(get_param(block,'SidelobeAttenuation'))));
end