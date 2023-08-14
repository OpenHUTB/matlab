classdef TimeFrequencyAnalyzerImpl<handle





    properties(Access=private)
App
MainModel
MainView
MainController
    end

    methods(Access=private)

        function this=TimeFrequencyAnalyzerImpl()
            this.createApp();
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay(this.App);
            wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay(busyOverlay);
            dialog=wavelettfanalyzer.internal.Dialog(this.App);
            wavelettfanalyzer.internal.Dialog.setGetDialog(dialog);
            this.MainModel=wavelettfanalyzer.internal.models.MainModel();
            this.MainController=wavelettfanalyzer.internal.controllers.MainController(this.MainModel);
            this.MainView=wavelettfanalyzer.internal.views.MainView(this.MainController,this.App);
            this.App.Visible=true;
            if~isempty(this.App)
                addlistener(this.App,'StateChanged',@(src,data)this.cb_AppStateChange());
            end
        end

        function close=cb_CloseApp(this)
            if this.App.Busy
                close=false;
            elseif this.MainModel.getModel().isEmpty()
                close=true;
            else
                close=false;
                dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
                dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:closeAppDialogTitle")));
                dialogMessage=string(getString(message("wavelet_tfanalyzer:dialog:closeAppDialogMessage")));
                dialog.showConfirm("closeApp",dialogTitle,dialogMessage);
            end
        end

        function cb_AppStateChange(this)
            import matlab.ui.container.internal.appcontainer.AppState;
            if this.App.State==AppState.TERMINATED
                if mislocked('wavelettfanalyzer.internal.setGetInstance')
                    munlock('wavelettfanalyzer.internal.setGetInstance');
                end
                this.deleteThis();
            end
        end

        function createApp(this)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            appOptions.Tag="timeFrequencyAnalyzer";
            appOptions.Title=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:appTitle")));
            this.App=AppContainer(appOptions);
            this.App.Tag="appContainer";
            appPos=wavelet.internal.setAppSizefromMonitor();
            this.App.WindowBounds=...
            [appPos.X,appPos.Y,appPos.Width,appPos.Height];
            this.App.CanCloseFcn=@(~,~)this.cb_CloseApp();
        end

        function deleteThis(this)
            delete(this.App);
            delete(this.MainModel);
            delete(this.MainController);
            delete(this.MainView);
            delete(wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay());
            delete(wavelettfanalyzer.internal.Dialog.setGetDialog());

            delete(this);
        end
    end

    methods(Static=true,Hidden)
        function result=setGetInstance(varargin)

            mlock;
            persistent tfAnalyzerInstance;
            if isempty(tfAnalyzerInstance)||~isvalid(tfAnalyzerInstance)
                tfAnalyzerInstance=wavelettfanalyzer.internal.TimeFrequencyAnalyzerImpl();
            end
            result=tfAnalyzerInstance;
            if~isempty(varargin)
                result.MainController.getImportController().cb_ImportSignals(true,false,varargin{1},varargin{2});
            end
            result.App.bringToFront;
        end
    end
end
