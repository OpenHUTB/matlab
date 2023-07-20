classdef Controller_1<handle





    properties(Access=public,Constant)
        UNITS=[{'Hz'};{'kHz'};{'MHz'};{'GHz'}]
        TOPOLOGY_OPTIONS=[{'2-Component'};{'L'};{'3-Component'};...
        {'Pi'};{'Tee'}]

        SER_CAP=1
        SER_INDCT=2
        SHNT_CAP=3
        SHNT_INDCT=4
        SER_RES=5;
        SHNT_RES=6;
    end

    properties(Access=protected)
        Model rf.internal.apps.matchnet.Model_1
        View rf.internal.apps.matchnet.View_1
Listeners
    end

    methods(Access=public)
        function this=Controller_1(model,view)
            this.Model=model;
            this.View=view;

            this.initialize();
        end
    end


    methods(Access=protected)
        function initialize(this)
            this.listenModel();

            this.listenConstraintsPanel();
            this.listenCircuitSelector();
            this.listenCircuitDisplayCanvas();
            this.listenPlotManager();
            this.listenRequirementsButtons();
            this.listenNewPlotButtons();
            this.listenGenerateButtons();
            this.listenExportButton();
            this.listenSaveButton();
        end

        function listenModel(this)
            this.Listeners.NewNetworksGeneratedListener1=addlistener(this.Model,'NewNetworksGenerated',@(h,e)(this.View.myToolstrip.newNetworksAvailable(e)));
            this.Listeners.NewNetworksGeneratedListener2=addlistener(this.Model,'NewNetworksGenerated',@(h,e)(this.View.myCircuitSelectorPanel.newNetworksAvailable(e)));
            this.Listeners.PerformanceDataAvailableListener=addlistener(this.Model,'NetworkDataAvailable',@(h,e)(this.View.myConstraintsPanel.updatePerformanceData(e)));

            this.Listeners.ImportToolBarListener=addlistener(this.Model,'ConfigUpdate',@(h,e)(this.View.myToolstrip.updateConfig(e)));

            this.Listeners.PlotDataAvailableListener=addlistener(this.Model,'NetworkDataAvailable',@(h,e)(this.View.myMasterPlotManager.addCircuitData(e)));
            this.Listeners.EvalparamsUpdatedListener1=addlistener(this.Model,'EvalparamsUpdated',@(h,e)(this.View.myMasterPlotManager.evalparamsUpdated(e)));

            this.Listeners.NetworkDrawingDataAvailableListener=addlistener(this.Model,'NetworkDrawingDataAvailable',@(h,e)(this.View.myCircuitDisplay.setCircuit(e)));
            this.Listeners.StatusBarListener1=addlistener(this.Model,'SBarUpdate',@(h,e)(this.View.statusBarUpdate(e)));
            this.Listeners.StatusBarListener2=addlistener(this.Model,'SBarUpdate',@(h,e)(this.View.CBK_GenerateBtnView()));
            this.Listeners.ViewBusy=addlistener(this.Model,'AppBusy',@(h,e)(this.View.setBusy(e)));

            this.Listeners.StatusBarListener3=addlistener(this.Model,'InvalidParameters',@(h,e)(this.View.myNewSession.CBK_setParameters(e)));
            this.Listeners.StatusBarListener4=addlistener(this.Model,'InvalidParameters_2',@(h,e)(this.View.CBK_setParameters(e)));

            this.Listeners.EnablePlotButtons=addlistener(this.Model,'EnablePlotButtons',@(h,e)(this.View.CBK_GenerateBtnView()));

            this.Listeners.NewName=addlistener(this.Model,'NewName',@(h,e)this.View.newName(e));
        end

        function listenConstraintsPanel(this)
            this.Listeners.PerformanceDataRequestedListener=addlistener(this.View.myConstraintsPanel,'CircuitDataRequested',@(h,e)(this.Model.supplyCircuitData(e)));
        end

        function listenCircuitSelector(this)
            this.Listeners.SelectedCircuitsChangedListener1=addlistener(this.View.myCircuitSelectorPanel,'SelectedCircuitsChanged',@(h,e)(this.View.myCircuitDisplay.newCircuitsSelected(e)));
            this.Listeners.SelectedCircuitsChangedListener2=addlistener(this.View.myCircuitSelectorPanel,'SelectedCircuitsChanged',@(h,e)(this.View.myConstraintsPanel.newCircuitsSelected(e)));
            this.Listeners.SelectedCircuitsChangedListener3=addlistener(this.View.myCircuitSelectorPanel,'SelectedCircuitsChanged',@(h,e)(this.View.myMasterPlotManager.newCircuitsSelected(e)));
            this.Listeners.SelectedCircuitsChangedListener4=addlistener(this.View.myCircuitSelectorPanel,'SelectedCircuitsChanged',@(h,e)(this.View.newCircuitsSelected(e)));
            this.Listeners.SelectedCircuitsChangedListener5=addlistener(this.View.myCircuitSelectorPanel,'SelectedCircuitsChangedView',@(h,e)(this.View.setBusy(e)));
        end

        function listenCircuitDisplayCanvas(this)
            this.Listeners.CircuitDrawingDataRequestedListener=addlistener(this.View.myCircuitDisplay,'CircuitDrawingDataRequested',@(h,e)(this.Model.supplyCircuitDrawingData(e)));
        end

        function listenPlotManager(this)
            this.Listeners.PlotDataRequestedListener=addlistener(this.View.myMasterPlotManager,'CircuitDataRequested',@(h,e)(this.Model.supplyCircuitData(e)));
        end


        function listenRequirementsButtons(this)
            ImportBtn=this.View.myToolstrip.ImportButton;
            addlistener(ImportBtn,'ButtonPushed',@(h,e)importAction(this.Model));

            addlistener(this.View,'ZModelUpdate',@(h,e)newTerminations(this.Model,e));
            addlistener(this.View,'CircuitsList',@(h,e)exportCircuitCBK(this.Model,e));

            addlistener(this.View,'EvalparamEditedUIVM',@(h,e)(this.Model.updateEvalparam(e)));
            addlistener(this.View,'EvalparamDeletedUIVM',@(h,e)(this.Model.deleteEvalparam(e)));
            addlistener(this.View,'CircuitDataRequestedUIVM',@(h,e)(this.Model.supplyCircuitData(e)));

            addlistener(this.View,'ResetModel',@(h,e)(this.Model.resetModel()));
            addlistener(this.View,'OpenModel',@(h,e)openAction(this.Model));
            addlistener(this.View,'SaveModel',@(h,e)saveAction(this.Model));
        end

        function listenGenerateButtons(this)
            gbtn=this.View.myToolstrip.GenerateNetworksButton;
            addlistener(gbtn,'ButtonPushed',@(h,e)this.View.CBK_GenerateButton());
            addlistener(this.View,'NetworkGeneration',@(h,e)(this.Model.generateNetworks(e)));
        end

        function listenNewPlotButtons(this)
            cartBtn=this.View.myToolstrip.NewCartesianSplitButton;
            items=cartBtn.Popup.getChildByIndex();
            addlistener(cartBtn,'ButtonPushed',@(h,e)this.View.newPlotCBK({'Cartesian',items(1).Text}));
            for j=1:length(items)
                addlistener(items(j),'ItemPushed',@(h,e)this.View.newPlotCBK({'Cartesian',items(j).Text}));
            end

            smithBtn=this.View.myToolstrip.NewSmithSplitButton;
            items=smithBtn.Popup.getChildByIndex();
            addlistener(smithBtn,'ButtonPushed',@(h,e)this.View.newPlotCBK({'Smith',items(1).Text}));
            for j=1:length(items)
                addlistener(items(j),'ItemPushed',@(h,e)this.View.newPlotCBK({'Smith',items(j).Text}));
            end
        end

        function listenExportButton(this)
            exptBtn=this.View.myToolstrip.ExportSplitButton;
            items=exptBtn.Popup.getChildByIndex();

            addlistener(exptBtn,'ButtonPushed',@(h,e)this.View.exportActionCBK('circuit'));
            for j=1:length(items)
                addlistener(items(j),'ItemPushed',@(h,e)this.View.exportActionCBK(items(j).Tag));
            end
        end

        function listenSaveButton(this)
            exptBtn=this.View.myToolstrip.SaveSessionButton;
            items=exptBtn.Popup.getChildByIndex();

            addlistener(exptBtn,'ButtonPushed',@(h,e)this.Model.saveAction());
            for j=1:length(items)
                addlistener(items(j),'ItemPushed',@(h,e)this.Model.savePopupActions(items(j).Text));
            end
        end
    end
end
