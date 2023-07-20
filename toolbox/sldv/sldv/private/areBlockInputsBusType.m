function yesno=areBlockInputsBusType(blockH)




    yesno=false;
    phs=get_param(blockH,'PortHandles');

    for i=1:length(phs.Inport)
        hdl=phs.Inport(i);
        busType=get_param(hdl,'CompiledBusType');
        if~(strcmp(busType,'NOT_BUS')||...
            strcmp(busType,'VIRTUAL_BUS'))
            yesno=true;
        end
    end
end
