function dstP=getBoundaryDstForOutport(outportBlock,ms)





    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    portO=get(outportBlock,'Object');
    assert(isa(portO,'Simulink.Outport'),'This function only support outport block');





    po=portO.getParent;
    blkportnumber=portO.Port;
    ports=str2double(blkportnumber);

    if isa(po,'Simulink.BlockDiagram')



        assert(~strcmp(po.Name,ms.model),'Root level outports should not be here.')

        assert(ms.refMdlToMdlBlk.isKey(po.Handle))
        mblk=ms.refMdlToMdlBlk(po.Handle);
        po=get(mblk,'Object');





        if po.isSynthesized&&~isempty(po.VirtualBusOutportInformation)






            virtualmaps=slslicer.internal.virtual.getVirtualBusPortsMappingInRefModel(po,'outport');
            ports=virtualmaps(str2double(blkportnumber));
        end
    end

    allPortHandles=po.PortHandles;
    portHs=allPortHandles.Outport(ports);
    dstP=portHs;
end
