classdef EvolutionsTreeManager<handle




    properties(Hidden,SetAccess=immutable)
ProjectInterface
AppModel
EventHandler
    end

    properties
RootEvolution
TreeTitle
    end

    properties(GetAccess=public,SetAccess=public,SetObservable,AbortSet)
SelectedEvolution
    end

    methods
        function this=EvolutionsTreeManager(appModel)
            this.ProjectInterface=appModel.ProjectInterface;
            this.SelectedEvolution=evolutions.model.EvolutionInfo.empty(1,0);
            this.AppModel=appModel;
            this.EventHandler=appModel.EventHandler;
            this.update;

            addlistener(this,'SelectedEvolution','PostSet',@this.handleSelectedEvolutionSet);
            addlistener(this.EventHandler,'EvolutionChanged',@this.handleEvolutionChanged);
            addlistener(this.EventHandler,'EvolutionCreated',@this.handleEvolutionCreated);
            addlistener(this.EventHandler,'CanvasClicked',@this.handleCanvasClickedState);
        end

        function update(this)
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            curEti=treeListManager.CurrentSelected;
            if~isempty(curEti)
                this.RootEvolution=treeListManager.CurrentSelected.EvolutionManager.RootEvolution;
            else
                this.RootEvolution=evolutions.model.EvolutionInfo.empty(1,0);
            end
            this.SelectedEvolution=evolutions.model.EvolutionInfo.empty(1,0);
            this.setTreeTitle(treeListManager.CurrentSelected);
        end

        function data=getTreeData(this)
            data=this.RootEvolution;
        end

        function handleCanvasClickedState(this,~,~)
            this.SelectedEvolution=evolutions.model.EvolutionInfo.empty(1,0);
        end

        function setWorkingSelected(this)
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            curEti=treeListManager.CurrentSelected;
            if~isempty(curEti)
                this.SelectedEvolution=treeListManager.CurrentSelected.EvolutionManager.WorkingEvolution;
            else
                this.SelectedEvolution=evolutions.model.EvolutionInfo.empty(1,0);
            end
        end
    end

    methods(Access=protected)
        function setTreeTitle(this,node)
            if~isempty(node)
                this.TreeTitle=node.getName;
            else
                this.TreeTitle='Evolution Tree';
            end
        end
    end

    methods(Access=private)
        function handleSelectedEvolutionSet(this,~,~)
            notify(this.EventHandler,'TreeSelectionChanged',...
            evolutions.internal.ui.GenericEventData(this.SelectedEvolution));
        end

        function handleEvolutionChanged(this,~,~)
            this.update;
            notify(this.EventHandler,'EvolutionsTreeManagerChanged');
        end

        function handleEvolutionCreated(this,~,~)
            this.update;
            notify(this.EventHandler,'NewEvolutionCreated');
        end
    end
end
