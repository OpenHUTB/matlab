


classdef DataStoreMemoryBlock<slci.simulink.Block

    methods

        function obj=DataStoreMemoryBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.BlockStateStorageClassConstraint('DataStoreName'));
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('InitialValue'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'SignalType','auto','real'));
            obj.addConstraint(...
            slci.compatibility.SupportedStateDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32','boolean'}));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'WriteAfterWriteMsg','Error'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'ShareAcrossModelInstances','off'));
            obj.setSupportsEnums(true);
            obj.setSupportsBuses(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
