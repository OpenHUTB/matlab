classdef weightBurstEndEvent<dnnfpga.profiler.risingEdgeEvent



    methods(Access=public,Static=true)
        function type=getType()
            type='WeightBurstEnd';
        end
    end
end

