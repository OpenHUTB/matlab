function changeDataTransDiagSettingToWarning(model)
    if(strcmp(get_param(model,'EnableMultiTasking'),'on'))
        set_param(model,'MultiTaskRateTransMsg','warning');
    else
        set_param(model,'SingleTaskRateTransMsg','none');
    end
end
