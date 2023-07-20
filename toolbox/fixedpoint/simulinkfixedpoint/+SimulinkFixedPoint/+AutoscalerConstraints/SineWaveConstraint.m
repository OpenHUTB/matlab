classdef SineWaveConstraint<SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint






    methods
        function object=SineWaveConstraint(floatingPointConstraint)
            object=object@SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint(floatingPointConstraint);
        end
        function comments=getComments(this)
            commentToAdd=DAStudio.message('SimulinkFixedPoint:autoscaling:sinwaveConstraint');
            comments=appendComment(this,commentToAdd);
        end
    end
end


