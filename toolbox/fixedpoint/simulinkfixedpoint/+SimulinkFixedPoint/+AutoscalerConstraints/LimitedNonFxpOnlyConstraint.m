classdef LimitedNonFxpOnlyConstraint<SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint





    methods
        function comments=getComments(this)
            comments={DAStudio.message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
            this.ElementOfObject,getFullName(this),DAStudio.message('SimulinkFixedPoint:autoscaling:limitedDblBoolUFix1'))};
        end
    end
end


