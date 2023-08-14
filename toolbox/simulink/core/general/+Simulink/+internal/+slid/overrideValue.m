function overriddenObject=overrideValue(definitionObj,value)




    assert(isa(value,'double'),'Overriding value must be double');


    if isnumeric(definitionObj)
        overriddenObject=cast(value,'like',definitionObj);
    elseif isa(definitionObj,'Simulink.Parameter')
        overriddenObject=definitionObj.copy;
        overriddenObject.Value=value;
    else
        overriddenObject=definitionObj;
    end

