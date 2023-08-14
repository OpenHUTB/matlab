

classdef MainController<handle



    properties(Access=private)
Controllers
Dispatcher
    end

    methods(Hidden)

        function this=MainController(mainModel,dispatcher)
            this.Dispatcher=dispatcher;


            denoisingModel=mainModel.getDenoisingModel();
            this.Controllers.AxesController=waveletsignaldenoiser.internal.controllers.AxesController(denoisingModel);
            this.Controllers.ImportController=waveletsignaldenoiser.internal.controllers.ImportController(denoisingModel);
            this.Controllers.DenoiseController=waveletsignaldenoiser.internal.controllers.DenoiseController(denoisingModel);
            this.Controllers.DenoisedSignalsTableController=waveletsignaldenoiser.internal.controllers.DenoisedSignalsTableController(denoisingModel);
            this.Controllers.SessionController=waveletsignaldenoiser.internal.controllers.SessionController(denoisingModel);
            this.Controllers.ExportController=waveletsignaldenoiser.internal.controllers.ExportController(denoisingModel);
            this.Controllers.HelpController=waveletsignaldenoiser.internal.controllers.HelpController();

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

        function denoiseController=getDenoiseController(this)
            denoiseController=this.Controllers.DenoiseController;
        end

        function denoiseSignalsTableController=getDenoisedSignalsTableController(this)
            denoiseSignalsTableController=this.Controllers.DenoisedSignalsTableController;
        end

        function sessionController=getSessionController(this)
            sessionController=this.Controllers.SessionController;
        end

        function exportController=getExportController(this)
            exportController=this.Controllers.ExportController;
        end
    end
end