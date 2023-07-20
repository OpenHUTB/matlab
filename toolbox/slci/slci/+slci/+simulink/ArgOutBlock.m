

classdef ArgOutBlock<slci.simulink.Block

    methods

        function obj=ArgOutBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end
    end

end