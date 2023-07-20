function result=isCosimEnabledOnModel(obj)



    modelName=obj.getModelName;
    result=~strcmpi(hdlget_param(modelName,'GenerateCosimModel'),'None');

end