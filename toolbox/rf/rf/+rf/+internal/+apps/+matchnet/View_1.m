classdef View_1<matlab.ui.container.internal.AppContainer




    properties(Access=public,Hidden)

        myToolstrip rf.internal.apps.matchnet.Toolstrip_2

        myNewSession rf.internal.apps.matchnet.NewSession


        myCircuitSelectorPanel rf.internal.apps.matchnet.CircuitSelectorPanel
        myConstraintsPanel rf.internal.apps.matchnet.ConstraintsPanel
        myConstraintsUIFigure rf.internal.apps.matchnet.ConstraintsUIFigure



        myCircuitDisplay rf.internal.apps.matchnet.CircuitDisplayCanvas
        myDocumentGroup matlab.ui.internal.FigureDocumentGroup


        myStatusBar matlab.ui.internal.statusbar.StatusBar
        myStatusBarZdata matlab.ui.internal.statusbar.StatusLabel

        myMasterPlotManager rf.internal.apps.matchnet.MasterPlotManager
doclayout

InternalListeners
ExternalListeners

        myProgressDlg matlab.ui.dialog.ProgressDialog
    end


    methods(Access=public)

        function this=View_1()
            this@matlab.ui.container.internal.AppContainer('Title',...
            getString(message('rf:matchingnetworkgenerator:AppTitle')));


            this.myMasterPlotManager=rf.internal.apps.matchnet.MasterPlotManager();

            this.myToolstrip=rf.internal.apps.matchnet.Toolstrip_2;
            this.add(this.myToolstrip);

            this.initializeCircuitSelectorPanel();
            this.initializeWorkingArea();



            this.intializerStatusBar();
            this.initializeListeners();


            qabbtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            qabbtn.DocName='matchingNetworkDesigner';
            this.add(qabbtn);

            this.Visible=true;
        end

        function newName(this,evtdata)
            this.Title=[getString(message('rf:matchingnetworkgenerator:AppTitle')),' - ',evtdata.data];
        end

        function initializeListeners(this)
            gbtn=this.myToolstrip.NewSessionButton;
            addlistener(gbtn,'ButtonPushed',@(~,~)CBK_NewSessionButton(this));

            OpenBtn=this.myToolstrip.OpenSessionButton;
            addlistener(OpenBtn,'ButtonPushed',@(h,e)CBK_OpenButton(this));

            gbtn=this.myToolstrip.ConstraintsButton;
            addlistener(gbtn,'ButtonPushed',@(~,~)CBK_ConstraintsButton(this));









            gbtn=this.myToolstrip.GenerateNetworksButton;
            addlistener(gbtn,'ButtonPushed',@(~,~)CBK_GenerateBtnView(this));

            gbtn=this.myToolstrip.DefaultLayoutBtn;
            addlistener(gbtn,'ButtonPushed',@(~,~)initializeWorkingArea(this));
            addlistener(gbtn,'ButtonPushed',@(~,~)initializeCircuitSelectorPanel(this));
        end

        function exportActionCBK(this,flag)
            nodeList=this.myCircuitSelectorPanel.myCircuitTree.SelectedNodes;
            leafList=nodeList(arrayfun(@(node)(isempty(node.Children)),nodeList));
            cktNames={leafList.Text};
            data.CircuitNames=cktNames;
            data.Option=flag;
            this.notify('CircuitsList',rf.internal.apps.matchnet.ArbitraryEventData(data));
            uialert(this,...
            getString(message('rf:matchingnetworkgenerator:ExportMessage')),...
            getString(message('rf:matchingnetworkgenerator:ExportTitle')),...
            'Icon','success');
        end

        function CBK_NewSessionButton(this)
            if isempty(this.myNewSession)||~isvalid(this.myNewSession.SessionPopUp)
                if isempty(this.myStatusBarZdata.Text)
                    this.myNewSession=rf.internal.apps.matchnet.NewSession;
                    addlistener(this.myNewSession,'SBarUpdate',@(h,e)(this.statusBarUpdate(e)));
                    addlistener(this.myNewSession,'ImpUpdate',@(h,e)(this.impedanceUpdate(e)));
                else
                    resetSession(this)
                end
            end
        end

        function CBK_OpenButton(this)
            if~isempty(this.myStatusBarZdata.Text)
                yes=getString(message('rf:matchingnetworkgenerator:UnsavedPromptYes'));
                no=getString(message('rf:matchingnetworkgenerator:UnsavedPromptNo'));
                cancel=getString(message('rf:matchingnetworkgenerator:UnsavedPromptCancel'));

                selection=uiconfirm(this,...
                getString(message('rf:matchingnetworkgenerator:UnsavedPromptQuestion')),...
                getString(message('rf:matchingnetworkgenerator:UnsavedPromptTitle')),...
                'Options',{yes,no,cancel},'DefaultOption',1,...
                'CancelOption',3);
                switch selection
                case yes
                    this.notify('SaveModel');
                    resetView(this)
                    this.notify('ResetModel');
                    this.notify('OpenModel');
                case no
                    resetView(this)
                    this.notify('ResetModel');
                    this.notify('OpenModel');
                end
            else
                this.notify('OpenModel');
            end
        end

        function resetSession(this)
            yes=getString(message('rf:matchingnetworkgenerator:UnsavedPromptYes'));
            no=getString(message('rf:matchingnetworkgenerator:UnsavedPromptNo'));
            cancel=getString(message('rf:matchingnetworkgenerator:UnsavedPromptCancel'));

            selection=uiconfirm(this,...
            getString(message('rf:matchingnetworkgenerator:UnsavedPromptQuestion')),...
            getString(message('rf:matchingnetworkgenerator:UnsavedPromptTitle')),...
            'Options',{yes,no,cancel},'DefaultOption',1,...
            'CancelOption',3);
            switch selection
            case yes
                this.notify('SaveModel');
                resetView(this)
                this.notify('ResetModel');

                this.myNewSession=rf.internal.apps.matchnet.NewSession;
                addlistener(this.myNewSession,'SBarUpdate',@(h,e)(this.statusBarUpdate(e)));
                addlistener(this.myNewSession,'ImpUpdate',@(h,e)(this.impedanceUpdate(e)));
            case no
                resetView(this)
                this.notify('ResetModel');

                this.myNewSession=rf.internal.apps.matchnet.NewSession;
                addlistener(this.myNewSession,'SBarUpdate',@(h,e)(this.statusBarUpdate(e)));
                addlistener(this.myNewSession,'ImpUpdate',@(h,e)(this.impedanceUpdate(e)));
            end
        end

        function resetView(this)

            arrayfun(@(x)clearAxes(x),this.myMasterPlotManager.myPlotManagers)
            arrayfun(@(x)clearCache(x),this.myMasterPlotManager.myPlotManagers)







            delete(this.myCircuitSelectorPanel.myCircuitTree.Children)


            this.myToolstrip.setDefaultValues()
            this.myToolstrip.disableButtons(false)
            this.myToolstrip.myCircuitTree=[];


            destroyTable(this.myConstraintsPanel)
            if~isempty(this.myConstraintsUIFigure)
                this.myConstraintsUIFigure.RawTable=[];
            end


            this.myCircuitDisplay.clearCanvas()
            delete(this.myCircuitDisplay.ComponentPanel)


            this.myStatusBarZdata.Text='';
        end

        function isCanceled=processMatchingNetworkDesignerSaving(this)
            isCanceled=false;

            yes=getString(message('rf:matchingnetworkgenerator:UnsavedPromptYes'));
            no=getString(message('rf:matchingnetworkgenerator:UnsavedPromptNo'));
            cancel=getString(message('rf:matchingnetworkgenerator:UnsavedPromptCancel'));

            selection=uiconfirm(this,...
            getString(message('rf:matchingnetworkgenerator:UnsavedPromptQuestion')),...
            getString(message('rf:matchingnetworkgenerator:UnsavedPromptTitle')),...
            'Options',{yes,no,cancel},'DefaultOption',1,...
            'CancelOption',3);

            if isempty(selection)
                selection=cancel;
            end

            switch selection
            case yes
                this.notify('SaveModel');
            case no

            case cancel
                isCanceled=true;
            end
        end

        function CBK_ConstraintsButton(this)
            if isempty(this.myConstraintsUIFigure)||~isvalid(this.myConstraintsUIFigure.Figure)
                this.myConstraintsUIFigure=rf.internal.apps.matchnet.ConstraintsUIFigure(this.myConstraintsUIFigure.RawTable);
                addlistener(this.myConstraintsUIFigure,'EvalparamEditedUI',@(h,e)(this.CBK_updateEvalparam(e)));
                addlistener(this.myConstraintsUIFigure,'EvalparamDeletedUI',@(h,e)(this.CBK_deleteEvalparam(e)));
                addlistener(this.myConstraintsUIFigure,'CircuitDataRequestedUI',@(h,e)(this.CBK_supplyCircuitData(e)));

                addlistener(this.myConstraintsUIFigure,'EvalparamView',@(h,e)(this.myConstraintsPanel.CBK_ConstraintsPanel(e)));
            end
        end

        function CBK_updateEvalparam(this,e)
            if~(this.myToolstrip.GenerateNetworksButton.Enabled)
                this.notify('EvalparamEditedUIVM',e);
            end
        end

        function CBK_deleteEvalparam(this,e)
            if~(this.myToolstrip.GenerateNetworksButton.Enabled)
                this.notify('EvalparamDeletedUIVM',e);
            end
        end

        function CBK_GenerateBtnView(this)






            if~isempty(this.myCircuitSelectorPanel.myCircuitTree.Children)
                this.myToolstrip.NewCartesianSplitButton.Enabled=true;
                this.myToolstrip.NewSmithSplitButton.Enabled=true;
                this.myToolstrip.SaveSessionButton.Enabled=true;
            end
        end

        function newCircuitsSelected(this,evtdata)

            cktnames=evtdata.data.CircuitNames;
            if~isempty(cktnames)
                this.myToolstrip.ExportSplitButton.Enabled=true;
            else
                this.myToolstrip.ExportSplitButton.Enabled=false;
            end
        end

        function setBusy(this,evtdata)
            if~this.Busy
                if evtdata.data.Busy
                    this.myProgressDlg=uiprogressdlg(this,'Title',...
                    getString(message('rf:matchingnetworkgenerator:ProgressDlg')),...
                    'Indeterminate','on');
                else
                    close(this.myProgressDlg)
                end
            end

            if isfield(evtdata.data,'AnyUserCreated')
                if evtdata.data.AnyUserCreated
                    this.myToolstrip.NewSmithSplitButton.Popup.getChildByIndex(2).Enabled=false;
                else
                    this.myToolstrip.NewSmithSplitButton.Popup.getChildByIndex(2).Enabled=true;
                end
            end
        end

        function CBK_GenerateButton(this)
            this.myToolstrip.GenerateNetworksButton.Enabled=false;
            newChangesAvailable(this.myToolstrip)
            if~this.myToolstrip.GenerateNetworksButton.Enabled
                return
            end
            this.Busy=true;
            ctrfreqbox=this.myToolstrip.CenterFrequencyEditField;
            qbox=this.myToolstrip.QFactorEditField;

            ctrfreq=str2double(ctrfreqbox.Value)*1e9;
            q=str2double(qbox.Value);
            topflag=arrayfun(@(x)isequal(x.Value,true),this.myToolstrip.galleryItems);

            top=split(this.myToolstrip.galleryItems(topflag).Text,'-');
            if regexp(top{1},'\d')
                top{1}=str2double(top{1});
            end

            data.Topology=top{1};
            data.CenterFrequency=ctrfreq;
            data.Q=q;
            data.EvalparamTable=this.myConstraintsPanel.EvalparamTable;
            data.FREQUENCY_SCALAR=this.myConstraintsPanel.FREQUENCY_SCALAR;
            this.notify('NetworkGeneration',rf.internal.apps.matchnet.ArbitraryEventData(data));
            this.Busy=false;
        end

        function intializerStatusBar(this)
            this.myStatusBar=matlab.ui.internal.statusbar.StatusBar();
            this.myStatusBar.Tag='AppStatusBar';
            this.addStatusBar(this.myStatusBar);

            this.myStatusBarZdata=matlab.ui.internal.statusbar.StatusLabel();
            this.myStatusBarZdata.Tag='ZdataLabel';
            this.myStatusBarZdata.Region="left";
            this.myStatusBar.add(this.myStatusBarZdata);
        end

        function statusBarUpdate(this,e)
            Zs=e.data.SourceZ;
            if ischar(Zs)
                txt1=sprintf('Zsource: %s,\t',e.data.SourceZ);
            elseif isnumeric(Zs)
                if isscalar(Zs)
                    txt1=sprintf('Zsource: %s %c,\t',string(e.data.SourceZ),char(937));
                else
                    dims=size(Zs);
                    txt1=sprintf('Zsource: [%dx%d double],\t',dims(1),dims(2));
                end
            elseif isa(Zs,'function_handle')
                txt1=sprintf('Zsource: %s,\t',char(e.data.SourceZ));
            elseif isa(Zs,'rf.internal.netparams.AllParameters')||...
                isa(Zs,'em.Antenna')||isa(Zs,'circuit')
                if isfield(e.data,'SourceZTag')
                    txt1=sprintf('Zsource: %s,\t',char(e.data.SourceZTag));
                else
                    txt1=sprintf('Zsource: %s',class(Zs));
                end
            end
            Zl=e.data.LoadZ;
            if ischar(Zl)
                txt2=sprintf('Zload: %s',e.data.LoadZ);
            elseif isnumeric(Zl)
                if isscalar(Zl)
                    txt2=sprintf('Zload: %s %c',string(e.data.LoadZ),char(937));
                else
                    dims=size(Zl);
                    txt2=sprintf('Zload: [%dx%d double]\t',dims(1),dims(2));
                end
            elseif isa(Zl,'function_handle')
                txt2=sprintf('Zload: %s',char(e.data.LoadZ));
            elseif isa(Zl,'rf.internal.netparams.AllParameters')||...
                isa(Zl,'em.Antenna')||isa(Zl,'circuit')
                if isfield(e.data,'LoadZTag')
                    txt2=sprintf('Zload: %s',char(e.data.LoadZTag));
                else
                    txt2=sprintf('Zload: %s',class(Zl));
                end
            end
            txt=[txt1,txt2];
            this.myStatusBarZdata.Text=txt;
            this.myCircuitSelectorPanel.impedanceDisplay(txt1,txt2);
            this.myToolstrip.enableButtons(true)
            if isfield(e.data,'EvalparamTable')
                this.myConstraintsPanel.CBK_ConstraintsPanel(rf.internal.apps.matchnet.ArbitraryEventData(e.data.EvalparamTable.Data));
                this.myConstraintsUIFigure=rf.internal.apps.matchnet.ConstraintsUIFigure([],matlab.lang.OnOffSwitchState.off);
                this.myConstraintsUIFigure.RawTable=e.data.EvalparamTable.Data;
                this.myConstraintsUIFigure.closeNewSession();
            end
            this.myConstraintsPanel.gridOverall.Visible=...
            matlab.lang.OnOffSwitchState.on;
        end

        function impedanceUpdate(this,e)
            if isa(e.Source,'rf.internal.apps.matchnet.NewSession')
                this.notify('ZModelUpdate',e);
            elseif isa(e.Source,'rf.internal.apps.matchnet.Model_1')
                if isnumeric(e.data.Topology)
                    ItemtobeClicked.Text=[num2str(e.data.Topology),'-Components'];
                else
                    ItemtobeClicked.Text=[e.data.Topology,'-Topology'];
                end
                selectItem(this.myToolstrip,ItemtobeClicked)
            end
            this.myToolstrip.CenterFrequencyEditField.Value=num2str(e.data.CenterFrequency/1e9);
            this.myToolstrip.QFactorEditField.Value=num2str(e.data.Q);
        end

        function CBK_setParameters(this,evdata)
            if strcmp(evdata.data.title,'Info')
                uialert(this,evdata.data.message,evdata.data.title,...
                'Icon','info');
            else
                uialert(this,evdata.data.message,evdata.data.title);
            end
        end

        function initializeCircuitSelectorPanel(this)
            panelOptions.Title="Matching Network Browser";
            panelOptions.Region="left";
            panelOptions.Index=1;
            panelOptions.PreferredWidth=1/5;
            if isempty(this.myCircuitSelectorPanel)
                this.myCircuitSelectorPanel=rf.internal.apps.matchnet.CircuitSelectorPanel(panelOptions);
                this.add(this.myCircuitSelectorPanel);
            else
                this.myCircuitSelectorPanel.Region="left";
                this.myCircuitSelectorPanel.Maximized=0;
                this.myCircuitSelectorPanel.Collapsed=0;
                this.LeftCollapsed=0;
            end
        end

























        function initializeWorkingArea(this)

            this.doclayout.gridDimensions.w=2;
            this.doclayout.gridDimensions.h=2;
            this.doclayout.tileCount=4;
            this.doclayout.tileCoverage=[1,2;3,4];
            this.doclayout.columnWeights=[0.6,0.4];
            this.doclayout.rowWeights=[0.43,0.57];
            this.doclayout.emptyTileCount=0;

            if isempty(this.myDocumentGroup)
                this.myDocumentGroup=matlab.ui.internal.FigureDocumentGroup;
                this.myDocumentGroup.Title="Documents";
                this.myDocumentGroup.Tag="Docs";
                this.add(this.myDocumentGroup);
            end


















            if isempty(this.myConstraintsPanel)
                figOptions.Title="Circuit Display";
                figOptions.Tag='circ_1';
                figOptions.Closable=0;
                figOptions.DocumentGroupTag=this.myDocumentGroup.Tag;
                document=matlab.ui.internal.FigureDocument(figOptions);
                document.Tile=1;
                this.add(document);
                document.Figure.AutoResizeChildren='on';
                this.myCircuitDisplay=rf.internal.apps.matchnet.CircuitDisplayCanvas(document.Figure);
            end
            document1State.id="Docs_circ_1";
            tile1Children=[document1State];%#ok<NBRAK>

            if isempty(this.myConstraintsPanel)

                figOptions.Title="Constraints";
                figOptions.Tag='const_1';
                figOptions.Closable=0;
                figOptions.DocumentGroupTag=this.myDocumentGroup.Tag;
                document=matlab.ui.internal.FigureDocument(figOptions);
                document.Tile=2;
                this.add(document);
                document.Figure.AutoResizeChildren='on';
                this.myConstraintsPanel=rf.internal.apps.matchnet.ConstraintsPanel(document.Figure);
            end
            document2State.id="Docs_const_1";
            tile2Children=[document2State];%#ok<NBRAK>

            if isempty(this.myMasterPlotManager.myPlotManagers)

                figOptions=this.addPlot('Cartesian');
                document3State.id="Docs_"+figOptions.Tag;
                tile3Children=[document3State];%#ok<NBRAK>


                figOptions=this.addPlot('ZTransform');
                document4State.id="Docs_"+figOptions.Tag;
                tile4Children=[document4State];%#ok<NBRAK>
            else
                if~any(arrayfun(@(x)isa(x,'rf.internal.apps.matchnet.CartesianPlotManager'),...
                    this.myMasterPlotManager.myPlotManagers))
                    this.addPlot('Cartesian');
                end
                if~any(arrayfun(@(x)isa(x,'rf.internal.apps.matchnet.ZTransformPlotManager'),...
                    this.myMasterPlotManager.myPlotManagers))
                    this.addPlot('ZTransform');
                end
                tile3Children=[];
                tile4Children=[];
                for k=1:numel(this.myMasterPlotManager.myPlotManagers)
                    type=this.myMasterPlotManager.myPlotManagers(k).PlotType;
                    document=getDocument(this,"Docs",this.myMasterPlotManager.myPlotManagers(k).PlotID);
                    documentState.id="Docs_"+document.UserData;
                    switch type
                    case 'Cartesian'
                        tile3Children=[tile3Children,documentState];%#ok<AGROW>
                    case 'ZTransform'
                        tile4Children=[tile4Children,documentState];%#ok<AGROW>
                    end
                end
                for k=1:numel(this.myMasterPlotManager.myPlotManagers)
                    type=this.myMasterPlotManager.myPlotManagers(k).PlotType;
                    document=getDocument(this,"Docs",this.myMasterPlotManager.myPlotManagers(k).PlotID);
                    documentState.id="Docs_"+document.UserData;
                    switch type
                    case 'VSWR'
                        tile3Children=[tile3Children,documentState];%#ok<AGROW>
                    case 'Smith'
                        tile4Children=[tile4Children,documentState];%#ok<AGROW>
                    end
                end
            end
            tile1Occupancy.children=tile1Children;
            tile2Occupancy.children=tile2Children;
            tile3Occupancy.children=tile3Children;
            tile4Occupancy.children=tile4Children;
            this.doclayout.tileOccupancy=[tile1Occupancy,tile2Occupancy,tile3Occupancy,tile4Occupancy];
            this.DocumentLayout=this.doclayout;
        end


        function initializeInternalListeners(this)
            this.InternalListeners.PropertyChangedListener=addlistener(this,'PropertyChanged',@(~,e)(this.parsePropertyChangedEvent(e)));
        end

    end

    methods(Access=public)
        function figOptions=addPlot(this,type)

            plotidx=this.myMasterPlotManager.highestCount()+1;
            figOptions.Title=type;
            figOptions.Tag=['Plot_',num2str(plotidx)];
            figOptions.DocumentGroupTag=this.myDocumentGroup.Tag;
            document=matlab.ui.internal.FigureDocument(figOptions);

            if(strcmp(type,'Cartesian')||strcmp(type,'VSWR'))
                document.Tile=3;
            elseif(strcmp(type,'Smith')||strcmp(type,'ZTransform'))
                document.Tile=4;
            end
            this.add(document);
            document.UserData=figOptions.Tag;


            manager=feval("rf.internal.apps.matchnet."+type+"PlotManager",document);


            this.myMasterPlotManager.add(manager);

            addlistener(document,'ObjectBeingDestroyed',@(h,e)this.myMasterPlotManager.plotClosedCBK(e));
        end
    end


    events
