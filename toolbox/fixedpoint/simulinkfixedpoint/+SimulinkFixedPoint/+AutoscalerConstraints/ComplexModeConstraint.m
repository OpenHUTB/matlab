classdef ComplexModeConstraint<SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint






    methods
        function object=ComplexModeConstraint(floatingPointConstraint)
            object=object@SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint(floatingPointConstraint);
        end
        function comments=getComments(this)
            commentToAdd=DAStudio.message('SimulinkFixedPoint:autoscaling:ConstrainedFloatPointOnlyWhenComplex');
            comments=appendComment(this,commentToAdd);
        end
    end
end


