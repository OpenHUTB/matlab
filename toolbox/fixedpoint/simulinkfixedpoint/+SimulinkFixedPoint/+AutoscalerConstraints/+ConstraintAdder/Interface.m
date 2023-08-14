classdef Interface<handle





    properties
        AddOrder;
    end

    methods
        function constraint=addConstraints(this,constraint1,constraint2)

            if this.AddOrder==SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.AddOrder.InOrder
                constraint=addConstraintsInOrder(this,constraint1,constraint2);
            elseif this.AddOrder==SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.AddOrder.SwapOrder
                constraint=addConstraintsInOrder(this,constraint2,constraint1);
            else




                constraint=SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint.empty;
            end
        end
    end

    methods(Abstract,Access=protected)

        constraint=addConstraintsInOrder(this,constraint1,constraint2);
    end

    methods(Access=?SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Factory)
        function setAddOrder(this,addOrder)
            this.AddOrder=addOrder;
        end
    end
end


