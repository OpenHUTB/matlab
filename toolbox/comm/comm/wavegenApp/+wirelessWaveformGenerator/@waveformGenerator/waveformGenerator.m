classdef waveformGenerator<matlabshared.scopes.container.Application&...
    matlabshared.application.ToolGroupFileSystem




    properties(Hidden)

pRegistrations


pWavegenTab
pRadioTab


pParameters
pParametersFig
pImpairmentsFig
pRadioFig
pInfoFig



pNewSessionBtn
pImpairOnOff
pWaveformGallery
pWaveformGalleryItems
pRadioGalleryItems
pImpairBtn
pGenerateBtn
pSearchHWBtn
pPlotsBtn
pTransmitBtn
pExportTxBtn
pHWPopup
pStatus
pStatusLabel
pProgressBar
pRatePopup
pExportBtn
pExport2File
pExport2WS
pMessagePane


        pPlotTimeScope=false
        pPlotSpectrum=true
        pPlotConstellation=false
        pPlotEyeDiagram=false
        pPlotCCDF=false
        pCCDFBurstMode=false;
pTimeScope
pSpectrum1
pConstellation
pEyeDiagramFig
pCCDFFig

pCurrentWaveformType
pCurrentHWType
pCurrentHWTag
        pWaveform=[]
pWaveformConfiguration
pSampleRate
pGenerationImpairments

        pInGeneration=false
        pInTransmission=false
        pThrewValidationError=false


pFrequencyOffset
pPhaseNoise
pNonlinearity

pFirstWaveformType

GroupActionListener

