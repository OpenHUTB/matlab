function namedRangeData=findNamedRange(this,rangeId)

    namedRangeData=[];

    if isempty(this.hSheet)

        this.selectSheet();
    end
    if isempty(this.namedRanges)

        this.cacheNamedRangesInfo();
    end

    if isempty(this.namedRanges)
        return;
    end

    if nargin<2
        namedRangeData=this.namedRanges;
    else
        myIdx=strcmp(rangeId,{this.namedRanges.label});
        if any(myIdx)
            namedRangeData=this.namedRanges(myIdx);
        end
    end
end
