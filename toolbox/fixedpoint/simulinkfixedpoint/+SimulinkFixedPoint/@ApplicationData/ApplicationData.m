classdef ApplicationData<handle

    properties(AbortSet,SetObservable,GetObservable)

        dataset=[];

        ScaleUsing=0;

        subDatasetMap=[];

        AutoscalerProposalSettings;
    end

    methods
        function this=ApplicationData(model)

            this.AutoscalerProposalSettings=SimulinkFixedPoint.AutoscalerProposalSettings();

            fptRepositoryInstance=fxptds.FPTRepository.getInstance;
            this.dataset=fptRepositoryInstance.getDatasetForSource(Simulink.ID.getSID(model));


            bd=get_param(model,'Object');
            this.ScaleUsing=bd.FPTRunName;
            this.subDatasetMap=containers.Map('KeyType','double','ValueType','any');
        end

    end

    methods
        delete(this);
        settingStruct=settingToStruct(h)
        structToSetting(h,settingStruct);
    end

    methods(Static)
        addDataFromDerivedRange(data,selectedRunName)
        addDataFromSrc(data)
        addDataFromAMSI(data)
        addDataFromFxpInstrumenterService(data)
        mergeModelReferenceData(model,runName)
        mergeResultsInReferenceModels(curSelectedSys,runName_universal)
        mergeRunsInDatasets(templateDataset,mergedDataset,RunName)
        mergeResultsOfRuns(dataset,templateRunName,mergedRunName)
        updateResultsInModelsBlocks(topModel,runName)
        updateMdlBlkDataset(subModelDataset,modelBlkDataset,RunName)
    end

    methods(Static,Hidden)

        outData=createMergedData(templateResult,mergedResult);
        mergeResults(templateRunObject,mergedRunObject);
    end

end



