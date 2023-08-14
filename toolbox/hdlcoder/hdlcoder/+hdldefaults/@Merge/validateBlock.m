function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    blkH=hC.SimulinkHandle;
    blkname=getfullname(blkH);

    unequalPortWidths=get_param(blkH,'AllowUnequalInputPortWidths');
    if strcmp(unequalPortWidths,'on')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:mergeUnequalInputWidth'));
    end



    inputSignals=hC.PirInputSignals;
    for ii=1:numel(inputSignals)
        actionSignal=this.findActionSignalInNtwk(inputSignals(ii));
        if isempty(actionSignal)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:condMergeNotSameLevel'));%#ok<AGROW> 
            break;
        end
    end


    [fcnInfoRegistry,createFcnInfoMsgs]=...
    internal.ml2pir.ifmerge.FunctionInfoRegistryCache.retrieveAndSetCacheValue(blkname,hC);

    if~internal.mtree.Message.containErrorMsgs(createFcnInfoMsgs)
        constrainerArgs=internal.ml2pir.constrainer.PIRConstrainerArgs;
        constrainerArgs.IntsSaturate=false;
        constrainerArgs.IsNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;

        exprMap=containers.Map;


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
end
