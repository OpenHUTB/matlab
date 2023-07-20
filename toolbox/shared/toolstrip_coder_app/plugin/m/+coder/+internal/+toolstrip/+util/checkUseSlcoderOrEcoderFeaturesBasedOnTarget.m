function okStatus=checkUseSlcoderOrEcoderFeaturesBasedOnTarget(input)



    if isa(input,'SLM3I.CallbackInfo')
        modelH=input.model.handle;
    else
        modelH=input;
    end

    if strcmp(get_param(modelH,'IsERTTarget'),'on')
        okStatus=coder.internal.toolstrip.util.checkUseEmbeddedCoderFeatures(modelH);
    else
        okStatus=coder.internal.toolstrip.util.checkUseSimulinkCoderFeatures(modelH);
    end

