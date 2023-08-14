classdef Min<SimulinkFixedPoint.RangeBitCalculator.Interface





    methods
        function rangeBits=getRangeBits(this,context)
            rangeBits=getRangeBits@SimulinkFixedPoint.RangeBitCalculator.Interface(this,context);
            if~isinf(rangeBits)
                rangeBits=min(getWordLengths(this.Context))-max(getFractionLengths(this.Context))-getSigned(this.Context);
            end
        end
    end
end