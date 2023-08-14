function chooseParameters_sliderUpdate(modelName,parameterName)



    ds=ee.internal.mask.getSimscapeBlockDatasetFromModel(modelName);
    blockName=[modelName,'/Tuner'];
    if isfield(get_param(blockName,'ObjectParameters'),parameterName)
        value=get_param(blockName,parameterName);
    else
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:chooseParameters_sliderUpdate:error_ParameterName')));
    end
    ds.parameters.addParameter(parameterName,num2str(value));
end