function out=isValidParameter(hObj,paramName)





    if ischar(hObj)
        cs=getActiveConfigSet(hObj);
    else
        cs=hObj.getConfigSet();
    end
    out=true;
    assert(cs.isValidParam('CoderTargetData'),'The model is not set for Coder Target.');

    data=get_param(cs,'CoderTargetData');

    paramStruct=strsplit(paramName,'.');

    for i=1:numel(paramStruct)

        if isfield(data,paramStruct{i})
            data=data.(paramStruct{i});
        else
            out=false;
            break;
        end
    end