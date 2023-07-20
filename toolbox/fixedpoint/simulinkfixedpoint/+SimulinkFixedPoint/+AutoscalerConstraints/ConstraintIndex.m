classdef ConstraintIndex<handle










    enumeration
HardwareConstraint
MonotonicityConstraint
SpecificConstraint
    end
    methods
        function addOrder=getAddOrder(this,other)







            string1=string(this);
            string2=string(other);
            if string2>=string1
                addOrder=SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.AddOrder.InOrder;
            else
                addOrder=SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.AddOrder.SwapOrder;
            end
        end
    end
end


