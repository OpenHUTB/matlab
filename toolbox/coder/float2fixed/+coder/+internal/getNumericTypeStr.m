function tStr=getNumericTypeStr(T)



    if isempty(T)
        tStr='';
    else
        tStr=tostringInternalSlName(T);
    end

end
