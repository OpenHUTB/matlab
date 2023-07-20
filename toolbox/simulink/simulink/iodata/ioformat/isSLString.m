function IS_SLSTRING=isSLString(inStr)




    IS_STRING=isstring(inStr);

    if~IS_STRING
        IS_SLSTRING=false;
        return
    end

    CONTAINS_MISSING=any(ismissing(reshape(inStr,numel(inStr),1)));

    IS_SLSTRING=IS_STRING&&~CONTAINS_MISSING;

end
