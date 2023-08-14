classdef Max<SimulinkFixedPoint.RangeBitCalculator.Interface





    methods
        function rangeBits=getRangeBits(this,context)
            rangeBits=getRangeBits@SimulinkFixedPoint.RangeBitCalculator.Interface(this,context);
            if~isinf(rangeBits)
                rangeBits=max(getWordLengths(this.Context))-min(getFractionLengths(this.Context))-getSigned(this.Context);
            end
        end
    end
end