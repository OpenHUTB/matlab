classdef EvolutionTreeWebDocumentController<handle





    properties(SetAccess=immutable)

AppController
AppModel
AppView
EvolutionTreeDocumentView
EventHandler
    end

    properties(SetAccess=protected)
EvolutionPlotController
EvolutionTreeListManager
    end

    properties(SetAccess=protected)

    end

    methods
        function this=EvolutionTreeWebDocumentController(appController)
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            documentView=getSubView(this.AppView,'DocumentView');
            this.EvolutionTreeDocumentView=getSubView(documentView,'EvolutionTreeDocument');
            this.EventHandler=appController.EventHandler;
            createSubControllers(this);

        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);

            setup(this.EvolutionPlotController);
        end





        function delete(this)

            deleteSubControllers(this);


            deleteListeners(this);

        end

        function update(this)



            if~isempty(this.EvolutionTreeListManager.CurrentSelected)
                this.EvolutionTreeDocumentView.Title=this.EvolutionTreeListManager.CurrentSelected.getName;
            else
                this.EvolutionTreeDocumentView.Title=this.EvolutionTreeDocumentView.Name;
            end
            update(this.EvolutionPlotController);
        end
    end

    methods(Access=protected)
        function deleteSubControllers(this)
            props="EvolutionPlotController";
            evolutions.internal.ui.deleteControllers(this,props);
        end

        function deleteListeners(~)

        end

        function createSubControllers(this)
            import evolutions.internal.app.document.*
            this.EvolutionPlotController=EvolutionTreeWebDocument.EvolutionWebPlotController(this);
            this.EvolutionTreeListManager=getSubModel(this.AppModel,'EvolutionTreeListManager');
        end

        function installModelListeners(~)

        end

        function installViewListeners(~)

        end
    end
end


