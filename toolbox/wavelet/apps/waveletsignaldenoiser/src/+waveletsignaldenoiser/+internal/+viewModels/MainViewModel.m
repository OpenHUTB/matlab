

classdef MainViewModel<handle



    properties
AxesViewModel
ImportViewModel
DenoiseViewModel
DenoisedSignalsTableViewModel
SessionViewModel
ExportViewModel
    end

    methods
        function this=MainViewModel(mainController,dispatcher,signalPlotter)
            this.AxesViewModel=waveletsignaldenoiser.internal.viewModels.AxesViewModel(mainController.getAxesController(),dispatcher,signalPlotter);
            this.ImportViewModel=waveletsignaldenoiser.internal.viewModels.ImportViewModel(mainController.getImportController(),dispatcher,signalPlotter);
            this.DenoiseViewModel=waveletsignaldenoiser.internal.viewModels.DenoiseViewModel(mainController.getDenoiseController(),dispatcher,signalPlotter);
            this.DenoisedSignalsTableViewModel=waveletsignaldenoiser.internal.viewModels.DenoisedSignalsTableViewModel(mainController.getDenoisedSignalsTableController(),dispatcher,signalPlotter);
            this.SessionViewModel=waveletsignaldenoiser.internal.viewModels.SessionViewModel(mainController.getSessionController(),dispatcher,signalPlotter);
            this.ExportViewModel=waveletsignaldenoiser.internal.viewModels.ExportViewModel(mainController.getExportController(),dispatcher,signalPlotter);
        end
    end
end