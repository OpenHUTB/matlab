function v=ml2pirValidate(this,hC)




    v=hdlvalidatestruct;
    blkH=hC.SimulinkHandle;
    blkname=getfullname(blkH);

    if strcmp(hdlfeature('EnableFlattenSFComp'),'off')
        hDriver=hdlcurrentdriver;
        if strcmpi(hDriver.getCLI.InlineMATLABBlockCode,'on')

            msgobj=message('hdlcommon:matlab2dataflow:InlineGlobalNotAlwaysHonored');
            v(end+1)=hdlvalidatestruct(3,msgobj);
        end
    end



    mlfbImplParams=this.implParamNames;
    for i=1:numel(mlfbImplParams)
        msgobj=[];
        level=0;
        param=mlfbImplParams{i};
        value=hdlget_param(blkname,param);
        switch param
        case 'LoopOptimization'

            if~strcmpi(value,'unrolling')
                msgobj=message('hdlcommon:matlab2dataflow:LoopsAlwaysUnrolled',value);
                level=2;
            end
        case 'VariablesToPipeline'

            value=strtrim(value);
            if~isempty(value)
                msgobj=message('hdlcommon:matlab2dataflow:PipelineWithPragma',value);
                level=2;
            end
        case 'UseMatrixTypesInHDL'


            if strcmpi(value,'off')
                msgobj=message('hdlcommon:matlab2dataflow:MatrixTypesAlwaysUsed');
                level=3;
            end
        otherwise

            [msgobj,level]=slhdlcoder.SimulinkFrontEnd.validateAndSetNetworkParam(...
            {param,value},blkname);
            if~isempty(msgobj)
                switch lower(level)
                case 'error'
                    level=1;
                case 'warning'
                    level=2;
                case 'message'
                    level=3;
                otherwise
                    error('unexpected message level found');
                end
            end
        end
        if~isempty(msgobj)
            v(end+1)=hdlvalidatestruct(level,msgobj);%#ok<AGROW>
        end
    end
    if any(arrayfun(@(x)x.Status==1,v))
        return;
    end




    ins=hC.PirInputSignals;
    portHandles=get_param(blkH,'PortHandles');
    inPorts=portHandles.Inport;
    for i=1:numel(ins)
        type=ins(i).Type;
        if type.isRecordType
            if~(any(cellfun(@isempty,type.MemberAliasNames)))
                sigHrchy=get_param(inPorts(i),'SignalHierarchy');
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcommon:matlab2dataflow:ML2PIRBusAliasNotSupported',...
                ins(i).Name,sigHrchy.BusObject));%#ok<AGROW>
            end
        end
    end
    if any(arrayfun(@(x)x.Status==1,v))
        return;
    end


    chartData=internal.ml2pir.mlfb.getChartData(this,blkH);
    [fcnInfoRegistry,exprMap,~,createFcnInfoMsgs]=...
    internal.ml2pir.mlfb.FunctionInfoRegistryCache.retrieveAndSetCacheValue(blkname,chartData);

    if~internal.mtree.Message.containErrorMsgs(createFcnInfoMsgs)
        constrainerArgs=internal.ml2pir.constrainer.PIRConstrainerArgs;
        constrainerArgs.IsNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;
        constrainerArgs.IntsSaturate=internal.ml2pir.mlfb.getIntegersSaturateOnOverflow(blkname);
        constrainerArgs.FrameToSampleConversion=hdlgetparameter('FrameToSampleConversion');
        constrainerArgs.SamplesPerCycle=hdlgetparameter('SamplesPerCycle');


        constrMsgs=internal.ml2pir.constrainer.runPIRConstrainer(fcnInfoRegistry,exprMap,constrainerArgs);
    else
        constrMsgs=internal.mtree.Message.empty;
    end

    messages=[createFcnInfoMsgs,constrMsgs];


    v_constrainer=repmat(hdlvalidatestruct,1,numel(messages));

    for i=1:numel(messages)
        v_constrainer(i)=messages(i).toHdlValidateStruct;
    end

    v=[v,v_constrainer];


    chartH=internal.ml2pir.mlfb.getChartHandle(blkname);
    triggers=chartH.find('-isa','Stateflow.Trigger');

    if~isempty(triggers)
        msg=hdlvalidatestruct(1,message('hdlcommon:matlab2dataflow:ML2PIRTriggerInput'));
        v=[v,msg];
    end

end


