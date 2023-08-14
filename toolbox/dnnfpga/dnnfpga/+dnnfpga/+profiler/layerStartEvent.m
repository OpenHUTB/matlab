classdef layerStartEvent<dnnfpga.profiler.risingEdgeEvent



    methods(Access=public,Static=true)
        function type=getType()
            type='LayerStart';
        end
    end
end

