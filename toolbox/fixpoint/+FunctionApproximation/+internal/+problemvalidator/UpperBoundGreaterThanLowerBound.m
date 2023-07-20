classdef(Sealed)UpperBoundGreaterThanLowerBound<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:issuesWhileSettingBounds'
    end

    properties(Access=private)
        ErrorDimensions double=[]
    end

    methods
        function isValid=validate(~,context)







            if~isscalingunspecified(context.DataType)
                rDT=double(fixed.internal.type.finiteRepresentableRange(context.DataType));
                if isinf(context.LowerBound)&&isinf(context.UpperBound)
                    isValid=true;
                elseif~isinf(context.LowerBound)&&~isinf(context.UpperBound)
                    isValid=double(fixed.internal.math.castUniversal(context.UpperBound,context.DataType))...
                    >double(fixed.internal.math.castUniversal(context.LowerBound,context.DataType));
                elseif isinf(context.LowerBound)&&~isinf(context.UpperBound)
                    isValid=~isfloat(context.DataType)...
                    &&double(fixed.internal.math.castUniversal(context.UpperBound,context.DataType))>rDT(1);
                else
                    isValid=~isfloat(context.DataType)...
                    &&double(fixed.internal.math.castUniversal(context.LowerBound,context.DataType))<rDT(2);
                end
            else
                isValid=true;
            end
        end
    end

    methods
        function diagnostic=getDiagnostic(~,context)
            diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:upperLesserThanLowerBound',context.Dimension));
        end
    end
end
