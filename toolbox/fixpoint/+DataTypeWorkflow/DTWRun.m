classdef DTWRun<handle




    properties(SetAccess=private)
RunName
SelectedSystemToScale
        ModelReferences='';
        ModelReferenceInstances='';
    end

    properties(Access=private)
        SelectedSystemResults={};
        ModelReferencesResults={};
        ModelReferenceInstancesResults={};
    end

    methods(Access={?DataTypeWorkflow.Converter,?DataTypeWorkflow.DTWRun},Hidden)

        function this=DTWRun(runName,mdlName)
            this.RunName=runName;
            this.SelectedSystemToScale=mdlName;
            this.prepareResultsToSave;
        end

        function badRestoredResults=restoreDTWRun(this)
            badRestoredResults=this.restoreDatasets({this.SelectedSystemToScale},{this.SelectedSystemResults});

            if~isempty(this.ModelReferences)

                badRSMdlRef=this.restoreDatasets(this.ModelReferences,this.ModelReferencesResults);
                badRestoredResults=[badRestoredResults,badRSMdlRef];


                badRSInstance=this.restoreMdlRefInstancesDatasets;
                badRestoredResults=[badRestoredResults,badRSInstance];
            end
        end
    end

    methods(Access=private)
        function prepareResultsToSave(this)

            this.SelectedSystemResults=this.collectResultsOfMdl(this.SelectedSystemToScale);



            [allModels,mdlRefBlks]=find_mdlrefs(this.SelectedSystemToScale,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'IncludeProtectedModels',false);

            if~isempty(mdlRefBlks)


                this.ModelReferences=allModels(1:length(allModels)-1);


                this.ModelReferencesResults=this.prepareMdlRefResults(this.ModelReferences);


                this.ModelReferenceInstances=this.mdlRefInstanceToSID(mdlRefBlks);

                this.ModelReferenceInstancesResults=this.prepareMdlRefResults(this.ModelReferenceInstances);
            end
        end

        function results=collectResultsOfMdl(this,mdl)


            fptRepositoryInstance=fxptds.FPTRepository.getInstance;
            dataset=fptRepositoryInstance.getDatasetForSource(mdl);
            runObj=dataset.getRun(this.RunName);
            results=runObj.getResults;
        end

        function results=prepareMdlRefResults(this,models)


            results=cell(1,length(models));
            for refIdx=1:length(models)
                results{refIdx}=this.collectResultsOfMdl(models{refIdx});
            end
        end

        function badRestoredResults=restoreDatasets(this,models,savedResultsOfMdls)

            fptRepositoryInstance=fxptds.FPTRepository.getInstance;
            for mdlIdx=1:length(models)
                dataset=fptRepositoryInstance.getDatasetForSource(models{mdlIdx});
                badRestoredResults=dataset.restoreRun(this.RunName,savedResultsOfMdls{mdlIdx});
            end
        end

        function badRestoredResults=restoreMdlRefInstancesDatasets(this)


            badRestoredResults={};
            for mdlRefIdx=1:length(this.ModelReferenceInstances)
                if Simulink.ID.isValid(this.ModelReferenceInstances{mdlRefIdx})
                    instanceHandle=get_param(this.ModelReferenceInstances{mdlRefIdx},'handle');
                    appdata=SimulinkFixedPoint.getApplicationDataAsSubMdl(this.SelectedSystemToScale,instanceHandle);
                    dataset=appdata.subDatasetMap(instanceHandle);

                    savedResults=this.ModelReferenceInstancesResults{mdlRefIdx};
                    badRestoredResults=[badRestoredResults,dataset.restoreRun(this.RunName,savedResults)];%#ok<AGROW>
                else
                    inValidResult=this.ModelReferenceInstancesResults(mdlRefIdx);
                    badRestoredResults=[badRestoredResults,inValidResult];%#ok<AGROW>
                end
            end
        end

        function mdlRefSIDs=mdlRefInstanceToSID(~,mdlRefBlks)

            mdlRefSIDs=cell(1,length(mdlRefBlks));
            for refIdx=1:length(mdlRefBlks)
                mdlRefSIDs{refIdx}=Simulink.ID.getSID(mdlRefBlks{refIdx});
            end
        end
    end

end

