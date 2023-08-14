function obsParams=getClientParameters(this,obsParams,varargin)






    dataProcStrategy='CD_block_data_trajectory_strategy';



    obsParams.TimeBased=true;
    this.IsTimeBased=true;



    obsParams.DataProcStrategy=dataProcStrategy;
    blk=get_param(this.FullPath,'ScopeConfiguration');

    obsParams.filterImpls={'webscope_datastorage_filter',...
    'webscope_deinterleave_filter',...
    'CD_block_transform_filter',...
    'CD_block_measurements_data_filter',...
    };

    propertyArray=obsParams.clientProperties;
    numSignals=varargin{5};

    islastSignal=numSignals==numel(varargin{3});

    propertyArray=this.addCustomProperties(propertyArray,'sampleTime',ones(1,numSignals),'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'offset',zeros(1,numSignals),'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'timeBased',true,'bool',false);
    propertyArray=this.addCustomProperties(propertyArray,'magPhaseData',false,'bool',true);
    propertyArray=this.addCustomProperties(propertyArray,'startTime',0,'double',false);
    propertyArray=this.addCustomProperties(propertyArray,'dataProcessingStrategy',dataProcStrategy,'string',false);
    propertyArray=this.addCustomProperties(propertyArray,'PlotType','Line','string',false);
    propertyArray=this.addCustomProperties(propertyArray,'startID',int32(zeros(numSignals,1))','integer',true);
    propertyArray=this.addCustomProperties(propertyArray,'endID',int32(zeros(numSignals,1))','integer',true);
    propertyArray=this.addCustomProperties(propertyArray,'needsInterleavedComplex',true,'bool',false);


    sps=str2double(blk.SamplesPerSymbol);
    soff=str2double(blk.SampleOffset);
    std=str2double(blk.SymbolsToDisplay);
    stdfi=strcmpi(blk.SymbolsToDisplaySource,'Input frame length');
    clientID=this.ClientID;

    if islastSignal
        try
            checkSamplesVsSymbols(sps,soff,std,stdfi,varargin{3});
            isValidProp=true;
            ParamSettings='Pass';
        catch ME1
            isValidProp=false;
            ParamSettings=ME1.message;
        end
    end

    propertyArray=this.addCustomProperties(propertyArray,'showTrajectory',boolFromLogical(blk.ShowTrajectory),'bool',false);
    propertyArray=this.addCustomProperties(propertyArray,'symbolsToDisplaySource',stdfi,'bool',false);

    propertyArray=this.addCustomProperties(propertyArray,'sampleOffset',soff,'integer',false);
    propertyArray=this.addCustomProperties(propertyArray,'samplesPerSymbol',sps,'integer',false);
    propertyArray=this.addCustomProperties(propertyArray,'symbolsToDisplay',std,'integer',false);

    measurementInterval=blk.MeasurementInterval;
    if isempty(measurementInterval)
        if isValidProp&&islastSignal
            [errStr,~]=utils.message('EvaluateUndefinedVariable',get_param(this.FullPath,'MeasurementInterval'));
            ParamSettings=errStr;
            isValidProp=false;
        end
        measurementInterval='Current display';
    end
    propertyArray=this.addCustomProperties(propertyArray,'measurementInterval',convertCharsToStrings(measurementInterval),'string',false);
    propertyArray=this.addCustomProperties(propertyArray,'evmNormalization',convertCharsToStrings(blk.EVMNormalization),'string',false);
    propertyArray=this.addCustomProperties(propertyArray,'measurementChannel',int32(blk.MeasurementPortChannel),'integer',false);
    propertyArray=this.addCustomProperties(propertyArray,'measurementSignal',int32(blk.MeasurementSignal),'integer',false);
    propertyArray=this.addCustomProperties(propertyArray,'enableMeasurements',boolFromLogical(blk.EnableMeasurements),'bool',false);
    blk.tempClientID=clientID;
    refValue=blk.ReferenceConstellation;
    [refNumRows,refConst,newValue,xRefData,yRefData,refConstStr,isNumRefChanged]=updateReferenceConstellaltionValues(refValue,str2double(blk.NumInputPorts));
    if~isempty(newValue)&&isNumRefChanged

        preserveDirty=Simulink.PreserveDirtyFlag(bdroot(this.FullPath),'blockDiagram');%#ok
        blk.ReferenceConstellation=newValue;
    end
    if isempty(refValue)&&blk.EnableMeasurements
        if isValidProp&&islastSignal
            msgthis=message('comm:ConstellationDiagramWebScope:InvalidReferenceConstellation');
            ParamSettings=msgthis;
            isValidProp=false;
        end
    end
    if islastSignal
        channel=['/webscope',clientID];
        if isValidProp
            msg.action=['onPostErrorMessage',clientID];
        else
            msg.action=['onPreErrorMessage',clientID];
        end
        msg.params=ParamSettings;
        message.publish(channel,msg);
    end
    propertyArray=this.addCustomProperties(propertyArray,'refNumRows',refNumRows,'double',true);
    propertyArray=this.addCustomProperties(propertyArray,'referenceConstellation',refConst,'double',true);
    if islastSignal
        publishReferenceConstellation(blk,clientID,this.FullPath,xRefData,yRefData,refConstStr);
    end
    obsParams.clientProperties=propertyArray;
end

function[refNumRows,refConst,newValue,xRefData,yRefData,refConstStr,isNumRefChanged]=updateReferenceConstellaltionValues(refValue,numInputPorts)
    newValue=[];

    if ischar(refValue)
        [refValue,~,~]=uiservices.evaluate(refValue);
        if numel(refValue)==1&&iscell(refValue{1})
            refValue=refValue{:};
        end
        newValue=refValue;
    end
    isNumRefChanged=false;
    if~isempty(refValue)
        if~iscell(refValue)
            refValue={refValue};
        end
        currentRefValue=numel(refValue);
        if numInputPorts>currentRefValue
            defaultRefValue=[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i];
            for idx=currentRefValue+1:numInputPorts
                refValue{idx}=defaultRefValue;
            end
            newValue=refValue;
            isNumRefChanged=true;
        elseif numInputPorts~=currentRefValue
            temp=cell(size(numInputPorts));
            for idx=1:numInputPorts
                temp{idx}=refValue{idx};
            end
            refValue=temp;
            newValue=refValue;
        end
        xRefData=cell(size(refValue));
        yRefData=cell(size(refValue));
        refNumRows=cell(size(refValue));
        refConstStr=cell(size(refValue));
        for idx=1:numel(refValue)
            xRefData{idx}=real(refValue{idx});
            refConstStr{idx}=mat2str(refValue{idx});
            refNumRows{idx}=numel(xRefData{idx});
            yRefData{idx}=imag(refValue{idx});
        end

        [refConst,refNumRows]=getReferenceConstellation(xRefData,yRefData);
    else
        refNumRows=[];
        refConst=[];
        xRefData=[];
        yRefData=[];
        refConstStr=[];
    end
end

function booleanvalue=boolFromLogical(value)
    booleanvalue=false;
    if(value)
        booleanvalue=true;
    end
end

function[updateReferenceConstelaltion,updateRefNumRows]=getReferenceConstellation(xRefData,yRefData)
    referenceConstelaltion=[];
    tempRefNumRows=[];
    for id=1:numel(xRefData)
        for idx=1:numel(xRefData{id})
            referenceConstelaltion(end+1)=xRefData{id}(idx);
        end
        for idx=1:numel(yRefData{id})
            referenceConstelaltion(end+1)=yRefData{id}(idx);
        end
        tempRefNumRows=vertcat(tempRefNumRows,numel(xRefData{id}));
    end
    updateReferenceConstelaltion=referenceConstelaltion;
    updateRefNumRows=tempRefNumRows;
end

function publishReferenceConstellation(blk,clientID,blkPath,xRefData,yRefData,refConstStr)
    if isempty(refConstStr)
        return;
    end
    if isempty(xRefData)||(iscell(xRefData)&&isempty(xRefData{1}))
        return;
    end
    channel=['/webscope',clientID];
    msg.action=['updateParamSettings',clientID];
    referenceConstString=get_param(blkPath,'ReferenceConstellation');
    ParamSettings=struct('ReferenceConstellation',struct('referenceConstellation',refConstStr,...
    'xRefData',xRefData,'yRefData',yRefData,'referenceConstellationString',referenceConstString),...
    'SymbolsToDisplay',struct('value',str2double(blk.SymbolsToDisplay),'variable',get_param(blkPath,'SymbolsToDisplay')),...
    'SamplesPerSymbol',struct('value',str2double(blk.SamplesPerSymbol),'variable',get_param(blkPath,'SamplesPerSymbol')),...
    'SampleOffset',struct('value',str2double(blk.SampleOffset),'variable',get_param(blkPath,'SampleOffset')),...
    'MeasurementInterval',struct('value',blk.MeasurementInterval,'variable',get_param(blkPath,'MeasurementInterval')),...
    'MeasurementChannel',struct('value',int32(blk.MeasurementChannel),'variable',get_param(blkPath,'MeasurementChannel')));
    msg.params=ParamSettings;
    message.publish(channel,msg);
end

function[success,exception]=checkSamplesVsSymbols(sps,soff,std,stdfi,maxDims)





    success=true;
    exception=[];

    if~isempty(std)&&~stdfi
        if std<=0||(floor(std)~=std)
            success=false;
            id='comm:ConstellationVisual:InvalidSymbolsToDisplay';
            msg=getString(message(id,getString(message('comm:ConstellationVisual:InputFrameLength'))));
        end
    end

    if~isempty(soff)
        if soff<0||(floor(soff)~=soff)
            success=false;
            id='comm:ConstellationVisual:InvalidSampleOffset';
            msg=getString(message(id));
        end
    end

    if~success
        throw(MException(id,msg));
    end

    if~isempty(sps)

        if sps<1||(floor(sps)~=sps)
            id='comm:ConstellationVisual:InvalidSamplesPerSymbol';
            msg=getString(message(id));
            throw(MException(id,msg));
        end


        if~isempty(soff)&&soff>=sps
            id='comm:ConstellationVisual:InvalidSamplesPerSymbol';
            msg=getString(message(id));
            throw(MException(id,msg));
        end

        if stdfi
            for idx=1:numel(maxDims)
                ratio=maxDims(idx)/sps;
                if floor(ratio)~=ratio
                    id='comm:ConstellationVisual:FrameLengthNotDivisibleBlock';
                    msg=getString(message(id));
                    throw(MException(id,msg));
                end
            end
        end
    end
end
