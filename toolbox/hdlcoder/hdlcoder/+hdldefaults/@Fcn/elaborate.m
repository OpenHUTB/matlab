function hNewC=elaborate(this,hN,hC)





    slhd=hC.SimulinkHandle;
    blkname=getfullname(slhd);


    implParamNames=this.implParamNames;
    implPvPairs=cell(1,numel(implParamNames)*2);
    idx=1;
    for ii=1:numel(implParamNames)
        param=implParamNames{ii};
        if any(strcmp(param,{'InputPipeline','OutputPipeline'}))
            continue;
        end
        val_raw=hdlget_param(blkname,param);

        [~,~,val]=slhdlcoder.SimulinkFrontEnd.validateAndSetNetworkParam(...
        {param,val_raw},blkname);

        assert(~isempty(val),'unexpected implementation parameter found for Fcn block');
        implPvPairs{idx}=param;
        implPvPairs{idx+1}=val;
        idx=idx+2;
    end
    implPvPairs(idx:end)=[];


    ml2pirSettings=[{'OriginalSLHandle',slhd,'ParentNetwork',hN,...
    'SLRate',hC.PirInputSignals.SimulinkRate,'Traceability',hdlgetparameter('Traceability')},...
    implPvPairs];

    fcnInfoRegistry=internal.ml2pir.fcn.FunctionInfoRegistryCache.getCacheValue(blkname);

    fcnTypeInfo=fcnInfoRegistry.registry.values;
    fcnTypeInfo=fcnTypeInfo{1};

    builder=internal.ml2pir.fcn.PIRGraphBuilder(ml2pirSettings{:});

    fcn2pir=internal.ml2pir.Function2SubsystemConverter(...
    fcnInfoRegistry,[],fcnTypeInfo,builder);

    fcnNtwk=get_param(blkname,'Name');
    hNewC=fcn2pir.run(fcnNtwk);


    hC.PirInputSignal.addReceiver(hNewC.PirInputPort(1));
    hC.PirOutputSignal.addDriver(hNewC.PirOutputPort(1));
    hN.removeComponent(hC);
end
