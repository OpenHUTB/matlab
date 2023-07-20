function v=validate(this,hC)




    v=hdlvalidatestruct;
    blkH=hC.SimulinkHandle;
    blkname=getfullname(blkH);


    if~hdlgetparameter('using_ml2pir')

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:engine:missingImplementation',blkname));
        return
    elseif~targetcodegen.targetCodeGenerationUtils.isNFPMode

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nfponlyblock'));
        return
    end


    mlfbImplParams=this.implParamNames;
    for i=1:numel(mlfbImplParams)
        param=mlfbImplParams{i};
        value=hdlget_param(blkname,param);


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
        if~isempty(msgobj)
            v(end+1)=hdlvalidatestruct(level,msgobj);%#ok<AGROW>
        end
    end
    if any(arrayfun(@(x)x.Status==1,v))
        return;
    end


    fcnInfoRegistry=...
    internal.ml2pir.fcn.FunctionInfoRegistryCache.retrieveAndSetCacheValue(blkname,hC);


    fcnInfos=fcnInfoRegistry.getAllFunctionTypeInfos;
    messages=cell(1,numel(fcnInfos));

    constrainerArgs=internal.ml2pir.constrainer.PIRConstrainerArgs;
    constrainerArgs.IsNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;

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


