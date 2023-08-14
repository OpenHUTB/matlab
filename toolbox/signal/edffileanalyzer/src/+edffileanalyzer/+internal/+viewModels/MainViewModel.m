

classdef MainViewModel<handle



    properties
ImportViewModel
SignalsTableViewModel
SessionViewModel
    end

    methods
        function this=MainViewModel(mainController,dispatcher,signalMgr)
            this.ImportViewModel=edffileanalyzer.internal.viewModels.ImportViewModel(mainController.getImportController(),dispatcher,signalMgr);
            this.SignalsTableViewModel=edffileanalyzer.internal.viewModels.SignalsTableViewModel(mainController.getSignalsTableController(),dispatcher,signalMgr);
            this.SessionViewModel=edffileanalyzer.internal.viewModels.SessionViewModel(mainController.getSessionController(),dispatcher,signalMgr);
        end
    end
end