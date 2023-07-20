function adapter=makeAdapter(compHandl)







    blckHandle=compHandl.SimulinkHandle;



    ph=get_param(compHandl.SimulinkHandle,'PortHandles');
    if length(ph.Inport)<1||length(ph.Outport)~=1||~isempty(ph.LConn)||~isempty(ph.RConn)
        systemcomposer.internal.adapter.resetPorts(compHandl.SimulinkHandle);
    end

    SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(blckHandle,SimulinkSubDomainMI.SimulinkSubDomainEnum.ArchitectureAdapter);

    adapterImpl=systemcomposer.utils.getArchitecturePeer(blckHandle);
    adapterImpl.setIsAdapterComponent(true);
    adapter=systemcomposer.internal.getWrapperForImpl(adapterImpl,'systemcomposer.arch.Component');


    ps=get_param(adapter.SimulinkHandle,'PortSchema');
    set_param(adapter.SimulinkHandle,'PortSchema',ps);
end

