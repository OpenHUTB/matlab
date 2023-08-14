function reserved=isReservedToken(strs)















    reservedTokens={'time'};



    if ischar(strs)
        strs=cellstr(strs);
    end



    reserved=strcmp(strs,reservedTokens);

