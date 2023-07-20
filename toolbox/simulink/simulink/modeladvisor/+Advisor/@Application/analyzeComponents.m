








function analyzeComponents(this)
    newInit=false;
    if~isempty(this.ComponentManager)

        if~strcmp(this.AnalysisRoot,this.ComponentManager.AnalysisRoot)
            this.initComponentManager();
            newInit=true;
        end


        this.ComponentManager.analyzeDependencies();
    else

        this.initComponentManager();
        this.ComponentManager.analyzeDependencies();
        newInit=true;
    end

    if newInit

        inputs.ids={};
        inputs.type=[];
        inputs.status=true;
        this.applyComponentSelection(inputs);
    end


    if~isempty(this.AsynchronousComponentSelectionCache)
        for n=1:length(this.AsynchronousComponentSelectionCache)
            this.applyComponentSelection(this.AsynchronousComponentSelectionCache{n});
        end


        this.AsynchronousComponentSelectionCache={};
    end





    allComponents=this.ComponentManager.getComponents();
    allInstanceIds={allComponents.ID};

    allMAObjCompIds=this.CompId2MAObjIdxMap.keys;

    outdatedComponentIds=setdiff(allMAObjCompIds,allInstanceIds);

    if~isempty(outdatedComponentIds)

        for n=1:length(outdatedComponentIds)
            this.deleteMAObj(outdatedComponentIds{n});
        end
    end
end