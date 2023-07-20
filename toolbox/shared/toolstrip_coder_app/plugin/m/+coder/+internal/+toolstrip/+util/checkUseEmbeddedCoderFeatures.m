function okStatus=checkUseEmbeddedCoderFeatures(input)


    if isa(input,'SLM3I.CallbackInfo')
        modelH=input.model.handle;
    else
        modelH=input;
    end

    okStatus=coder.internal.toolstrip.util.checkUseSimulinkCoderFeatures(modelH);
    if okStatus
        if strcmp(get_param(modelH,'UseEmbeddedCoderFeatures'),'off')
            diag=MSLException([],message('RTW:configSet:UseEmbeddedCoderFeaturesOffErrorMsg',get_param(modelH,'name')));
            sldiagviewer.reportError(diag);
            okStatus=false;
        end
    end
