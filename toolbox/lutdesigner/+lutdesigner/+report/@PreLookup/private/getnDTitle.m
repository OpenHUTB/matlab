function ts=getnDTitle(history,breakPoints,nDims,zeroBasedIndices)







    if nargin<4
        zeroBasedIndices=0;
    end

    ts='(:,:';
    for i=3:nDims
        thisIdx=history(i-2);
        try
            if isa(breakPoints{i}(thisIdx),"embedded.fi")
                fiValue=breakPoints{i}(thisIdx);
                ts=sprintf("%s,%s",ts,fiValue.Value);
            else
                ts=sprintf("%s,%f",ts,breakPoints{i}(thisIdx));
            end
        catch
            ts=sprintf("%s,[%i]",ts,thisIdx-zeroBasedIndices);
        end
    end
    ts=[ts,')'];
end
