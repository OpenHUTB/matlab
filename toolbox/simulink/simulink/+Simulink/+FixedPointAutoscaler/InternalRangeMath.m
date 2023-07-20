


classdef InternalRangeMath<Simulink.FixedPointAutoscaler.InternalRange


    methods(Access='public')

        function obj=InternalRangeMath(blockObject,runObj,allResults)
            obj=obj@Simulink.FixedPointAutoscaler.InternalRange(blockObject,runObj,allResults);
        end

        function calcInternalRange(obj)

            if strcmpi(obj.blockObject.getPropValue('Function'),'magnitude^2')
                obj.putRange(obj.unionRange(obj.getDerivedRange,0));
            elseif strcmpi(obj.blockObject.getPropValue('Function'),'square')
                inComplexity=obj.getInputConnectedComplexity();
                if inComplexity{1}
                    inRange=obj.getInputConnectedRanges();
                    calcRange=obj.calcSquareRange(inRange{1},inComplexity{1});
                    obj.putRange(obj.unionRange(inRange{1},calcRange));
                end
            end
        end
    end

end

