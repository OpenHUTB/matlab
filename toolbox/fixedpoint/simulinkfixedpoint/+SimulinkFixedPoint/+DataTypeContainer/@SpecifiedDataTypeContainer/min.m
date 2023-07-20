function minVal=min(this)



    if~this.isRangeCalculated
        calculateRanges(this);
    end
    minVal=min(this.range);
end