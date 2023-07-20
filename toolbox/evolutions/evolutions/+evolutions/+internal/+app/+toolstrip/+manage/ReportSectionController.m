classdef ReportSectionController<evolutions.internal.ui.tools.ToolstripSectionController




    properties(SetAccess=immutable)

AppModel
AppController
AppView

ReportSectionView

EventHandler

StateController
    end

    properties(SetAccess=protected)

StateListener
    end

    methods
        function this=ReportSectionController(appController)
            this.AppController=appController;
            this.AppView=getAppView(appController);
            this.AppModel=getAppModel(appController);
            this.ReportSectionView=getSubView(appController,'ReportSection');
            this.EventHandler=appController.EventHandler;
            this.StateController=appController.StateController;
        end

        function updateWidgetStates(this)
            view=this.ReportSectionView;
            state=this.StateController;
            enableWidget(view,state.GenerateReport,'generateReport');
        end
    end


    methods(Access=protected)
        function updateView(~)

        end

        function installModelListeners(~)

        end

        function installViewListeners(this)

            view=this.ReportSectionView;

            view.GenerateReportButton.ButtonPushedFcn=@this.onGenerateReport;

            this.StateListener=...
            addlistener(this.EventHandler,'StateChanged',@this.onStateChange);
        end
    end


    methods(Hidden,Access=protected)
        function onStateChange(this,~,~)
            updateWidgetStates(this);
        end

        function onGenerateReport(this,~,~)
            evolutionTreeListManager=getSubModel(this.AppModel,...
            'EvolutionTreeListManager');
            currentTree=evolutionTreeListManager.CurrentSelected;
            this.AppController.CustomDialogInterface.generateReport(currentTree);
        end
    end
end
