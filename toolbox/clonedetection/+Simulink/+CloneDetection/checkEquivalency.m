function equivalencyCheckResults=checkEquivalency(replacementResults)




    loadedModels={};
    try

        if~isa(replacementResults,'Simulink.CloneDetection.ReplacementResults')||...
            isempty(replacementResults.ClonesId)
            DAStudio.error('sl_pir_cpp:creator:InvalidReplacementResultsObject');
        end

        Simulink.CloneDetection.internal.util.checkoutLicenseForCloneDetection();

        clonesId=split(replacementResults.ClonesId,",");





        if~(length(clonesId)>=3)
            DAStudio.error('sl_pir_cpp:creator:InvalidReplacementResultsObject');
        end

        modelDirectory=clonesId{1};
        modelName=clonesId{2};
        clonesDataId=clonesId{3};

        if slEnginePir.util.loadBlockDiagramIfNotLoaded(fullfile(modelDirectory,modelName))
            loadedModels=[loadedModels;{modelName}];
        end

        clonesRawData=Simulink.CloneDetection.internal.util.getSavedResultsForVersion(...
        clonesDataId,modelName);
        clonesRawData.model=get_param(modelName,'handle');
        set_param(modelName,'CloneDetectionUIObj',clonesRawData);

        equivalencyCheckResults=...
        Simulink.CloneDetection.EquivalencyCheckResults(replacementResults);

        if Simulink.CloneDetection.internal.util.backupModelExists(clonesRawData)
            testManager=Simulink.CloneDetection.internal.DDGViews.TestManagerDialog(...
            modelName);
            Simulink.CloneDetection.internal.util.gui.show(testManager);

            resultsData=testManager.CheckEquivalencyResult;
            equivalencyCheckResults.addEquivalencyCheckResults(resultsData);
        end

        slEnginePir.util.closeBlockDiagramsInList(loadedModels);
    catch exception
        slEnginePir.util.closeBlockDiagramsInList(loadedModels);
        exception.throwAsCaller();
        return;
    end
end
