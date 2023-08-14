function out=cellGetParam(objH,prop)
    out=get_param(objH,prop);
    if~iscell(out)
        out={out};
    end
end
