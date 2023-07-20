

classdef MainViewModel<handle



    properties
AxesViewModel
ImportViewModel
DecomposeViewModel
DecomposedSignalsTableViewModel
SessionViewModel
LevelSelectionTableViewModel
ExportViewModel
    end

    methods
        function this=MainViewModel(mainController,dispatcher,signalPlotter)
            this.AxesViewModel=mra.internal.viewModels.AxesViewModel(mainController.getAxesController(),dispatcher,signalPlotter);
            this.ImportViewModel=mra.internal.viewModels.ImportViewModel(mainController.getImportController(),dispatcher,signalPlotter);
            this.DecomposeViewModel=mra.internal.viewModels.DecomposeViewModel(mainController.getDecomposeController(),dispatcher,signalPlotter);
            this.DecomposedSignalsTableViewModel=mra.internal.viewModels.DecomposedSignalsTableViewModel(mainController.getDecomposedSignalsTableController(),dispatcher,signalPlotter);
            this.SessionViewModel=mra.internal.viewModels.SessionViewModel(mainController.getSessionController(),dispatcher,signalPlotter);
            this.LevelSelectionTableViewModel=mra.internal.viewModels.LevelSelectionTableViewModel(mainController.getLevelSelectionTableController(),dispatcher,signalPlotter);
            this.ExportViewModel=mra.internal.viewModels.ExportViewModel(mainController.getExportController(),dispatcher,signalPlotter);
        end
    end
end