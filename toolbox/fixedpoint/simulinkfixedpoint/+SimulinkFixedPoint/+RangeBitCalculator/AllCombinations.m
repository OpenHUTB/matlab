classdef AllCombinations<SimulinkFixedPoint.RangeBitCalculator.Interface





    methods
        function rangeBits=getRangeBits(this,context)
            rangeBits=getRangeBits@SimulinkFixedPoint.RangeBitCalculator.Interface(this,context);
            if~isinf(rangeBits)
                [WLGrid,FLGrid]=meshgrid(getWordLengths(this.Context),getFractionLengths(this.Context));
                rangeBits=WLGrid-FLGrid-getSigned(this.Context);
            end
        end
    end
end