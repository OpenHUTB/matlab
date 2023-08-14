


classdef DataTypeConversionBlock<slci.simulink.Block

    methods

        function obj=DataTypeConversionBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'ConvertRealWorld','Real World Value (RWV)'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RndMeth','Zero','Floor'));
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


