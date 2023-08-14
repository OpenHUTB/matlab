function cachedAccelOriginalSTF=getCachedAccelOriginalSTF(model,useModelSetting)









    cachedAccelOriginalSTF='';

    modelRTWGenSettings=get_param(model,'RTWGenSettings');

    if~isempty(modelRTWGenSettings)&&...
        isfield(modelRTWGenSettings,'AccelOriginalSTF')


        cachedAccelOriginalSTF=strtrim(modelRTWGenSettings.AccelOriginalSTF);


        cachedAccelOriginalSTF=regexprep(cachedAccelOriginalSTF,'\s+.*','');
    end

    if useModelSetting||isempty(cachedAccelOriginalSTF)

        cachedAccelOriginalSTF=get_param(model,'SystemTargetFile');
    end




