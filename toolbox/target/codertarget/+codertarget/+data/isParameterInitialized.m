function ret=isParameterInitialized(hObj,paramName)




    if ischar(hObj)
        cs=getActiveConfigSet(hObj);
    else
        cs=hObj.getConfigSet();
    end

    if cs.isValidParam('CoderTargetData')
        data=get_param(cs,'CoderTargetData');
        pos=strfind(paramName,'.');
        if isempty(pos)
            ret=isfield(data,paramName);
        else
            s1=paramName(1:pos-1);
            s2=paramName(pos+1:end);
            ret=isfield(data,s1);
            if ret
                ret=isfield(data.(s1),s2);
            end
        end
    else
        ret=false;
    end
end