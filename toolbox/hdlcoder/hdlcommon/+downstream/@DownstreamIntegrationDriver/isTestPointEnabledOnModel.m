function result=isTestPointEnabledOnModel(obj)



    modelName=obj.getModelName;
    result=strcmpi(hdlget_param(modelName,'EnableTestpoints'),'on');

end