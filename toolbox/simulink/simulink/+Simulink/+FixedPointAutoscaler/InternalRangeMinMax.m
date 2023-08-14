

classdef InternalRangeMinMax<Simulink.FixedPointAutoscaler.InternalRange


    methods(Access='public')

        function obj=InternalRangeMinMax(blockObject,runObj,allResults)
            obj=obj@Simulink.FixedPointAutoscaler.InternalRange(blockObject,runObj,allResults);
        end
    end

    methods(Access='public')
        function calcInternalRange(obj)
            numInputs=size(obj.blockObject.portHandles.Inport,2);

            if(numInputs>1)
                inRanges=obj.getInputConnectedRanges;
                outRange=obj.unionRange(inRanges{:});
                obj.putRange(outRange);
            end
        end
    end
end