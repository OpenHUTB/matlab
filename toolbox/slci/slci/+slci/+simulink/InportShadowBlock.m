

classdef InportShadowBlock<slci.simulink.Block

    methods

        function obj=InportShadowBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

        function out=getVirtual(aObj)
            out=~strcmp(aObj.getParam('Parent'),aObj.ParentModel().getParam('Name'));
        end

    end

end
