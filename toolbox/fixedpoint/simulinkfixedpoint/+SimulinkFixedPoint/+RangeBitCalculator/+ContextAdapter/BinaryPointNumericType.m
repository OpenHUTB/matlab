classdef BinaryPointNumericType<SimulinkFixedPoint.RangeBitCalculator.ContextAdapter.Interface






    methods
        function this=BinaryPointNumericType(numericType)
            this.Context=SimulinkFixedPoint.RangeBitCalculator.Context(...
            numericType.SignednessBool,...
            numericType.WordLength,...
            numericType.FractionLength);
        end
    end
end