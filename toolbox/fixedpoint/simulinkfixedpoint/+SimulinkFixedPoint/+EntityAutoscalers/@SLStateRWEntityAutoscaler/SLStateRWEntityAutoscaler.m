classdef SLStateRWEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler










    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
    end

    methods(Access=protected)
        [inport,outport]=getPortsToShareWithState(h);
    end

end


