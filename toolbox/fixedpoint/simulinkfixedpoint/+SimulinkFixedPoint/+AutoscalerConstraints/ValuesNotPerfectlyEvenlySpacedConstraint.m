classdef ValuesNotPerfectlyEvenlySpacedConstraint<SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint








    methods
        function object=ValuesNotPerfectlyEvenlySpacedConstraint(floatingPointConstraint)
            object=object@SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint(floatingPointConstraint);
        end
        function comments=getComments(this)
            commentToAdd=getString(message('SimulinkFixedPoint:autoscaling:ExplicitValuesNotEvenlySpaced'));
            comments=appendComment(this,commentToAdd);
        end
    end
end

