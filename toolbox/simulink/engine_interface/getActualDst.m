function actDst=getActualDst(blk,portIdx)

































    hBlk=get_param(blk,'Handle');

    if hasActualDstInfo(hBlk,portIdx)
        hPh=get_param(hBlk,'PortHandles');
        ports=get_param(hBlk,'Ports');
        nOPorts=ports(2);
        nSPorts=ports(5);
        maxIdx=nOPorts+nSPorts;

        if portIdx<=nOPorts
            h=get_param(hPh.Outport(portIdx),'Object');
        elseif portIdx<=maxIdx
            error('getActualDst:state','State port not supported')
        else
            error('getActualDst:invalididx','port index must be <= %d',maxIdx)
        end
        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
        actDst=h.getActualDst;
        delete(sess);
    else
        actDst=-1;
    end

end
