function strs=removeReservedTokens(strs)












    if~isempty(strs)
        isReserved=SimBiology.internal.isReservedToken(strs);
        strs=strs(~isReserved);
    end
