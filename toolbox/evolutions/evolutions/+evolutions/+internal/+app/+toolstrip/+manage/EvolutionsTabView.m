classdef EvolutionsTabView<evolutions.internal.ui.tools.ToolstripTab







    properties(Constant)
        Title=getString(message('evolutions:ui:Tab1'));
        Name='EvolutionsTab';
        Tag='default';
    end

    properties(SetAccess=protected)
ProjectSection
EvolutionTreeSection
FileSection
WorkingModelSection
EvolutionsSection
TestSection
CompareSection
TreeViewSection
EnvironmentSection
ReportSection
ProfileSection
    end

    methods
        function this=EvolutionsTabView(parent)
            this@evolutions.internal.ui.tools.ToolstripTab(parent);
        end

        function v=getSubView(this,type)

            switch type
            case 'FileSection'
                v=this.FileSection;
            case 'WorkingModelSection'
                v=this.WorkingModelSection;
            case 'EvolutionsSection'
                v=this.EvolutionsSection;
            case 'TestSection'
                v=this.TestSection;
            case 'CompareModeSection'
                v=this.CompareSection;
            case 'ProjectSection'
                v=this.ProjectSection;
            case 'ManageTreeViewSection'
                v=this.TreeViewSection;
            case 'EnvironmentSection'
                v=this.EnvironmentSection;
            case 'ReportSection'
                v=this.ReportSection;
            case 'ProfileSection'
                v=this.ProfileSection;
            otherwise
                assert(strcmp(type,'EvolutionTreeSection'));
                v=this.EvolutionTreeSection;
            end
        end

        function enableWidget(this,enabled,type)
            enableWidget(this.EvolutionsSection,enabled,type);
        end
    end

    methods(Access=protected)
        function createTabComponents(this)

            import evolutions.internal.app.toolstrip.manage.*;
            this.EvolutionTreeSection=EvolutionTreeSectionView(this);


            this.EvolutionsSection=EvolutionsSectionView(this);
            this.TreeViewSection=TreeViewSectionView(this);
            this.EnvironmentSection=EnvironmentSectionView(this);
            this.ReportSection=ReportSectionView(this);
            this.ProfileSection=ProfileSectionView(this);
        end

        function layoutTab(this)
            addSection(this,this.EvolutionTreeSection);


            addSection(this,this.EvolutionsSection);
            addSection(this,this.TreeViewSection);
            addSection(this,this.EnvironmentSection);
            if evolutions.internal.getFeatureState('EnableReport')
                addSection(this,this.ReportSection);
            end
            if evolutions.internal.getFeatureState('EnableCustomProfiles')
                addSection(this,this.ProfileSection);
            end
        end
    end
end
