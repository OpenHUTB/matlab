


classdef CCallerBlock<slci.simulink.Block

    methods

        function obj=CCallerBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.addConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8',...
            'uint8','int16','uint16',...
            'int32','uint32'}));

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end

