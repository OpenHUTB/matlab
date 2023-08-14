function[sys,dt,mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR]=computeQuickSimulation(obj)























    sys=[];
    dt=[];
    mismatchedValuesBlocksCTLE=[];
    mismatchedValuesBlocksDFECDR=[];
    if isempty(obj)||isempty(obj.Elements)
        return;
    end

    format compact;


    if~obj.refreshValuesFromWorkspaceVariables()
        return;
    end


    jitter=obj.Jitter.getJitterObject();


    symbol_time=getNumericValue(obj.SymbolTime);
    samples_per_symbol=getNumericValue(obj.SamplesPerSymbol);
    BER_target=getNumericValue(obj.BERtarget);
    modulation=serdes.internal.callbacks.convertModulation(obj.Modulation);
    signaling=getStringValue(obj.Signaling);
    dt=symbol_time/samples_per_symbol;


    elements=obj.Elements;
    txBlocksCount=0;
    rxBlocksCount=0;
    channelIndex=0;
    rcTxIndex=0;
    rcRxIndex=0;
    mismatchedValuesBlocksCountCTLE=0;
    mismatchedValuesBlocksCTLE={};
    mismatchedValuesBlocksCountDFECDR=0;
    mismatchedValuesBlocksDFECDR={};
    for i=1:numel(elements)
        if isa(elements{i},'serdes.internal.apps.serdesdesigner.channel')
            channelIndex=i;

            if strcmpi(elements{i}.ChannelModel,'Impulse response')
                channelSourceFlag=1;
            else
                channelSourceFlag=3;
            end
            channelImpulseSampleInterval=getNumericValue(elements{i}.ImpulseSampleInterval);




            if elements{i}.isWorkspaceVariable(elements{i}.ImpulseResponse)
                channelImpulseResponse=elements{i}.getWorkspaceVariableValue('ImpulseResponse');
            else
                channelImpulseResponse=getNumericValue(elements{i}.ImpulseResponse);
            end

            channelLoss=getNumericValue(elements{i}.ChannelLoss_dB);
            channelImpedanceSingleEnded=getNumericValue(elements{i}.Impedance);
            channelImpedanceDifferential=getNumericValue(elements{i}.DifferentialImpedance);
            channelTargetFrequency=getNumericValue(elements{i}.TargetFrequency);

            EnableCrosstalk=elements{i}.XTalkEnabled;
            CrosstalkSpecification=elements{i}.XTalkSpecification;

            FEXTICN=elements{i}.FE_XTalkICN;
            NEXTICN=elements{i}.NE_XTalkICN;

        elseif isa(elements{i},'serdes.internal.apps.serdesdesigner.rcTx')
            rcTxIndex=i;
            rTx=getNumericValue(elements{i}.R);
            cTx=getNumericValue(elements{i}.C);
            riseTime=getNumericValue(elements{i}.RiseTime);
            voltage=getNumericValue(elements{i}.Voltage);
        elseif isa(elements{i},'serdes.internal.apps.serdesdesigner.rcRx')
            rcRxIndex=i;
            rRx=getNumericValue(elements{i}.R);
            cRx=getNumericValue(elements{i}.C);
        elseif channelIndex==0
            txBlocksCount=txBlocksCount+1;
        else
            rxBlocksCount=rxBlocksCount+1;
        end
    end


    txAnalogModel=serdes.internal.serdessystem.AnalogModel('R',rTx,'C',cTx);
    if txBlocksCount>0
        txBlocks=getBlocks(elements,1,rcTxIndex-1);
        tx=serdes.internal.serdessystem.Transmitter('Blocks',txBlocks,...
        'Name','tx_Design',...
        'AnalogModel',txAnalogModel,...
        'VoltageSwingIdeal',voltage,...
        'RiseTime',riseTime);
        for i=1:txBlocksCount
            if isa(txBlocks{i},'serdes.CTLE')&&~areScalarsOrVectorsOfSameLength(txBlocks{i})
                mismatchedValuesBlocksCountCTLE=mismatchedValuesBlocksCountCTLE+1;
                mismatchedValuesBlocksCTLE{mismatchedValuesBlocksCountCTLE}=txBlocks{i};
            elseif isa(txBlocks{i},'serdes.DFECDR')&&~areScalarsOrVectorsOfSameLength(txBlocks{i})
                mismatchedValuesBlocksCountDFECDR=mismatchedValuesBlocksCountDFECDR+1;
                mismatchedValuesBlocksDFECDR{mismatchedValuesBlocksCountDFECDR}=txBlocks{i};
            end
        end
    else
        tx=serdes.internal.serdessystem.Transmitter(...
        'Name','tx_Design',...
        'AnalogModel',txAnalogModel,...
        'VoltageSwingIdeal',voltage,...
        'RiseTime',riseTime);
    end


    rxAnalogModel=serdes.internal.serdessystem.AnalogModel('R',rRx,'C',cRx);
    if rxBlocksCount>0
        rxBlocks=getBlocks(elements,rcRxIndex+1,rcRxIndex+rxBlocksCount);
        rx=serdes.internal.serdessystem.Receiver('Blocks',rxBlocks,...
        'Name','rx_Design',...
        'AnalogModel',rxAnalogModel);
        for i=1:rxBlocksCount
            if isa(rxBlocks{i},'serdes.CTLE')&&~areScalarsOrVectorsOfSameLength(rxBlocks{i})
                mismatchedValuesBlocksCountCTLE=mismatchedValuesBlocksCountCTLE+1;
                mismatchedValuesBlocksCTLE{mismatchedValuesBlocksCountCTLE}=rxBlocks{i};
            elseif isa(rxBlocks{i},'serdes.DFECDR')&&~areScalarsOrVectorsOfSameLength(rxBlocks{i})
                mismatchedValuesBlocksCountDFECDR=mismatchedValuesBlocksCountDFECDR+1;
                mismatchedValuesBlocksDFECDR{mismatchedValuesBlocksCountDFECDR}=rxBlocks{i};
            end
        end
    else
        rx=serdes.internal.serdessystem.Receiver(...
        'Name','rx_Design',...
        'AnalogModel',rxAnalogModel);
    end


    if channelSourceFlag==3
        if strcmpi(signaling,'Single-ended')
            zimpedance=2*channelImpedanceSingleEnded;
        else
            zimpedance=channelImpedanceDifferential;
        end

        if EnableCrosstalk
            fb=1/symbol_time/modulation;
            if strcmpi(CrosstalkSpecification,'Custom')
                channel=serdes.internal.serdessystem.ChannelData(...
                'ChannelLossdB',channelLoss,...
                'ChannelDifferentialImpedance',zimpedance,...
                'ChannelLossFreq',channelTargetFrequency,...
                'EnableCrosstalk',EnableCrosstalk,...
                'CrosstalkSpecification',CrosstalkSpecification,...
                'fb',fb,...
                'FEXTICN',FEXTICN,...
                'NEXTICN',NEXTICN);
            else
                channel=serdes.internal.serdessystem.ChannelData(...
                'ChannelLossdB',channelLoss,...
                'ChannelDifferentialImpedance',zimpedance,...
                'ChannelLossFreq',channelTargetFrequency,...
                'EnableCrosstalk',EnableCrosstalk,...
                'CrosstalkSpecification',CrosstalkSpecification,...
                'fb',fb);
            end
        else
            channel=serdes.internal.serdessystem.ChannelData(...
            'ChannelLossdB',channelLoss,...
            'ChannelDifferentialImpedance',zimpedance,...
            'ChannelLossFreq',channelTargetFrequency);
        end
    elseif channelSourceFlag==1
        channel=serdes.internal.serdessystem.ChannelData(...
        'impulse',channelImpulseResponse,...
        'dt',channelImpulseSampleInterval);
    else
        dummyimpulse=zeros(200,1);
        dummyimpulse(10)=1/dt;
        channel=serdes.internal.serdessystem.ChannelData(...
        'impulse',dummyimpulse,'dt',dt);
    end


    sys=serdes.internal.serdessystem.SerdesSystem(...
    'TxModel',tx,...
    'RxModel',rx,...
    'ChannelData',channel,...
    'SymbolTime',symbol_time,...
    'SamplesPerSymbol',samples_per_symbol,...
    'Signaling',signaling,...
    'Modulation',modulation,...
    'JitterAndNoise',jitter,...
    'BERtarget',BER_target);
