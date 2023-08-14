function simulationInput=setLogging(simulationInput,options)




    loggingSpec=Simulink.Simulation.LoggingSpecification();


    constraints=options.Constraints.values;



    uniqueLoggingPoints=cell(numel(constraints),1);
    for cIndex=1:numel(constraints)
        uniqueLoggingPoints{cIndex}=tostring(constraints{cIndex});
    end
    [~,uniqueLoggingIndex]=unique(uniqueLoggingPoints);


    for uIndex=1:numel(uniqueLoggingIndex)
        if~isequal(constraints{uniqueLoggingIndex(uIndex)}.getMode(),'Assertion')

            if options.LoggingInfo.isKey(tostring(constraints{uniqueLoggingIndex(uIndex)}))
                loggingInfo=options.LoggingInfo(tostring(constraints{uniqueLoggingIndex(uIndex)}));
                constraints{uniqueLoggingIndex(uIndex)}.setLoggingInfo(loggingInfo);
            end
            loggingSpec.addSignalsToLog(constraints{uniqueLoggingIndex(uIndex)}.loggingInfo);
        end
    end



    simulationInput=simulationInput.setLoggingSpecification(loggingSpec);
end