function maxVal=max(this)



    if~this.isRangeCalculated
        calculateRanges(this);
    end
    maxVal=max(this.range);
end