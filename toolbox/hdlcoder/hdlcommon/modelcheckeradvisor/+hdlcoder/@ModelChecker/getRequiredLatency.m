function[reqLatency,minLat,maxLat,flag,msgId]=getRequiredLatency(block,globalLatencyStrategy,targetConfigNFP)




    flag=true;
    msgId="NA";
    minLat=0;
    maxLat=0;
    isProductBlock=false;
    try
        type=get_param(block,'Operator');
    catch
        type=get_param(block,'BlockType');
        if strcmpi(type,'Product')
            isProductBlock=true;
            inputs=get_param(block,'Inputs');
            if strcmpi(inputs,'/')
                type='reciprocal';
            else
                if contains(inputs,'/')
                    type='div';
                end
            end
        end


        if strcmpi(type,'Gain')
            gainVal=get_param(block,'gain');
            if hdlispowerof2(str2num(gainVal))
                type='GainPow2';
            end
        end

    end
    nfpType=hdlcoder.ModelChecker.getNFPBlockTypeBySlType(type);
    [inputDataType,outputDataType]=hdlcoder.ModelChecker.getNFPBlockDataType(block);

    if isempty(inputDataType)&&isempty(outputDataType)
        reqLatency=getFixedPointLatency(block);

    elseif targetConfigNFP&&~isempty(nfpType)
        ph=get_param(block,'PortHandles');
        if~isempty(ph)
            if isProductBlock&&((length(ph.Inport)>2)||strcmpi(inputs,'/*'))


                msgId='HDLShared:hdlmodelchecker:unsupportedMultipleInputs';
                reqLatency=0;
                flag=false;
                return;
            end
            dim=get_param(ph.Inport,'CompiledPortDimensions');
            if~isempty(dim)
                if~isScalarDataType(dim)



                    msgId='HDLShared:hdlmodelchecker:unsupportedVectorInputs';
                    reqLatency=0;
                    flag=false;
                    return;
                end
            end
        end

        if isNfpLUT(nfpType)

            msgId='HDLShared:hdlmodelchecker:unsupportedLUTBlockForLatencyCheck';
            reqLatency=0;
            flag=false;
            return;
        end


        try
            latencyStrategyBlock=hdlget_param(block,'LatencyStrategy');
        catch
            latencyStrategyBlock='inherit';
        end
        if(strcmpi(nfpType,'Convert'))
            if isempty(inputDataType)
                conversionStr=['NUMERICTYPE_TO_',outputDataType];
            elseif isempty(outputDataType)
                conversionStr=[inputDataType,'_TO_NUMERICTYPE'];
            elseif strcmp(inputDataType,outputDataType)
                reqLatency=0;minLat=0;maxLat=0;
                return;
            else
                conversionStr=[inputDataType,'_TO_',outputDataType];
            end
            [minLat,maxLat]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies(nfpType,conversionStr,'NATIVEFLOATINGPOINT');
        else
            [minLat,maxLat]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies(nfpType,inputDataType,'NATIVEFLOATINGPOINT');
        end

        if(strcmpi(latencyStrategyBlock,'inherit'))
            latencyStrategyBlock=globalLatencyStrategy;
        end
        if(strcmpi(latencyStrategyBlock,'Max'))
            reqLatency=maxLat;
        elseif(strcmpi(latencyStrategyBlock,'Min'))
            reqLatency=minLat;
        elseif(strcmpi(latencyStrategyBlock,'Zero'))
            reqLatency=0;
        else

            if strcmpi(type,'sqrt')||strcmpi(type,'rsqrt')
                reqLatency=hdlget_param(block,'CustomLatency');
            else
                reqLatency=hdlget_param(block,'NFPCustomLatency');
            end
        end

    else
        reqLatency=0;
    end
end


