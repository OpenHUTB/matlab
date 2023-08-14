classdef SpecificConstraint<SimulinkFixedPoint.RangeBitCalculator.ContextAdapter.Interface





    methods
        function this=SpecificConstraint(specificConstraint)
            this.Context=SimulinkFixedPoint.RangeBitCalculator.Context(...
            isSigned(specificConstraint),...
            specificConstraint.SpecificWL,...
            specificConstraint.SpecificFL);
        end
    end
end