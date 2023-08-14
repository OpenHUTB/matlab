function actSrc=getActualSrc(blk,portIdx)
































    hBlk=get_param(blk,'Handle');

    if hasActualSrcInfo(hBlk,portIdx)
        hPh=get_param(hBlk,'PortHandles');
        ports=get_param(hBlk,'Ports');
        nIPorts=ports(1);
        nCPorts=ports(3)+ports(4)+ports(8);
        maxIdx=nIPorts+nCPorts;

        if hasInvisibleInput(hBlk)

            if~isequal(portIdx,1)
                error('getActulSrc:portidxne1','Port index must be 1')
            end
            h=get_param(hBlk,'Object');
        elseif portIdx<=nIPorts

            h=get_param(hPh.Inport(portIdx),'Object');
        elseif portIdx<=maxIdx

            portType=getActualSrcPortType(hBlk,portIdx);
            cpH=getActualSrcControlPort(hPh,portType);
            h=get_param(cpH,'Object');
        else
            error('getActualSrc:invalididx','Port index must be <= %d',maxIdx)
        end
        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
        actSrc=h.getActualSrc;
        delete(sess);
    else
        actSrc=-1;
    end

end
