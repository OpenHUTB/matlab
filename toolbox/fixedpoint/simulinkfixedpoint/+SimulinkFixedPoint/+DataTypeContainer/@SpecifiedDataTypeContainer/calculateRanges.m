function calculateRanges(this)




    rangeInfo=[];
    if isFixed(this)||isFloat(this)||isBoolean(this)
        if~(isFixed(this)&&contains(this.evaluatedNumericType.DataTypeMode,'unspecified'))
            rangeInfo=double(fixed.internal.type.finiteRepresentableRange(this.evaluatedNumericType));
        end
    end
    this.range=rangeInfo;
    this.isRangeCalculated=true;
end
