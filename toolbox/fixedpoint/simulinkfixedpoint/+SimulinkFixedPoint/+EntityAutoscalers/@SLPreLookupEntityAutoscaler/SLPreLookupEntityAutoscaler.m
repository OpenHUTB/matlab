classdef SLPreLookupEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler











    methods
        associateRecords=gatherAssociatedParam(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        sharedLists=gatherSharedDT(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        [isForBlkParam,blkParamName]=isPathItemForBlockParam(h,srcBlk,pathItem)

    end

    methods(Hidden)
        res=getBlockMaskTypeAttributes(h,blkObj,pathItem)
        numberOfPoints=getNumberOfPoints(~,blockObject)
        numberOfPoints=getNumberOfPointsExplicitValuesMode(~,blockObject)
        [isValid,minimumValue,maximumValue,parameterObject]=getBreakpointData(h,blockObject)
    end

    methods(Static)
        hasConstraint=hasFloatingPointConstraint(blockObject);
        dataTypeCreator=getDataTypeCreator(blockObject);
    end
end

