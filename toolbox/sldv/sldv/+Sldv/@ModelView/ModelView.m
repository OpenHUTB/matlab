




classdef(Sealed)ModelView<handle

    properties(Hidden,Access=private)
        Data=[];
        Informer=[];
        ResultFiles=Sldv.Utils.initDVResultStruct();
        Objects=[];
        highlighted=false;
        highlighter;
        progressUIHandle;
    end

    methods
        function obj=ModelView(sldvData,resultFiles,progressUIHandle)
            obj.Data=sldvData;
            obj.Informer=[];

            modelH=get_param(sldvData.ModelInformation.Name,'Handle');



            referencedModels=find_mdlrefs(modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);




            if sldvprivate('isObserverSupportON',sldvData.AnalysisInformation.Options)
                obsRefBlks=Simulink.observer.internal.getObserverRefBlocksInBD(modelH);
                observerModels=cell(numel(obsRefBlks),1);
                for idx=1:numel(obsRefBlks)
                    observerModels{idx}=get_param(obsRefBlks(idx),'ObserverModelName');
                end
            else
                observerModels={};
            end

            obj.Objects.models=[referencedModels;observerModels];
            obj.Objects.charts=[];


            for index=1:length(obj.Objects.models)
                SLStudio.Utils.RemoveHighlighting(get_param(obj.Objects.models{index},'Handle'));
            end







            if nargin>2
                obj.progressUIHandle=progressUIHandle;
            else
                obj.progressUIHandle=[];
            end

            handles=get_param(modelH,'AutoVerifyData');

            if nargin<2
                if isfield(handles,'currentResult')
                    resultFiles=handles.currentResult;
                else
                    resultFiles=Sldv.Utils.initDVResultStruct();
                end
            end
            obj.ResultFiles=resultFiles;



            if isfield(handles,'modelView')&&handles.modelView.isvalid
                delete(handles.modelView);
            end
            handles.modelView=obj;
            set_param(modelH,'AutoVerifyData',handles);




            obj.initializeHighlighting;
            obj.Informer=Sldv.InspectorWorkflow.Inspector(sldvData,resultFiles);
            obj.openHighlightSystem();

        end

        function progressUIHandle=getProgressHandle(obj)
            progressUIHandle=obj.progressUIHandle;
        end
        function highlightedStatus=isHighlighted(obj)
            highlightedStatus=obj.highlighted;
        end
        function initializeHighlighting(obj)
            obj.highlighter=...
            Sldv.HighlightingWorkflows.ModelItemHighlighter(obj.Data);


            obj.highlighted=true;
        end

        function d=data(obj)
            d=obj.Data;
        end

        function update(obj,files,filters)
            if nargin<3

                [hasError,justifiedObjectives]=obj.getJustifiedObjectivesFromFilters();
            else

                [hasError,justifiedObjectives]=obj.getJustifiedObjectivesFromFilters(filters);
            end

            if hasError
                return;
            end

            obj.ResultFiles=files;
            obj.Informer.updateResultFiles(obj.ResultFiles);
            obj.Informer.updateUI(obj.isHighlighted,justifiedObjectives);
            obj.Informer.displayUI(obj.isHighlighted);
        end





        function updateSldvData(obj,sldvData,resultFiles)
            obj.Data=sldvData;
            if nargin==3
                obj.ResultFiles=resultFiles;
                obj.Informer.updateSldvData(obj.Data);
                obj.Informer.updateResultFiles(obj.ResultFiles);
                obj.Informer.populateInspectorData;
                obj.Informer.updateUI(obj.isHighlighted);
                obj.Informer.displayUI(obj.isHighlighted);
            end


            if slavteng('feature','IncrementalHighlighting')
                if~isempty(obj.highlighter)
                    obj.highlighter.updateSldvData(sldvData);
                end
            end
        end

        function updateAnalysisStatus(obj,analysisStatus)
            if~isempty(obj.Data)&&isfield(obj.Data,'AnalysisInformation')
                obj.Data.AnalysisInformation.Status=analysisStatus;
            end
        end

        function updateModifiedObjectives(obj,modifiedObjectives,modifiedPathObjectives)
            if slavteng('feature','IncrementalHighlighting')
                obj.incrementalUpdateObjectives(modifiedObjectives);
                if(nargin==3)&&~isempty(modifiedPathObjectives)
                    obj.incrementalUpdatePathObjectives(modifiedPathObjectives);
                end



                obj.highlighter.updateSldvData(obj.Data);
                obj.Informer.updateSldvData(obj.Data);
                obj.Informer.updateResultFiles(obj.ResultFiles);
                obj.Informer.populateInspectorData;
                obj.Informer.updateUI(obj.isHighlighted);
                obj.Informer.displayUI(obj.isHighlighted);
            else
                assert(0,'Incremental Highlighting should be featured on');
            end
        end



        function removeHighlightingPreservingData(obj)
            obj.highlighter.clearHighlightingOnElements;



            if~isempty(obj.Informer)
                obj.getInformerHandle.hide();
            end
        end

        function allowRemoveHighlighting=shouldAllowRemoveHighlighting(~,model)
            modelH=get_param(model,'Handle');
            allowRemoveHighlighting=false;

            sldvSession=sldvprivate('sldvGetActiveSession',modelH);


            if~isempty(sldvSession)&&(sldvSession.isAnalysisRunning()||...
                sldvSession.isGeneratingResults())
                allowRemoveHighlighting=true;
            end
        end








        function remove_highlight_during_analysis(obj)
            modelH=get_param(obj.Data.ModelInformation.Name,'Handle');
            session=sldvprivate('sldvGetActiveSession',modelH);
            session.toggleHighlighting(false);
        end

        function remove_highlight(obj)
            model=obj.Data.ModelInformation.Name;

            if~isempty(obj.progressUIHandle)&&obj.shouldAllowRemoveHighlighting(model)








            else

                modelH=get_param(model,'Handle');
                session=sldvprivate('sldvGetActiveSession',modelH);
                if~isempty(session)
                    session.notifyHighlightViewListeners(false);
                end





                if~isempty(obj.highlighter)
                    obj.highlighter.clearHighlighting();
                end

                obj.highlighted=false;



                if~isempty(obj.Informer)
                    defaultT=obj.GetInformerSummary;
                    informer=obj.getInformerHandle();
                    informer.buffer={defaultT};
                    informer.defaultText=defaultT;
                    pathHighlighter=obj.Informer.getPathHighlighter;
                    if~isempty(pathHighlighter)
                        pathHighlighter.clearHighlighting;
                    end
                end
            end
        end

        function refresh(obj)



            if isfield(obj.Informer,'text')
                obj.Informer.text=obj.Informer.buffer{1};
            end
            obj.openHighlightSystem();
        end

        function delete(obj)
            obj.release;
        end
    end

    methods
        function release(obj)
            if obj.isvalid

                obj.remove_highlight;
                obj.Data=[];
                obj.highlighter=[];
                obj.Informer=[];
                obj.progressUIHandle=[];
            end
        end





        function openHighlightSystem(obj)
            sldvData=obj.Data;
            sys=sldvData.ModelInformation.Name;

            sldvSession=sldvprivate('sldvGetActiveSession',sys);
            if~isempty(sldvSession)&&...
                (sldvSession.isAnalysisRunning()||sldvSession.isGeneratingResults())

            else
                mdlH=get_param(sys,'Handle');


                app=SLM3I.SLDomain.getLastActiveStudioAppFor(mdlH);
                if~isempty(app)
                    studio=app.getStudio();
                    studio.show();
                else



                    open_system(sys);
                end
            end
        end

        function view(obj,filters,files)
            if nargin<2

                [hasError,justifiedObjectives]=obj.getJustifiedObjectivesFromFilters();
            else

                [hasError,justifiedObjectives]=obj.getJustifiedObjectivesFromFilters(filters);
            end

            if hasError
                return;
            end

            if nargin>2
                obj.ResultFiles=files;
            end


            obj.highlighter.highlight(justifiedObjectives);

            obj.highlighted=true;

            obj.Informer.updateSldvData(obj.Data);
            obj.Informer.updateResultFiles(obj.ResultFiles);
            obj.Informer.populateInspectorData(justifiedObjectives);
            obj.Informer.updateUI(obj.isHighlighted,justifiedObjectives);
            obj.Informer.displayUI(obj.isHighlighted);
        end

        function bringInformerToFront(obj)
            obj.Informer.bringInformerToFront;
        end

        function displayDataforSid(obj,sid)
            obj.Informer.displayDataforSid(sid);
        end
    end

    methods(Hidden)
        function handle=getInformerHandle(obj)
            handle=obj.Informer.getInformer();
        end
    end

    methods(Access=private)


        summary=GetInformerSummary(obj);


        highlightSid=GetHighlightSid(obj,sid);

    end

    methods(Access=private)
        function incrementalUpdateObjectives(obj,modifiedObjectives)
            if~isempty(modifiedObjectives)
                modifiedSldvDataObjectives=obj.Data.Objectives;

                for objectiveIndex=1:length(modifiedObjectives)
                    modifiedSldvDataObjectives(...
                    modifiedObjectives(objectiveIndex).index).status...
                    =modifiedObjectives(objectiveIndex).status;
                end
                obj.Data.Objectives=modifiedSldvDataObjectives;
            end
        end

        function incrementalUpdatePathObjectives(obj,modifiedPathObjectives)
            if~isempty(modifiedPathObjectives)
                existingPathObjectives=obj.Data.PathObjectives;

                for pathObjectiveIndex=1:length(modifiedPathObjectives)
                    existingPathObjectives(...
                    modifiedPathObjectives(pathObjectiveIndex).index).status...
                    =modifiedPathObjectives(pathObjectiveIndex).status;
                end

                obj.Data.PathObjectives=existingPathObjectives;
            end

        end

        function[hasError,justifiedObjectives]=getJustifiedObjectivesFromFilters(obj,filters)
            hasError=false;
            justifiedObjectives=[];

            if sldvprivate('cannot_apply_filter',obj.Data)
                return;
            end

            if nargin==1
                [filter,hasError]=sldvprivate('getFilterFromAutoVerifyData',obj.Data.ModelInformation.Name,true);
                if hasError||isempty(filter)
                    return;
                end
            else
                if isempty(filters)
                    return;
                else
                    if ischar(filters)

                        [readStatus,filters,err]=sldvprivate('readFilterFiles',...
                        obj.Data.ModelInformation.Name,...
                        filters);
                        if~readStatus
                            error(err);
                        end
                    else

                        for i=1:length(filters)
                            if filters(i).hasUnappliedChanges
                                filters(i).show;
                                hasError=true;
                                errordlg(getString(message('Sldv:Filter:ApplyOrRevertOrCloseFilterMdlHighlight')),...
                                getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),...
                                'modal');

                                return;
                            end
                        end
                    end
                    filter=Sldv.Filter.mergeInMemory(filters);
                end
            end
            [hasError,justifiedObjectives]=obj.getJustifiedObjectivesFromFilter(filter);
        end

        function[hasError,justifiedObjectives]=getJustifiedObjectivesFromFilter(obj,filter)
            hasError=false;
            justifiedObjectives=[];

            if isempty(filter)
                return;
            end

            justifiedInfo=sldvprivate('getObjectivesJustifiedAfterAnalysis',...
            obj.Data,...
            filter);
            justifiedObjectives=justifiedInfo.objectives;
        end
    end
end


