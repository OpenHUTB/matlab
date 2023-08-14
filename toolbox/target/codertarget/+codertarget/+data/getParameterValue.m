function value=getParameterValue(hObj,paramName)





    if ischar(hObj)
        cs=getActiveConfigSet(hObj);
    else
        cs=hObj.getConfigSet();
    end

    assert(cs.isValidParam('CoderTargetData'),'The model is not set for Coder Target.');

    data=get_param(cs,'CoderTargetData');
    try
        pos=strfind(paramName,'.');
        if isempty(pos)
            value=data.(paramName);
        else
            s1=paramName(1:pos-1);
            s2=paramName(pos+1:end);
            value=data.(s1).(s2);
        end
    catch me %#ok<NASGU>
        assert(false,'The parameter %s is not defined for selected hardware board.',paramName);
    end
end