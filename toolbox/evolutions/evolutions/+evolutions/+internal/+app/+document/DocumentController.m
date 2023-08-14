classdef DocumentController<handle




    properties(Constant)


        ManageModeDocumentControllers="EvolutionTreeDocumentController";

    end

    properties(SetAccess=immutable)

AppController
AppModel
AppView
DocumentView
EventHandler
    end

    properties(SetAccess=protected)

SelectedModeControllers

EvolutionTreeDocumentController
EvolutionDocumentController
    end

    properties(SetAccess=protected)

    end

    methods
        function this=DocumentController(appController)
            this.AppController=appController;
            this.AppModel=getAppModel(appController);
            this.AppView=getAppView(appController);
            this.DocumentView=getSubView(this.AppView,'DocumentView');
            this.EventHandler=appController.EventHandler;
            setDefaultContext(this);
            createSubControllers(this);
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);

            controllers=this.SelectedModeControllers;
            for idx=1:numel(controllers)
                setup(this.(controllers(idx)));
            end
        end



        function delete(this)

            deleteListeners(this);

            deleteControllers(this);
        end

        function updateDocument(this)
            controllers=this.SelectedModeControllers;
            for idx=1:numel(controllers)
                update(this.(controllers(idx)));
            end
        end

        function setManageContext(this)
            this.SelectedModeControllers=this.ManageModeDocumentControllers;

            deleteControllers(this);

            setManageContext(this.DocumentView);

            changeContext(this);
        end
    end

    methods(Access=protected)
        function setDefaultContext(this)
            this.SelectedModeControllers=this.ManageModeDocumentControllers;
        end
        function changeContext(this)

            createSubControllers(this);
            setup(this);
            updateDocument(this);
        end

        function createSubControllers(this)
            import evolutions.internal.app.document.*
            controllers=this.SelectedModeControllers;
            for idx=1:numel(controllers)
                controller=controllers(idx);
                switch controller

                case 'EvolutionTreeDocumentController'
                    this.EvolutionTreeDocumentController=EvolutionTreeWebDocument...
                    .EvolutionTreeWebDocumentController(this.AppController);
                otherwise
                    assert(strcmp(controller,'EvolutionDocumentController'));
                    this.EvolutionDocumentController=EvolutionDocument...
                    .EvolutionDocumentController(this.AppController);
                end
            end
        end

        function installModelListeners(~)

        end

        function installViewListeners(~)

        end

        function deleteListeners(~)
        end

        function deleteControllers(this)
            props=["EvolutionTreeDocumentController",...
            "EvolutionDocumentController"];
            evolutions.internal.ui.deleteControllers(this,props);
        end
    end
end


