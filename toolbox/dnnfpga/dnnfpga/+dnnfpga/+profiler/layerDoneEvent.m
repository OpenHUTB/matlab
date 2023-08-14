classdef layerDoneEvent<dnnfpga.profiler.risingEdgeEvent



    methods(Access=public,Static=true)
        function type=getType()
            type='LayerDone';
        end
    end
end

