


classdef InternalRangeBias<Simulink.FixedPointAutoscaler.InternalRange


    methods(Access='public')

        function obj=InternalRangeBias(blockObject,runObj,allResults)
            obj=obj@Simulink.FixedPointAutoscaler.InternalRange(blockObject,runObj,allResults);
        end

        function calcInternalRange(obj)





            inRange=obj.getInputConnectedRanges;
            biasRange=obj.getParameterRange('Bias');
            outRange=obj.calcAddRange(inRange{1},biasRange);
            obj.putRange(obj.unionRange(biasRange,outRange,inRange{1}));
        end
    end
end

