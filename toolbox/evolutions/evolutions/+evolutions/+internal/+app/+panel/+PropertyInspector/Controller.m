classdef Controller<handle




    properties(SetAccess=immutable)
AppController
AppModel
AppView
InspectorView

EventHandler
    end

    properties(SetAccess=protected)

EvolutionInfoController
EvolutionTreeInfoController
FileListController
FileInfoController
ComparisonController
    end

    properties(SetAccess=protected)

CanvasClickedListener
EvolutionClickedListener
StereotypeChangedListener
EdgeClickedListener
    end

    methods
        function this=Controller(parentController)

            appController=parentController.AppController;
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);


            this.InspectorView=getSubView(this.AppView,'PropertyInspector');
            this.EventHandler=appController.EventHandler;
            createSubControllers(this);

        end

        function update(this)

            updateDefaultView(this)
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);

            setupSubControllers(this);
        end

        function delete(this)

            deleteListeners(this);
            deleteControllers(this);
        end
    end

    methods(Access=protected)
        function setDefaultView(this)
            setEvolutionTreeInfoView(this.InspectorView);
        end

        function updateDefaultView(this)
            update(this.EvolutionTreeInfoController);
            update(this.FileInfoController);
        end

        function setupSubControllers(this)
            setup(this.EvolutionInfoController);
            setup(this.EvolutionTreeInfoController);
            setup(this.FileListController)
            setup(this.FileInfoController)
            setup(this.ComparisonController)

        end

        function createSubControllers(this)






            import evolutions.internal.app.panel.*;

            this.EvolutionInfoController=PropertyInspector.EvolutionInfoController(this);
            this.EvolutionTreeInfoController=PropertyInspector.EvolutionTreeInfoController(this);
            this.FileListController=PropertyInspector.FileListController(this);
            this.FileInfoController=PropertyInspector.FileInfoController(this);
            this.ComparisonController=PropertyInspector.ComparisonController(this);
        end

        function deleteListeners(this)

            listeners=["CanvasClickedListener","EvolutionClickedListener",...
            "StereotypeChangedListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(~)

        end

        function installViewListeners(this)

            this.StereotypeChangedListener=...
            listener(this.EventHandler,'StereotypeChanged',...
            @(~,~)updateViewData(this));

            this.CanvasClickedListener=...
            listener(this.EventHandler,'CanvasClicked',...
            @(~,~)setEvolutionTreeInfoView(this.InspectorView));

            this.EvolutionClickedListener=...
            listener(this.EventHandler,'NodeClicked',...
            @(~,~)setEvolutionInfoView(this.InspectorView));

            this.EdgeClickedListener=...
            listener(this.EventHandler,'EdgeClicked',...
            @(~,~)setEdgeInfoView(this.InspectorView));
        end

        function deleteControllers(this)
            props=["EvolutionInfoController",...
            "EvolutionTreeInfoController",...
            "FileListController",...
            "FileInfoController",...
            "ComparisonController"];
            evolutions.internal.ui.deleteControllers(this,props);
        end

        function updateViewData(this,~,~)
            update(this.EvolutionTreeInfoController);
            update(this.EvolutionInfoController);
            update(this.FileListController);
        end
    end
end