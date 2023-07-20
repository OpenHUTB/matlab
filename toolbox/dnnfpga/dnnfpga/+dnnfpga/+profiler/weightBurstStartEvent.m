classdef weightBurstStartEvent<dnnfpga.profiler.risingEdgeEvent



    methods(Access=public,Static=true)
        function type=getType()
            type='WeightBurstStart';
        end
    end
end

