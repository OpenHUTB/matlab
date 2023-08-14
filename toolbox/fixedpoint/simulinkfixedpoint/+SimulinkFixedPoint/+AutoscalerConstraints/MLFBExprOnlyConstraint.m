classdef MLFBExprOnlyConstraint<SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint






    methods
        function comments=getComments(~)
            comments={DAStudio.message('SimulinkFixedPoint:autoscaling:limitedMLFBExprOnly')};
        end
    end
end


