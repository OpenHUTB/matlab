function[v]=baseSFValidate(this,hC)


    v=validateImplParams(this,hC);




    v_settings=this.get_validate_settings(hC);
    if v_settings.checkretimeincompatibility
        v=[v,validateRetimingCompatibility(this,hC.Owner)];
    end

    if(v_settings.checkretimeblackbox)
        v=[v,validateRetimingBlackbox(this,hC.Owner)];
    end

    if(v_settings.incompatibleforxilinx)
        v=[v,validateXilinxCoregenCompatibility(this,hC)];
    end

    if(v_settings.incompatibleforaltera)
        v=[v,validateAlteraMegafunctionCompatibility(this,hC)];
    end

    if(v_settings.checkmatrices)
        v=[v,validateMatrices(this,hC,v_settings.maxsupporteddimension)];
    end


    maxOversampling=hdlgetparameter('maxoversampling');
    if(maxOversampling>0&&maxOversampling~=inf&&v_settings.checksingleratesharing)
        v=[v,validateSinglerateSharing(this,hC.Owner,hC)];
    end





    if strcmp(hdlfeature('EnableFlattenSFComp'),'on')&&hC.Owner.getFlattenSFHolderNetwork&&~isempty(hC.PirInputPorts)&&~strcmp(hC.PirInputPorts(end).Kind,'data')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:CannotInlineChartsWithEvents'));
    end




    chartId=sfprivate('block2chart',hC.simulinkHandle);
    rt=sfroot;
    chartH=rt.idToHandle(chartId);
    v=[v,checkChartSettings(this,chartH)];
    v=[v,checkChartParameters(chartH,hC.simulinkHandle)];
    v=[v,checkForAtomicSubcharts(chartH)];
    v=[v,checkForSimulinkFunctions(chartH)];
    try


        hdldefaults.abstractRegister.findSingleRateSignal(hC);
    catch



        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:singlerate'));
    end

    if this.isStateflowChart(chartH)
        v=checkStateflowSettings(this,v);
    end

    if hdlgetparameter('EnableTestpoints')
        v=warnIfStateFlowTestpointsPresent(this,chartH,v);
    end




    phan=get_param(hC.SimulinkHandle,'PortHandles');
    triggerPortWidth=get_param(phan.Trigger,'CompiledPortWidth');

    distPipe=getImplParams(this,'DistributedPipelining');
    distPipe=~isempty(distPipe)&&strcmp(distPipe,'on');
    if~isempty(triggerPortWidth)
        if distPipe
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:SFInEventDistPipe'));
        end

        if triggerPortWidth>1
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:MultipleInputEvents'));
        end

        triggerIdx=length(hC.PirInputSignals);
        if(triggerIdx>0)
            triggerSig=hC.PirInputSignals(triggerIdx);
            triggerType=triggerSig.Type;
            if triggerType.isArrayType


                triggerType=triggerType.BaseType;
            end
            if~triggerType.isBooleanType&&~triggerType.isUnsignedType(1)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:InputEventType'));
            end
        end

        hNIC=hC.Owner.instances;
        result=checkRates(hNIC);
        if~isempty(result)
            for j=1:length(result)
                v(end+1)=result;%#ok<AGROW>
            end
        end
    end



    sharingFactor=getImplParams(this,'SharingFactor');
    loopOpt=getImplParams(this,'LoopOptimization');
    mapRam=getImplParams(this,'MapPersistentVarsToRAM');
    varPipe=getImplParams(this,'VariablesToPipeline');
    inputPipe=getImplParams(this,'InputPipeline');
    outputPipe=getImplParams(this,'outputPipeline');







    if~isempty(triggerPortWidth)
        if~isempty(inputPipe)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:stateflow:triggerPortInPipeConflict',...
            'InputPipeline',inputPipe));
        end

        if~isempty(outputPipe)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:stateflow:triggerPortOutPipeConflict',...
            'OutputPipeline',outputPipe));
        end
    end



    if~isempty(triggerPortWidth)||hC.Owner.hasTriggeredInstances
        if(~isempty(sharingFactor)&&(sharingFactor>0))
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:stateflow:triggerPortSharingConflict',...
            'SharingFactor',sharingFactor));
        end

        badParamName=[];

        if(~isempty(loopOpt)&&strcmp(loopOpt,'Streaming'))
            badParamName='LoopOptimization';
        end

        if(~isempty(mapRam)&&strcmp(mapRam,'on'))
            badParamName='MapPersistentVarsToRAM';
        end

        if~isempty(varPipe)
            badParamName='VariablesToPipeline';
        end

        if~isempty(badParamName)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:stateflow:triggerPortOptimConflict',...
            badParamName,getImplParams(this,badParamName)));
        end
    end


    msgObj=validateForFloatPorts(this,hC);
    if~isempty(msgObj)
        v(end+1)=hdlvalidatestruct(1,msgObj);
    end


    r=sfroot;
    chartUddH=r.idToHandle(chartId);
    chartParams=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');
    for ii=1:numel(chartParams)
        paramName=chartParams(ii).Name;
        [~,v1]=hdlbuiltinimpl.EmlImplBase.getTunableParameter(hC.SimulinkHandle,paramName);
        if~isempty(v1)
            v(end+1)=v1;%#ok<AGROW>
        end
    end
