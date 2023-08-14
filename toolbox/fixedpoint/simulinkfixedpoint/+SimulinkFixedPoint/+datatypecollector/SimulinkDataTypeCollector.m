classdef(Sealed)SimulinkDataTypeCollector<SimulinkFixedPoint.datatypecollector.DataTypeCollector





    properties(Constant,Hidden)
        RunName='SimulinkDataTypeCollector';
    end

    properties
        SimType=Simulink.CMI.CompiledSimType.Sim;
        LicenseType=Simulink.EngineInterfaceVal.fixedPoint;
        HandleCompile logical=true
        ResultsToTableAdapter SimulinkFixedPoint.datatypecollector.ResultsToTableAdapter=SimulinkFixedPoint.datatypecollector.ResultsToDataTypeTableAdapter
        ResultsFilter SimulinkFixedPoint.datatypecollector.ResultsFilter=SimulinkFixedPoint.datatypecollector.InSUDResultsFilter
    end

    methods
        function tableWithTypes=getTableWithTypes(this,topModel,sud)



            engineInterfaceVal=this.LicenseType;
            simType=this.SimType;
            proposalSettings=SimulinkFixedPoint.AutoscalerProposalSettings;
            proposalSettings.scaleUsingRunName=this.RunName;
            proposalSettings.setLicenseType(engineInterfaceVal);
            proposalSettings.setSimType(simType);
            proposalSettings.setHandleCompile(false);
            engineContext=SimulinkFixedPoint.DataTypingServices.EngineContext(...
            topModel,...
            sud,...
            proposalSettings,...
            SimulinkFixedPoint.DataTypingServices.EngineActions.CollectDataTypes);
            collectionObj=SimulinkFixedPoint.DataTypingServices.DataTypeCollection(...
            engineContext.systemUnderDesign,...
            engineContext.topModelModelReferences,...
            engineContext.proposalSettings);


            this.ResultsFilter.setTopModel(engineContext.topModel);
            this.ResultsFilter.setSUD(engineContext.systemUnderDesign);



            if this.HandleCompile
                models=engineContext.topModelModelReferences;
                nModels=numel(models);
                simulationModeHandler=fixed.internal.simulationmodehandler.AccelModeHandler(models{nModels});
                simulationModeHandler.switchToNormalMode();
                for iModel=nModels:-1:1
                    model=models{iModel};
                    modelCompileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(model);
                    modelCompileHandler.setLicenseType(proposalSettings.LicenseType);
                    modelCompileHandler.setSimType(proposalSettings.SimType);
                    modelCompileHandler.setMaskCompileError(false);
                    modelCompileHandler.start();
                    if iModel==nModels
                        cleanupObject=onCleanup(@()modelCompileHandler.stop());
                    end
                end
                handlerCleaunup=onCleanup(@()simulationModeHandler.restoreSimulationMode());
            end


            fptRepository=fxptds.FPTRepository.getInstance();
            modelObj=get_param(topModel,'Object');
            modelOrSubsystemName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(modelObj);
            dataset=fptRepository.getDatasetForSource(modelOrSubsystemName);
            runObj=dataset.getRun(proposalSettings.scaleUsingRunName);
            dataset.setLastUpdatedRun(proposalSettings.scaleUsingRunName);
            runObj.initialize(modelOrSubsystemName);
            collectionObj.execute();



            dataLayer=fxptds.DataLayerInterface.getInstance();
            allResultsArray=dataLayer.getAllResultsFromRunUsingModelSource(topModel,proposalSettings.scaleUsingRunName);
            allResults=cell(size(allResultsArray));
            for iResult=1:numel(allResults)
                allResults{iResult}=allResultsArray(iResult);
            end
            allResults=this.ResultsFilter.filter(allResults);


            tableWithTypes=this.ResultsToTableAdapter.getTable(allResults);


            dataset.deleteRun(proposalSettings.scaleUsingRunName);
        end
    end
end
