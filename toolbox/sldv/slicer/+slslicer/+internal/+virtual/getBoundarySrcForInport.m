function srcP=getBoundarySrcForInport(inportPort,ms)





    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    portO=get(inportPort,'Object');
    assert(isa(portO,'Simulink.Inport'),'This function only support inport block.');





    po=portO.getParent;
    if isempty(po)
        parentName=portO.Parent;
        po=get_param(parentName,'Object');
    end

    blkportnumber=portO.Port;
    ports=str2double(blkportnumber);

    if isa(po,'Simulink.BlockDiagram')



        assert(~strcmp(po.Name,ms.model),'Root level inports should not be here.')

        assert(ms.refMdlToMdlBlk.isKey(po.Handle))
        mblk=ms.refMdlToMdlBlk(po.Handle);
        po=get(mblk,'Object');





        if po.isSynthesized&&~isempty(po.VirtualBusInportInformation)





            virtualmaps=slslicer.internal.virtual.getVirtualBusPortsMappingInRefModel(po,'inport');
            ports=virtualmaps(ports);
        end
    end
    allPortHandles=po.PortHandles;
    portHs=allPortHandles.Inport(ports);
    srcP=portHs;
end