end


function result=checkChartSettings(this,chartH)
    result=[];
    if this.isStateflowChart(chartH)

        if chartH.exportChartFunctions==1
            result=[result,hdlvalidatestruct(1,message('hdlcoder:stateflow:badexportfunctions'))];
        end

        if(strcmpi(chartH.StateMachineType,'Moore'))&&(chartH.InitializeOutput~=1)
            hDriver=hdlcurrentdriver;


            if~(hDriver.getParameter('SplitMooreChartStateUpdate'))
                result=[result,hdlvalidatestruct(1,message('hdlcoder:stateflow:badinitoutput',hDriver.ModelName))];
            end
        end
    end
end



function result=checkChartParameters(chartH,slbh)
    result=[];
    chartParams=chartH.find('-isa','Stateflow.Data','Scope','Parameter');
    for ii=1:numel(chartParams)
        if chartParams(ii).Tunable
            if~sfprivate('is_eml_chart_block',slbh)
                if strcmpi(chartParams(ii).ParsedInfo.Type.Base,'structure')
                    msg=message('hdlcoder:stateflow:unsupportedparamstruct',...
                    chartParams(ii).Name,chartParams(ii).Path);
                    result=[result,hdlvalidatestruct(1,msg)];%#ok<AGROW>
                end
                if strcmpi(chartParams(ii).ParsedInfo.Complexity,'on')
                    msg=message('hdlcoder:stateflow:unsupportedparamcomplex',...
                    chartParams(ii).Name,chartParams(ii).Path);
                    result=[result,hdlvalidatestruct(1,msg)];%#ok<AGROW>
                end
                if~isempty(chartParams(ii).ParsedInfo.Array.Size)
                    msg=message('hdlcoder:stateflow:unsupportedparamarray',...
                    chartParams(ii).Name,chartParams(ii).Path);
                    result=[result,hdlvalidatestruct(1,msg)];%#ok<AGROW>
                end

            end
        end
    end
end



function result=checkForSimulinkFunctions(chartH)
    result=[];
    slfHandles=chartH.find('-isa','Stateflow.SLFunction','IsExplicitlyCommented',false,'IsImplicitlyCommented',false);
    if~isempty(slfHandles)
        for ii=1:numel(slfHandles)
            msg=message('hdlcoder:stateflow:SLFunctionUnsupported',...
            [slfHandles(ii).Path,'/',slfHandles(ii).Name]);
            result=[result,hdlvalidatestruct(1,msg)];%#ok <AGROW>
        end
    end
end



function result=checkForAtomicSubcharts(chartH)
    result=[];
    ascHandles=chartH.find('-isa','Stateflow.AtomicSubchart','IsExplicitlyCommented',false,'IsImplicitlyCommented',false);
    if~isempty(ascHandles)
        for ii=1:numel(ascHandles)
            msg=message('hdlcoder:stateflow:AtomicSubchartUnsupported',...
            [ascHandles(ii).Path,'/',ascHandles(ii).Name]);
            result=[result,hdlvalidatestruct(1,msg)];%#ok <AGROW>
        end
    end
end


function result=checkRates(hNIC)
    result=[];
    numInstances=length(hNIC);
    for i=1:numInstances
        current=hNIC(i);
        sigs=[current.PirInputSignals;current.PirOutputSignals];
        ratesMatch=checkSignalRates(sigs);
        if~ratesMatch
            result=hdlvalidatestruct(1,message('hdlcoder:stateflow:mismatchedRates'));
        end
    end
end



function allMatch=checkSignalRates(signals)
    allMatch=true;
    singleRate=[];
    if~isempty(signals)
        for i=1:length(signals)
            currentRate=signals(i).SimulinkRate;
            if~isinf(currentRate)&&currentRate~=-1
                if isempty(singleRate)
                    singleRate=currentRate;
                else
                    if currentRate~=singleRate
                        allMatch=false;
                        break;
                    end
                end
            end
        end
    end
end


function v=checkStateflowSettings(this,v)


    varpipes=getImplParams(this,'VariablesToPipeline');
    if~isempty(varpipes)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:VariablePipelineUnsupported'));
    end

    ramMapping=getImplParams(this,'MapPersistentVarsToRAM');
    if~isempty(ramMapping)&&~strcmpi(ramMapping,'off')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:UnsupportedOptim','MapPersistentVarsToRAM'));
    end

    loopopts=getImplParams(this,'LoopOptimization');
    if~isempty(loopopts)&&strcmpi(loopopts,'Streaming')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:LoopStreamingUnsupported'));
    end

    sharing=getImplParams(this,'SharingFactor');
    if~isempty(sharing)&&sharing>1
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:SharingUnsupported'));
    end

end




function v=warnIfStateFlowTestpointsPresent(~,chartH,v)
    States=chartH.find('-isa','Stateflow.State');
    for ii=1:length(States)
        if(States(ii).Testpoint)
            msgObj=message('hdlcoder:stateflow:featureTestpointIgnoresStateTestpoint');
            v(end+1)=hdlvalidatestruct(2,msgObj);%#ok<AGROW>
            return;
        end
    end
end






