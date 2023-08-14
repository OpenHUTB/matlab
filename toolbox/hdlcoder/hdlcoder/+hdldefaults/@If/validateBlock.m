function v=validateBlock(~,hC)




    v=hdlvalidatestruct;
    blkH=hC.SimulinkHandle;
    blkname=getfullname(blkH);


    if strcmp(hdlfeature('EnableConditionalSubsystem'),'off')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:engine:missingImplementation',getfullname(blkH)));
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
