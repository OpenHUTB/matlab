

classdef DeadZoneBlock<slci.simulink.Block

    methods

        function obj=DeadZoneBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('LowerValue'));
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('UpperValue'));


            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32'}));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'SaturateOnIntegerOverflow','off'));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


