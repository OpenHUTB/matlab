function chooseParameters_sliderRangeUpdate(modelName,parameterName)



    blockName=[modelName,'/Tuner'];
    if isfield(get_param(blockName,'ObjectParameters'),parameterName)
        aMaskObj=Simulink.Mask.get(blockName);
        aSlider=aMaskObj.getParameter(parameterName);
        low=get_param(blockName,[parameterName,'_min']);
        high=get_param(blockName,[parameterName,'_max']);
        aSlider.Range=[str2double(low),str2double(high)];
    else
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:chooseParameters_sliderRangeUpdate:error_ParameterName')));
    end
end