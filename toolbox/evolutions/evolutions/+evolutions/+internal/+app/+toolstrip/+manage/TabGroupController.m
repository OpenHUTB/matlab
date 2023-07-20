classdef TabGroupController<handle




    properties(SetAccess=immutable)

AppModel
AppView
AppController
    end

    properties(SetAccess=protected)

EvolutionsTabController
    end

    methods
        function this=TabGroupController(appController)



            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.AppController=appController;


            createSubControllers(this);
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);

            setup(this.EvolutionsTabController);
        end

        function delete(this)

            props="EvolutionsTabController";
            evolutions.internal.ui.deleteControllers(this,props);
        end

        function c=getSubController(this,type)
            switch type
            case{'project','evolutiontree','file','working',...
                'evolutions','test','compareMode','report'}
                c=getSubController(this.EvolutionsTabController,type);
            otherwise
                assert(strcmp(type,'EvolutionsTabController'));
                c=this.EvolutionsTabController;
            end
        end
    end


    methods(Access=protected)
        function createSubControllers(this)






            import evolutions.internal.app.toolstrip.*;
            appController=this.AppController;


            this.EvolutionsTabController=manage.EvolutionsTabController(appController);
        end

        function installModelListeners(~)

        end

        function installViewListeners(~)

        end
    end
end


