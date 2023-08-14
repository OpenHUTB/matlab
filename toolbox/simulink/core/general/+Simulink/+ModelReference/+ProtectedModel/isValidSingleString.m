function out=isValidSingleString(val)




    if isstring(val)&&length(val)==1
        out=true;
    else
        out=false;
    end
end