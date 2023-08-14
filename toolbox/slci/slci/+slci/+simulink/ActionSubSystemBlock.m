



classdef ActionSubSystemBlock<slci.simulink.SubSystemBlock

    methods

        function obj=ActionSubSystemBlock(aBlk,aModel)
            obj=obj@slci.simulink.SubSystemBlock(aBlk,aModel);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
