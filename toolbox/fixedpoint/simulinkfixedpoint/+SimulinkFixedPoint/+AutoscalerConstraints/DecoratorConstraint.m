classdef(Abstract)DecoratorConstraint<SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint




    properties(SetAccess=protected)
        Constraint;
    end

    methods
        function object=DecoratorConstraint(floatingPointConstraint)
            object.Constraint=floatingPointConstraint;
        end

        function setSourceInfo(this,object,elementOfObject)
            setSourceInfo@SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint(this,object,elementOfObject);
            setSourceInfo(this.Constraint,object,elementOfObject);
        end

        function comments=appendComment(this,commentToAdd)
            comments=getComments(this.Constraint);
            comments={[comments{1},' ',commentToAdd]};
        end
    end
end