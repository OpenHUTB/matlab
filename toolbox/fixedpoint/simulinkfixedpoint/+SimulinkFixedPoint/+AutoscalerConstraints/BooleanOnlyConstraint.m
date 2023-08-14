classdef BooleanOnlyConstraint<SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint





    methods
        function comments=getComments(this)
            comments={DAStudio.message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
            this.ElementOfObject,getFullName(this),DAStudio.message('SimulinkFixedPoint:autoscaling:ConstrainedbooleanOnly'))};
        end
    end
end