MatchingProblemChanged
NewPlotDataRequested
MatchingNetworkImported
MatchingNetworkDeleted
MatchingNetworkCloned
MatchingNetworkAltered
EvalparamAdded
EvalparamEdited
EvalparamDeleted

ZModelUpdate
CircuitsList
NetworkGeneration

EvalparamEditedUI
EvalparamDeletedUI

CircuitDataRequestedUI

EvalparamEditedUIVM
EvalparamDeletedUIVM
CircuitDataRequestedUIVM

ResetModel
OpenModel
SaveModel
    end


    methods(Access=public)

        function newPlotCBK(this,requestedPlot)




            if(strcmp(requestedPlot{1},'Cartesian'))
                switch(requestedPlot{2})
                case 'S-parameters'
                    this.addPlot('Cartesian');
                case 'VSWR'
                    this.addPlot('VSWR');
                end
            elseif(strcmp(requestedPlot{1},'Smith'))
                switch(requestedPlot{2})
                case 'S-parameters'
                    this.addPlot('Smith');
                case 'Impedance Transformation'
                    this.addPlot('ZTransform');
                end
            end
        end

    end


    methods(Access=public)
        function parsePropertyChangedEvent(this,event)%#ok<INUSL>
            disp(event);
            if(strcmp(event.PropertyName,'SelectedChild'))

            end
        end
    end


    methods(Access=protected)
        function checkPlotFocusChanged(this)
            possibleTag=this.SelectedChild.tag;
            pm=this.myMasterPlotManager.getPlotManagerByTag(possibleTag);
            if(~isempty(pm))

                this.myPlotEditPanel.setCurrentPlot(pm);
            end
        end
    end

end
