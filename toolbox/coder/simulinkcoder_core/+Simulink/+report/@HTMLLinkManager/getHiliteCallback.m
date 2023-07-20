function out=getHiliteCallback(obj,sid)
    if isempty(obj.JavaScriptHilite)
        out=sprintf(obj.DefaultHiliteCallbackFormat,sid);
    else
        out=sprintf(obj.JavaScriptHilite,sid);
    end
end
