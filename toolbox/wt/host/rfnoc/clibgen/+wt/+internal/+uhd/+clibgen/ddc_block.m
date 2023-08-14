classdef ddc_block<wt.internal.uhd.clibgen.block





    methods(Access=protected)
        function control=getCustomBlockController(obj)
            control=obj.graph.get_block_uhd__rfnoc__ddc_block_control_(getID(obj));
        end
    end

    methods
        function setInputRate(obj,inputRate,channel)
            obj.ctrl.set_input_rate(inputRate,channel);
        end

        function val=setOutputRate(obj,outputRate,channel)
            val=obj.ctrl.set_output_rate(outputRate,channel);
        end

        function val=getInputRate(obj,channel)
            val=obj.ctrl.get_input_rate(channel);
        end

        function val=getOutputRate(obj,channel)
            val=obj.ctrl.get_output_rate(channel);
        end
    end
end

