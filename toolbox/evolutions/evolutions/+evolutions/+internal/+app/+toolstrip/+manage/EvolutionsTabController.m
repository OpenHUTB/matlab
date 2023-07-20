classdef EvolutionsTabController<handle





    properties(SetAccess=immutable)

AppModel
AppView
AppController
    end

    properties(SetAccess=protected)

EvolutionTreeSectionController
FileSectionController
EvolutionsSectionController
TestSectionController
TreeViewSectionController
EnvironmentSectionController
ReportSectionController
ProfileSectionController
    end

    methods
        function this=EvolutionsTabController(appController)



            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.AppController=appController;


            createSectionControllers(this);
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);
            setup(this.EvolutionTreeSectionController);


            setup(this.EvolutionsSectionController);
            setup(this.TreeViewSectionController);
            setup(this.EnvironmentSectionController);
            setup(this.ReportSectionController);
            setup(this.ProfileSectionController);
        end

        function delete(this)

            props=["FileSectionController",...
            "EvolutionsSectionController",...
            "EvolutionTreeSectionController","ProfileSectionController",...
            "TreeViewSectionController","EnvironmentSectionController",...
            "ReportSectionController","ProfileSectionController"];
            evolutions.internal.ui.deleteControllers(this,props);
        end

        function c=getSubController(this,type)

            switch type
            case 'evolutiontree'
                c=this.EvolutionTreeSectionController;
            case 'file'
                c=this.FileSectionController;
            case 'evolutions'
                c=this.EvolutionsSectionController;
            case 'report'
                c=this.ReportSectionController;
            case 'profile'
                c=this.ProfileSectionController;
            case 'environment'
                c=this.EnvironmentSectionController;
            otherwise
                assert(strcmp(type,'TreeView'));
                c=this.TreeViewSectionController;
            end
        end
    end


    methods(Access=protected)
        function createSectionControllers(this)






            import evolutions.internal.app.toolstrip.*;
            appController=this.AppController;


            this.EvolutionTreeSectionController=manage.EvolutionTreeSectionController(appController);


            this.EvolutionsSectionController=manage.EvolutionsSectionController(appController);
            this.TreeViewSectionController=manage.TreeViewSectionController(appController,'ManageTreeViewSection');
            this.EnvironmentSectionController=manage.EnvironmentSectionController(appController);
            this.ReportSectionController=manage.ReportSectionController(appController);
            this.ProfileSectionController=manage.ProfileSectionController(appController);
        end

        function installModelListeners(~)

        end

        function installViewListeners(~)

        end
    end
end