end


function blocks=getBlocks(elements,beginIndex,endIndex)
    count=0;
    for i=beginIndex:endIndex
        element=elements{i};
        if isa(element,'serdes.internal.apps.serdesdesigner.agc')
            block=serdes.AGC;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.ffe')
            block=serdes.FFE;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.vga')
            block=serdes.VGA;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.satAmp')
            block=serdes.SaturatingAmplifier;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.dfeCdr')
            block=serdes.DFECDR;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.cdr')
            block=serdes.CDR;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.ctle')
            block=serdes.CTLE;
        elseif isa(element,'serdes.internal.apps.serdesdesigner.transparent')
            block=serdes.PassThrough;
        else
            block=[];
        end
        if~isempty(block)
            count=count+1;
            blocks{count}=block;
            if isprop(element,'BlockName')

                set(block,'BlockName',element.Name);
            end
            if~isempty(element.ParameterNames)
                blockParameters=get(block);
                if~isempty(blockParameters)

                    amiParameters=element.getAMIParameters;
                    for k=1:numel(element.ParameterNames)
                        name=element.ParameterNames{k};
                        if hasSetAccess(block,name)&&~strcmp(elements{i}.ParameterValues{k},'?')
                            amiParameter=[];
                            if~isempty(amiParameters)
                                for m=1:numel(amiParameters)
                                    if isprop(amiParameters{m},'Name')&&strcmpi(amiParameters{m}.Name,element.ParameterNames{k})||...
                                        isprop(amiParameters{m},'NodeName')&&strcmpi(amiParameters{m}.NodeName,element.ParameterNames{k})
                                        amiParameter=amiParameters{m};
                                        break;
                                    end
                                end
                            end
                            if~isempty(amiParameter)&&isprop(amiParameter,'CurrentValue')
                                value=amiParameter.CurrentValue;
                            else
                                value=getTypedValue(elements{i}.ParameterValues{k},block.(name));
                            end
                            if~strcmpi(value,string(message('serdes:serdesdesigner:DataTypeConversionError')))
                                block.(name)=value;
                            end
                        end
                    end
                end
            end
        end
    end
