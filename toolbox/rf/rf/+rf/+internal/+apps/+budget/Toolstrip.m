classdef Toolstrip<handle






    properties(Transient=true)
ToolGroup
AppContainer
    end


    properties
ElementGallery
ElementGalleryItems
ElementGalleryCats
AnalysisTab
NewBtn
OpenBtn
SaveBtn
DeleteBtn
HBBtn
PlotBtn
OIP2item
IIP2item
PlotBtn2D
OIP22Ditem
IIP22Ditem
SmithBtn
PolarBtn
ExportBtn
SystemParameters
DefaultLayoutBtn
TestbenchItem
PlotBandwidthLabel
PlotResolutionLabel
PlotBandwidthEdit
PlotResolutionEdit
PlotBandwidthUnits
AutoUpdateCheckbox
UseAppContainer
StatusBar
StatusLabel
    end

    properties(Dependent=true)
PlotBandwidth
PlotResolution
    end

    properties(Access=private)
IconRoot
TrashIcon
AmplifierIcon
ModulatorIcon
DeModulatorIcon
NportIcon
RFelementIcon
FilterIcon
TxlineIcon
seriesRLCIcon
shuntRLCIcon
AttenuatorIcon
antennaIcon
PhaseshiftIcon
RxAntennaIcon
SParametersIcon
PlotIcon3D
PlotIcon2D
LCLadderIcon
TxRxAntennaIcon
mixerIMTIcon

    end

    methods

        function self=Toolstrip(varargin)

            parser=inputParser;
            parser.addOptional('UseAppContainer',false,@islogical);
            parse(parser,varargin{:})
            self.UseAppContainer=parser.Results.UseAppContainer;
            if self.UseAppContainer
                self.AppContainer=...
                matlab.ui.container.internal.AppContainer(...
                'Title','RF Budget Analyzer',...
                'Tag',['rfBudgetAnalyzer_',char(matlab.lang.internal.uuid)]);

                helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
                helpButton.DocName='rf/rfbudget_app';
                helpButton.Tag='helpButton';
                self.AppContainer.add(helpButton);
            else
                self.ToolGroup=...
                matlab.ui.internal.desktop.ToolGroup('RF Budget Analyzer');
                self.ToolGroup.setClosingApprovalNeeded(true);
            end
            createIcons(self);

            createAnalysisTab(self);
            createFileSection(self);
            createSystemParametersSection(self);
            createElementGallery(self);
            createHarmonicBalanceSection(self);
            createPlotSection(self);
            createViewSection(self);
            createExportSection(self);

            appSize=rf.internal.apps.budget.View.AppSize;
            if self.UseAppContainer


                self.StatusBar=matlab.ui.internal.statusbar.StatusBar;
                self.StatusBar.Tag='statusBar';
                self.StatusLabel=matlab.ui.internal.statusbar.StatusLabel;
                self.StatusLabel.Tag='statusLabel';
                self.StatusLabel.Text="";
                add(self.StatusBar,self.StatusLabel);
                add(self.AppContainer,self.StatusBar);
                self.AppContainer.Visible=true;
                waitfor(self.AppContainer,'State',matlab.ui.container.internal.appcontainer.AppState.RUNNING);

                self.AppContainer.WindowBounds(3:4)=[appSize(1),appSize(2)];
                self.AppContainer.DocumentGridDimensions=[1,2];
                self.AppContainer.DocumentTileCoverage=[1,2];
            else


                setContextualHelpCallback(self.ToolGroup,...
                @(h,e)helpview(fullfile(docroot,'rf','helptargets.map'),...
                'rfbudget_app'))
                removeViewTab(self)
                enableDocking(self)
                self.ToolGroup.disableDataBrowser();


                self.ToolGroup.setClosingApprovalNeeded(true);
                self.ToolGroup.open
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;

                frame=md.getFrameContainingGroup(self.ToolGroup.Name);
                frame.setSize(appSize(1),appSize(2))

                md.hideClient('DataBrowserContainer',self.ToolGroup.Name)

                md.setDocumentArrangement(self.ToolGroup.Name,md.TILED,java.awt.Dimension(2,2));
                md.setDocumentRowSpan(self.ToolGroup.Name,0,0,2);
                md.setDocumentColumnWidths(self.ToolGroup.Name,[0.29,0.71]);
                md.setDocumentRowHeights(self.ToolGroup.Name,[0.50,0.50]);
            end
        end
    end

    methods

        function set.PlotBandwidth(self,freq)
            [y,e,u]=engunits(freq);
            i=strcmp(u,{'','k','M','G','T'});
            if any(i)
                self.PlotBandwidthEdit.Value=num2str(y);
                self.PlotBandwidthUnits.SelectedIndex=find(i);
            elseif e<...
