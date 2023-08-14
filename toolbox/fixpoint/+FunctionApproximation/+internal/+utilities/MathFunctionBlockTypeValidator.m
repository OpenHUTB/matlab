classdef(Sealed)MathFunctionBlockTypeValidator<FunctionApproximation.internal.utilities.ValidatorInterface







    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=MathFunctionBlockTypeValidator()
        end
    end

    methods
        function success=validate(this,blockPath)
            success=FunctionApproximation.internal.Utils.getBlockType(blockPath)...
            ==FunctionApproximation.internal.BlockType.Math;
            if success
                blockObject=get_param(blockPath,'Object');
                if~ismember(FunctionApproximation.internal.ProblemDefinitionFactory.mapBlockOperatorToMathFunction(blockObject),...
                    FunctionApproximation.internal.ProblemDefinitionFactory.getMathFunctionStrings)
                    success=false;
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
                    this.Diagnostic=this.Diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:mathBlockModeNotSupported')));
                end
            else
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
            end
        end
    end
end
