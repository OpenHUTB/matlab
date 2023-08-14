classdef ToolstripController<handle




    properties(SetAccess=immutable)

AppModel
AppView
AppController
EventHandler
    end

    properties(SetAccess=protected)

ManageTabGroupController
CompareTabGroupController
    end

    methods
        function this=ToolstripController(appController)



            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.AppController=appController;
            this.EventHandler=appController.EventHandler;

            createSubControllers(this);
            setDefaultContext(this);
        end

        function setup(this)

            installViewListeners(this);
            setup(this.ManageTabGroupController);
        end

        function delete(this)

            deleteControllers(this);
        end

        function c=getSubController(this,type)
            switch type
            case{'project','evolutiontree','file','working',...
                'evolutions','test','comparemode','report','environment','TreeView'}
                c=getSubController(this.ManageTabGroupController,type);
            otherwise
                assert(strcmp(type,'ManageTabGroup'));
                c=this.ManageTabGroupController;
            end
        end

        function setManageContext(this)
            view=getSubView(this.AppView,'ManageTabGroup');
            setActiveContext(this.AppView,getTag(view));
        end

    end


    methods(Access=protected)
        function createSubControllers(this)






            import evolutions.internal.app.toolstrip.*;
            appController=this.AppController;


            this.ManageTabGroupController=manage.TabGroupController(appController);
        end

        function installModelListeners(~)

        end

        function installViewListeners(~)

        end

        function deleteControllers(this)
            props=["ManageTabGroupController","CompareTabGroupController"];
            evolutions.internal.ui.deleteControllers(this,props);
        end

        function setDefaultContext(this)
            setManageContext(this)
        end
    end
end


