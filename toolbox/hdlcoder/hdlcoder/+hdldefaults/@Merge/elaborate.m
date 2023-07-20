function new_hC=elaborate(this,hN,hC)





    slbh=hC.SimulinkHandle;
    blkname=getfullname(slbh);


    ml2pirSettings={'OriginalSLHandle',slbh,'ParentNetwork',hN,...
    'SLRate',hC.PirInputSignals(1).SimulinkRate,'Traceability',hdlgetparameter('Traceability')};

    fcnInfoRegistry=internal.ml2pir.ifmerge.FunctionInfoRegistryCache.getCacheValue(blkname);

    fcnTypeInfo=fcnInfoRegistry.registry.values;
    fcnTypeInfo=fcnTypeInfo{1};

    builder=internal.ml2pir.ifmerge.PIRGraphBuilder(ml2pirSettings{:});

    fcn2pir=internal.ml2pir.Function2SubsystemConverter(...
    fcnInfoRegistry,[],fcnTypeInfo,builder);

    fcnNtwk=get_param(blkname,'Name');
    new_hC=fcn2pir.run(fcnNtwk);


    inputSignals=hC.PirInputSignals;
    inputNum=numel(inputSignals);
    for ii=0:inputNum-1
        inputSignal=inputSignals(ii+1);
        conditionInputIdx=ii+inputNum;

        inputSignal.addReceiver(new_hC,ii);

        actionSignal=this.findActionSignalInNtwk(inputSignal);
        assert(~isempty(actionSignal),'unable to find the ifaction signal path in same network as merge');
        actionSignal.addReceiver(new_hC,conditionInputIdx);


    end

    originalOutputSignal=hC.PirOutputSignals(1);
    originalOutputSignal.addDriver(new_hC,0);



    yPrev=hN.addSignal(originalOutputSignal.Type,[originalOutputSignal.Name,'_prev']);
    yPrev.SimulinkRate=originalOutputSignal.SimulinkRate;
    yPrev.addReceiver(new_hC,numel(new_hC.PirInputPorts)-1);
    yDelay=pirelab.getIntDelayComp(hN,originalOutputSignal,yPrev,1);

    yDelay.OrigModelHandle=slbh;
    yDelay.copyComment(hC);




    refNwOut=new_hC.ReferenceNetwork.PirOutputSignals;
    assert(isscalar(refNwOut));

    hN.flattenNic(new_hC);


    port_buffer=refNwOut.getReceivers.Owner;
    assert(isa(port_buffer,'hdlcoder.buffer_comp'));
    originalOutputSignal.acquireDrivers(refNwOut);
    originalOutputSignal.disconnectDriver(port_buffer.PirOutputPorts);

    hN.removeComponent(hC);


    new_hC=originalOutputSignal.getConcreteDrivingComps;
end


