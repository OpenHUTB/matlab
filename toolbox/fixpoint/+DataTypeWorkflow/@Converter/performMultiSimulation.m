function[simOut,simIn,mergedRunName]=performMultiSimulation(this,simulationSettings)






    simIn=simulationSettings.simIn;


    dataLayer=fxptds.DataLayerInterface.getInstance();
    facade=this.getWorkflowTopologyFacade();


    allDatasets=fxptds.getAllDatasetsForModel(this.TopModel);


    mergedRunName=this.CurrentRunName;





    [~,fptID]=dataLayer.getIdFromRunName(this.TopModel,mergedRunName);
    if~isempty(fptID)
        deriveNode=facade.query(fptID,'search','exact','type','Derive');
        if isempty(deriveNode{1})
            mergedRunName=this.makeRunNameUnique(mergedRunName);
        end
    end



    isEmbedded=dataLayer.isRunVerificationRun(this.TopModel,mergedRunName);


    numScenarios=numel(simIn);
    scenarioRunNames=cell(numScenarios,1);






    for idx=1:numel(simIn)


        simIn(idx)=this.updateSimulationInputObject(simIn(idx));


        simIn(idx).validate;


        simInModel=simIn(idx).ModelName;
        assert(strcmp(simInModel,this.TopModel),message('FixedPointTool:fixedPointTool:simulationInputModelError',this.TopModel));



        modelParams={simIn(idx).ModelParameters.Name};
        givenRunNameIndex=find(strcmp(modelParams,'FPTRunName'));
        if~isempty(givenRunNameIndex)
            scenarioRunName=simIn(idx).ModelParameters(givenRunNameIndex).Value;
        else

            scenarioRunName=[mergedRunName,'_Scenario_',+num2str(idx)];
        end



        simIn(idx)=simIn(idx).setModelParameter('MinMaxOverflowArchiveMode','Merge');



        scenarioRunName=this.makeRunNameUnique(scenarioRunName);
        simIn(idx)=simIn(idx).setModelParameter('FPTRunName',scenarioRunName);


        scenarioRunNames{idx}=scenarioRunName;


        if isEmbedded


            dataLayer.addEmbeddedRunName(this.TopModel,scenarioRunName);
        end
    end


    allSDIRunsBeforeSim=Simulink.sdi.getAllRunIDs;



    simWarning=warning('off','Simulink:Commands:SimulationsWithErrors');

    cleanup=onCleanup(@()warning('on',simWarning.identifier));

    try
        simOut=sim(simIn,...
        'ShowSimulationManager',simulationSettings.ShowSimulationManager,...
        'ShowProgress',simulationSettings.ShowProgress...
        );


        for sIndex=1:length(simOut)
            if~isempty(simOut(sIndex).ErrorMessage)
                diagnostic=simOut(sIndex).SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic;
                if~isempty(diagnostic)

                    diagnostic.reportAsError;
                end
            end
        end

    catch e


        this.deleteRuns(mergedRunName,scenarioRunNames);




        throw(e);
    end


    allSDIRunsAfterSim=Simulink.sdi.getAllRunIDs;



    allSDIRunsForMultiSim=setdiff(allSDIRunsAfterSim,allSDIRunsBeforeSim,'stable');

    hasSDIForEachScenario=numel(allSDIRunsForMultiSim)==numScenarios;


    for idx=1:numScenarios
        scenarioRunName=scenarioRunNames{idx};


        this.ApplicationData.mergeModelReferenceData(get_param(this.TopModel,'Object'),scenarioRunName);


        this.createSettingsMapFromSystem(scenarioRunName);



        if hasSDIForEachScenario


            sdiRunID=allSDIRunsForMultiSim(idx);

            sigLogStruct=struct('modelName',this.TopModel,'runID',sdiRunID);
            DataTypeWorkflow.SigLogServices.updateFromEventData(sigLogStruct,scenarioRunName);
        end










        for datasetIdx=1:numel(allDatasets)

            ds=allDatasets{datasetIdx};
            this.ApplicationData.mergeResultsOfRuns(ds,scenarioRunName,mergedRunName);
        end

    end



    SimulinkFixedPoint.ApplicationData.mergeModelReferenceData(get_param(this.TopModel,'Object'),mergedRunName);


    this.createSettingsMapFromSystem(mergedRunName);

end

