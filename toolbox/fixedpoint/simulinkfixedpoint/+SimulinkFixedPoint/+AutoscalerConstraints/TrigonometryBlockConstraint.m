classdef TrigonometryBlockConstraint<SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint






    methods
        function object=TrigonometryBlockConstraint(floatingPointConstraint)
            object=object@SimulinkFixedPoint.AutoscalerConstraints.DecoratorConstraint(floatingPointConstraint);
        end
        function comments=getComments(this)
            blkOperation=this.Object.Operator;
            approxMethod=this.Object.ApproximationMethod;
            commentToAdd=DAStudio.message('SimulinkFixedPoint:autoscaling:NoFxptSupportForTrigFunction',blkOperation,approxMethod);
            comments=appendComment(this,commentToAdd);
        end
    end
end