function[wordLength,fractionLength,signed]=getWordLength(dataType)

    wordLength=0;
    fractionLength=0;
    signed=false;

    if isempty(dataType)
        return;
    end


    if strcmpi(dataType,'int8')
        wordLength=8;
        signed=true;
    elseif strcmpi(dataType,'uint8')
        wordLength=8;
    elseif strcmpi(dataType,'int16')
        wordLength=16;
        signed=true;
    elseif strcmpi(dataType,'uint16')
        wordLength=16;
    elseif strcmpi(dataType,'int32')
        wordLength=32;
        signed=true;
    elseif strcmpi(dataType,'uint32')
        wordLength=32;
    elseif strcmpi(dataType,'int64')
        wordLength=64;
        signed=true;
    elseif strcmpi(dataType,'uint64')
        wordLength=64;
    else
        if contains(dataType,'(')
            fixdType=split(dataType,'(');
            splitValues=split(fixdType(2),')');
            splitValues=split(splitValues(1),',');
            wordLength=splitValues(2);
            fractionLength=splitValues(3);
            if strcmpi(fixdType(1),'sfixdt')
                signed=true;
            end
        else

            splitValues=split(dataType,'fix');
            signFlag=splitValues(1);
            splitValues=split(splitValues(2),'_');
            wordLength=str2double(splitValues(1));
            if(numel(splitValues)>1)
                if contains(splitValues(2),'En')
                    splitValues=split(splitValues(2),'En');
                    fractionLength=str2double(splitValues(2));
                else
                    splitValues=split(splitValues(2),'E');
                    fractionLength=-1*str2double(splitValues(2));
                end
            end
            if strcmpi(signFlag,'s')
                signed=true;
            end
        end
    end
end


function latency=getFixedPointLatency(blockHandle)

    blkType=get_param(blockHandle,'BlockType');
    latency=0;
    if strcmpi(blkType,'Inport')||strcmpi(blkType,'Outport')||...
        strcmpi(blkType,'Subsystem')||strcmpi(blkType,'S-Function')...
        ||strcmpi(blkType,'M-S-Function')
        return;
    end

    blkArchitecture=hdlget_param(blockHandle,'Architecture');

    if strcmpi(blkType,'DiscreteIntegrator')
        latency=getDiscreteTimeIntegratorLatency(blockHandle);
    elseif strcmpi(blkType,'MultiplyAccumulate')
        latency=getMultiplyAccumulateLatency(blockHandle);
    elseif strcmpi(blkType,'MultiplyAccumulateParallel')
        latency=getMultiplyAccumulateParallelLatency(blockHandle);
    elseif strcmpi(blkType,'MagnitudeAngleToComplex')
        latency=getPol2CartCordicLatency(blockHandle);
    elseif strcmpi(blkType,'Product')
        if strcmpi(blkArchitecture,'ReciprocalRsqrtBasedNewton')
            latency=getReciprocalRsqrtBasedNewtonLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'ReciprocalRsqrtBasedNewtonSingleRate')
            latency=getReciprocalRsqrtBasedNewtonSingleRateLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'Cascade')
            latency=getProductCascadeLatency(blockHandle);
        else
            inputs=get_param(blockHandle,'Inputs');
            if contains(inputs,'/')&&strcmpi(blkArchitecture,'ShiftAdd')
                latency=getNonRestoreDivideLatency(blockHandle);
            end
        end
    elseif strcmpi(blkType,'Trigonometry')
        latency=getCordicLatency(blockHandle);
    elseif strcmpi(blkType,'Sqrt')
        if strcmpi(blkArchitecture,'RecipSqrtNewton')
            latency=getReciprocalSqrtNewtonLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'RecipSqrtNewtonSingleRate')
            latency=getReciprocalSqrtNewtonSingleRateLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'SqrtNewton')
            latency=getSqrtNewtonLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'SqrtNewtonSingleRate')
            latency=getSqrtNewtonSingleRateLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'SqrtFunction')
            latency=getSqrtFunctionLatency(blockHandle);
        end
    elseif strcmpi(blkType,'Sum')
        if strcmpi(blkArchitecture,'Cascade')
            latency=getSumCascadeLatency(blockHandle);
        end
    elseif strcmpi(blkType,'Math')
        latency=getMathFunctionLatency(blockHandle);
    elseif strcmpi(blkType,'MinMax')
        if strcmpi(blkArchitecture,'Cascade')
            latency=getMinMaxCascadeLatency(blockHandle);
        end
    elseif strcmpi(blkType,'Reciprocal')
        if strcmpi(blkArchitecture,'ReciprocalNewton')
            latency=getReciprocalNewtonLatency(blockHandle);
        elseif strcmpi(blkArchitecture,'ReciprocalNewtonSingleRate')
            latency=getReciprocalNewtonSingleRateLatency(blockHandle);
        end
    else
        latency=0;
    end
end


