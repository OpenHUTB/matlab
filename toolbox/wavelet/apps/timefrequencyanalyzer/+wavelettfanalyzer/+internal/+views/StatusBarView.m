classdef StatusBarView<handle




    properties(Access=private)
AnalysisController
ExportController
ImportController
NewSessionController
TableController
StatusBarLabel
    end

    methods(Hidden)

        function this=StatusBarView(app,mainController)
            this.AnalysisController=mainController.getAnalysisController();
            this.ExportController=mainController.getExportController();
            this.ImportController=mainController.getImportController();
            this.NewSessionController=mainController.getNewSessionController();
            this.TableController=mainController.getTableController();
            this.addStatusBar(app)
            this.subscribeToControllerEvents();
        end
    end

    methods(Access=private)
        function subscribeToControllerEvents(this)
            addlistener(this.AnalysisController,"UpdateStatusBar",@(~,args)this.cb_UpdateStatus(args));
            addlistener(this.AnalysisController,"ClearStatusBar",@(~,~)this.cb_ClearStatus());
            addlistener(this.ExportController,"UpdateStatusBar",@(~,args)this.cb_UpdateStatus(args));
            addlistener(this.ImportController,"ClearStatusBar",@(~,~)this.cb_ClearStatus());
            addlistener(this.NewSessionController,"ClearStatusBar",@(~,~)this.cb_ClearStatus());
            addlistener(this.TableController,"ClearStatusBar",@(~,~)this.cb_ClearStatus());
            addlistener(this.TableController,"ClearStatusBar",@(~,~)this.cb_ClearStatus());
        end

        function cb_ClearStatus(this)
            this.StatusBarLabel.Text="";
        end

        function cb_UpdateStatus(this,args)
            this.StatusBarLabel.Text=args.Data.status;
        end


        function addStatusBar(this,app)
            import matlab.ui.internal.statusbar.*;
            statusBar=StatusBar();
            statusBar.Tag="statusBar";
            this.StatusBarLabel=StatusLabel();
            this.StatusBarLabel.Tag="statusBarLabel";
            statusBar.add(this.StatusBarLabel);
            app.addStatusBar(statusBar);
        end
    end

end
