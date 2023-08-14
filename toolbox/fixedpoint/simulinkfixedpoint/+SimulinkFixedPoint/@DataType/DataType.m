


classdef DataType<hgsetget&matlab.mixin.Copyable







    methods(Static)
        resBool=areEquivalent(dt1,dt2)
        decimalNumberStr=compactButAccurateNum2Str(origNumberInDouble)
        [minRwvInDouble,maxRwvInDouble]=getFixedPointRepMinMaxRwvInDouble(dt)
        res=isFixedPointType(dt)
        res=isScaledDouble(dt)
    end

end