function latency=getNonRestoreDivideLatency(blockHandle)
    latencyStrategy=hdlget_param(blockHandle,'LatencyStrategy');

    if strcmpi(latencyStrategy,'CUSTOM')
        latency=hdlget_param(blockHandle,'CustomLatency');
        return;
    elseif strcmpi(latencyStrategy,'ZERO')
        latency=0;
        return;
    end


    pHandles=get_param(blockHandle,'PortHandles');
    if isempty(pHandles.Inport)
        latency=0;
        return;
    end


    signConsideration=0;

    if(numel(pHandles.Inport)>1)
        in1Type=get_param(pHandles.Inport(1),'CompiledPortDataType');
        in2Type=get_param(pHandles.Inport(2),'CompiledPortDataType');
        [wordLength,~,in1Signed]=getWordLength(in1Type);
        [~,~,in2Signed]=getWordLength(in2Type);
        if in1Signed~=in2Signed
            signConsideration=1;
        end
    else
        dType=get_param(pHandles.Outport(1),'CompiledPortDataType');
        wordLength=getWordLength(dType);
    end
    if wordLength==0
        latency=0;
        return;
    end
    additionalItrs=4;

    latency=wordLength+additionalItrs+signConsideration;
end


function latency=getCordicLatency(blockHandle)
    isSysObj=isa(blockHandle,'hdlcoder.sysobj_comp');
    if isSysObj







    else
        iterNum=hdlslResolve('NumberOfIterations',blockHandle);
        customLatency=hdlget_param(blockHandle,'CustomLatency');
        if(isempty(customLatency))
            customLatency=0;
        end

        latencyStrategy=hdlget_param(blockHandle,'LatencyStrategy');
        if(isempty(latencyStrategy))
            latencyStrategy='MAX';
        end
        fName=get_param(blockHandle,'Operator');
        if(strcmpi(fName,'atan2'))
            if(strcmpi(latencyStrategy,'MAX'))
                additionalItrs=3;
                latency=iterNum+additionalItrs;
            elseif(strcmpi(latencyStrategy,'CUSTOM'))
                latency=customLatency;
            else
                latency=0;
            end
        else

            if(strcmpi(latencyStrategy,'MAX'))
                additionalItrs=1;
                latency=iterNum+additionalItrs;
            elseif(strcmpi(latencyStrategy,'CUSTOM'))
                latency=customLatency;
            else
                latency=0;
            end
        end
    end

end


function latency=getDiscreteTimeIntegratorLatency(blockHandle)
    externalReset=get_param(blockHandle,'ExternalReset');

    if~isempty(externalReset)&&...
        (strcmpi(externalReset,'rising')||strcmpi(externalReset,'falling'))
        latency=1;
    else
        latency=0;
    end
end


function latency=getMathFunctionLatency(~)


    latency=0;

end


function latency=getMinMaxCascadeLatency(blockHandle)


    pHandles=get_param(blockHandle,'PortHandles');
    if isempty(pHandles.Inport)
        latency=0;
        return;
    end

    latency=0;
    if(numel(pHandles.Inport)>1)
        latency=1;
    end
end


function latency=getMultiplyAccumulateLatency(~)
    latency=0;
end


function latency=getMultiplyAccumulateParallelLatency(~)

    latency=0;
end


function latency=getPol2CartCordicLatency(blockHandle)
    if targetcodegen.targetCodeGenerationUtils.isNFPMode
        latency=0;
    else
        nItr=hdlslResolve('NumberOfIterations',blockHandle);
        additionalItrs=1;
        latency=nItr+additionalItrs;
    end
end


function latency=getProductCascadeLatency(~)
    latency=1;
end


function latency=getReciprocalSqrtNewtonLatency(blockHandle)

    iterNum=hdlslResolve('Iterations',blockHandle);
    additionalItrs=2;
    latency=iterNum+additionalItrs;
end


function latency=getReciprocalSqrtNewtonSingleRateLatency(blockHandle)

    additionalItrs=5;
    iterNum=hdlslResolve('Iterations',blockHandle);

    latency=iterNum*4+additionalItrs;
end


function latency=getReciprocalNewtonLatency(blockHandle)

    iterNum=hdlslResolve('NumberOfIterations',blockHandle);

    additionalItrs=1;
    latency=additionalItrs+iterNum;
end



function latency=getReciprocalNewtonSingleRateLatency(blockHandle)

    iterNum=hdlslResolve('NumberOfIterations',blockHandle);

    pHandles=get_param(blockHandle,'PortHandles');
    if isempty(pHandles.Inport)
        latency=0;
        return;
    end
    in1Type=get_param(pHandles.Inport(1),'CompiledPortDataType');
    if~(strcmpi(in1Type,'single')||...
        strcmpi(in1Type,'double')||...
        strcmpi(in1Type,'half'))
        additionalItrs=1;
        latency=additionalItrs+(iterNum*2);
    else

        latency=0;
    end
