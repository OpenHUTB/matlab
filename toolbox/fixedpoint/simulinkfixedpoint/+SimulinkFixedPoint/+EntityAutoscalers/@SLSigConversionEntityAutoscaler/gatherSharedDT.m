function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};
    ph=blkObj.PortHandles;

    if hIsVirtualBus(h,ph.Outport(1))
        outPortObj=get_param(ph.Outport(1),'Object');
        if isAnyDestVec(h,outPortObj)||isHiddenBusCopyBuffer(h,blkObj)
            sharedLists=hShareDTAllInputVirBusSrcAndOutput(h,blkObj);
        end
    else
        if isCopyMode(blkObj)
            sameDTAllPorts=hShareDTSpecifiedPorts(h,blkObj,-1,-1);
            sharedLists=h.hAppendToSharedLists(sharedLists,sameDTAllPorts);
        end
    end



    function destIsVec=isAnyDestVec(h,outPortObj)

        destIsVec=false;


        inDownstreamPortHhandles=outPortObj.getActualDst;
        if~isempty(inDownstreamPortHhandles)
            inDownstreamPortH_vec=inDownstreamPortHhandles(:,1);
            for i=1:length(inDownstreamPortH_vec)
                inDownstreamPortH=inDownstreamPortH_vec(i);
                if~hIsVirtualBus(h,inDownstreamPortH)
                    destIsVec=true;
                    return;
                end
            end
        end


        function isHidBusCopyBuf=isHiddenBusCopyBuffer(h,SigConvObj)
            isHidBusCopyBuf=false;

            if SigConvObj.isSynthesized&&isCopyMode(SigConvObj)
                ph=SigConvObj.PortHandles;
                if hIsVirtualBus(h,ph.Inport)&&hIsVirtualBus(h,ph.Outport)
                    isHidBusCopyBuf=true;
                end
            end


            function copymode=isCopyMode(SigConvObj)
                copymode=false;
                conversionOutput=SigConvObj.ConversionOutput;
                if strcmp(conversionOutput,'Signal copy')||...
                    strcmp(conversionOutput,'Contiguous copy')
                    copymode=true;
                end