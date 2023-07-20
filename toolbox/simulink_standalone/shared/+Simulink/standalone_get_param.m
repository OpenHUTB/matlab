function parameterValue=standalone_get_param(model,parameterName)
    try

        if(iscell(model))
            model=cell2mat(model);
        end
        if(isempty(model))
            parameterValue=char([]);
            return;
        end


        modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface(model);





        modelInterface.initializeForDeployment();

        modelInterface.debugLog(2,['get_param(',model,', ',parameterName,') called ']);


        if(strfind(model,'/')>=0)
            parameterValue=modelInterface.get_block_param(model,parameterName);
        else
            parameterValue=modelInterface.get_param(parameterName);
        end


        if(isempty(parameterValue))
            parameterValue=char([]);
        end

        if(modelInterface.verbosityLevel>1)
            if(isstruct(parameterValue))
                modelInterface.debugLog(2,['get_param(',model,', ',parameterName,') returning ']);
                disp(parameterValue);
            elseif(isnumeric(parameterValue))
                modelInterface.debugLog(2,['get_param(',model,', ',parameterName,') returning ',num2str(parameterValue)]);
            else
                modelInterface.debugLog(2,['get_param(',model,', ',parameterName,') returning ',parameterValue]);
            end
        end

    catch exc
        disp(['get_param(',model,', ',parameterName,') threw an exception']);
        getReport(exc)
        disp(exc)
        parameterValue=char([]);
    end
end
