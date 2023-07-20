classdef HardwareConstraintAndMonotonicityConstraint<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface







    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,hardwareConstraint,monotonicityConstraint)




            constraint=hardwareConstraint.ChildConstraint+monotonicityConstraint;
            setSourceInfo(constraint,monotonicityConstraint.Object,monotonicityConstraint.ElementOfObject);
        end
    end
end


