function sharedDTLists=hShareSrcAtSamePort(h,blkObj)




    sharedDTLists={};
    ph=blkObj.PortHandles;
    for portNumb=1:length(ph.Inport)
        portObj=get_param(ph.Inport(portNumb),'Object');
        sharedDTatOnePort=getAllSourceSignal(h,portObj,false);

        if length(sharedDTatOnePort)>1
            sharedDTLists{end+1}=sharedDTatOnePort;%#ok
            continue;
        end

        if length(sharedDTatOnePort)==1&&...
            isHiddenBusCopyBuffer(h,sharedDTatOnePort{1}.blkObj)
            sharedDTLists{end+1}=sharedDTatOnePort;%#ok
            continue;
        end

    end



    function isHidBusCopyBuf=isHiddenBusCopyBuffer(h,blkObj)
        isHidBusCopyBuf=false;

        if isa(blkObj,'Simulink.SignalConversion')&&...
            blkObj.isSynthesized&&isCopyMode(blkObj)
            ph=blkObj.PortHandles;
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




