

classdef MainController<handle



    properties(Access=private)
Controllers
Dispatcher
    end

    methods
        function this=MainController(mainModel,dispatcher)
            this.Dispatcher=dispatcher;


            model=mainModel.getModel();
            this.Controllers.ImportController=edffileanalyzer.internal.controllers.ImportController(model);
            this.Controllers.SignalsTableController=edffileanalyzer.internal.controllers.SignalsTableController(model);
            this.Controllers.SessionController=edffileanalyzer.internal.controllers.SessionController(model);
            this.Controllers.HelpController=edffileanalyzer.internal.controllers.HelpController();


            this.subscribeAllControllers();
        end
    end

    methods(Access=private)
        function subscribeAllControllers(this)
            this.Dispatcher.subscribeToClient(this.Controllers);

            importData.data.importFromDialog=false;
            this.Dispatcher.subscribeToReadyToShow(@(args)cb_Import(this.Controllers.ImportController,importData));
        end
    end

    methods(Hidden)

        function importController=getImportController(this)
            importController=this.Controllers.ImportController;
        end

        function signalsTableController=getSignalsTableController(this)
            signalsTableController=this.Controllers.SignalsTableController;
        end

        function signalsTableController=getSessionController(this)
            signalsTableController=this.Controllers.SessionController;
        end
    end
end