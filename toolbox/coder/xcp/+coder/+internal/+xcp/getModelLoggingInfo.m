








function modelLoggingInfo=getModelLoggingInfo(model)
    modelLoggingInfo=Simulink.SimulationData.ModelLoggingInfo.createFromModel(model);


    currentModelLoggingInfo=get_param(model,'DataLoggingOverride');
    overrideSignals=~strcmp(currentModelLoggingInfo.LoggingMode,'LogAllAsSpecifiedInModel');

    if(overrideSignals)
        modelLoggingInfo.LoggingMode='OverrideSignals';
    else


        modelLoggingInfo.LoggingMode='LogAllAsSpecifiedInModel';
    end

    if overrideSignals














        for i=1:numel(modelLoggingInfo.Signals)
            found=false;
            sig=modelLoggingInfo.Signals(i);



            for j=1:numel(currentModelLoggingInfo.LogAsSpecifiedByModels)
                currentModel=currentModelLoggingInfo.LogAsSpecifiedByModels{j};
                isTopLevelModel=strcmp(model,currentModel);

                if isTopLevelModel
                    if(sig.BlockPath.getLength()==1)


                        found=true;
                        break;
                    end
                elseif((sig.BlockPath.getLength()>1)&&...
                    strcmp(sig.BlockPath.getBlock(1),currentModel))


                    found=true;
                    break;
                end
            end

            if~found


                for j=1:numel(currentModelLoggingInfo.Signals)
                    currentSig=currentModelLoggingInfo.Signals(j);


                    if isequal(sig.BlockPath,currentSig.BlockPath)&&...
                        (sig.OutputPortIndex==currentSig.OutputPortIndex)


                        found=true;
                        modelLoggingInfo.Signals(i).LoggingInfo=currentSig.LoggingInfo;
                        break;
                    end
                end
            end

            if~found


                modelLoggingInfo.Signals(i).LoggingInfo.DataLogging=false;
            end
        end
    end
end

