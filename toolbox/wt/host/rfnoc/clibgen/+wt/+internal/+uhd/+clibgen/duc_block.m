classdef duc_block<wt.internal.uhd.clibgen.block




    methods(Access=protected)
        function control=getCustomBlockController(obj)
            control=obj.graph.get_block_uhd__rfnoc__duc_block_control_(getID(obj));
        end
    end

    methods
        function val=setInputRate(obj,inputRate,channel)
            val=obj.ctrl.set_input_rate(inputRate,channel);
        end

        function setOutputRate(obj,outputRate,channel)
            obj.ctrl.set_output_rate(outputRate,channel);
        end

        function val=getInputRate(obj,channel)
            val=obj.ctrl.get_input_rate(channel);
        end

        function val=getOutputRate(obj,channel)
            val=obj.ctrl.get_output_rate(channel);
        end
    end
end
