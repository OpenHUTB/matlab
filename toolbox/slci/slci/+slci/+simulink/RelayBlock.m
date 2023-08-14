

classdef RelayBlock<slci.simulink.Block

    methods

        function obj=RelayBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('OnSwitchValue'));


            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('OffSwitchValue'));


            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('OnOutputValue'));


            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('OffOutputValue'));


            obj.setSupportsEnums(true);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end

