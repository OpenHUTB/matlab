





function groupTRangeSet(this,TRange,varargin)
    if nargin>2
        groupIdx=varargin{1};
        grpCnt=length(groupIdx);
        for gidx=1:grpCnt
            m=groupIdx(gidx);
            this.Groups(m).TimeRange=TRange{gidx};
        end
    else
        for i=1:this.NumGroups
            this.Groups(i).TimeRange=TRange{i};
        end
    end
end