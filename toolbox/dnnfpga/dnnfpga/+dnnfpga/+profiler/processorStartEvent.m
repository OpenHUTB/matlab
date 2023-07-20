classdef processorStartEvent<dnnfpga.profiler.risingEdgeEvent



    methods(Access=public,Static=true)
        function type=getType()
            type='ProcessorStart';
        end
    end
end

