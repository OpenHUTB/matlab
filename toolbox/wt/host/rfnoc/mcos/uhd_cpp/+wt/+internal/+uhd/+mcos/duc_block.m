



classdef duc_block<wt.internal.uhd.mcos.block
    properties
    end

    methods
        function obj=duc_block(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(blockName,varargin);
            obj.ctrl=uhd.internal.duc;
            makeBlock(obj,radio);
        end
    end

    methods
        function val=setInputRate(obj,val,port)
            val=obj.ctrl.setInputRate(val,port);
        end

        function setOutputRate(obj,val,port)
            obj.ctrl.setOutputRate(val,port);
        end

        function val=getInputRate(obj,chan)
            val=obj.ctrl.getInputRate(chan);
        end

        function val=getOutputRate(obj,chan)
            val=obj.ctrl.getOutputRate(chan);
        end

    end

end
