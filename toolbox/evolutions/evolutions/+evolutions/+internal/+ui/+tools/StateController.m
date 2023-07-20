classdef StateController<handle




    properties(SetAccess=immutable)
AppController
AppModel
EventHandler
FileListManager
EvolutionsTreeManager
EvolutionTreeListManager
    end

    properties(Access=protected,Dependent)
SelectedEvolution
ActiveEvolution



ButtonStates
    end

    properties

        CreateEvolutionTree logical
        ChangeEvolutionTree logical
        DeleteEvolutionTree logical
    end

    properties

        Add logical
        AddToActive logical
        AddToAll logical
        AddToActiveFileOnly logical
        AddToActiveWithDependencies logical
        AddToAllFileOnly logical
        AddToAllWithDependencies logical
        Remove logical
        RemoveFromActive logical
        RemoveFromAll logical
        Get logical
        HasEvolutions logical
        isWorkingEvolution logical
        CurrentSelected logical
        ActiveEvolutionEdgeSelected logical
        EdgeClicked logical
        CanvasClicked logical
    end

    properties

        Create logical
        Update logical
        DeleteNode logical
        DeleteBranch logical
    end

    properties

TreeViewButton

SelectedEdge
    end

    properties

        GenerateReport logical
    end

    properties(Access=protected)

FileListListener
FileListManagerListener
EvolutionTreeClickListener
EvolutionTreeListManagerListener
CompareFileSelectionChangeListener
ButtonStateChangeListener
EdgeSelectionChangedListener
CanvasClickListener
    end

    methods
        function selectedEvolution=get.SelectedEvolution(this)
            selectedEvolution=this.EvolutionsTreeManager.SelectedEvolution;
        end

        function activeEvolution=get.ActiveEvolution(this)
            currentTree=this.EvolutionTreeListManager.CurrentSelected;
            activeEvolution=this.AppController.ProjectInterface.getEvolutionTreeWorkingNode(currentTree);
        end

        function buttonStates=get.ButtonStates(this)
            buttonStates=this.FileListManager.ButtonStates;
        end
    end

    methods(Access=?evolutions.internal.app.AppController)
        function this=StateController(appController)

            this.AppController=appController;
            this.AppModel=appController.AppModel;
            this.EventHandler=appController.EventHandler;
            this.FileListManager=getSubModel(this.AppModel,'FileList');
            this.EvolutionsTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            this.EvolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            this.ActiveEvolutionEdgeSelected=false;
            this.EdgeClicked=false;
            initializeStates(this);
        end

        function setup(this)
            installListeners(this);
            updateStates(this);
        end

    end

    methods(Access=protected)
        function installListeners(this)

            this.FileListListener=...
            addlistener(this.EventHandler,'WorkingModelChanged',@this.onStateChange);
            this.FileListManagerListener=...
            addlistener(this.EventHandler,'FileListChanged',@this.onStateChange);
            this.EvolutionTreeClickListener=...
            addlistener(this.EventHandler,'TreeSelectionChanged',@this.onStateChange);
            this.EvolutionTreeListManagerListener=...
            addlistener(this.EventHandler,'EvolutionTreeListManagerChanged',@this.onStateChange);
            this.CompareFileSelectionChangeListener=...
            addlistener(this.EventHandler,'CompareFileSelectionChanged',@this.onStateChange);
            this.EdgeSelectionChangedListener=...
            listener(this.EventHandler,'SelectedEdgeChanged',@this.EdgeClickedStates);
            this.CanvasClickListener=...
            listener(this.EventHandler,'CanvasClicked',@this.CanvasClickedStates);
            this.CanvasClickListener=...
            listener(this.EventHandler,'NodeClicked',@this.onStateChange);
        end

        function initializeStates(this)
            this.ChangeEvolutionTree=false;
            this.DeleteEvolutionTree=false;
            this.CreateEvolutionTree=false;
            this.DeleteNode=false;
            this.DeleteBranch=false;
            this.Get=false;
            this.TreeViewButton=false;
            this.GenerateReport=false;
            this.HasEvolutions=false;
            this.isWorkingEvolution=false;
            this.CurrentSelected=false;
            this.Create=false;
            this.Update=false;
        end

        function onStateChange(this,~,~)
            this.ActiveEvolutionEdgeSelected=false;
            this.EdgeClicked=false;
            this.CanvasClicked=false;
            updateStates(this);
        end

        function updateStates(this)
            initializeStates(this);
            findEvolutionTreeSectionStates(this);
            findFileSectionStates(this);
            findEvolutionSectionStates(this);
            findEvolutionTreeViewSectionStates(this);
            findReportSectionStates(this);
            notify(this.EventHandler,'StateChanged');
        end

        function findEvolutionTreeSectionStates(this)
            treeList=getTreeList(this);
            this.ChangeEvolutionTree=numel(treeList)>1;
            this.DeleteEvolutionTree=~isempty(treeList);
            this.CreateEvolutionTree=true;
        end

        function findFileSectionStates(this)
            if~isempty(this.SelectedEvolution)


                this.HasEvolutions=~this.EvolutionsTreeManager.RootEvolution.IsWorking;
                this.isWorkingEvolution=this.SelectedEvolution.IsWorking;
                this.CurrentSelected=~isempty(this.FileListManager.CurrentSelected)&&...
                this.SelectedEvolution.IsWorking;
            end
        end

        function EdgeClickedStates(this,~,evtdata)
            this.EdgeClicked=true;
            this.CanvasClicked=false;
            this.SelectedEdge=evtdata.EventData.tag;
            this.ActiveEvolutionEdgeSelected=strcmp('ActiveEvolutionConnection',this.SelectedEdge);
            updateStates(this)
        end

        function CanvasClickedStates(this,~,~)
            this.EdgeClicked=false;
            this.CanvasClicked=true;
            updateStates(this);
        end

        function findEvolutionSectionStates(this)

            if this.EdgeClicked
                this.Create=this.ActiveEvolutionEdgeSelected;
            elseif~isempty(this.SelectedEvolution)
                this.Create=this.SelectedEvolution.IsWorking;

                this.Update=isequal(this.ActiveEvolution.Parent,this.SelectedEvolution)&&(length(this.SelectedEvolution.Children)==1);
                deleteEnable=~isempty(this.FileListManager.FileList)&&...
                ~this.SelectedEvolution.IsWorking;
                this.DeleteBranch=deleteEnable&&~isempty(this.SelectedEvolution.Children);

                this.DeleteNode=getNodeDeleteState(this,deleteEnable);

                this.Get=~isequal(this.SelectedEvolution,this.ActiveEvolution);
            end
        end

        function findEvolutionTreeViewSectionStates(this)
            treeList=getTreeList(this);
            this.TreeViewButton=~isempty(treeList);
        end

        function findReportSectionStates(this)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            treeList=treeListManager.getAllTrees(projectRefListModel.ReferenceList);
            this.GenerateReport=~isempty(treeList);
        end

        function tf=getNodeDeleteState(this,deleteEnable)
            isRoot=deleteEnable&&isempty(this.SelectedEvolution.Parent);
            if isRoot

                tf=~(numel(this.SelectedEvolution.Children)>1);
            else

                tf=deleteEnable;
            end
        end

        function treeList=getTreeList(this)
            projectRefListModel=getSubModel(this.AppModel,'ProjectReferenceListManager');
            treeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            treeList=treeListManager.getAllTrees(projectRefListModel.ReferenceList);
        end
    end

end
