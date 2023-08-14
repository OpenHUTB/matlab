classdef Default<SimulinkFixedPoint.AutoscalerConstraints.ConstraintAdder.Interface
















    methods(Access=protected)
        function constraint=addConstraintsInOrder(~,constraint1,constraint2)
            constraint=constraint1;
            if isempty(constraint2)
                constraint=constraint1;
            elseif isempty(constraint1)
                constraint=constraint2;
            elseif~allowsFixedPointProposals(constraint2)
                constraint=constraint2;
            end
        end
    end
end
