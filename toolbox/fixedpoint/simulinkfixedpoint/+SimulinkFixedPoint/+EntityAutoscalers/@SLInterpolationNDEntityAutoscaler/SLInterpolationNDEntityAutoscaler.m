classdef SLInterpolationNDEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler











    methods
        associateRecords=gatherAssociatedParam(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        sharedLists=gatherSharedDT(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        [isForBlkParam,blkParamName]=isPathItemForBlockParam(h,srcBlk,pathItem)

    end

    methods(Hidden)
        res=getBlockMaskTypeAttributes(h,blkObj,pathItem)
        [isValid,minimumValue,maximumValue,parameterObject]=getTableData(h,blockObject)
    end

    methods(Access=private)


        [indexPortsNums,fracPortNums,busPortNums,selectPortNums]=analyzeInports(h,blkObj);
    end

    methods(Static)
        hasConstraint=hasFloatingPointConstraint(blockObject);
    end
end