




classdef ASCIIToStringBlock<slci.simulink.Block

    methods

        function obj=ASCIIToStringBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.setSupportsString(true);


            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'uint8'}));
            obj.addConstraint(...
            slci.compatibility.SupportedInputDimensionConstraint);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
