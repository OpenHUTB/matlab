function out=getDependentParameters(cs,parameter)




    adapter=configset.internal.data.ConfigSetAdapter(cs);
    if~adapter.isValidParam(parameter)
        throw(MSLException([],message('configset:diagnostics:PropNotExist',parameter)));
    end
    data=adapter.getParamData(parameter);
    if isempty(data)
        out={};
    else
        out=data.FullChildren;
    end
