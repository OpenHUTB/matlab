

classdef ArgInBlock<slci.simulink.Block

    methods

        function obj=ArgInBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end
    end

end