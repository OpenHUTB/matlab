


function[selectedCompIds,subTrees]=setupRun(this)

    if this.MultiMode




        cm=this.ComponentManager;
        if isempty(cm)||~cm.IsInitialized||cm.IsDirty
            this.analyzeComponents();
        end


        for n=1:length(this.AsynchronousComponentSelectionCache)
            this.applyComponentSelection(this.AsynchronousComponentSelectionCache{n});
        end


        this.AsynchronousComponentSelectionCache={};





        [selectedCompIds,subTrees]=...
        this.getSelectedComponentsToExecute();





        try


            if~isempty(this.RootModel)&&~bdIsLoaded(this.RootModel)
                load_system(this.RootModel);
            end

            this.ComponentManager.ensureComponentsAreLoaded(...
            this.AnalysisRootComponentId);
        catch E
            if strcmp(E.identifier,'Simulink:Commands:OpenSystemUnknownSystem')
                DAStudio.error('Advisor:base:Components_ComponentNotLoaded',E.message);
            else
                rethrow(E);
            end
        end

    else
        selectedCompIds={this.AnalysisRootComponentId};
        subTrees.RootModel=this.RootModel;
        subTrees.Models={this.RootModel};
    end



    this.RunTime=now;


    for n=1:length(selectedCompIds)
        if strcmp(this.AnalysisRootComponentId,selectedCompIds{n})
            isRootModel=true;
        else
            isRootModel=false;
        end

        [~,status]=this.updateModelAdvisorObj(selectedCompIds{n},isRootModel);



        if status~=0
            DAStudio.error('Advisor:base:App_CannotInitMAObj',selectedCompIds{n});
        end
    end
end