AppContainer
FreezeHandle
UseAppContainer

        PriorPanelFolding=true
        Initializing=true;
    end

    methods(Access=protected)
        processOpenData(obj,newData,tag);
        data=getSaveData(obj,tag);
    end

    methods
        function obj=waveformGenerator(varargin)

            obj@matlabshared.scopes.container.Application(getString(message('comm:waveformGenerator:DialogTitle')));


            if nargin>2||(nargin==1&&~ischar(varargin{1}))
                error('comm:waveformGenerator:InvalidCall',getString(message('comm:waveformGenerator:InvalidCall')));
            end

            processNextInstance(obj);

            if nargin==0

                defaultTag='OFDM';
            else
                defaultTag=varargin{1};
            end
            obj.pFirstWaveformType=defaultTag;

            if obj.useAppContainer


                obj.Toolstrip=wirelessWaveformGenerator.ToolstripWithoutMainTab(obj);
            else
                obj.Toolstrip=matlab.ui.internal.toolstrip.TabGroup();
            end
            obj.Toolstrip.Tag="wirelessWavegenTabGroup";
            obj.pRegistrations=obj.getRegisteredWaveforms();
            obj.pWavegenTab=obj.createGeneralTab(defaultTag);
            obj.Toolstrip.add(obj.pWavegenTab,1);
            obj.pRadioTab=obj.createRadioTab();
            obj.Toolstrip.add(obj.pRadioTab,2);
            addlistener(obj.Toolstrip,'SelectedTabChanged',@(src,event)selectedTabChangedCallback(obj,src,event));

            titleStr=getString(message('comm:waveformGenerator:DialogTitle'));


            pos=matlabshared.application.getInitialToolPosition([1280,768],0.7);

            if obj.useAppContainer


                obj.Window.open();

                obj.AppContainer=obj.Window.AppContainer;
                obj.AppContainer.Title=getString(message('comm:waveformGenerator:DialogTitle'));
                obj.AppContainer.WindowBounds=pos;
                obj.AppContainer.add(obj.Toolstrip);


                figureGroup=matlab.ui.internal.FigureDocumentGroup();
                figureGroup.Title="Figure Document Group";
                figureGroup.Tag="figureDocumentGroup";
                add(obj.AppContainer,figureGroup);






                obj.pStatus=matlab.ui.internal.statusbar.StatusBar();
                obj.pStatus.Tag="statusBar";
                obj.pStatusLabel=matlab.ui.internal.statusbar.StatusLabel();
                obj.pStatusLabel.Tag="statusLabel";
                obj.pStatusLabel.Text="";
                obj.pStatus.add(obj.pStatusLabel);
                obj.AppContainer.addStatusBar(obj.pStatus);
                obj.AppContainer.addStatusComponent(obj.pStatusLabel)
                obj.AppContainer.Visible=true;

                obj.pProgressBar=matlab.ui.internal.statusbar.StatusProgressBar();
                obj.pProgressBar.Tag="ControlSystemDesignerStatusProgressBar";
                obj.pProgressBar.Region="right";
                obj.pStatus.add(obj.pProgressBar);

                obj.waveformTypeChange(defaultTag);

                obj.Initializing=false;
            else

                obj.ToolGroup=matlab.ui.internal.desktop.ToolGroup(titleStr);


                obj.ToolGroup.hideViewTab();


                obj.ToolGroup.addTabGroup(obj.Toolstrip);


                obj.ToolGroup.disableDataBrowser();

                obj.ToolGroup.setPosition(pos(1),pos(2),pos(3),pos(4));
                obj.ToolGroup.setClosingApprovalNeeded(true);

                setHelpButtonLink(obj,defaultTag);
                obj.ToolGroup.open;

                obj.pParametersFig=figure('Name',getString(message('comm:waveformGenerator:WaveformFig')),...
                'NumberTitle','off','HandleVisibility','off','Tag','WavegenFig');
                obj.pParametersFig.UserData=obj;
                obj.ToolGroup.addFigure(obj.pParametersFig);

                obj.pParameters=wirelessWaveformGenerator.Parameters(obj);

                obj.ToolGroup.setWaiting(true);


                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                frame=md.getFrameContainingGroup(obj.ToolGroup.Name);
                obj.pStatus=javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
                javaMethodEDT('setSharedStatusBar',frame,obj.pStatus);


                obj.pProgressBar=javax.swing.JProgressBar;
                set(obj.pProgressBar,'Value',0);
                javaMethodEDT('setVisible',obj.pProgressBar,false);
                obj.pStatus.add(obj.pProgressBar,'East');

                obj.waveformTypeChange(defaultTag);

                prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                state=java.lang.Boolean.FALSE;
                md.getClient(obj.pParametersFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);

                notify(obj,'ToolGroupConstructed');

                obj.pParametersFig.DeleteFcn=@obj.onComponentBeingDestroyed;

                if obj.pPlotSpectrum
                    saFig=obj.pSpectrum1.getFramework.Parent;

                    figure(saFig);
                end

                obj.ToolGroup.setWaiting(false);
                obj.ToolGroup.setClosingApprovalNeeded(false);
                addToolGroupListeners(obj.Window)

                obj.GroupActionListener=event.listener(obj.ToolGroup,'GroupAction',@obj.groupActionCallback);
            end
        end

        function reset(self)
            if~isempty(self.pFrequencyOffset)
                reset(self.pFrequencyOffset);
            end
            if~isempty(self.pPhaseNoise)
                reset(self.pPhaseNoise);
            end
            if~isempty(self.pNonlinearity)
                reset(self.pNonlinearity);
            end
        end

        function release(self)
            if~isempty(self.pFrequencyOffset)
                release(self.pFrequencyOffset);
            end
            if~isempty(self.pPhaseNoise)
                release(self.pPhaseNoise);
            end
            if~isempty(self.pNonlinearity)
                release(self.pNonlinearity);
            end
        end

        function freezeApp(obj)
            if isempty(obj.FreezeHandle)||~isvalid(obj.FreezeHandle)
                obj.FreezeHandle=obj.Window.freezeUserInterface;
            end
        end
        function unfreezeApp(obj)
            delete(obj.FreezeHandle);
        end

        function figs=getAllVisualizations(obj)
            figs=gobjects(0);
            dialogs=obj.pParameters.DialogsMap;
            for dialog=dialogs.values()
                figs=[figs;getAllFigs(dialog{:})];%#ok<AGROW>
            end
        end

        function title=getTitle(this)
            title=getTitle@matlabshared.application.Application(this);
        end

        function t=getTag(~)
            t='waveformGenerator';
        end

        function helpCallback(obj,~,~)

            helpCallback(obj.pParameters.CurrentDialog);
        end
    end

    methods(Access=protected)

        function processNextInstance(this)



            appTitle=getString(message('comm:waveformGenerator:DialogTitle'));
            inst=this.Instances.keys;

            numInst=numel(inst);
            if numInst==1

                this.Key=appTitle;
                this.Instances([this.Key,' (1)'])=this;
            else



                this.Instances(this.Key)=this.Instances([this.Key,' (1)']);


                this.Key=[appTitle,' (',num2str(numInst),')'];
                this.Instances(this.Key)=this;
            end
        end

        function updateDynamicTabs(~)

        end

        function setHelpButtonLink(obj,defaultTag)



            if strcmp(defaultTag,'OFDM')
                setContextualHelpCallback(obj.ToolGroup,...
                @(h,e)helpview(fullfile(docroot,'comm','comm.map'),...
                'wirelessWaveformGenerator_app'));

            elseif strcmp(defaultTag,'Downlink')
                setContextualHelpCallback(obj.ToolGroup,...
                @(h,e)helpview(fullfile(docroot,'5g','helptargets.map'),...
                'FiveGWaveformGenerator_app'));

            elseif strcmp(defaultTag,'Downlink RMC')
                setContextualHelpCallback(obj.ToolGroup,...
                @(h,e)helpview(fullfile(docroot,'lte','helptargets.map'),...
                'LTEWaveformGenerator_app'));

            else
                setContextualHelpCallback(obj.ToolGroup,...
                @(h,e)helpview(fullfile(docroot,'wlan','helptargets.map'),...
                'WLANWaveformGenerator_app'));

            end
        end

        function selectedTabChangedCallback(obj,~,~)

            if obj.pInTransmission
                if obj.useAppContainer
                    obj.AppContainer.SelectedToolstripTab.tag='transmitterTab';
                else
                    obj.ToolGroup.SelectedTab='transmitterTab';
                end
                return
            end

            if obj.useAppContainer
                currTab=obj.AppContainer.SelectedToolstripTab.tag;
                freezeApp(obj);
            else
                obj.ToolGroup.setWaiting(true);
                currTab=obj.ToolGroup.SelectedTab;
            end
            inRadioTab=strcmp(currTab,'transmitterTab');
            params=obj.pParameters;

            firstTime=false;

            if inRadioTab
                if obj.useAppContainer
                    if isempty(obj.pParameters.RadioDialog)
                        document=matlab.ui.internal.FigurePanel(...
                        'Title',getString(message('comm:waveformGenerator:RadioFig')),...
                        'Tag','RadioFig');
                        addPanel(obj.AppContainer,document);
                        obj.pRadioFig=document.Figure;
                        obj.pRadioFig.Tag='RadioFig';
                        firstTime=true;
                        params.LayoutTransmitter=uigridlayout(obj.pRadioFig,[1,1]);
                        params.AccordionTransmitter=matlab.ui.container.internal.Accordion('Parent',params.LayoutTransmitter);
                    else
                        radioPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:RadioFig')));



                        radioPanel.Opened=false;

                        radioPanel.Showing=true;
                        radioPanel.Opened=true;
                    end


                    wavegenPanel=obj.AppContainer.getPanel('ConfigPanel');
                    wavegenPanel.Opened=false;
                    impairPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:ImpairmentsFig')));
                    if~isempty(impairPanel)
                        impairPanel.Opened=false;
                    end
                end
                if isempty(obj.pParameters.RadioDialog)
                    if~obj.useAppContainer
                        obj.pRadioFig=figure('Name',getString(message('comm:waveformGenerator:RadioFig')),...
                        'NumberTitle','off','HandleVisibility','off','Tag','RadioFig');
                        obj.ToolGroup.addFigure(obj.pRadioFig);
                        firstTime=true;
                    end

                    params.DialogsMap('wirelessWaveformGenerator.transmitter.InstrumentDialog')=wirelessWaveformGenerator.transmitter.InstrumentDialog(params,params.WaveformGenerator.pRadioFig);
                    params.DialogsMap('wirelessWaveformGenerator.transmitter.TxWaveformDialogICT')=wirelessWaveformGenerator.transmitter.TxWaveformDialogICT(params,params.WaveformGenerator.pRadioFig);
                    params.RadioDialog=params.DialogsMap('wirelessWaveformGenerator.transmitter.InstrumentDialog');
                    params.TxWaveformDialog=params.DialogsMap('wirelessWaveformGenerator.transmitter.TxWaveformDialogICT');
                    obj.pCurrentHWType='Instrument';
                    obj.pCurrentHWTag='Instrument';
                    params.setupRadioPanel();

                    if isKey(obj.pParameters.DialogsMap,'wirelessWaveformGenerator.transmitter.TxWaveformDialogICT')
                        txDialog=obj.pParameters.DialogsMap('wirelessWaveformGenerator.transmitter.TxWaveformDialogICT');
                        txDialog.TukeyWindowingLabel.Visible=~obj.pParameters.CurrentDialog.hasWindowing();
                        txDialog.TukeyWindowingGUI.Visible=~obj.pParameters.CurrentDialog.hasWindowing();
                    end
                end
            end

            if obj.useAppContainer
                if~inRadioTab
                    radioPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:RadioFig')));
                    radioPanel.Opened=false;


                    wavegenPanel=obj.AppContainer.getPanel('ConfigPanel');
                    wavegenPanel.Opened=true;
                    impairPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:ImpairmentsFig')));
                    if~isempty(impairPanel)&&obj.pImpairBtn.Value
                        impairPanel.Opened=true;
                        wavegenPanel.Collapsed=true;
                    end
                end
            else
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                loc=com.mathworks.widgets.desk.DTLocation.create(0);


                if inRadioTab
                    obj.pRadioFig.Visible=inRadioTab;
                    drawnow;
                    obj.pParametersFig.Visible=~inRadioTab;
                    javaMethodEDT('setClientLocation',md,obj.pRadioFig.Name,obj.ToolGroup.Name,loc);

                end
                if~inRadioTab
                    obj.pParametersFig.Visible=~inRadioTab;
                    drawnow;
                    obj.pRadioFig.Visible=inRadioTab;
                    prevLoc=javaMethodEDT('getClientLocation',md,obj.pParametersFig.Name);
                    if~inRadioTab&&~isempty(prevLoc)&&prevLoc.getTile()~=0
                        javaMethodEDT('setClientLocation',md,obj.pParametersFig.Name,obj.ToolGroup.Name,loc);
                    end
                end
                drawnow;
            end
            postSelectedTabChanged(obj.pParameters.CurrentDialog);

            if inRadioTab

                showSDR=supportsSDR(obj.pParameters.CurrentDialog);
                for entry=1:numel(obj.pRadioGalleryItems)
                    if~strcmp(obj.pRadioGalleryItems{entry}.Tag,'Instrument')
                        obj.pRadioGalleryItems{entry}.Enabled=showSDR;
                    end
                end

                if~obj.useAppContainer
                    prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                    state=java.lang.Boolean.FALSE;
                    md.getClient(obj.pRadioFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);
                else
                    pause(1);
                    layoutPanels(obj.pParameters.RadioDialog);
                end

                obj.pParameters.TxWaveformDialog.setRate(obj.pSampleRate);
                obj.setStatus(getString(message('comm:waveformGenerator:ConfigureHW')));
                if firstTime&&supportScanning(obj.pParameters.RadioDialog)&&~isConnected(obj.pParameters.RadioDialog.HardwareInterface)
                    findHardware(obj.pParameters.RadioDialog);
                end
            elseif obj.useAppContainer
                pause(1);
                layoutPanels(obj.pParameters.CurrentDialog);
            end

            if obj.useAppContainer
                unfreezeApp(obj);
            else
                obj.ToolGroup.setWaiting(false);
            end
        end

        function r=getRegisteredWaveforms(~)
            h=extmgr.Library.Instance;
            r=h.getRegistrationSet('wirelessWaveformGenerator','register');
        end

        function groupActionCallback(this,~,event)


            et=event.EventData.EventType;
            if strcmp(et,'CLOSING')
                this.cleanup();
            end
        end

        function cleanup(this)
            delete([this.getAllVisualizations();this.pParametersFig;this.pImpairmentsFig;this.pRadioFig;this.pInfoFig;this.pEyeDiagramFig;this.pCCDFFig]);


            this.deleteScopeFig(this.pTimeScope);
            this.deleteScopeFig(this.pSpectrum1);
            this.deleteScopeFig(this.pConstellation);

            if~isempty(this.pParameters.RadioDialog)
                this.pParameters.RadioDialog.cleanup();
            end


            dialogs=keys(this.pParameters.DialogsMap);
            for idx=1:numel(dialogs)
                dialog=this.pParameters.DialogsMap(dialogs{idx});
                cleanupDlg(dialog);
            end
        end

        function onComponentBeingDestroyed(this,~,~)

            notify(this,'ToolGroupBeingDestroyed');

            this.cleanup();

            close(this);
        end

        function b=onCloseRequest(this,varargin)
            b=false;
            if this.useAppContainer


                if~isvalid(this)||this.Initializing
                    return;
                end
            end
            b=true;

            onCloseRequest@matlabshared.application.ToolGroupFileSystem(this);
        end

        function deleteScopeFig(~,scope)
            if~isempty(scope)
                frameWork=getFramework(scope);
                if~isempty(frameWork)
                    fig=frameWork.Parent;
                    delete(fig);
                end
            end
        end
    end


    methods(Hidden)
        function spec=getSaveFileSpecification(~,~)
            spec={'*.mat',getString(message('comm:waveformGenerator:FileTypeDescription'))};
        end

        function title=getSaveDialogTitle(~,~)
            title=getString(message('comm:waveformGenerator:SaveDialogTitleSession'));
        end

        function title=getOpenDialogTitle(~,~)
            title=getString(message('comm:waveformGenerator:OpenDialogTitleSession'));
        end

        function b=showRecentFiles(~)
            b=true;
        end

        function openSplitOpening(~)
        end
        function openSplitOpened(~)
        end

        function b=useAppContainer(this)
            b=useAppContainer@matlabshared.application.Application(this);


        end




    end

    methods(Hidden,Static)
        function varargout=forceAppContainer(varargin)
            persistent forceFlag;
            if nargin
                forceFlag=varargin{1};
            end
            if nargout
                if isempty(forceFlag)
                    forceFlag=true;
                end
                varargout{1}=forceFlag;
            end
        end
    end

    methods(Static)
        results=getCCDF(wave)
        plotCCDF(ax,ccdfResults,holdAxesLimits)
        CCDFBurstModeCheckBoxCallback(src,evt)
    end
end

