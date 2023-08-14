classdef HardwareConstraintAndHardwareConstraint<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface







    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,hardwareConstraint1,hardwareConstraint2)

            constraint=SimulinkFixedPoint.AutoscalerConstraints.MixedHardwareConstraint(hardwareConstraint1,hardwareConstraint2);
        end
    end
end


