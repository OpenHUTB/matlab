function[enabled]=getModelBlockSimulationModeShouldBeEnabled(modelBlockHandle)


    simModeEntries=SLStudio.Utils.getModelBlockSimModeEntries(modelBlockHandle);

    enabled=length(simModeEntries)>1;
end

