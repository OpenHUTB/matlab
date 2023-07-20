






function simAndPause(obj,violationTime)
    slicerConfig=SlicerConfiguration.getConfiguration(obj.model);
    msObj=slicerConfig.modelSlicer;
    simHandler=msObj.simHandler;


    if(violationTime==0)
        simHandler.stepper.forward;
    else
        simHandler.runAndPause(violationTime);
    end
end
