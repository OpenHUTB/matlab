function result=getParamWithUnit(handle,name)





    paramTable=foundation.internal.mask.getEvaluatedBlockParameters(handle,true);

    names=string(paramTable.Properties.RowNames);
    values=paramTable.Value;
    units=paramTable.Unit;

    idx=find(strcmpi(names,name),1);

    if isempty(idx)
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:getParamWithUnit:error_Parameter')));
    end
    if isempty(values{idx})||ischar(values{idx})
        pm_error('physmod:ee:library:ParameterUndefined',name);
    end
    if isempty(units{idx})
        result=simscape.Value(values{idx});
    else
        result=simscape.Value(values{idx},units{idx});
    end
end