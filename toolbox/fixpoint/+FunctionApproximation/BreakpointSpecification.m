classdef BreakpointSpecification<double
















    enumeration
        EvenPow2Spacing(1)
        EvenSpacing(0)
        ExplicitValues(2)
    end

    methods
        function isEven=isEvenSpacing(this)

            isEven=this==FunctionApproximation.BreakpointSpecification.EvenSpacing...
            |this==FunctionApproximation.BreakpointSpecification.EvenPow2Spacing;
        end
    end

    methods(Static)
        function spacingEnum=getEnum(spacingString)



            stringWithNoSpaces=regexprep(spacingString,' ','');
            spacingEnum=FunctionApproximation.BreakpointSpecification(stringWithNoSpaces);
        end

        function spacingString=getString(spacingEnum)

            if isEvenSpacing(spacingEnum)
                spacingString='Even spacing';
            else
                spacingString='Explicit values';
            end
        end

        function highestEnum=getHighestEnum(spacingEnums)




            if any(spacingEnums==2)
                highestEnum=FunctionApproximation.BreakpointSpecification.ExplicitValues;
            elseif any(spacingEnums==0)
                highestEnum=FunctionApproximation.BreakpointSpecification.EvenSpacing;
            else
                highestEnum=FunctionApproximation.BreakpointSpecification.EvenPow2Spacing;
            end
        end
    end
end


