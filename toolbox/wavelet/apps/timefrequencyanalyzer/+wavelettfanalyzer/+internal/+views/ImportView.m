classdef ImportView<handle




    properties(Access=private)
ImportController
ImportFigure
HelpButton
ImportButton
CancelButton
    end

    methods(Hidden)

        function this=ImportView(controllers)
            this.ImportController=controllers.importController;
            this.subscribeToControllerEvents();
        end
    end

    methods(Access=private)
        function subscribeToControllerEvents(this)
            addlistener(this.ImportController,"OpenImportDialog",@(~,~)this.cb_OpenImportDialog());
            addlistener(this.ImportController,"SetDialogImportButtonEnable",@(~,args)this.cb_SetDialogImportButtonEnable(args));
            addlistener(this.ImportController,"CloseImportDialog",@(~,~)this.cb_CloseImportDialog());
        end


        function cb_OpenImportDialog(this)
            this.ImportFigure=uifigure("Name",string(getString(message("wavelet_tfanalyzer:dialog:importDialogTitle"))),"Resize","off","WindowStyle","modal");
            this.ImportFigure.CloseRequestFcn=@(~,~)this.ImportController.cb_CloseImportDialog();
            this.ImportController.cb_CreateWorkspaceBrowser(this.ImportFigure);

            this.HelpButton=uibutton(this.ImportFigure,"Text",string(getString(message("wavelet_tfanalyzer:dialog:importDialogHelpButton"))),"Position",[10,10,100,22]);
            this.HelpButton.Tag="importDialogHelpButton";
            this.HelpButton.ButtonPushedFcn=@(~,~)this.cb_ShowHelp();

            this.ImportButton=uibutton(this.ImportFigure,"Text",string(getString(message("wavelet_tfanalyzer:dialog:importDialogImportButton"))),"Position",[340,10,100,22],"Enable",false);
            this.ImportButton.Tag="importDialogImportButton";
            this.ImportButton.ButtonPushedFcn=@(~,~)this.ImportController.cb_ImportSignals(false,true,this.ImportFigure);

            this.CancelButton=uibutton(this.ImportFigure,"Text",string(getString(message("wavelet_tfanalyzer:dialog:importDialogCancelButton"))),"Position",[450,10,100,22]);
            this.CancelButton.Tag="importDialogCancelButton";
            this.CancelButton.ButtonPushedFcn=@(~,~)this.ImportController.cb_CloseImportDialog();

            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
        end

        function cb_SetDialogImportButtonEnable(this,args)
            this.ImportButton.Enable=args.Data.enabled;
        end

        function cb_CloseImportDialog(this)
            this.ImportButton.delete();
            this.CancelButton.delete();
            this.HelpButton.delete();
            this.ImportFigure.delete();
        end

        function cb_ShowHelp(this)
            mapRoot=fullfile(docroot,"/wavelet/","wavelet.map");
            helpview(mapRoot,"wavelettfanalyzer_importSignals");
        end
    end

end
