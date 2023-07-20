classdef MATLABVariableEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler






    methods
        [DTConInfo,comments,paramName]=gatherSpecifiedDT(~,variableIdentifier,varargin)
        [min_val,max_val]=gatherDesignMinMax(~,variableIdentifier,varargin)
        sharedList=gatherSharedDT(this,variableIdentifier);
        sharedList=gatherSharedDTWithBusObj(this,variableIdentifier,elementName,busObjHandleMap);
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(this,variableIdentifier,elemenName,busObjHandleMap);
        sfDataObject=hGetRelatedSFData(this,variableIdentifier);
    end

end


