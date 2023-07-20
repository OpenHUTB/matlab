function result=isSVDPIEnabledOnModel(obj)



    modelName=obj.getModelName;
    result=~strcmpi(hdlget_param(modelName,'GenerateSVDPITestbench'),'None');

end