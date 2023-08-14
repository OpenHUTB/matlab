classdef CompareManager<handle




    properties(Hidden,SetAccess=immutable)
AppModel
ProjectInterface
EventHandler
    end

    properties(Dependent,SetAccess=private)
        Stereotypes char
    end

    properties(SetAccess=protected,GetAccess=public)
FilesAddedList
FilesChangedList
FilesRemovedList
SelectedEvolutionInCompare
DifferencesStruct
CurrentProjectPath

        Description char
        EvolutionNode char
    end

    properties(GetAccess=public,SetAccess=public,SetObservable,AbortSet)
SelectedEdge
CompareEdge
    end

    methods
        function this=CompareManager(appModel)
            this.AppModel=appModel;
            this.ProjectInterface=appModel.ProjectInterface;
            this.EventHandler=appModel.EventHandler;
            initialize(this);
            addlistener(this.EventHandler,'EdgeSelectionChanged',@this.handleSelectedEdgeSet);
        end

        function updateEdgeSummary(this,selectedEdge)
            populateEdgeSummary(this,selectedEdge);
        end

        function update(this)
            if~isempty(this.CompareEdge)
                this.updateEdgeSummary(this.CompareEdge);
            end
        end

        function setDifferences(this,differences,currentProjectPath)
            this.DifferencesStruct=differences;
            this.CurrentProjectPath=currentProjectPath;
        end

        function stereotypes=get.Stereotypes(this)
            stereotypes=char.empty;
        end
    end

    methods(Access=protected)
        function initialize(this)

            this.Description=char.empty;
            this.CompareEdge=evolutions.model.Edge.empty(1,0);
        end

        function populateEdgeSummary(this,selectedEdge)


            this.Description=sprintf(strrep(selectedEdge.Description,'%','%%'));
        end
    end

    methods(Access=private)
        function handleSelectedEdgeSet(this,~,~)
            notify(this.EventHandler,'SelectedEdgeChanged',...
            evolutions.internal.ui.GenericEventData(this.SelectedEdge));
        end
    end
end
