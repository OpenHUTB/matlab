classdef FileInfoController<handle





    properties(SetAccess=immutable)

AppController
AppModel
AppView

DocumentController
InspectorView
FileInfoManager

EventHandler
    end

    properties(SetAccess=protected)


    end

    properties(SetAccess=protected)

EvolutionChangeListener
FileListSelectionChangedListener
CommentListener
    end

    methods
        function this=FileInfoController(parentController)

            this.DocumentController=parentController;
            appController=parentController.AppController;
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);


            this.InspectorView=getSubView(this.AppView,'PropertyInspector');
            this.FileInfoManager=getSubModel(this.AppModel,'FileSummary');

            this.EventHandler=appController.EventHandler;
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);
        end

        function delete(this)

            deleteListeners(this)
        end

        function update(this)
            view=this.InspectorView;
            update(view,this.FileInfoManager);
        end

    end

    methods(Access=protected)
        function deleteListeners(this)

            listeners=["EvolutionChangeListener",...
            "FileListSelectionChangedListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

        function installModelListeners(~)

        end

        function installViewListeners(this)

            this.EvolutionChangeListener=...
            listener(this.EventHandler,'EvolutionChanged',@this.updateSummaryManager);
            this.FileListSelectionChangedListener=...
            listener(this.EventHandler,'FileListSelectionChanged',@this.updateSummaryManager);
        end

        function updateSummaryManager(this,~,~)
            updateFileSummary(this.FileInfoManager);
            update(this);
        end
    end
end
