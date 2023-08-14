



classdef custom_block<wt.internal.uhd.mcos.block

    properties
    end

    methods
        function obj=custom_block(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(blockName,varargin);
            obj.ctrl=uhd.internal.custom;
            makeBlock(obj,radio);
        end
    end
end
