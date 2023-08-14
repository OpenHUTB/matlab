function out=isValid(obj)


    if isempty(obj.ParamMap)||isempty(obj.ComponentMap)
        out=false;
    else
        out=true;
    end


