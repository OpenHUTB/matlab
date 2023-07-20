





function simulateForCoverage(obj,violationTime)



    origWarningState=warning('off','ModelSlicer:EnhancedCovCollectionFailed');
    cleanupObject=onCleanup(@()warning(origWarningState.state,'ModelSlicer:EnhancedCovCollectionFailed'));


    slicerConfig=SlicerConfiguration.getConfiguration(obj.model);
    msObj=slicerConfig.modelSlicer;
    sc=slicerConfig.CurrentCriteria;
    simHandler=slicerConfig.modelSlicer.simHandler;

    if~obj.isFastRestartSupported
        slicerConfig.modelSlicer.terminateModelForTimeWindowSimulation();
    end


    if~msObj.collectCoverageDuringSimulation
        msObj.collectCoverageDuringSimulation=true;
    end

    sc.collectCoverage(slicerConfig,0,violationTime,[],simHandler);
    msObj.collectCoverageDuringSimulation=false;

    if~obj.isFastRestartSupported
        slicerConfig.toggleInitialized;
    end

end


