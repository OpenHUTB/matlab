classdef TabGroupView<evolutions.internal.ui.tools.AppToolstripTabGroup




    properties(Constant)
        Name='ManageTabGroup';
        Contextual=true;
    end

    properties(SetAccess=protected)

EvolutionsTab
    end

    methods
        function this=TabGroupView(parent)
            this@evolutions.internal.ui.tools.AppToolstripTabGroup(parent);
            createModalContext(this);
        end

        function v=getSubView(this,type)

            switch type
            case{'ProjectSection','EvolutionTreeSection','FileSection',...
                'WorkingModelSection','EvolutionsSection',...
                'CompareModeSection','ManageTreeViewSection',...
                'ReportSection','ProfileSection','EnvironmentSection'}
                v=getSubView(this.EvolutionsTab,type);
            otherwise
                assert(strcmp(type,'EvolutionsTab'));
                v=this.EvolutionsTab;
            end
        end
    end

    methods(Access=protected)
        function createComponents(this)
            this.EvolutionsTab=evolutions.internal.app.toolstrip.manage...
            .EvolutionsTabView(this);
        end

        function layout(this)

            addTab(this,this.EvolutionsTab);
        end

    end
end


