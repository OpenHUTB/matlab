classdef SLLookupTableEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler



    methods

        [sharedLists]=gatherSharedDT(this,blockObject);


        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(this,blockObject);


        [pathItems]=getPathItems(this,blockObject);


        [res]=getBlockMaskTypeAttributes(this,blockObject,pathItem);


        [associateRecords]=gatherAssociatedParam(this,blockObject);


        [isForBlkParam,blkParamName]=isPathItemForBlockParam(this,blockObject,pathItem);


        [minValue,maxValue]=gatherDesignMinMax(h,blkObj,pathItem);


        pathItems=getPortMapping(h,blkObj,inputPortNumber,outportNumber)
    end

    methods(Static)
        hasConstraint=hasFloatingPointConstraint(blockObject);
        dataTypeCreator=getDataTypeCreator(blkObj,index);
        index=getIndexFromBreakpointPathitem(breakpointPathItem);
    end
end