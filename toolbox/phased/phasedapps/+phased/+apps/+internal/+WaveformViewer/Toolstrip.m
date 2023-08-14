classdef Toolstrip<handle



    properties(Transient=true)
ToolGroup
AppContainer
    end
    properties
IsAppContainer
AnalysisTab
NewBtn
OpenBtn
SaveBtn
AddWavBtn
DeleteBtn
CopyBtn
ExportBtn
LibraryWorkspacePopup
LibraryScriptPopup
LibraryFilePopup
LibrarySimulinkPopup
WaveformWorkspacePopup
WaveformScriptPopup
WaveformFilePopup
WaveformSimulinkPopup
WaveformReportPopup
DefaultBtn
RealImagBtn
MagnitudePhaseBtn
SpectrumBtn
MatchedFilterResponseBtn
StretchProcessorResponseBtn
PspectrumBtn
SpectrogramBtn
AmbFnContourBtn
AmbFnSurfaceBtn
AmbFnDelayBtn
AmbFnDopplerBtn
AutoCorrelationBtn
PlotSettingsGallery
SimulinkBtn
QuickAccessBarHelpListener

isWaveformLibraryEnabled
AppHandle
    end

    methods
        function self=Toolstrip(apphandle,isAppContainer)

            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            self.AppHandle=apphandle;
            self.IsAppContainer=isAppContainer;

            if self.IsAppContainer
                appOptions.Tag='pulseWaveformapp';
                appOptions.Title=strcat(getString(message('phased:apps:waveformapp:title')),'-',getString(message('phased:apps:waveformapp:DefaultSessionName')));
                self.AppContainer=AppContainer(appOptions);

            else
                [~,name]=fileparts(tempname);
                self.ToolGroup=...
                matlab.ui.internal.desktop.ToolGroup(strcat(getString(message('phased:apps:waveformapp:title')),'-',getString(message('phased:apps:waveformapp:DefaultSessionName'))),name);

                self.ToolGroup.setPosition(100,100,1100,770);
            end


            createAnalysisTab(self);
            createFileSection(self);
            createWaveformSection(self);
            createGalleryPlotSection(self);
            createDefaultLayoutSection(self);
            createExportSection(self);

            s=settings;
            if s.matlab.ui.internal.figuretype.webfigures.ActiveValue
                s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue=1;
                s.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue=1;
            end

            if self.IsAppContainer

                helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
                helpButton.DocName='phased/radarWaveformAnalyzer';
                self.AppContainer.add(helpButton);
                self.AppContainer.Visible=true;
            else
                removeViewTab(self)
                self.configureQuickAccessBarHelpButton(@self.helpCallback);

                self.ToolGroup.disableDataBrowser();

                self.ToolGroup.setClosingApprovalNeeded(true);
                self.ToolGroup.open
            end

        end
        function name=getGroupName(self)
            name=self.ToolGroup.Name;
        end
    end
    methods

        function createAnalysisTab(self)
            import matlab.ui.internal.toolstrip.*

            tabgroup=TabGroup();
            self.AnalysisTab=Tab(getString(message('phased:apps:waveformapp:AnalyzerTab')));
            self.AnalysisTab.Tag='analyzetab';
            add(tabgroup,self.AnalysisTab);
            tabgroup.SelectedTab=self.AnalysisTab;
            if self.IsAppContainer
                tabgroup.Tag='tabgroup';
                addTabGroup(self.AppContainer,tabgroup)
            else
                self.ToolGroup.addTabGroup(tabgroup)
            end
        end

        function createFileSection(self)
            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection(getString(message('phased:apps:waveformapp:FileLabel')));
            section.Tag='File';

            column=addColumn(section);
            button=SplitButton(getString(message('phased:apps:waveformapp:NewButton')),Icon.NEW_24);
            button.Tag='NewBtn';
            button.Description=getString(message('phased:apps:waveformapp:NewButtonTooltip'));
            button.ButtonPushedFcn=@(h,e)newActions(self.AppHandle.Model,self.AppHandle.View);
            add(column,button)
            self.NewBtn=button;

            popup=PopupList();
            self.NewBtn.Popup=popup;

            item=ListItem(getString(message('phased:apps:waveformapp:SessionLabel')),Icon.NEW_16);
            item.Description=getString(message('phased:apps:waveformapp:SessionDescription'));
            item.Tag='NewSession';
            item.ItemPushedFcn=@(h,e)newActions(self.AppHandle.Model,self.AppHandle.View);
            add(popup,item)

            item=ListItem(getString(message('phased:apps:waveformapp:ImportFileLabel')),Icon.NEW_16);
            item.Description=getString(message('phased:apps:waveformapp:ImportFileDescription'));
            item.Tag='ImportFile';
            item.ItemPushedFcn=@(h,e)importPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:ImportFileLabel')));
            add(popup,item)

            item=ListItem(getString(message('phased:apps:waveformapp:ImportWorkspaceLabel')),Icon.NEW_16);
            item.Tag='ImportWorkspace';
            item.Description=getString(message('phased:apps:waveformapp:ImportWorkspaceDescription'));
            item.ItemPushedFcn=@(h,e)importPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:ImportWorkspaceLabel')));
            add(popup,item)
            self.NewBtn.Enabled=true;

            column=addColumn(section);
            button=Button(getString(message('phased:apps:waveformapp:OpenButton')),Icon.OPEN_24);
            button.Tag='OpenBtn';
            button.Description=getString(message('phased:apps:waveformapp:OpenTooltip'));
            button.Enabled=true;
            button.ButtonPushedFcn=@(h,e)openAction(self.AppHandle.Model,self.AppHandle.View);
            add(column,button)
            self.OpenBtn=button;

            column=addColumn(section);
            button=SplitButton(getString(message('phased:apps:waveformapp:SaveButton')),Icon.SAVE_24);
            button.Description=getString(message('phased:apps:waveformapp:SaveTooltip'));
            button.ButtonPushedFcn=@(h,e)saveAction(self.AppHandle.Model,self.AppHandle.View);
            button.Tag='SaveBtn';
            add(column,button)
            self.SaveBtn=button;

            popup=PopupList();
            self.SaveBtn.Popup=popup;
            item=ListItem(getString(message('phased:apps:waveformapp:SaveButton')),Icon.SAVE_16);
            item.ShowDescription=false;
            item.Tag='Save';
            item.ItemPushedFcn=@(h,e)savePopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SaveButton')));
            add(popup,item)

            item=ListItem(getString(message('phased:apps:waveformapp:SaveasLabel')),Icon.SAVE_AS_16);
            item.ShowDescription=false;
            item.Tag='Saveas';
            item.ItemPushedFcn=@(h,e)savePopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SaveasLabel')));
            add(popup,item)
            self.SaveBtn.Enabled=true;
        end

        function createWaveformSection(self)
            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection(getString(message('phased:apps:waveformapp:LibrarySection')));
            section.Tag='Waveform';

            column=addColumn(section);
            button=Button(getString(message('phased:apps:waveformapp:AddButton')),Icon.ADD_24);
            button.Tag='AddWavBtn';
            button.Enabled=true;
            button.Description=getString(message('phased:apps:waveformapp:AddTooltip'));
            button.ButtonPushedFcn=@(h,e)addAction(self.AppHandle.View);

            add(column,button);
            self.AddWavBtn=button;

            column=addColumn(section);
            button=Button(getString(message('phased:apps:waveformapp:DeleteButton')),Icon.DELETE_16);
            button.Tag='DeleteBtn';
            button.Enabled=true;
            button.Description=getString(message('phased:apps:waveformapp:DeleteTooltip'));
            button.ButtonPushedFcn=@(h,e)deleteAction(self.AppHandle.View);
            add(column,button)
            self.DeleteBtn=button;

            button=Button(getString(message('phased:apps:waveformapp:DuplicateButton')),Icon.COPY_16);
            button.Tag='CopyBtn';
            button.Enabled=true;
            button.Description=getString(message('phased:apps:waveformapp:DuplicateTooltip'));
            button.ButtonPushedFcn=@(h,e)duplicateAction(self.AppHandle.View);
            add(column,button)
            self.CopyBtn=button;
        end

        function createExportSection(self)
            import matlab.ui.internal.toolstrip.*

            self.isWaveformLibraryEnabled=phased.apps.internal.WaveformViewer.licenseCheck(self.IsAppContainer);

            iconsRoot=fullfile(matlabroot,'toolbox','phased','phasedapps',...
            '+phased','+apps','+internal','+WaveformViewer');
            scriptIcon=Icon(fullfile(iconsRoot,'Code_Gen_24.png'));
            reportIcon=Icon(fullfile(iconsRoot,'Report_Gen_24.png'));

            section=self.AnalysisTab.addSection(getString(message('phased:apps:waveformapp:ExportSection')));
            section.CollapsePriority=10;
            section.Tag='Export';

            haveSimulink=builtin('license','test','SIMULINK');
            if haveSimulink
                column=addColumn(section);
                button=SplitButton(getString(message('phased:apps:waveformapp:SimulinkButton')),Icon.SIMULINK_24);
                button.Tag='SimulinkBtn';
                button.Description=getString(message('phased:apps:waveformapp:SimulinkTooltip'));
                button.DynamicPopupFcn=@(src,evt)SimulinkPopupUpdate(self);
                button.ButtonPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SimulinkLabel')));

                popup=PopupList();
                button.Popup=popup;

                self.WaveformSimulinkPopup=ListItem(getString(message('phased:apps:waveformapp:SimulinkWaveformLabel')),Icon.SIMULINK_24);
                self.WaveformSimulinkPopup.Tag='WaveformSimulink';
                self.WaveformSimulinkPopup.ShowDescription=false;
                self.WaveformSimulinkPopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SimulinkLabel')));
                add(popup,self.WaveformSimulinkPopup)

                if self.isWaveformLibraryEnabled
                    self.LibrarySimulinkPopup=ListItem(getString(message('phased:apps:waveformapp:SimulinkLibraryLabel')),Icon.SIMULINK_24);
                    self.LibrarySimulinkPopup.Tag='LibrarySimulinkPopup';
                    self.LibrarySimulinkPopup.ShowDescription=false;
                    self.LibrarySimulinkPopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SimulinkLabel')));
                    add(popup,self.LibrarySimulinkPopup)
                end

                button.Enabled=true;
                add(column,button)
                self.SimulinkBtn=button;
            end

            column=addColumn(section);
            button=SplitButton(getString(message('phased:apps:waveformapp:ExportSection')),Icon.CONFIRM_24);
            button.Description=getString(message('phased:apps:waveformapp:ExportTooltip'));
            button.Tag='ExportBtn';
            button.DynamicPopupFcn=@(src,evt)ExportPopupUpdate(self);
            button.ButtonPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')));

            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='ExportPopup';

            Header=PopupListHeader(getString(message('phased:apps:waveformapp:WaveformHeader')));
            Header.Tag='ExportWaveform';
            add(popup,Header);

            self.WaveformWorkspacePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')),Icon.CONFIRM_24);
            self.WaveformWorkspacePopup.Tag='WaveformWorkspace';
            self.WaveformWorkspacePopup.ShowDescription=false;
            self.WaveformWorkspacePopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')));
            add(popup,self.WaveformWorkspacePopup)

            self.WaveformScriptPopup=ListItem(getString(message('phased:apps:waveformapp:WaveformScriptLabel')),scriptIcon);
            self.WaveformScriptPopup.Tag='WaveformScript';
            self.WaveformScriptPopup.ShowDescription=false;
            self.WaveformScriptPopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformScriptLabel')));
            add(popup,self.WaveformScriptPopup)

            self.WaveformFilePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformFileLabel')),Icon.FIND_FILES_24);
            self.WaveformFilePopup.Tag='WaveformFile';
            self.WaveformFilePopup.ShowDescription=false;
            self.WaveformFilePopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformFileLabel')));
            add(popup,self.WaveformFilePopup)

            self.WaveformReportPopup=ListItem(getString(message('phased:apps:waveformapp:WaveformReportLabel')),reportIcon);
            self.WaveformReportPopup.Tag='WaveformReport';
            self.WaveformReportPopup.ShowDescription=false;
            self.WaveformReportPopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:GenerateReportLabel')));
            add(popup,self.WaveformReportPopup)

            if self.isWaveformLibraryEnabled
                Header=PopupListHeader(getString(message('phased:apps:waveformapp:LibraryHeader')));
                Header.Tag='ExportLibrary';
                add(popup,Header);

                self.LibraryWorkspacePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')),Icon.CONFIRM_24);
                self.LibraryWorkspacePopup.Tag='LibraryWorkspacePopup';
                self.LibraryWorkspacePopup.ShowDescription=false;
                self.LibraryWorkspacePopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')));
                add(popup,self.LibraryWorkspacePopup)

                self.LibraryScriptPopup=ListItem(getString(message('phased:apps:waveformapp:WaveformScriptLabel')),scriptIcon);
                self.LibraryScriptPopup.Tag='LibraryScriptPopup';
                self.LibraryScriptPopup.ShowDescription=false;
                self.LibraryScriptPopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformScriptLabel')));
                add(popup,self.LibraryScriptPopup)

                self.LibraryFilePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformFileLabel')),Icon.FIND_FILES_24);
                self.LibraryFilePopup.Tag='LibraryFilePopup';
                self.LibraryFilePopup.ShowDescription=false;
                self.LibraryFilePopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformFileLabel')));
                add(popup,self.LibraryFilePopup)
            end

            button.Enabled=true;
            add(column,button)
            self.ExportBtn=button;
        end

        function createDefaultLayoutSection(self)
            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection(getString(message('phased:apps:waveformapp:LayoutSection')));
            section.Tag='Default';

            column=addColumn(section);
            button=Button(getString(message('phased:apps:waveformapp:LayoutButton')),Icon.LAYOUT_24);
            button.Tag='LayoutBtn';
            button.Description=getString(message('phased:apps:waveformapp:LayoutTooltip'));
            button.Enabled=true;
            button.ButtonPushedFcn=@(h,e)defaultLayoutAction(self.AppHandle.View);
            add(column,button)
            self.DefaultBtn=button;

        end

        function createGalleryPlotSection(self)
            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection(getString(message('phased:apps:waveformapp:AnalysisSection')));

            iconsRoot=fullfile(matlabroot,'toolbox','phased','phasedapps',...
            '+phased','+apps','+internal','+WaveformViewer');
            realImaginaryIcon=Icon(fullfile(iconsRoot,'real_and_imaginary_24.png'));
            magnitudePhaseIcon=Icon(fullfile(iconsRoot,'magnitude_and_phase_24_2.png'));
            spectrumIcon=Icon(fullfile(iconsRoot,'spectrum_24.png'));
            persistenceSpectrumIcon=Icon(fullfile(iconsRoot,'persistence_spectrum_24_1.png'));
            spectrogramIcon=Icon(fullfile(iconsRoot,'spectrogram_24.png'));
            ambContourIcon=Icon(fullfile(iconsRoot,'ambiguity_24_1.png'));
            ambSurfaceIcon=Icon(fullfile(iconsRoot,'ambiguity_surface_24.png'));
            ambDelayCutIcon=Icon(fullfile(iconsRoot,'ambiguity_delay_cut_24.png'));
            ambDoplplerCutIcon=Icon(fullfile(iconsRoot,'ambiguity_doppler_cut_24.png'));
            ambAutoCorrelationIcon=Icon(fullfile(iconsRoot,'ambiguity_autocorrelation_24.png'));
            MatchedFilterResponseIcon=Icon(fullfile(iconsRoot,'ambiguity_autocorrelation_24.png'));
            StretchProcessorResponseIcon=Icon(fullfile(iconsRoot,'ambiguity_autocorrelation_24.png'));
            column=addColumn(section);

            popup=GalleryPopup('ShowSelection',false);
            gallery=Gallery(popup,'MaxColumnCount',3,'MinColumnCount',2);
            gallery.Tag='PlotGallery';
            column.add(gallery);
            gallery.Enabled=true;
            self.PlotSettingsGallery=gallery;

            NormalCategory=GalleryCategory(getString(message('phased:apps:waveformapp:SignalSection')));
            NormalCategory.Tag='NormalCategory';
            AmbiguityCategory=GalleryCategory(getString(message('phased:apps:waveformapp:AmbiguitySection')));
            AmbiguityCategory.Tag='AmbiguityCategory';
            popup.add(NormalCategory);
            popup.add(AmbiguityCategory);

            item=GalleryItem(getString(message('phased:apps:waveformapp:RealandImaginary')),realImaginaryIcon);
            item.Tag='RealImag';
            item.Description=getString(message('phased:apps:waveformapp:RealandImaginaryTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:realimag')));
            NormalCategory.add(item);
            self.RealImagBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:MagnitudeandPhase')),magnitudePhaseIcon);
            item.Tag='MagnitudePhase';
            item.Description=getString(message('phased:apps:waveformapp:MagnitudeandPhaseTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:magphase')));
            NormalCategory.add(item);
            self.MagnitudePhaseBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:Spectrum')),spectrumIcon);
            item.Tag='Spectrum';
            item.Description=getString(message('phased:apps:waveformapp:SpectrumTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:spectrum')));
            NormalCategory.add(item);
            self.SpectrumBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:PersistenceSpectrumLabel')),persistenceSpectrumIcon);
            item.Tag='PersistenceSspectrum';
            item.Description=getString(message('phased:apps:waveformapp:PersistenceSpectrumTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:pspectrum')));
            NormalCategory.add(item);
            self.PspectrumBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:Spectrogram')),spectrogramIcon);
            item.Tag='Spectrogram';
            item.Description=getString(message('phased:apps:waveformapp:SpectrogramTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:spectrogram')));
            NormalCategory.add(item);
            self.SpectrogramBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:ContourLabel')),ambContourIcon);
            item.Tag='Contour';
            item.Description=getString(message('phased:apps:waveformapp:ContourTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:ambfuncontour')));
            AmbiguityCategory.add(item);
            self.AmbFnContourBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:SurfaceLabel')),ambSurfaceIcon);
            item.Tag='Surface';
            item.Description=getString(message('phased:apps:waveformapp:SurfaceTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:ambfunsurf')));
            AmbiguityCategory.add(item);
            self.AmbFnSurfaceBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:DelayCutLabel')),ambDelayCutIcon);
            item.Tag='DelayCut';
            item.Description=getString(message('phased:apps:waveformapp:DelayCutTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:ambfundelaycut')));
            AmbiguityCategory.add(item);
            self.AmbFnDelayBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:DopplerCutLabel')),ambDoplplerCutIcon);
            item.Tag='DopplerCut';
            item.Description=getString(message('phased:apps:waveformapp:DopplerCutTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:ambfundopplercut')));
            AmbiguityCategory.add(item);
            self.AmbFnDopplerBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:AutoCorrelationLabel')),ambAutoCorrelationIcon);
            item.Tag='AutoCorrelation';
            item.Description=getString(message('phased:apps:waveformapp:AutoCorrelationTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:autocorrelation')));
            AmbiguityCategory.add(item);
            self.AutoCorrelationBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:MatchedFilterLabel')),MatchedFilterResponseIcon);
            item.Tag='MatchedFilter';
            item.Description=getString(message('phased:apps:waveformapp:MatchedFilterTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:matchedfilterresponse')));
            NormalCategory.add(item);
            self.MatchedFilterResponseBtn=item;
            item=GalleryItem(getString(message('phased:apps:waveformapp:StretchProcessorLabel')),StretchProcessorResponseIcon);
            item.Tag='StretchProcessor';
            item.Description=getString(message('phased:apps:waveformapp:StretchProcessorTooltip'));
            item.ItemPushedFcn=@(h,e)addplotAction(self.AppHandle.View,getString(message('phased:apps:waveformapp:stretchprocessorresponse')));
            NormalCategory.add(item);
            self.StretchProcessorResponseBtn=item;
        end

        function removeViewTab(self)

            group=self.ToolGroup.Peer.getWrappedComponent;
            group.putGroupProperty(...
            com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,...
            false);
            group.putGroupProperty(...
            com.mathworks.widgets.desk.DTGroupProperty.SHOW_SINGLE_ENTRY_DOCUMENT_BAR,false);
        end

        function configureQuickAccessBarHelpButton(self,helpCallback)
            action=com.mathworks.toolbox.shared.controllib.desktop.TSUtils.getAction('Help',javax.swing.ImageIcon);
            self.QuickAccessBarHelpListener=...
            addlistener(action.getCallback,'delayed',helpCallback);
            ctm=com.mathworks.toolstrip.factory.ContextTargetingManager;
            ctm.setToolName(action,'help')
            ja=javaArray('javax.swing.Action',1);
            ja(1)=action;
            group=self.ToolGroup.Peer.getWrappedComponent;
            group.putGroupProperty(...
            com.mathworks.widgets.desk.DTGroupProperty.CONTEXT_ACTIONS,ja);
        end
        function helpCallback(~,~,~)

            helpview([docroot,'\phased\helptargets.map'],'waveform_app');
        end

        function popup=SimulinkPopupUpdate(self)
            import matlab.ui.internal.toolstrip.*

            popup=PopupList();
            self.SimulinkBtn.Popup=popup;
            self.SimulinkBtn.ButtonPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SimulinkLabel')));

            self.isWaveformLibraryEnabled=phased.apps.internal.WaveformViewer.licenseCheck(self.IsAppContainer);

            self.WaveformSimulinkPopup=ListItem(getString(message('phased:apps:waveformapp:SimulinkWaveformLabel')),Icon.SIMULINK_24);
            self.WaveformSimulinkPopup.Tag='WaveformSimulink';
            self.WaveformSimulinkPopup.ShowDescription=false;
            self.WaveformSimulinkPopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SimulinkLabel')));
            add(popup,self.WaveformSimulinkPopup)

            if self.isWaveformLibraryEnabled
                self.LibrarySimulinkPopup=ListItem(getString(message('phased:apps:waveformapp:SimulinkLibraryLabel')),Icon.SIMULINK_24);
                self.LibrarySimulinkPopup.Tag='LibrarySimulinkPopup';
                self.LibrarySimulinkPopup.ShowDescription=false;
                self.LibrarySimulinkPopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:SimulinkLabel')));
                add(popup,self.LibrarySimulinkPopup)
            end
            rowIndex=self.AppHandle.View.Canvas.WaveformList.getSelectedRows;
            if numel(rowIndex)>1
                self.WaveformSimulinkPopup.Enabled=false;
            end
        end

        function popup=ExportPopupUpdate(self)
            import matlab.ui.internal.toolstrip.*
            self.isWaveformLibraryEnabled=phased.apps.internal.WaveformViewer.licenseCheck(self.IsAppContainer);

            iconsRoot=fullfile(matlabroot,'toolbox','phased','phasedapps',...
            '+phased','+apps','+internal','+WaveformViewer');
            scriptIcon=Icon(fullfile(iconsRoot,'Code_Gen_24.png'));
            reportIcon=Icon(fullfile(iconsRoot,'Report_Gen_24.png'));
            popup=PopupList();
            self.ExportBtn.Popup=popup;
            self.ExportBtn.Popup.Tag='ExportPopup';
            self.ExportBtn.ButtonPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')));

            Header=PopupListHeader(getString(message('phased:apps:waveformapp:WaveformHeader')));
            Header.Tag='ExportWaveform';
            add(popup,Header);

            self.WaveformWorkspacePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')),Icon.CONFIRM_24);
            self.WaveformWorkspacePopup.Tag='WaveformWorkspace';
            self.WaveformWorkspacePopup.ShowDescription=false;
            self.WaveformWorkspacePopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')));
            add(popup,self.WaveformWorkspacePopup)

            self.WaveformScriptPopup=ListItem(getString(message('phased:apps:waveformapp:WaveformScriptLabel')),scriptIcon);
            self.WaveformScriptPopup.Tag='WaveformScript';
            self.WaveformScriptPopup.ShowDescription=false;
            self.WaveformScriptPopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformScriptLabel')));
            add(popup,self.WaveformScriptPopup)

            self.WaveformFilePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformFileLabel')),Icon.FIND_FILES_24);
            self.WaveformFilePopup.Tag='WaveformFile';
            self.WaveformFilePopup.ShowDescription=false;
            self.WaveformFilePopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformFileLabel')));
            add(popup,self.WaveformFilePopup)

            self.WaveformReportPopup=ListItem(getString(message('phased:apps:waveformapp:WaveformReportLabel')),reportIcon);
            self.WaveformReportPopup.Tag='WaveformReport';
            self.WaveformReportPopup.ShowDescription=false;
            self.WaveformReportPopup.ItemPushedFcn=@(h,e)exportWavPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:GenerateReportLabel')));
            add(popup,self.WaveformReportPopup)


            if self.isWaveformLibraryEnabled
                Header=PopupListHeader(getString(message('phased:apps:waveformapp:LibraryHeader')));
                Header.Tag='ExportLibrary';
                add(popup,Header);

                self.LibraryWorkspacePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')),Icon.CONFIRM_24);
                self.LibraryWorkspacePopup.Tag='LibraryWorkspacePopup';
                self.LibraryWorkspacePopup.ShowDescription=false;
                self.LibraryWorkspacePopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformWorkspaceLabel')));
                add(popup,self.LibraryWorkspacePopup)

                self.LibraryScriptPopup=ListItem(getString(message('phased:apps:waveformapp:WaveformScriptLabel')),scriptIcon);
                self.LibraryScriptPopup.Tag='LibraryScriptPopup';
                self.LibraryScriptPopup.ShowDescription=false;
                self.LibraryScriptPopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformScriptLabel')));
                add(popup,self.LibraryScriptPopup)

                self.LibraryFilePopup=ListItem(getString(message('phased:apps:waveformapp:WaveformFileLabel')),Icon.FIND_FILES_24);
                self.LibraryFilePopup.Tag='LibraryFilePopup';
                self.LibraryFilePopup.ShowDescription=false;
                self.LibraryFilePopup.ItemPushedFcn=@(h,e)exportLibraryPopupActions(self.AppHandle.Model,self.AppHandle.View,getString(message('phased:apps:waveformapp:WaveformFileLabel')));
                add(popup,self.LibraryFilePopup)
            end
            rowIndex=self.AppHandle.View.Canvas.WaveformList.getSelectedRows;
            if numel(rowIndex)>1
                self.WaveformWorkspacePopup.Enabled=false;
                self.WaveformScriptPopup.Enabled=false;
                self.WaveformFilePopup.Enabled=false;
                self.WaveformReportPopup.Enabled=false;
            end
        end
    end
end