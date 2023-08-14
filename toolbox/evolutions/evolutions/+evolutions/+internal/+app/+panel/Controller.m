classdef Controller<handle




    properties(SetAccess=immutable)

AppController
AppModel
AppView
PanelView

EventHandler
    end

    properties(SetAccess=protected)
PropertyInspectorPanelController
FileViewerPanelController
    end

    properties(SetAccess=protected)

    end

    methods
        function this=Controller(appController)
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.PanelView=getSubView(this.AppView,'PanelView');
            this.EventHandler=appController.EventHandler;
            setDefaultContext(this);
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);

            setup(this.PropertyInspectorPanelController);
            if(evolutions.internal.getFeatureState('EnableWebview'))
                setup(this.FileViewerPanelController);
            end
        end



        function delete(this)

            deleteListeners(this);

            deleteControllers(this);
        end

        function update(this)

            if(evolutions.internal.getFeatureState('EnableWebview'))
                update(this.FileViewerPanelController);
            end
            update(this.PropertyInspectorPanelController);
        end

        function setManageContext(this)

            setManageContext(this.PanelView);

            createSubControllers(this);
            setup(this);
            update(this);
        end

    end

    methods(Access=protected)
        function setDefaultContext(this)
            setManageContext(this);
        end

        function createSubControllers(this)
            import evolutions.internal.app.panel.*
            this.PropertyInspectorPanelController=PropertyInspector.Controller(this);
            this.FileViewerPanelController=FileViewer.Controller(this);
        end

        function installModelListeners(~)

        end

        function installViewListeners(~)

        end

        function deleteListeners(~)
        end

        function deleteControllers(this)
            props=["PropertyInspectorPanelController",...
            "FileViewerPanelController"];
            evolutions.internal.ui.deleteControllers(this,props);
        end
    end

    methods
        function c=getSubController(this,type)
            switch type
            case 'PropertyInspector'
                c=this.PropertyInspectorPanelController;
            otherwise
                assert(isequal(type,'FileViewerPanelController'))
                c=this.FileViewerPanelController;
            end
        end
    end
end


