






function loadSimInputValues(obj,simInputValues,stopTime)

    simIn=Simulink.SimulationInput(obj.debugMdl);



    if~isempty(simInputValues)
        dataValues=simInputValues.dataValues;
        simIn=simIn.setExternalInput(dataValues);


        if~isempty(simInputValues.paramValues)
            for i=1:length(simInputValues.paramValues)
                param=simInputValues.paramValues(i);
                if~param.noEffect
                    paramName=param.name;
                    paramValue=param.value;
                    if existsInGlobalScope(obj.debugMdl,paramName)
                        currentVal=evalinGlobalScope(obj.debugMdl,paramName);
                        if isa(currentVal,'Simulink.Parameter')||...
                            isa(currentVal,'mpt.Parameter')
                            paramCopy=currentVal.copy();
                            paramCopy.Value=paramValue;
                            paramValue=paramCopy;
                        end
                    end
                    simIn=simIn.setVariable(paramName,paramValue);
                end
            end
        end

        simIn=simIn.setModelParameter('StopTime',num2str(stopTime));
    end


    simIn=simIn.setModelParameter('EnableRollBack','on');
    simIn=simIn.setModelParameter('NumberOfSteps',1);


    obj.revertSimulationInput;


    tempState=Simulink.internal.TemporaryModelState(simIn,'EnableConfigSetRefUpdate','on');


    obj.disableDirtyFlagForAllModels;


    obj.setSimInRevertTempState(tempState);

end
