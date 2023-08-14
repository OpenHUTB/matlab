function results=getOverlayLoggingResults()


    numTries=0;
    results=struct;

    while isempty(fields(results))
        results=Simulink.sdi.SessionSaveLoad.getMldatxOverlayTestResults();
        numTries=numTries+1;
        if numTries>10
            break;
        end
        pause(0.5);
    end
end