

classdef MainController<handle



    properties(Access=private)
Controllers
Dispatcher
    end

    methods(Hidden)

        function this=MainController(mainModel,dispatcher)
            this.Dispatcher=dispatcher;


            decomposeModel=mainModel.getDecompositionModel();
            this.Controllers.AxesController=mra.internal.controllers.AxesController(decomposeModel);
            this.Controllers.ImportController=mra.internal.controllers.ImportController(decomposeModel);
            this.Controllers.DecomposeController=mra.internal.controllers.DecomposeController(decomposeModel);
            this.Controllers.DecomposedSignalsTableController=mra.internal.controllers.DecomposedSignalsTableController(decomposeModel);
            this.Controllers.SessionController=mra.internal.controllers.SessionController(decomposeModel);
            this.Controllers.LevelSelectionTableController=mra.internal.controllers.LevelSelectionTableController(decomposeModel);
            this.Controllers.ExportController=mra.internal.controllers.ExportController(decomposeModel);
            this.Controllers.HelpController=mra.internal.controllers.HelpController();

            this.subscribeAllControllers();
        end

        function subscribeAllControllers(this)
            this.Dispatcher.subscribeToClient(this.Controllers);

            importData.data.importFromDialog=false;
            this.Dispatcher.subscribeToReadyToShow(@(args)cb_Import(this.Controllers.ImportController,importData));
        end

        function axesController=getAxesController(this)
            axesController=this.Controllers.AxesController;
        end

        function importController=getImportController(this)
            importController=this.Controllers.ImportController;
        end

        function decomposeController=getDecomposeController(this)
            decomposeController=this.Controllers.DecomposeController;
        end

        function decomposedSignalsTableController=getDecomposedSignalsTableController(this)
            decomposedSignalsTableController=this.Controllers.DecomposedSignalsTableController;
        end

        function sessionController=getSessionController(this)
            sessionController=this.Controllers.SessionController;
        end

        function levelSelectionTableController=getLevelSelectionTableController(this)
            levelSelectionTableController=this.Controllers.LevelSelectionTableController;
        end

        function exportController=getExportController(this)
            exportController=this.Controllers.ExportController;
        end
    end
end