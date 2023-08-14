function callback=getCallbackForAssessments(isRapidAccel)

    if isRapidAccel


        callback='EngineSimStatusTerminating';
    else
        callback='EngineSimStatusRunning';
    end
end
