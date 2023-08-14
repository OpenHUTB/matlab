


classdef SqrtBlock<slci.simulink.Block

    methods

        function obj=SqrtBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'Operator','sqrt','signedSqrt'));
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'OutputSignalType','complex'));
            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single'}));



            if~strcmpi(get_param(aBlk,'Operator'),'signedSqrt')
                obj.addConstraint(...
                slci.compatibility.SqrtIntermediateResultsDataTypeConstraint);
            end
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


