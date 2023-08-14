function[designMin,designMax,compiledDT,removeResult]=getCompiledRangeInfo(h,blkObj,blkPathItem)






    designMin=[];
    designMax=[];
    compiledDT='';
    removeResult=false;

    blkPorts=blkObj.PortHandles;
    if isempty(blkPorts.Outport)
        return;
    end

    blkOutport=[];
    pathItems=h.getPortMapping(blkObj,[],1:length(blkPorts.Outport));
    str_idx=strcmp(pathItems,blkPathItem);
    idx=find(str_idx==1);
    if~isempty(idx)
        blkOutport=blkPorts.Outport(idx);
    end

    if~isempty(blkOutport)
        if h.hIsVirtualBus(blkOutport)||h.hIsNonVirtualBus(blkOutport)
            removeResult=true;
        else
            designMinRaw=get_param(blkOutport,'CompiledPortDesignMin');
            designMaxRaw=get_param(blkOutport,'CompiledPortDesignMax');

            designMin=SimulinkFixedPoint.AutoscalerUtils.RestructureDesignRanges(designMinRaw);
            designMax=SimulinkFixedPoint.AutoscalerUtils.RestructureDesignRanges(designMaxRaw);

            compiledDT=get_param(blkOutport,'CompiledPortDataType');
            switch compiledDT
            case{'double','single','boolean'}

            otherwise
                try
                    [dtObj,isScaledDouble]=fixdt(compiledDT);
                    compiledDT=fixdt(dtObj);
                    if isScaledDouble
                        compiledDT=['Scaled Double of ',compiledDT];
                    end
                catch e %#ok



                end
            end
        end
    end



