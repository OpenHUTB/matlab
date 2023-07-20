function setIsSimulationOutput(modelH,val)




    try
        coveng=cvi.TopModelCov.getInstance(modelH);

        if~isempty(coveng)&&isempty(coveng.isSimulationOutput)
            coveng.isSimulationOutput=val;
        end

    catch MEx
        rethrow(MEx);
    end
