

classdef SwitchCaseBlock<slci.simulink.Block

    methods

        function obj=SwitchCaseBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.MultiCaseConditionConstraint);


            obj.addConstraint(...
            slci.compatibility.ConstantPortConstraint('Inport',1));

            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end

