function outputData=simulateModel(obj,simIn)








    try

        outputData=sim(simIn);

    catch ME



        obj.revertSigNamesAndLogging(unique(obj.subModel));

        if strcmp(ME.identifier,'Simulink:logLoadBlocks:SigLogDatasetFormatVariableDims')
            error(message('stm:general:BaselineForVariableSizeSignalNotSupported'));
        end






        eID="stm:TestForSubsystem:ModelCompilationOrSimulationFailed";
        exToShow=MException(eID,message(eID).getString);
        exToShow=exToShow.addCause(ME);
        throwAsCaller(exToShow);

    end

end

