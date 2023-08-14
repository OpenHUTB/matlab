function bool=isSLDVTestVector(aVar)





    if nargin>0
        if isstring(aVar)
            aVar=cellstr(aVar);
        end
    end

    bool=sldvshareprivate('isSldvData',aVar);

