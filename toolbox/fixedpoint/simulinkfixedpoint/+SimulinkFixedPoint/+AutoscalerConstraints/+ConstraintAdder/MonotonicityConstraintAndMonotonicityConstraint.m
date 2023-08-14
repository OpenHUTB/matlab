classdef MonotonicityConstraintAndMonotonicityConstraint<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface






    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,monotonicityConstraint1,monotonicityConstraint2)



            dataTypeCreator=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.Composite(...
            monotonicityConstraint1.DataTypeCreator,monotonicityConstraint2.DataTypeCreator);
            constraint=SimulinkFixedPoint.AutoscalerConstraints.MonotonicityConstraint(dataTypeCreator);
            setSourceInfo(constraint,monotonicityConstraint1.Object,monotonicityConstraint1.ElementOfObject)
        end
    end
end


