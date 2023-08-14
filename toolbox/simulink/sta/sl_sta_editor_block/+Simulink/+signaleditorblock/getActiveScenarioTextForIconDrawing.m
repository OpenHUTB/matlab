function returnText=getActiveScenarioTextForIconDrawing(block)





    returnText='Scenario';
    if getSimulinkBlockHandle(block)>0


        returnText=get_param(gcb,'ActiveScenario');
    end

end

