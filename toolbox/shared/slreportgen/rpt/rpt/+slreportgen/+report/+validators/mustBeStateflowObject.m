function mustBeStateflowObject(obj)
    validObj=isempty(obj)||isa(obj,'Stateflow.Object');

    if(~validObj)
        error(message("slreportgen:report:error:invalidSFObjectPropertySource"));
    end
end