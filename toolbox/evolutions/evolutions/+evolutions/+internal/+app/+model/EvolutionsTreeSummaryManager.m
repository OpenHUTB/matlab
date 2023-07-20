classdef EvolutionsTreeSummaryManager<handle




    events
    end

    properties(Dependent,SetAccess=private)
        Stereotypes char
    end

    properties(SetAccess=protected,GetAccess=public)
AppModel
        Name char
        Project char


        CreatedOn char
        UpdatedOn char
        UpdatedBy char
        Description char
    end

    methods
        function this=EvolutionsTreeSummaryManager(appModel)
            this.AppModel=appModel;
            this.update;
        end

        function update(this)
            evolutionsTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
            selectedNode=evolutionsTreeListManager.CurrentSelected;
            if isempty(selectedNode)
                initialize(this);

            else

                populateEvolutionSummary(this,selectedNode);
            end
        end

        function stereotypes=get.Stereotypes(~)
            stereotypes=char.empty;
        end
    end

    methods(Access=protected)
        function initialize(this)
            this.Name=char.empty;
            this.Project=char.empty;


            this.CreatedOn=char.empty;
            this.UpdatedOn=char.empty;
            this.UpdatedBy=char.empty;
            this.Description=char.empty;
        end

        function populateEvolutionSummary(this,selectedNode)

            this.Name=selectedNode.getName;
            this.Project=selectedNode.Project.Name;


            this.CreatedOn=selectedNode.Created;
            this.UpdatedOn=selectedNode.Updated;
            this.UpdatedBy=selectedNode.Author;
            this.Description=sprintf(strrep(selectedNode.Description,'%','%%'));
        end
    end
end
