

classdef UnaryMinusBlock<slci.simulink.Block

    methods

        function obj=UnaryMinusBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8','int16','int32'}));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
