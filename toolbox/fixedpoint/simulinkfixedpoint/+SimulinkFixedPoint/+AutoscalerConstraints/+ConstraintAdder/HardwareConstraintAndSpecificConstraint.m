classdef HardwareConstraintAndSpecificConstraint<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface







    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,hardwareConstraint,specificConstraint)


            constraint=hardwareConstraint.ChildConstraint+specificConstraint;
            setSourceInfo(constraint,specificConstraint.Object,specificConstraint.ElementOfObject);
        end
    end
end


