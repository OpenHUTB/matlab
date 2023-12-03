function addFunctionHandle(h,fh)
    validateattributes(fh,'function_handle',{})

    if~any(cellfun(@(f)isequal(f,fh),h.TargetInfoFcns))
        h.TargetInfoFcns{end+1}=fh;
        allTypesNeedRefresh(h);
    end
