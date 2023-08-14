classdef EvolutionsSummaryManager<handle




    events
    end

    properties(SetAccess=protected,GetAccess=public)
AppModel
        Name char
        Parent char
        IsWorking logical
        Project char
EvolutionNode


        CreatedOn char
        UpdatedOn char
        UpdatedBy char
        Description char
    end

    methods
        function this=EvolutionsSummaryManager(appModel)
            this.AppModel=appModel;
            initialize(this);
        end

        function updateEvolutionSummary(this,selectedNode)
            if nargin<2
                tree=getSubModel(this.AppModel,'EvolutionsTreeManager');
                selectedNode=tree.SelectedEvolution;
            end

            this.EvolutionNode=selectedNode;
            if isempty(selectedNode)
                initialize(this);

            else

                populateEvolutionSummary(this,selectedNode);
            end
        end
    end

    methods(Access=protected)
        function initialize(this)
            this.Name=char.empty;
            this.Parent=char.empty;
            this.IsWorking=false;


            this.CreatedOn=char.empty;
            this.UpdatedOn=char.empty;
            this.UpdatedBy=char.empty;
            this.Description=char.empty;
        end

        function populateEvolutionSummary(this,selectedNode)

            this.Name=selectedNode.getName;
            notApplicableMessage=getString(message('evolutions:ui:InfoNotApplicable'));
            if~isempty(selectedNode.Parent)
                this.Parent=selectedNode.Parent.getName;
            else
                this.Parent=notApplicableMessage;
            end
            this.IsWorking=selectedNode.IsWorking;

            this.CreatedOn=selectedNode.Created;
            this.UpdatedOn=selectedNode.Updated;
            this.UpdatedBy=selectedNode.Author;
            this.Description=sprintf(strrep(selectedNode.Description,'%','%%'));
        end
    end
end