end


function isMatched=areScalarsOrVectorsOfSameLength(block)
    if isa(block,'serdes.CTLE')
        switch block.Specification
        case 'DC Gain and Peaking Gain'
            values={block.PeakingFrequency,block.DCGain,block.PeakingGain'};
        case 'DC Gain and AC Gain'
            values={block.PeakingFrequency,block.DCGain,block.ACGain'};
        case 'AC Gain and Peaking Gain'
            values={block.PeakingFrequency,block.ACGain,block.PeakingGain'};
        otherwise
            values={};
        end
    elseif isa(block,'serdes.DFECDR')
        values={block.TapWeights,block.MinimumTap,block.MaximumTap};
    else
        values={};
    end
    if~isempty(values)&&numel(values)>1
        isMatched=serdes.internal.apps.serdesdesigner.BlockDialog.areScalarsOrVectorsOfSameLength(values,{},{});
    else
        isMatched=true;
    end
end


function value=getTypedValue(sourceValue,destination)
    value=serdes.internal.apps.serdesdesigner.BlockDialog.getTypedValue(sourceValue,destination);
end


function bool=getLogicalValue(value)
    bool=serdes.internal.apps.serdesdesigner.BlockDialog.getLogicalValue(value);
end


function int=getIntegerValue(value)
    int=serdes.internal.apps.serdesdesigner.BlockDialog.getIntegerValue(value);
end


function num=getNumericValue(value)
    num=serdes.internal.apps.serdesdesigner.BlockDialog.getNumericValue(value);
end


function str=getStringValue(value)
    str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(value);
end


function canBeSet=hasSetAccess(element,parameterName)
    canBeSet=serdes.internal.apps.serdesdesigner.BlockDialog.hasSetAccess(element,parameterName);
end
