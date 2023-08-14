































function[out,e]=FddULRateMatching(varargin)

    if isempty(varargin{1})
        out=[];e=[];
        return
    end
    [out,e]=fdd(['FddULRateMatching',varargin]);
    e=[e{:}];


    if size(varargin{1},2)==1
        out=transpose(out);
    end
end


