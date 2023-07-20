classdef generalEvent<dnnfpga.profiler.abstractEvent


    methods(Access=public,Static=true)
        function type=getType()
            type='General';
        end
    end
end

