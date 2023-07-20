function textStep=getTextStepImpl(hObj)


    if strcmp(hObj.TextStepMode,'auto')
        textStep=getLevelStepImpl(hObj);
    else
        textStep=hObj.TextStep_I;
    end
end
