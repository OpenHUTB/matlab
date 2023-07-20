


function v=validateBlock(~,hC)
    if slfeature('STVariantsInHDL')==0
        return;
    end
    v=hdlvalidatestruct;

    blkname=getfullname(hC.OrigModelHandle);
    fcnInfoRegistry=...
    internal.ml2pir.variantmerge.FunctionInfoRegistryCache.retrieveAndSetCacheValue(blkname,hC);

    constrainerArgs=internal.ml2pir.constrainer.PIRConstrainerArgs;
    constrainerArgs.IsNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;


    fcnInfos=fcnInfoRegistry.getAllFunctionTypeInfos;
    messages=cell(1,numel(fcnInfos));

    for i=1:numel(fcnInfos)
        constrainer=internal.ml2pir.constrainer.PIRConstrainer(fcnInfos{i},...
        [],fcnInfoRegistry,constrainerArgs);


        messages{i}=constrainer.run;
    end
    messages=[messages{:}];

    v_constrainer=repmat(hdlvalidatestruct,1,numel(messages));

    for i=1:numel(messages)
        v_constrainer(i)=messages(i).toHdlValidateStruct;
    end
    v=[v,v_constrainer];
end
