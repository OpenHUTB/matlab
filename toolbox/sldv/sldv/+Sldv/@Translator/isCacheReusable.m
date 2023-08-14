


function isReusable=isCacheReusable(obj)
    isReusable=false;


    cachedTranslationState=obj.mCompatibilityData.translationState;
    if isempty(cachedTranslationState)
        return;
    end






    if isfield(cachedTranslationState.TranslationOptions,'TestGeneration')
        testGenTarget=obj.mOptions.TestGenTarget;
        if~strcmp(testGenTarget,'Model')&&...
            ~strcmp(cachedTranslationState.TranslationOptions.TestGeneration.TestgenTarget,'Model')&&...
            ~strcmp(testGenTarget,cachedTranslationState.TranslationOptions.TestGeneration.TestgenTarget)
            return;
        end
    end



    modelBasedTestGen=strcmp(obj.mOptions.TestGenTarget,'Model');
    parameterConfigSetting=obj.mOptions.ParameterConfiguration;
    if~modelBasedTestGen&&...
        (strcmp(parameterConfigSetting,'Auto')||strcmp(parameterConfigSetting,'DetermineFromGeneratedCode'))
        return;
    end


    if Sldv.Translator.anyChangeInTranslationOptions(cachedTranslationState.TranslationOptions,obj.mTranslationState.TranslationOptions)
        return;
    end


    if isCustomCodeInfoChanged(obj)
        return;
    end

















    isReusable=Sldv.Translator.checksumConsistencyCheck(cachedTranslationState.ComponentChecksum,obj.mTranslationState.ComponentChecksum);
end





