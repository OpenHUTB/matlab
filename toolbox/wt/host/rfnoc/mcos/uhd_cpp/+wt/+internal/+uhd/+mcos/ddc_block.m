



classdef ddc_block<wt.internal.uhd.mcos.block

    properties
    end

    methods
        function obj=ddc_block(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(blockName,varargin);
            obj.ctrl=uhd.internal.ddc;
            makeBlock(obj,radio);
        end
    end
    methods

        function setInputRate(obj,val,port)
            obj.ctrl.setInputRate(val,port);
        end

        function val=setOutputRate(obj,val,port)
            val=obj.ctrl.setOutputRate(val,port);
        end

        function val=getOutputRate(obj,port)
            val=obj.ctrl.getOutputRate(port);
        end

        function val=getInputRate(obj,port)
            val=obj.ctrl.getInputRate(port);
        end
    end
end
