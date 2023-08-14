classdef ToolstripView<handle





    properties(Constant)
        Name char='TabGroups';
    end

    properties(SetAccess=protected)
AppView
ManageTabGroup
CompareTabGroup
    end

    methods
        function this=ToolstripView(appView)
            this.AppView=appView;
            createComponents(this);
            layout(this);
        end

        function v=getSubView(this,type)
            switch type
            case 'ManageTabGroup'
                v=this.ManageTabGroup;
            case{'ProjectSection','EvolutionTreeSection','FileSection',...
                'WorkingModelSection','EvolutionsSection',...
                'CompareModeSection','EvolutionsTab',...
                'ManageTreeViewSection','ReportSection',...
                'ProfileSection','EnvironmentSection'}
                v=getSubView(this.ManageTabGroup,type);
            case{'CompareSection','CloseCompareSection','CompareTreeViewSection'}
                v=getSubView(this.CompareTabGroup,type);
            otherwise
                assert(strcmp(type,'CompareTabGroup'));
                v=this.CompareTabGroup;
            end
        end
    end

    methods
        function createComponents(this)
            import evolutions.internal.app.toolstrip.*
            this.ManageTabGroup=manage.TabGroupView(this.AppView);
        end

        function layout(this)
            addTabGroup(this.AppView,this.ManageTabGroup)
        end

    end

end
