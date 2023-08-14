function okStatus=checkUseSimulinkCoderFeatures(input)


    if isa(input,'SLM3I.CallbackInfo')
        modelH=input.model.handle;
    else
        modelH=input;
    end

    okStatus=true;
    if strcmp(get_param(modelH,'UseSimulinkCoderFeatures'),'off')
        diag=MSLException([],message('RTW:configSet:UseSimulinkCoderFeaturesOffErrorMsg',get_param(modelH,'name')));
        sldiagviewer.reportError(diag);
        okStatus=false;
    end
