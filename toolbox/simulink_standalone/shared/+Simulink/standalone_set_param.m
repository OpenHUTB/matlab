function standalone_set_param(model,parameterName,parameterValue)
    try

        if(iscell(model))
            model=cell2mat(model);
        end
        if(isempty(model))
            return;
        end


        modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface(model);





        modelInterface.initializeForDeployment();

        if(modelInterface.verbosityLevel>1)
            if(isstruct(parameterValue))
                modelInterface.debugLog(2,['set_param(',model,', ',parameterName,', ']);
                disp(parameterValue);
                modelInterface.debugLog(2,') called');
            elseif(isnumeric(parameterValue))
                modelInterface.debugLog(2,['set_param(',model,', ',parameterName,', ',num2str(parameterValue),') called']);
            else
                modelInterface.debugLog(2,['set_param(',model,', ',parameterName,', ',parameterValue,') called']);
            end
        end


        if(strfind(model,'/')>=0)
            modelInterface.set_block_param(model,parameterName,parameterValue);
        else
            modelInterface.set_param(parameterName,parameterValue);
        end

        if(modelInterface.verbosityLevel>1)
            if(isstruct(parameterValue))
                modelInterface.debugLog(2,['set_param(',model,', ',parameterName,', ']);
                disp(parameterValue);
                modelInterface.debugLog(2,') called');
            elseif(isnumeric(parameterValue))
                modelInterface.debugLog(2,['set_param(',model,', ',parameterName,', ',num2str(parameterValue),') returning']);
            else
                modelInterface.debugLog(2,['set_param(',model,', ',parameterName,', ',parameterValue,') returning']);
            end
        end

    catch exc
        disp(['set_param(',model,', ',parameterName,') threw an exception']);
        getReport(exc)
        disp(exc)
    end
end
