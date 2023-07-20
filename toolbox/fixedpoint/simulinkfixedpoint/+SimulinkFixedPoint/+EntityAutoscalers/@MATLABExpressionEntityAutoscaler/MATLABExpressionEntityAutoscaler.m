classdef MATLABExpressionEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler






    methods

        [DTConInfo,comments,paramName]=gatherSpecifiedDT(~,expressionIdentifier,varargin);
        [min_val,max_val]=gatherDesignMinMax(~,~,varargin);
        sharedList=gatherSharedDT(~,~);
        sharedList=gatherSharedDTWithBusObj(~,~,~,~);
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(~,~,~,~);

    end

end


