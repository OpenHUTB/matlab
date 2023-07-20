

classdef EnablePortBlock<slci.simulink.Block

    methods

        function obj=EnablePortBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(slci.compatibility.BooleanEnablePortConstraint());
            obj.addConstraint(slci.compatibility.RootEnablePortConstraint());

            obj.addConstraint(...
            slci.compatibility.ConstantPortConstraint('Enable',1));

        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
