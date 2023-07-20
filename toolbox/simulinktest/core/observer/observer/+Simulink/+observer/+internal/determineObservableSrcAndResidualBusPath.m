function ret=determineObservableSrcAndResidualBusPath(phObj,elementString)


























































    nvBus=strcmp(phObj.CompiledBusType,'NON_VIRTUAL_BUS');
    notBus=strcmp(phObj.CompiledBusType,'NOT_BUS');
    vBus=strcmp(phObj.CompiledBusType,'VIRTUAL_BUS');

    if notBus





        if strcmp(phObj.PortType,'inport')

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            ret.observedPort=phObj.getGraphicalSrc;
            delete(sess);
        else
            ret.observedPort=phObj.Handle;
        end
        ret.elems=[];

    elseif nvBus

        if strcmp(phObj.PortType,'inport')

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            ret.observedPort=phObj.getGraphicalSrc;
            delete(sess);
        else
            ret.observedPort=phObj.Handle;
        end
        elems=[];
        if~isempty(elementString)



            elems=Simulink.observer.internal.extractSignalNames(elementString);
        end
        ret.elems=elems;
    else
        assert(vBus);


        assert(~isempty(elementString));
        elems=Simulink.observer.internal.extractSignalNames(elementString);





        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);

        if strcmp(phObj.PortType,'outport')



            dst=phObj.getGraphicalDst;
            if isempty(dst)
                assert(false);
            end
            phObj=get_param(dst(1),'Object');

        end
        busSrcInfo=phObj.getActualSrcForVirtualBus;
        delete(sess);

        ret=findNVBoundary(busSrcInfo,elems,phObj,elementString);
    end

end



function ret=findNVBoundary(busSrcInfo,elems,phObj,origSel)
    assert(isa(busSrcInfo,'containers.Map'));

    assert(busSrcInfo.isKey(elems(1).name),"Could not find the element in the bus src map");
    elemSrcInfo=busSrcInfo(elems(1).name);

    if isa(elemSrcInfo,'containers.Map')



        assert(isscalar(elems(1).index)&&elems(1).index==-1);



        elems(1)=[];

        ret=findNVBoundary(elemSrcInfo,elems,phObj,origSel);
    else

        if elemSrcInfo(1,4)~=-1



            DAStudio.error('Simulink:SltBlkMap:partialSliceObservationNotSupported',...
            origSel,phObj.PortNumber,phObj.Parent);
        end

        ret.observedPort=elemSrcInfo(1,1);
        busType=get_param(elemSrcInfo(1,1),'CompiledBusType');

        if strcmp(busType,'NON_VIRTUAL_BUS')
            if elems(1).index~=-1






                elems(1).name='';
            else





                elems(1)=[];
            end
            ret.elems=elems;
        else

            elems(1)=[];
            assert(strcmp(busType,'NOT_BUS'));
            assert(isempty(elems));
            ret.elems=[];
        end
    end
end