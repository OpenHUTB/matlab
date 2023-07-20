function result=IsFMUTarget(modelName)
    if bdIsLoaded(modelName)
        stf=get_param(modelName,'RTWSystemTargetFile');
        result=isequal(stf,'fmu2cs.tlc');
    else
        result=false;
    end
end
