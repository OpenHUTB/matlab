classdef MainView<handle




    properties(Access=private)
AxesView
ImportView
StatusBarView
TableView
ToolstripView
    end

    methods(Hidden)

        function this=MainView(mainController,app)


            analysisController=mainController.getAnalysisController();
            importController=mainController.getImportController();
            newSessionController=mainController.getNewSessionController();
            tableController=mainController.getTableController();

            axesViewControllers.analysisController=analysisController;
            axesViewControllers.importController=importController;
            axesViewControllers.newSessionController=newSessionController;
            axesViewControllers.tableController=tableController;
            this.AxesView=wavelettfanalyzer.internal.views.AxesView(app,axesViewControllers);

            importViewControllers.importController=importController;
            this.ImportView=wavelettfanalyzer.internal.views.ImportView(importViewControllers);

            this.StatusBarView=wavelettfanalyzer.internal.views.StatusBarView(app,mainController);

            tableViewControllers.analysisController=analysisController;
            tableViewControllers.importController=importController;
            tableViewControllers.newSessionController=newSessionController;
            tableViewControllers.tableController=tableController;
            this.TableView=wavelettfanalyzer.internal.views.TableView(app,tableViewControllers);

            this.ToolstripView=wavelettfanalyzer.internal.views.ToolstripView(app,mainController);
        end
    end

end