1e-12
                self.PlotBandwidthEdit.Value=num2str(freq*1e-12);
                self.PlotBandwidthUnits.SelectedIndex=5;
            else
                self.PlotBandwidthEdit.Value=num2str(freq);
                self.PlotBandwidthUnits.SelectedIndex=1;
            end
        end

        function freq=get.PlotBandwidth(self)
            fac=1e3^(self.PlotBandwidthUnits.SelectedIndex-1);
            freq=fac*str2double(self.PlotBandwidthEdit.Value);
        end

        function set.PlotResolution(self,val)
            self.PlotResolutionEdit.Value=num2str(val);
        end

        function val=get.PlotResolution(self)
            val=str2double(self.PlotResolutionEdit.Value);
        end

        function createIcons(self)


            import matlab.ui.internal.toolstrip.*
            self.IconRoot=fullfile(matlabroot,...
            'toolbox','rf','rf','+rf','+internal','+apps','+budget');
            self.TrashIcon=Icon.DELETE_24;
            self.AmplifierIcon=Icon(fullfile(self.IconRoot,'amp_24.png'));
            self.ModulatorIcon=Icon(fullfile(self.IconRoot,'modulator_24.png'));
            self.DeModulatorIcon=Icon(fullfile(self.IconRoot,'demodulator_24.png'));
            self.NportIcon=Icon(fullfile(self.IconRoot,'S_P_24.png'));
            self.RFelementIcon=Icon(fullfile(self.IconRoot,'generic_24.png'));
            self.FilterIcon=Icon(fullfile(self.IconRoot,'filter_24.png'));
            self.TxlineIcon=Icon(fullfile(self.IconRoot,'txline_24.png'));
            self.seriesRLCIcon=Icon(fullfile(self.IconRoot,'seriesRLC_24.png'));
            self.shuntRLCIcon=Icon(fullfile(self.IconRoot,'shuntRLC_24.png'));
            self.AttenuatorIcon=Icon(fullfile(self.IconRoot,'Attenuator_24.png'));
            self.PhaseshiftIcon=Icon(fullfile(self.IconRoot,'phaseshift_24.png'));
            self.LCLadderIcon=Icon(fullfile(self.IconRoot,'lowpasstee_24.png'));
            self.antennaIcon=Icon(fullfile(self.IconRoot,'antenna_24.png'));
            self.RxAntennaIcon=Icon(fullfile(self.IconRoot,'rx_24.png'));
            self.mixerIMTIcon=Icon(fullfile(self.IconRoot,'mixerIMT_24.png'));
            self.PlotIcon2D=Icon(fullfile(self.IconRoot,'2D_Analysis_Plot_24.png'));
            self.PlotIcon3D=Icon(fullfile(self.IconRoot,'3D_Analysis_Plot_24.png'));
            self.SParametersIcon=Icon(fullfile(self.IconRoot,'S-Parameters_Plot_24.png'));
            self.TxRxAntennaIcon=Icon(fullfile(self.IconRoot,'TransmitReceive_24.png'));

        end

        function createAnalysisTab(self)

            import matlab.ui.internal.toolstrip.*
            tabgroup=TabGroup();
            self.AnalysisTab=Tab('RF Budget Analyzer');
            self.AnalysisTab.Tag='tab1';
            add(tabgroup,self.AnalysisTab);
            tabgroup.SelectedTab=self.AnalysisTab;
            if self.UseAppContainer
                tabgroup.Tag='tabGroup';
                self.AppContainer.addTabGroup(tabgroup);
            else
                self.ToolGroup.addTabGroup(tabgroup);
            end
        end

        function createFileSection(self)



            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection('File');
            section.Tag='File';

            column=addColumn(section);
            column.Tag='NewColumn';
            button=SplitButton('New',Icon.NEW_24);
            self.NewBtn=button;
            button.Tag='newButton';
            button.Description=...
            'Start new RF budget analysis from blank canvas or template';

            popup=PopupList();
            button.Popup=popup;
            item=ListItem('Blank canvas');
            item.ShowDescription=false;
            item.Tag='blankCanvasListItem';
            add(popup,item)
            item=ListItem('Receiver');
            item.ShowDescription=false;
            item.Tag='receiverListItem';
            add(popup,item)
            item=ListItem('Transmitter');
            item.ShowDescription=false;
            item.Tag='transmitterListItem';
            add(popup,item)
            button.Enabled=false;
            add(column,button)

            column=addColumn(section);
            column.Tag='OpenColumn';
            button=Button('Open',Icon.OPEN_24);
            self.OpenBtn=button;
            button.Tag='openButton';
            button.Description=...
            'Open .MAT file containing saved RF budget analysis';
            button.Enabled=false;
            add(column,button)

            column=addColumn(section);
            column.Tag='SaveColumn';
            button=SplitButton('Save',Icon.SAVE_24);
            button.Tag='saveSplitButton';
            self.SaveBtn=button;
            button.Description=...
            'Save current RF budget analysis to .MAT file';
            button.Tag='saveSplitButton';

            popup=PopupList();
            button.Popup=popup;
            item=ListItem('Save',Icon.SAVE_16);
            item.ShowDescription=false;
            add(popup,item)
            item=ListItem('Save As...',Icon.SAVE_AS_16);
            item.ShowDescription=false;
            add(popup,item)
            button.Enabled=false;
            add(column,button)
        end

        function createSystemParametersSection(self)


            self.SystemParameters=rf.internal.apps.budget.SystemParametersSection(self);
        end

        function createDeleteSection(self)



            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection('Delete');
            section.Tag='Delete';
            if self.UseAppContainer
                column=addColumn(section,65);
            else
                column=addColumn(section);
            end
            column.Tag='DeleteColumn';
            button=Button(['Delete',newline,'Element'],self.TrashIcon);
            self.DeleteBtn=button;
            button.Description='Delete selected element';
            button.Tag='DeleteBtn';
            button.Enabled=false;
            add(column,button)
        end

        function createHarmonicBalanceSection(self)




            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection('Harmonic Balance');
            section.Tag='HarmonicBalance';
            column=addColumn(section,...
            'HorizontalAlignment','center');
            column.Tag='HBColumn';
            if self.UseAppContainer
                button=Button('HB-Analyze',Icon.RUN_16);
            else
                button=Button('HB-Analyze',Icon.RUN_24);
            end
            self.HBBtn=button;
            button.Description='Run Harmonic Balance analysis';
            button.Tag='HBBtn';
            button.Enabled=false;
            add(column,button)
            checkBox=CheckBox('Auto-Analyze');
            self.AutoUpdateCheckbox=checkBox;
            checkBox.Description='Automatically recompute Harmonic Balance analysis';
            checkBox.Tag='AutoUpdateCheckBox';
            checkBox.Enabled=false;
            add(column,checkBox)
        end

        function createElementGallery(self)


            import matlab.ui.internal.toolstrip.*;
            section=self.AnalysisTab.addSection('Elements');
            section.Tag='Add';
            column=addColumn(section);
            column.Tag='galleryColumn';
            ElementGalleryPopup=GalleryPopup(...
            'ShowSelection',false,...
            'GalleryItemTextLineCount',2);

            elements={...
            'Amplifier',...
            'Modulator',...
            'Demodulator',...
            'S_Parameters',...
            'generic',...
            'filter',...
            'txline',...
            'seriesRLC',...
            'shuntRLC',...
            'Attenuator',...
            'RFantenna',...
            'Receiver',...
            'TxRxAntenna',...
            'lcladder',...
            'Phaseshift',...
            'MixerIMT'};
            self.ElementGalleryCats.('Linear_Elements')=...
            GalleryCategory('Linear Elements');
            self.ElementGalleryCats.('Non_Linear_Elements')=...
            GalleryCategory('Non-Linear Elements');
            ElementGalleryPopup.add(...
            self.ElementGalleryCats.('Non_Linear_Elements'));
            ElementGalleryPopup.add(...
            self.ElementGalleryCats.('Linear_Elements'));
            for i=1:numel(elements)
                if strcmpi(elements{i},'Amplifier')
                    ic=self.AmplifierIcon;
                    self.ElementGalleryItems.('Amplifier')=...
                    GalleryItem('Amplifier',ic);
                    self.ElementGalleryItems.('Amplifier').Description=...
                    'Add amplifier element';
                    self.ElementGalleryItems.('Amplifier').Tag='amplifier';
                elseif strcmpi(elements{i},'Modulator')
                    ic=self.ModulatorIcon;
                    self.ElementGalleryItems.('Modulator')=...
                    GalleryItem('Modulator',ic);
                    self.ElementGalleryItems.('Modulator').Description=...
                    'Add modulator element';
                    self.ElementGalleryItems.('Modulator').Tag='modulator';
                elseif strcmpi(elements{i},'Demodulator')
                    ic=self.DeModulatorIcon;
                    self.ElementGalleryItems.('Demodulator')=...
                    GalleryItem('Demodulator',ic);
                    self.ElementGalleryItems.('Demodulator').Description=...
                    'Add demodulator element';
                    self.ElementGalleryItems.('Demodulator').Tag='demodulator';
                elseif strcmpi(elements{i},'S_Parameters')
                    ic=self.NportIcon;
                    self.ElementGalleryItems.('S_Parameters')=...
                    GalleryItem('S-Parameters',ic);
                    self.ElementGalleryItems.('S_Parameters').Description=...
                    'Add S-Parameters element';
                    self.ElementGalleryItems.('S_Parameters').Tag='s_parameters';
                elseif strcmpi(elements{i},'generic')
                    ic=self.RFelementIcon;
                    self.ElementGalleryItems.('generic')=...
                    GalleryItem('Generic',ic);
                    self.ElementGalleryItems.('generic').Description=...
                    'Add generic element';
                    self.ElementGalleryItems.('generic').Tag='generic';
                elseif strcmpi(elements{i},'filter')
                    ic=self.FilterIcon;
                    self.ElementGalleryItems.('filter')=...
                    GalleryItem('Filter',ic);
                    self.ElementGalleryItems.('filter').Description=...
                    'Add filter element';
                    self.ElementGalleryItems.('filter').Tag='filter';
                elseif strcmpi(elements{i},'txline')
                    ic=self.TxlineIcon;
                    self.ElementGalleryItems.('txline')=...
                    GalleryItem(['Transmission',newline,'Line'],ic);
                    self.ElementGalleryItems.('txline').Description=...
                    'Add transmission line element';
                    self.ElementGalleryItems.('txline').Tag='txline';
                elseif strcmpi(elements{i},'seriesRLC')
                    ic=self.seriesRLCIcon;
                    self.ElementGalleryItems.('seriesRLC')=...
                    GalleryItem('Series RLC',ic);
                    self.ElementGalleryItems.('seriesRLC').Description=...
                    'Add seriesRLC element';
                    self.ElementGalleryItems.('seriesRLC').Tag='seriesRLC';
                elseif strcmpi(elements{i},'shuntRLC')
                    ic=self.shuntRLCIcon;
                    self.ElementGalleryItems.('shuntRLC')=...
                    GalleryItem('Shunt RLC',ic);
                    self.ElementGalleryItems.('shuntRLC').Description=...
                    'Add shuntRLC element';
                    self.ElementGalleryItems.('shuntRLC').Tag='shuntRLC';
                elseif strcmpi(elements{i},'Attenuator')
                    ic=self.AttenuatorIcon;
                    self.ElementGalleryItems.('Attenuator')=...
                    GalleryItem('Attenuator',ic);
                    self.ElementGalleryItems.('Attenuator').Description=...
                    'Add attenuator element';
                    self.ElementGalleryItems.('Attenuator').Tag='attenuator';
                elseif strcmpi(elements{i},'RFantenna')
                    ic=self.antennaIcon;
                    self.ElementGalleryItems.('RFantenna')=GalleryItem('Transmitter',ic);
                    self.ElementGalleryItems.('RFantenna').Description='Add antenna element';
                    self.ElementGalleryItems.('RFantenna').Tag='rfantenna';

                elseif strcmpi(elements{i},'lcladder')
                    ic=self.LCLadderIcon;
                    self.ElementGalleryItems.('lcladder')=GalleryItem('LC Ladder',ic);
                    self.ElementGalleryItems.('lcladder').Description='Add lcladder element';
                    self.ElementGalleryItems.('lcladder').Tag='lcladder';
                elseif strcmpi(elements{i},'Phaseshift')
                    ic=self.PhaseshiftIcon;
                    self.ElementGalleryItems.('Phaseshift')=GalleryItem('Phase Shift',ic);
                    self.ElementGalleryItems.('Phaseshift').Description='Add Phaseshift element';
                    self.ElementGalleryItems.('Phaseshift').Tag='phaseshift';

                elseif strcmpi(elements{i},'Receiver')
                    ic=self.RxAntennaIcon;
                    self.ElementGalleryItems.('Receiver')=GalleryItem('Receiver',ic);
                    self.ElementGalleryItems.('Receiver').Description='Add receiver antenna element';
                    self.ElementGalleryItems.('Receiver').Tag='receiver';

                elseif strcmpi(elements{i},'MixerIMT')
                    ic=self.mixerIMTIcon;
                    self.ElementGalleryItems.('MixerIMT')=...
                    GalleryItem('Mixer IMT',ic);
                    self.ElementGalleryItems.('MixerIMT').Description=...
                    'Add mixerIMT element';
                    self.ElementGalleryItems.('MixerIMT').Tag='MixerIMT';

                elseif strcmpi(elements{i},'TxRxAntenna')
                    ic=self.TxRxAntennaIcon;
                    self.ElementGalleryItems.('TxRxAntenna')=GalleryItem('TxRxAntenna',ic);
                    self.ElementGalleryItems.('TxRxAntenna').Description='Add transmit-receive antenna element';
                    self.ElementGalleryItems.('TxRxAntenna').Tag='TxRxAnt';







                end
                if any(strcmpi(elements{i},{...
                    'Demodulator',...
                    'Modulator',...
                    'Amplifier',...
                    'generic',...
                    'MixerIMT'}))
                    self.ElementGalleryCats.('Non_Linear_Elements').add(...
                    self.ElementGalleryItems.(elements{i}));
                else
                    self.ElementGalleryCats.('Linear_Elements').add(...
                    self.ElementGalleryItems.(elements{i}));
                end
            end
            self.ElementGallery=Gallery(ElementGalleryPopup,'MaxColumnCount',3,'MinColumnCount',2);
            self.ElementGallery.Tag='gallery';
            column.add(self.ElementGallery);
            column=addColumn(section);
            button=Button(['Delete',newline,'Element'],self.TrashIcon);
            self.DeleteBtn=button;
            button.Description='Delete selected element';
            button.Tag='DeleteBtn';
            button.Enabled=false;
            add(column,button)
        end

        function createPlotSection(self)


            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection('Plots');
            section.Tag='Plot';
            create2DPlotSection(self,section);
            column=addColumn(section);
            button=SplitButton(['3D',newline,' Plot'],self.PlotIcon3D);
            self.PlotBtn=button;
            button.Description='Plot Friis results for a frequency range and for all stages';
            button.Tag='PlotBtn';
            column.Tag='Plot';

            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='plot_popup';

            item=ListItemWithPopup('S-Parameters');
            item.Tag='S-parameters';
            item.ShowDescription=false;

            sub_popup=PopupList();

            sub_item=ListItem('S11');
            sub_item.Tag='S11';
            sub_item.ShowDescription=false;
            sub_popup.add(sub_item);

            sub_item=ListItem('S12');
            sub_item.Tag='S12';
            sub_item.ShowDescription=false;
            sub_popup.add(sub_item);

            sub_item=ListItem('S21');
            sub_item.Tag='S21';
            sub_item.ShowDescription=false;
            sub_popup.add(sub_item);

            sub_item=ListItem('S22');
            sub_item.Tag='S22';
            sub_item.ShowDescription=false;
            sub_popup.add(sub_item);
            item.Popup=sub_popup;
            item.Popup.Tag='Sparameters_popup';
            add(popup,item);
            item=ListItem('Output Power - Pout');
            item.Tag='Pout';
            item.ShowDescription=false;
            add(popup,item)
            item=ListItem('Transducer Gain - GainT');
            item.Tag='GainT';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Noise Figure - NF');
            item.Tag='NF';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Output Third-Order Intercept - OIP3');
            item.Tag='OIP3';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Input Third-Order Intercept - IIP3');
            item.Tag='IIP3';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Signal-to-Noise Ratio - SNR');
            item.Tag='SNR';
            item.ShowDescription=false;
            add(popup,item)
            button.Enabled=false;
            add(column,button)
            column=addColumn(section);

            column.Tag='SmithColumn';
            button=Button(['S Parameters',newline,'Plot'],self.SParametersIcon);
            self.SmithBtn=button;
            button.Description=...
            'Plot Smith, Rectangular and Polar plot of S-Parameters upto a particular stage';
            button.Tag='s_Parameters_Plot';
            button.Enabled=false;
            add(column,button)
            createPlotFrequencySection(self,section);
        end

        function createPlotFrequencySection(self,section)


            import matlab.ui.internal.toolstrip.*
            if self.UseAppContainer
                labelColumn=addColumn(section,...
                'Width',65,...
                'HorizontalAlignment','right');
            else
                labelColumn=addColumn(section,...
                'HorizontalAlignment','right');
            end

            self.PlotBandwidthLabel=Label('Plot Bandwidth');
            self.PlotBandwidthLabel.Description=...
            'Bandwidth used for plotting analysis.';
            labelColumn.add(...
            self.PlotBandwidthLabel);
            labelColumn.Tag='PlotFrequencyLabelColumnTag';

            self.PlotResolutionLabel=Label('Resolution');
            self.PlotResolutionLabel.Description=...
            'Number of frequency points used for plotting analysis.';
            labelColumn.add(...
            self.PlotResolutionLabel);
            editColumn=addColumn(section,...
            'Width',rf.internal.apps.budget.SystemParametersSection.Width2);
            editColumn.Tag='PlotFrequencyEditColumnTag';
            self.PlotBandwidthEdit=EditField('');
            self.PlotBandwidthEdit.Tag='PlotBandwidth';
            self.PlotBandwidthEdit.Description='Bandwidth used for plotting analysis.';
            editColumn.add(...
            self.PlotBandwidthEdit);
            self.PlotResolutionEdit=EditField('');
            self.PlotResolutionEdit.Tag='PlotResolution';
            self.PlotResolutionEdit.Description='Number of frequency points used for plotting analysis.';
            editColumn.add(...
            self.PlotResolutionEdit);

            UnitsVal=[{'Hz'};{'kHz'};{'MHz'};{'GHz'};{'THz'}];
            if self.UseAppContainer
                unitsColumn=addColumn(section,...
                'Width',65);
            else
                unitsColumn=addColumn(section);
            end
            unitsColumn.Tag='PlotFrequencyUnitsColumnTag';
            self.PlotBandwidthUnits=DropDown();
            self.PlotBandwidthUnits.replaceAllItems(UnitsVal);
            self.PlotBandwidthUnits.Tag='PlotBandwidthUnits';
            unitsColumn.add(...
            self.PlotBandwidthUnits);
            resUnitsLabel=Label('points');
            unitsColumn.add(resUnitsLabel);
        end

        function create2DPlotSection(self,section)

            import matlab.ui.internal.toolstrip.*
            column=addColumn(section);
            column.Tag='2D-Plot column';
            button=SplitButton(['2D',newline,' Plot'],self.PlotIcon2D);
            self.PlotBtn2D=button;
            button.Description='Plot Friis/Harmonic Balance results at input frequency';
            button.Tag='2DPlotBtn';

            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='2d_plot_popup';

            item=ListItem('Output Power - Pout');
            item.Tag='Pout 2D';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Transducer Gain - GainT');
            item.Tag='GainT 2D';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Noise Figure - NF');
            item.Tag='NF 2D';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Output Third-Order Intercept - OIP3');
            item.Tag='OIP3 2D';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Input Third-Order Intercept - IIP3');
            item.Tag='IIP3 2D';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Signal-to-Noise Ratio - SNR');
            item.Tag='SNR 2D';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem('Output Second-Order Intercept - OIP2');
            item.Tag='OIP2 2D';
            item.ShowDescription=false;
            item.Enabled=false;
            self.OIP22Ditem=item;
            add(popup,item)

            item=ListItem('Input Second-Order Intercept - IIP2');
            item.Tag='IIP2 2D';
            item.ShowDescription=false;
            item.Enabled=false;
            self.IIP22Ditem=item;
            add(popup,item)
            button.Enabled=false;
            add(column,button)
        end

        function createViewSection(self)


            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection('View');
            section.Tag='View';
            column=addColumn(section);
            column.Tag='DeflayoutColumn';
            button=Button(['Default',newline,'Layout'],Icon.LAYOUT_24);
            self.DefaultLayoutBtn=button;
            button.Description='Restore to default layout';
            button.Tag='DefaultLayoutBtn';
            add(column,button)
        end

        function createExportSection(self)



            import matlab.ui.internal.toolstrip.*

            section=self.AnalysisTab.addSection('Export');
            section.CollapsePriority=1;
            section.Tag='Export';
            column=addColumn(section);
            column.Tag='ExportColumn';
            button=SplitButton('Export',Icon.CONFIRM_24);
            self.ExportBtn=button;
            button.Description='Export to MATLAB or Simulink';
            button.Tag='ExportBtn';

            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='export_popup';
            header=PopupListHeader('MATLAB');
            popup.add(header);
            item=ListItem('MATLAB Workspace');
            item.Description='Export rfbudget object to MATLAB workspace';
            item.Tag='MATLAB workspace';
            item.ShowDescription=true;
            add(popup,item)
            item=ListItem('MATLAB Script');
            item.Description='Generate MATLAB script';
            item.Tag='Generate MATLAB script';
            item.ShowDescription=true;
            add(popup,item)

            v=[ver('Simulink'),ver('rfblks'),ver('dsp')];
            installedProducts={v(:).Name};
            haveSimulink=builtin('license','test','SIMULINK')&&...
            any(strcmp('Simulink',installedProducts));
            haveRFBlockset=builtin('license','test','RF_Blockset')&&...
            any(strcmp('RF Blockset',installedProducts));
            if haveSimulink&&haveRFBlockset
                header=PopupListHeader('Simulink');
                popup.add(header);
                item=ListItem('RF Blockset');
                item.Tag='RF Blockset';
                item.Description='Export to RF Blockset';
                item.ShowDescription=true;
                add(popup,item)
                haveDST=builtin('license','test','Signal_Blocks')&&...
                any(strcmp('DSP System Toolbox',installedProducts));
                if haveDST
                    item=ListItem('Measurement Testbench');
                    item.Tag='Measurement testbench';
                    item.Description='Export to testbench in RF Blockset';
                    item.ShowDescription=true;
                    add(popup,item)
                    self.TestbenchItem=item;
                end

                item=ListItem('RF System');
                item.Description='Export to rfsystem object';
                item.Tag='rfsystem object';
                item.ShowDescription=true;
                add(popup,item)
            end
            button.Enabled=false;
            add(column,button)
        end

        function removeViewTab(self)


            if self.UseAppContainer
            else
                g=self.ToolGroup.Peer.getWrappedComponent;
                g.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,...
                false);
            end
        end

        function enableDocking(self)


            if self.UseAppContainer
            else
                g=self.ToolGroup.Peer.getWrappedComponent;
                g.putGroupProperty(...
                com.mathworks.widgets.desk.DTGroupProperty.DOCKABLE,true)%#ok<*JAPIMATHWORKS>
            end
        end

        function enableIP2(self,val)

            if self.AutoUpdateCheckbox.Value
                val=true;
            end
            self.OIP22Ditem.Enabled=val;
            self.IIP22Ditem.Enabled=val;
            if~val
            end
        end
        function enableInputPower(self,value)
            self.SystemParameters.AvailableInputPowerEdit.Enabled=value;
            self.SystemParameters.AvailableInputPowerLabel.Enabled=value;
            self.SystemParameters.AvailableInputPowerUnits.Enabled=value;
        end
        function enableTestbench(self,value)

            self.TestbenchItem.Enabled=value;
            if~value
                self.TestbenchItem.Description="Export to testbench (not supported with antenna element)";
            else
                self.TestbenchItem.Description="Export to testbench in RF Blockset";
            end
        end
    end
end







