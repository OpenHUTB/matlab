classdef DoubleOnlyConstraint<SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint





    methods
        function comments=getComments(this)
            comments={DAStudio.message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
            this.ElementOfObject,getFullName(this),DAStudio.message('SimulinkFixedPoint:autoscaling:limitedFloatingPointOnly'))};
        end
    end
end


