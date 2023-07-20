


function loggedSignalsUnionMap=getUnionOfAllLoggedSignals(actualSimulationInputs)





    sigsMap=containers.Map;
    for idx=1:numel(actualSimulationInputs)
        logSpec=actualSimulationInputs(idx).LoggingSpecification;
        if~isempty(logSpec)
            sigs=logSpec.SignalsToLog;
            for jdx=1:numel(sigs)

                key=sigs(jdx).BlockPath.toPipePath;
                key=[key,':',num2str(sigs(jdx).OutputPortIndex)];
                if~sigsMap.isKey(key)
                    sigs(jdx).LoggingInfo.DataLogging=false;
                    sigsMap(key)=sigs(jdx);
                end
            end
        end
    end
    loggedSignalsUnionMap=sigsMap;
end


