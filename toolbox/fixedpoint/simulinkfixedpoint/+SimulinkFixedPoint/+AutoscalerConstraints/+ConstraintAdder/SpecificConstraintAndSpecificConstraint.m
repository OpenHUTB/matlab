classdef SpecificConstraintAndSpecificConstraint<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface







    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,specificConstraint1,specificConstraint2)

            [hasSignednessConflict,signedness]=...
            SimulinkFixedPoint.AutoscalerConstraints.mergeSignedness(string(specificConstraint1.SpecificSigned),string(specificConstraint2.SpecificSigned));
            [hasWordlengthConflict,wordlength]=...
            SimulinkFixedPoint.AutoscalerConstraints.mergeVectors(specificConstraint1.SpecificWL,specificConstraint2.SpecificWL);
            [hasFractionlengthConflict,fractionlength]=...
            SimulinkFixedPoint.AutoscalerConstraints.mergeVectors(specificConstraint1.SpecificFL,specificConstraint2.SpecificFL);


            constraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint(...
            signedness,wordlength,fractionlength);


            setHasSignednessConflict(constraint,hasSignednessConflict);
            setHasWordlengthConflict(constraint,hasWordlengthConflict);
            setHasFractionlengthConflict(constraint,hasFractionlengthConflict);



            setSourceInfo(constraint,specificConstraint1.Object,specificConstraint1.ElementOfObject);
        end
    end
end


