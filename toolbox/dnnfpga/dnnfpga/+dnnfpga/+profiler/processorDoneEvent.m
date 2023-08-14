classdef processorDoneEvent<dnnfpga.profiler.risingEdgeEvent



    methods(Access=public,Static=true)
        function type=getType()
            type='ProcessorDone';
        end
    end
end