end


function latency=getReciprocalRsqrtBasedNewtonLatency(blockHandle)



    pHandles=get_param(blockHandle,'PortHandles');
    if isempty(pHandles.Inport)
        latency=0;
        return;
    end

    iterNum=hdlget_param(blockHandle,'Iterations');
    in1Type=get_param(pHandles.Inport(1),'CompiledPortDataType');
    [~,~,signConsideration]=getWordLength(in1Type);

    if signConsideration
        additionalItrs=5;
    else
        additionalItrs=3;
    end

    latency=iterNum+additionalItrs;
end


function latency=getReciprocalRsqrtBasedNewtonSingleRateLatency(blockHandle)


    pHandles=get_param(blockHandle,'PortHandles');
    if isempty(pHandles.Inport)
        latency=0;
        return;
    end

    iterNum=hdlget_param(blockHandle,'Iterations');
    in1Type=get_param(pHandles.Inport(1),'CompiledPortDataType');
    [~,~,signConsideration]=getWordLength(in1Type);

    if signConsideration
        additionalItrs=8;
    else
        additionalItrs=6;
    end
    latency=iterNum*4+additionalItrs;
end


function latency=getSqrtFunctionLatency(blockHandle)

    latency=getSqrtBitsetLatency(blockHandle);
end

function latency=getSqrtBitsetLatency(blockHandle)



    pHandles=get_param(blockHandle,'PortHandles');
    if isempty(pHandles.Inport)
        latency=0;
        return;
    end

    in1Type=get_param(pHandles.Inport(1),'CompiledPortDataType');
    out1Type=get_param(pHandles.Outport(1),'CompiledPortDataType');
    [inputWL,inputFL,~]=getWordLength(in1Type);
    [outputWL,outputFL,outSigned]=getWordLength(out1Type);


    if outSigned
        k=outputWL-1;
    else
        k=outputWL;
    end


    useMul=hdlget_param(blockHandle,'UseMultiplier');
    if strcmpi(useMul,'on')
        algorithmMultOn=true;

    else
        algorithmMultOn=false;
    end

    if(~algorithmMultOn)
        inputIntL=inputWL-inputFL;
        outputIntL=ceil(inputIntL/2);
        newoutWL=outputIntL+outputFL;
        k=min(k,newoutWL);
    end

    pipeline=hdlget_param(blockHandle,'UsePipelines');
    if strcmpi(pipeline,'on')
        latencyStrategy=hdlget_param(blockHandle,'LatencyStrategy');
        if(isempty(latencyStrategy))
            latencyStrategy='MAX';
        end
        if(strcmpi(latencyStrategy,'MAX')||strcmpi(latencyStrategy,'inherit'))
            outputDelay=k+2;
        elseif(strcmpi(sqrtInfo.latencyStrategy,'MIN'))
            outputDelay=floor((k+2)/2);
        elseif(strcmpi(latencyStrategy,'CUSTOM'))
            outputDelay=hdlget_param(blockHandle,'CustomLatency');
        else
            outputDelay=0;
        end
    else
        outputDelay=0;
    end

    latency=outputDelay;
end



function latency=getSqrtNewtonLatency(blockHandle)

    iterNum=hdlget_param(blockHandle,'Iterations');
    additionalItrs=3;

    latency=iterNum+additionalItrs;

end


function latency=getSqrtNewtonSingleRateLatency(blockHandle)


    iterNum=hdlget_param(blockHandle,'Iterations');
    additionalItrs=6;


    latency=iterNum*4+additionalItrs;

end


function latency=getSumCascadeLatency(~)

    latency=1;

end


function latency=getTrigonometricFunctionLatency(blockHandle)




    latency=0;

end


function islut=isNfpLUT(blockType)

    islut=false;
    if strcmpi(blockType,'Lookup_n-D')
        islut=true;
    end
end

function scalarDataType=isScalarDataType(dim)
    scalarDataType=false;
    if~iscell(dim)
        if(((dim(1)==2)&&(dim(2)==1)&&(dim(3)==1))||...
            ((dim(1)==1)&&(dim(2)==1)))
            scalarDataType=true;
        end
    else

        for i=1:length(dim)
            scalarDataType=isScalarDataType(dim{i});
            if~scalarDataType
                return;
            end
        end
    end
end
