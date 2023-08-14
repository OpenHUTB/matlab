function[designMin,designMax,compiledDT,removeResult]=getModelCompiledDesignRange(h,blkObj,~)





    designMin=[];
    designMax=[];
    removeResult=false;

    compiledDT=blkObj.CompiledType;
    if strcmpi(blkObj.Scope,'output')&&~isempty(blkObj.Port)&&~isnan(blkObj.Port)&&~isinf(blkObj.Port)
        sfData=blkObj;

        chartId=sf('DataChartParent',sfData.Id);
        blkHandle=sf('Private','chart2block',chartId);
        blkObj=get_param(blkHandle,'Object');
        blkPorts=blkObj.PortHandles;
        if isempty(blkPorts.Outport)
            return;
        end
        blkOutport=blkPorts.Outport(sfData.Port);

        if h.hIsVirtualBus(blkOutport)||h.hIsNonVirtualBus(blkOutport)
            removeResult=true;
            compiledDT='';
        else
            designMinRaw=get_param(blkOutport,'CompiledPortDesignMin');
            designMaxRaw=get_param(blkOutport,'CompiledPortDesignMax');

            designMin=SimulinkFixedPoint.AutoscalerUtils.RestructureDesignRanges(designMinRaw);
            designMax=SimulinkFixedPoint.AutoscalerUtils.RestructureDesignRanges(designMaxRaw);

            compiledDT=get_param(blkOutport,'CompiledPortDataType');
        end
    end

    switch compiledDT
    case{'double','single','boolean'}

    otherwise
        try
            [dtObj,isScaledDouble]=fixdt(compiledDT);
            compiledDT=fixdt(dtObj);
            if isScaledDouble
                compiledDT=['Scaled Double of ',compiledDT];
            end
        catch e %#ok<NASGU>

        end
    end

