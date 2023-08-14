function new_hC=elaborate(~,hN,hC)





    slbh=hC.SimulinkHandle;
    blkname=getfullname(slbh);
    hOutSignals=hC.PirOutputSignals;
    hInSignals=hC.PirInputSignals;


    ml2pirSettings={'OriginalSLHandle',slbh,'ParentNetwork',hN,...
    'SLRate',hC.PirInputSignals(1).SimulinkRate};

    fcnInfoRegistry=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.getCacheValue(blkname);

    fcnTypeInfo=fcnInfoRegistry.registry.values;
    fcnTypeInfo=fcnTypeInfo{1};

    builder=internal.ml2pir.ifmerge.PIRGraphBuilder(ml2pirSettings{:});

    fcn2pir=internal.ml2pir.Function2SubsystemConverter(...
    fcnInfoRegistry,[],fcnTypeInfo,builder);

    fcnNtwk=get_param(blkname,'Name');
    new_hC=fcn2pir.run(fcnNtwk);


    for ii=1:numel(hInSignals)
        hInSignals(ii).addReceiver(new_hC,ii-1);
    end

    for ii=1:numel(hOutSignals)
        outSignal=hOutSignals(ii);
        outSignal.addDriver(new_hC,ii-1);
    end

end
