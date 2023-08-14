classdef MainController<handle




    properties(Access=private)
Controllers
    end

    methods(Hidden)

        function this=MainController(mainModel)
            model=mainModel.getModel();
            this.Controllers.AnalysisController=wavelettfanalyzer.internal.controllers.AnalysisController(model);
            this.Controllers.ExportController=wavelettfanalyzer.internal.controllers.ExportController(model);
            this.Controllers.ImportController=wavelettfanalyzer.internal.controllers.ImportController(model);
            this.Controllers.NewSessionController=wavelettfanalyzer.internal.controllers.NewSessionController(model);
            this.Controllers.TableController=wavelettfanalyzer.internal.controllers.TableController(model);
        end


        function analysisController=getAnalysisController(this)
            analysisController=this.Controllers.AnalysisController;
        end

        function exportController=getExportController(this)
            exportController=this.Controllers.ExportController;
        end

        function importController=getImportController(this)
            importController=this.Controllers.ImportController;
        end

        function newSessionController=getNewSessionController(this)
            newSessionController=this.Controllers.NewSessionController;
        end

        function tableController=getTableController(this)
            tableController=this.Controllers.TableController;
        end
    end

end
