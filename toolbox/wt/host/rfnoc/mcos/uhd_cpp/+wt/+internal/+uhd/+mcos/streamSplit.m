



classdef streamSplit<wt.internal.uhd.mcos.block

    properties
    end

    methods
        function obj=streamSplit(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(varargin);
            obj.ctrl=uhd.internal.streamSplit;
            obj.blockName=blockName;
            makeBlock(obj,radio);
        end
    end

end
