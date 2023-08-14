function hidSrc=hGetHiddenNonVirBusSrc(h,portObj,isAlreadySrcPort)















    hidSrc=[];

    if hIsNonVirtualBus(h,portObj.Handle)

        [srcSigID.blkObj,srcSigID.pathItem,srcSigID.srcInfo]=...
        getSourceSignal(h,portObj,isAlreadySrcPort);

        if fxptds.isStateflowChartObject(srcSigID.blkObj)||...
            isa(srcSigID.blkObj,'Stateflow.Data')
            return;
        end


        if~isempty(srcSigID.blkObj)&&~isempty(srcSigID.pathItem)...
            &&srcSigID.blkObj.isSynthesized

            hidSrc=srcSigID;
        end
    end



