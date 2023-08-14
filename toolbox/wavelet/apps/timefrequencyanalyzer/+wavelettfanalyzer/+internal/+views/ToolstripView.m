classdef ToolstripView<handle




    properties(Constant)
        ColumnWidth=75;
        QFactorWidth=100;
    end

    properties(Access=private)
AnalysisController
ExportController
ImportController
NewSessionController
TableController
DialogFigure

AnalyzerTab

NewSessionButton
ImportButton

DuplicateButton
DeleteButton

WorkInSamplesButton
SampleRateButton
SampleRateEditField
HzLabel

PreferencesButton
SeparatePlotsCheckBox
BoundaryLineCheckBox
ShadeRegionCheckBox


AnalyzerExportButton
AnalyzerExportScalogram
AnalyzerGenerateScript

ScalogramTab

WaveletDropDown
WaveletLabel

VoicesEditField
VoicesLabel

MinEditField
MinLabel
MaxEditField
MaxLabel

SymmetricButton
PeriodicButton

SymmetryEditField
SymmetryLabel
TimeBandwidthProductEditField
TimeBandwidthProductLabel

ResetButton

ComputeButton

ScalogramExportButton
ScalogramExportScalogram
ScalogramGenerateScript
    end

    methods(Hidden)

        function this=ToolstripView(app,mainController)
            this.AnalysisController=mainController.getAnalysisController();
            this.ExportController=mainController.getExportController();
            this.ImportController=mainController.getImportController();
            this.NewSessionController=mainController.getNewSessionController();
            this.TableController=mainController.getTableController();
            this.addToolstrip(app);
            this.cb_ResetToolstrip();
            this.setPreferences();
            this.subscribeToControllerEvents();
        end
    end

    methods(Access=private)
        function subscribeToControllerEvents(this)
            addlistener(this.AnalysisController,"UpdateToolstripTimeSettings",@(~,args)this.cb_UpdateToolstripTimeSettings(args));
            addlistener(this.AnalysisController,"UpdateToolstripCWTParameters",@(~,args)this.cb_UpdateToolstripCWTParameters(args));
            addlistener(this.AnalysisController,"UpdateMorseParamSettings",@(~,args)this.cb_UpdateMorseParams(args));
            addlistener(this.AnalysisController,"UpdateFrequencyLimits",@(~,args)this.cb_UpdateFrequencyLimits(args));
            addlistener(this.AnalysisController,"EnableComputeButton",@(~,~)this.cb_EnableComputeButton());
            addlistener(this.AnalysisController,"DisableComputeButton",@(~,~)this.cb_DisableComputeButton());
            addlistener(this.AnalysisController,"RevertSampleRate",@(~,args)this.cb_RevertSampleRate(args));
            addlistener(this.AnalysisController,"RevertVoices",@(~,args)this.cb_RevertVoices(args));
            addlistener(this.AnalysisController,"RevertMinFrequency",@(~,args)this.cb_RevertMinFrequency(args));
            addlistener(this.AnalysisController,"RevertMaxFrequency",@(~,args)this.cb_RevertMaxFrequency(args));
            addlistener(this.AnalysisController,"RevertSymmetry",@(~,args)this.cb_RevertSymmetry(args));
            addlistener(this.AnalysisController,"RevertTimeBandwidthProduct",@(~,args)this.cb_RevertTimeBandwidthProduct(args));
            addlistener(this.ImportController,"UpdateToolstrip",@(~,args)this.cb_UpdateToolstrip(args));
            addlistener(this.NewSessionController,"ClearToolstrip",@(~,~)this.cb_ResetToolstrip());
            addlistener(this.TableController,"UpdateToolstrip",@(~,args)this.cb_UpdateToolstrip(args));
            addlistener(this.TableController,"ClearToolstrip",@(~,~)this.cb_ResetToolstrip());
        end


        function cb_ResetToolstrip(this)
            this.enableAnalyzerTab(false);
            this.enableScalogramTab(false);
        end

        function cb_UpdateToolstrip(this,args)
            this.enableAnalyzerTab(true);
            this.enableScalogramTab(true);
            this.updateTimeSettings(args.Data);
            this.updateCWTParameters(args.Data);
        end

        function cb_UpdateToolstripTimeSettings(this,args)
            this.updateTimeSettings(args.Data);
        end

        function cb_UpdateToolstripCWTParameters(this,args)
            this.updateCWTParameters(args.Data);
        end

        function cb_UpdateMorseParams(this,args)
            isMorse=strcmp(args.Data.waveletName,"morse");
            this.updateMorseParameterSettings(isMorse,[3,60]);
        end

        function cb_UpdateFrequencyLimits(this,args)
            freqLims=args.Data.freqLims;
            this.MinEditField.Value=string(freqLims(1));
            this.MaxEditField.Value=string(freqLims(2));
        end

        function cb_EnableComputeButton(this)
            this.ComputeButton.Enabled=true;
        end

        function cb_DisableComputeButton(this)
            this.ComputeButton.Enabled=false;
        end

        function cb_RevertSampleRate(this,args)
            this.SampleRateEditField.Value=args.Data.value;
        end

        function cb_RevertVoices(this,args)
            this.VoicesEditField.Value=args.Data.value;
        end

        function cb_RevertMinFrequency(this,args)
            this.MinEditField.Value=args.Data.value;
        end

        function cb_RevertMaxFrequency(this,args)
            this.MaxEditField.Value=args.Data.value;
        end

        function cb_RevertSymmetry(this,args)
            this.SymmetryEditField.Value=args.Data.value;
        end

        function cb_RevertTimeBandwidthProduct(this,args)
            this.TimeBandwidthProductEditField.Value=args.Data.value;
        end

        function cb_ShowHelp(this)
            mapRoot=fullfile(docroot,"/wavelet/","wavelet.map");
            helpview(mapRoot,"wavelettfanalyzer_app");
        end


        function params=getParams(this)
            switch this.WaveletDropDown.SelectedIndex
            case 1
                params.waveletName="morse";
            case 2
                params.waveletName="amor";
            case 3
                params.waveletName="bump";
            end
            timeBandwidthProduct=str2double(this.TimeBandwidthProductEditField.Value);
            symmetry=str2double(this.SymmetryEditField.Value);
            params.morseParams=[symmetry,timeBandwidthProduct];
            params.voices=str2double(this.VoicesEditField.Value);
            params.extendSignal=this.SymmetricButton.Value;
            minFrequency=str2double(this.MinEditField.Value);
            maxFrequency=str2double(this.MaxEditField.Value);
            params.freqLims=[minFrequency,maxFrequency];
        end

        function setPreferences(this)
            this.SeparatePlotsCheckBox.Value=getpref("wavelettfanalyzer","separatePlots");
            this.BoundaryLineCheckBox.Value=getpref("wavelettfanalyzer","boundaryLine");
            this.ShadeRegionCheckBox.Value=getpref("wavelettfanalyzer","shadeRegion");
        end

        function enableAnalyzerTab(this,enabled)
            this.NewSessionButton.Enabled=enabled;
            this.DuplicateButton.Enabled=enabled;
            this.DeleteButton.Enabled=enabled;
            this.WorkInSamplesButton.Enabled=enabled;
            this.SampleRateButton.Enabled=enabled;
            this.SampleRateEditField.Enabled=enabled;
            this.HzLabel.Enabled=enabled;
            this.AnalyzerExportButton.Enabled=enabled;


            if~enabled
                this.WorkInSamplesButton.Value=true;
                this.SampleRateButton.Value=false;
                this.SampleRateEditField.Value="";
            end
        end

        function enableScalogramTab(this,enabled)
            this.WaveletDropDown.Enabled=enabled;
            this.VoicesEditField.Enabled=enabled;
            this.MinEditField.Enabled=enabled;
            this.MaxEditField.Enabled=enabled;
            this.SymmetricButton.Enabled=enabled;
            this.PeriodicButton.Enabled=enabled;
            this.SymmetryEditField.Enabled=enabled;
            this.TimeBandwidthProductEditField.Enabled=enabled;
            this.ResetButton.Enabled=enabled;
            this.ComputeButton.Enabled=false;
            this.ScalogramExportButton.Enabled=enabled;

            this.WaveletLabel.Enabled=enabled;
            this.VoicesLabel.Enabled=enabled;
            this.MinLabel.Enabled=enabled;
            this.MaxLabel.Enabled=enabled;
            this.TimeBandwidthProductLabel.Enabled=enabled;
            this.SymmetryLabel.Enabled=enabled;


            if~enabled
                this.WaveletDropDown.Value="";
                this.VoicesEditField.Value="10";
                this.SymmetricButton.Value=true;
                this.PeriodicButton.Value=false;
                this.MinEditField.Value="";
                this.MaxEditField.Value="";
                this.TimeBandwidthProductEditField.Value="";
                this.SymmetryEditField.Value="";
            end
        end

        function updateTimeSettings(this,args)
            isTimetable=args.isTimetable;
            isNormFreq=args.isNormFreq;
            sampleRate=args.sampleRate;

            if isTimetable
                this.WorkInSamplesButton.Value=false;
                this.SampleRateButton.Value=true;
                this.SampleRateEditField.Value=string(sampleRate);

                this.WorkInSamplesButton.Enabled=false;
                this.SampleRateButton.Enabled=false;
                this.SampleRateEditField.Enabled=false;
                this.HzLabel.Enabled=false;

                this.SampleRateEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:sampleRateEditFieldTimetableDesc")));
            else
                this.WorkInSamplesButton.Value=isNormFreq;
                this.SampleRateButton.Value=~isNormFreq;

                this.WorkInSamplesButton.Enabled=true;
                this.SampleRateButton.Enabled=true;
                this.SampleRateEditField.Enabled=~isNormFreq;
                this.HzLabel.Enabled=~isNormFreq;

                this.SampleRateEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:sampleRateEditFieldDesc")));

                if~isNormFreq
                    this.SampleRateEditField.Value=string(sampleRate);
                else
                    this.SampleRateEditField.Value="";
                end
            end
        end

        function updateMorseParameterSettings(this,enabled,morseParams)
            this.TimeBandwidthProductLabel.Enabled=enabled;
            this.SymmetryLabel.Enabled=enabled;
            this.TimeBandwidthProductEditField.Enabled=enabled;
            this.SymmetryEditField.Enabled=enabled;

            if enabled
                this.TimeBandwidthProductEditField.Value=string(morseParams(2));
                this.SymmetryEditField.Value=string(morseParams(1));
            else
                this.TimeBandwidthProductEditField.Value="";
                this.SymmetryEditField.Value="";
            end
        end

        function updateCWTParameters(this,args)
            switch args.waveletName
            case "morse"
                this.WaveletDropDown.SelectedIndex=1;
            case "amor"
                this.WaveletDropDown.SelectedIndex=2;
            case "bump"
                this.WaveletDropDown.SelectedIndex=3;
            end
            this.VoicesEditField.Value=string(args.voices);
            this.SymmetricButton.Value=args.extendSignal;
            this.PeriodicButton.Value=~args.extendSignal;
            this.MinEditField.Value=string(args.freqLims(1));
            this.MaxEditField.Value=string(args.freqLims(2));
            isMorse=strcmp(args.waveletName,"morse");
            this.updateMorseParameterSettings(isMorse,args.morseParams)
        end

        function addToolstrip(this,app)

            import matlab.ui.internal.toolstrip.*;

            helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            helpButton.Tag="helpButton";
            helpButton.ButtonPushedFcn=@(~,~)this.cb_ShowHelp();
            app.add(helpButton);

            tabGroup=TabGroup();
            tabGroup.Tag="tabGroup";

            this.AnalyzerTab=Tab(string(getString(message("wavelet_tfanalyzer:toolstrip:analyzerTabTitle"))));
            this.AnalyzerTab.Tag="analyzerTab";
            tabGroup.add(this.AnalyzerTab);

            this.addFileSection();
            this.addSelectedSection();
            this.addTimeSection();
            this.addOptionsSection();
            this.addAnalyzerExportSection();

            this.ScalogramTab=Tab(string(getString(message("wavelet_tfanalyzer:toolstrip:scalogramTabTitle"))));
            this.ScalogramTab.Tag="scalogramTab";
            tabGroup.add(this.ScalogramTab);


            this.addWaveletSection();
            this.addMorseParametersSection();
            this.addQFactorSection();
            this.addExtendSignalSection();
            this.addFrequencyLimitsSection();
            this.addResetSection();
            this.addComputeSection();
            this.addScalogramExportSection();

            app.add(tabGroup);
        end

        function addFileSection(this)
            import matlab.ui.internal.toolstrip.*;
            fileSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:fileSectionTitle"))));
            fileSection.Tag="fileSection";
            this.AnalyzerTab.add(fileSection);
            fileColumn1=Column();
            fileSection.add(fileColumn1);
            fileColumn2=Column();
            fileSection.add(fileColumn2);


            this.NewSessionButton=Button(string(getString(message("wavelet_tfanalyzer:toolstrip:newSessionButton"))),Icon.NEW_24);
            this.NewSessionButton.Tag="newSessionButton";
            this.NewSessionButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:newSessionButtonDesc")));
            this.NewSessionButton.ButtonPushedFcn=@(~,~)this.NewSessionController.cb_StartNewSession(true);
            fileColumn1.add(this.NewSessionButton);


            this.ImportButton=Button(string(getString(message("wavelet_tfanalyzer:toolstrip:importButton"))),Icon.IMPORT_24);
            this.ImportButton.Tag="importButton";
            this.ImportButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:importButtonDesc")));
            this.ImportButton.ButtonPushedFcn=@(~,~)this.ImportController.cb_OpenImportDialog();
            fileColumn2.add(this.ImportButton);
        end

        function addSelectedSection(this)
            import matlab.ui.internal.toolstrip.*;
            selectedSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:selectedSectionTitle"))));
            selectedSection.Tag="selectedSection";
            this.AnalyzerTab.add(selectedSection);
            selectedColumn1=Column();
            selectedSection.add(selectedColumn1);


            this.DuplicateButton=Button(string(getString(message("wavelet_tfanalyzer:toolstrip:duplicateButton"))),Icon.COPY_16);
            this.DuplicateButton.Tag="duplicateButton";
            this.DuplicateButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:duplicateButtonDesc")));
            this.DuplicateButton.ButtonPushedFcn=@(~,~)this.AnalysisController.cb_DuplicateSignal();
            selectedColumn1.add(this.DuplicateButton);


            this.DeleteButton=Button(string(getString(message("wavelet_tfanalyzer:toolstrip:deleteButton"))),Icon.DELETE_16);
            this.DeleteButton.Tag="deleteButton";
            this.DeleteButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:deleteButtonDesc")));
            this.DeleteButton.ButtonPushedFcn=@(~,~)this.AnalysisController.cb_DeleteSignal();
            selectedColumn1.add(this.DeleteButton);
        end

        function addTimeSection(this)
            import matlab.ui.internal.toolstrip.*;
            timeSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:timeSectionTitle"))));
            timeSection.Tag="timeSection";
            this.AnalyzerTab.add(timeSection);
            timeColumn1=Column();
            timeSection.add(timeColumn1);
            timeColumn2=Column("Width",this.ColumnWidth);
            timeSection.add(timeColumn2);
            timeColumn3=Column();
            timeSection.add(timeColumn3);


            buttonGroup=ButtonGroup();
            this.WorkInSamplesButton=RadioButton(buttonGroup,string(getString(message("wavelet_tfanalyzer:toolstrip:workInSamplesButton"))));
            this.WorkInSamplesButton.Tag="workInSamplesButton";
            this.WorkInSamplesButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:workInSamplesButtonDesc")));
            this.WorkInSamplesButton.ValueChangedFcn=@(~,args)this.AnalysisController.cb_TimeSettingsButtonChanged(args,"WorkInSamples",...
            this.SampleRateEditField.Value,this.getParams());
            timeColumn1.add(this.WorkInSamplesButton);

            this.SampleRateButton=RadioButton(buttonGroup,string(getString(message("wavelet_tfanalyzer:toolstrip:sampleRateButton"))));
            this.SampleRateButton.Tag="sampleRateButton";
            this.SampleRateButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:sampleRateButtonDesc")));
            this.SampleRateButton.ValueChangedFcn=@(~,args)this.AnalysisController.cb_TimeSettingsButtonChanged(args,"SampleRate","1",this.getParams());
            timeColumn1.add(this.SampleRateButton);


            this.SampleRateEditField=EditField();
            this.SampleRateEditField.Tag="sampleRateEditField";
            this.SampleRateEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:sampleRateEditFieldDesc")));
            this.SampleRateEditField.ValueChangedFcn=@(~,args)this.AnalysisController.cb_SampleRateChanged(args,this.getParams());
            timeColumn2.addEmptyControl();
            timeColumn2.add(this.SampleRateEditField);


            this.HzLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:hzLabel"))));
            this.HzLabel.Tag="hzLabel";
            timeColumn3.addEmptyControl();
            timeColumn3.add(this.HzLabel);
        end

        function addOptionsSection(this)
            import matlab.ui.internal.toolstrip.*;
            optionsSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:optionsSectionTitle"))));
            optionsSection.Tag="optionsSection";
            this.AnalyzerTab.add(optionsSection);
            optionsColumn1=Column();
            optionsSection.add(optionsColumn1);


            this.PreferencesButton=DropDownButton(string(getString(message("wavelet_tfanalyzer:toolstrip:preferencesButton"))),Icon.SETTINGS_24);
            this.PreferencesButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:preferencesButtonDesc")));
            this.PreferencesButton.Tag="preferencesButton";
            optionsColumn1.add(this.PreferencesButton);

            preferencesDropDown=PopupList();
            scalogramHeader=PopupListHeader("Scalogram");

            this.BoundaryLineCheckBox=ListItemWithCheckBox(string(getString(message("wavelet_tfanalyzer:toolstrip:boundaryLine"))));
            this.BoundaryLineCheckBox.Tag="boundaryLineCheckBox";
            this.BoundaryLineCheckBox.ValueChangedFcn=@(~,args)this.AnalysisController.cb_BoundaryLineChanged(args);

            this.ShadeRegionCheckBox=ListItemWithCheckBox(string(getString(message("wavelet_tfanalyzer:toolstrip:shadeRegion"))));
            this.ShadeRegionCheckBox.Tag="shadeRegionCheckBox";
            this.ShadeRegionCheckBox.ValueChangedFcn=@(~,args)this.AnalysisController.cb_ShadeRegionChanged(args);

            this.SeparatePlotsCheckBox=ListItemWithCheckBox(string(getString(message("wavelet_tfanalyzer:toolstrip:separatePlots"))));
            this.SeparatePlotsCheckBox.Tag="separatePlotCheckBox";
            this.SeparatePlotsCheckBox.ValueChangedFcn=@(~,args)this.AnalysisController.cb_SeparatePlotsChanged(args);

            preferencesDropDown.add(scalogramHeader);
            preferencesDropDown.add(this.BoundaryLineCheckBox);
            preferencesDropDown.add(this.ShadeRegionCheckBox);
            preferencesDropDown.add(this.SeparatePlotsCheckBox);
            this.PreferencesButton.Popup=preferencesDropDown;
        end

        function addAnalyzerExportSection(this)
            import matlab.ui.internal.toolstrip.*;
            exportSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:exportSectionTitle"))));
            exportSection.Tag="exportSection";
            this.AnalyzerTab.add(exportSection);
            exportColumn1=Column();
            exportSection.add(exportColumn1);


            this.AnalyzerExportButton=SplitButton(string(getString(message("wavelet_tfanalyzer:toolstrip:exportButton"))),Icon.CONFIRM_24);
            this.AnalyzerExportButton.Tag="analyzerExportButton";
            this.AnalyzerExportButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:exportButtonDesc")));
            this.AnalyzerExportButton.ButtonPushedFcn=@(~,~)this.ExportController.cb_ExportScalogram(true);
            exportColumn1.add(this.AnalyzerExportButton);


            this.AnalyzerExportScalogram=ListItem(string(getString(message("wavelet_tfanalyzer:toolstrip:exportScalogram"))),Icon.EXPORT_16);
            this.AnalyzerExportScalogram.Tag="analyzerExportScalogram";
            this.AnalyzerExportScalogram.ItemPushedFcn=@(~,~)this.ExportController.cb_ExportScalogram(true);

            this.AnalyzerGenerateScript=ListItem(string(getString(message("wavelet_tfanalyzer:toolstrip:generateScript"))),Icon.MATLAB_16);
            this.AnalyzerGenerateScript.Tag="analyzerGenerateScript";
            this.AnalyzerGenerateScript.ItemPushedFcn=@(~,~)this.ExportController.cb_GenerateScript();

            exportDropDown=PopupList();
            exportDropDown.add(this.AnalyzerExportScalogram);
            exportDropDown.add(this.AnalyzerGenerateScript);
            this.AnalyzerExportButton.Popup=exportDropDown;
        end

        function addWaveletSection(this)
            import matlab.ui.internal.toolstrip.*;
            waveletSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:waveletSectionTitle"))));
            waveletSection.Tag="waveletSection";
            this.ScalogramTab.add(waveletSection);
            waveletColumn1=Column("Width",this.ColumnWidth);
            waveletSection.add(waveletColumn1);


            this.WaveletLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:waveletLabel"))));
            this.WaveletLabel.Tag="waveletLabel";
            waveletColumn1.add(this.WaveletLabel);


            values=["Morse";"Morlet";"bump"];
            this.WaveletDropDown=DropDown(values);
            this.WaveletDropDown.Tag="waveletDropDown";
            this.WaveletDropDown.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:waveletDropDownDesc")));
            this.WaveletDropDown.ValueChangedFcn=@(~,args)this.AnalysisController.cb_WaveletChanged(args,this.getParams());
            waveletColumn1.add(this.WaveletDropDown);
        end

        function addQFactorSection(this)
            import matlab.ui.internal.toolstrip.*;
            qFactorSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:qFactorSectionTitle"))));
            qFactorSection.Tag="qFactorSection";
            this.ScalogramTab.add(qFactorSection);
            qFactorColumn1=Column("Width",this.QFactorWidth);
            qFactorSection.add(qFactorColumn1);


            this.VoicesLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:voicesLabel"))));
            this.VoicesLabel.Tag="voicesLabel";
            qFactorColumn1.add(this.VoicesLabel);


            this.VoicesEditField=EditField();
            this.VoicesEditField.Tag="voicesEditField";
            this.VoicesEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:voicesEditFieldDesc")));
            this.VoicesEditField.ValueChangedFcn=@(~,args)this.AnalysisController.cb_VoicesChanged(args,this.getParams());
            qFactorColumn1.add(this.VoicesEditField)
        end

        function addFrequencyLimitsSection(this)
            import matlab.ui.internal.toolstrip.*;
            frequencyLimitsSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:frequencyLimitsSectionTitle"))));
            frequencyLimitsSection.Tag="frequencyLimitsSection";
            this.ScalogramTab.add(frequencyLimitsSection);
            frequencyLimitsColumn1=Column();
            frequencyLimitsSection.add(frequencyLimitsColumn1);
            frequencyLimitsColumn2=Column("Width",this.ColumnWidth);
            frequencyLimitsSection.add(frequencyLimitsColumn2);


            this.MinLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:minLabel"))));
            this.MinLabel.Tag="minLabel";
            frequencyLimitsColumn1.add(this.MinLabel);
            this.MaxLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:maxLabel"))));
            this.MaxLabel.Tag="maxLabel";
            frequencyLimitsColumn1.add(this.MaxLabel);


            this.MinEditField=EditField();
            this.MinEditField.Tag="minEditField";
            this.MinEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:minEditFieldDesc")));
            this.MinEditField.ValueChangedFcn=@(~,args)this.AnalysisController.cb_FrequencyLimitsChanged(args,"min",this.getParams());
            frequencyLimitsColumn2.add(this.MinEditField);

            this.MaxEditField=EditField();
            this.MaxEditField.Tag="maxEditField";
            this.MaxEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:maxEditFieldDesc")));
            this.MaxEditField.ValueChangedFcn=@(~,args)this.AnalysisController.cb_FrequencyLimitsChanged(args,"max",this.getParams());
            frequencyLimitsColumn2.add(this.MaxEditField);
        end

        function addExtendSignalSection(this)
            import matlab.ui.internal.toolstrip.*;
            extendSignalSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:extendSignalSectionTitle"))));
            extendSignalSection.Tag="extendSignalSection";
            this.ScalogramTab.add(extendSignalSection);
            extendSignalColumn1=Column();
            extendSignalSection.add(extendSignalColumn1);


            buttonGroup=ButtonGroup();
            this.SymmetricButton=RadioButton(buttonGroup,string(getString(message("wavelet_tfanalyzer:toolstrip:symmetricButton"))));
            this.SymmetricButton.Tag="symmetricButton";
            this.SymmetricButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:symmetricButtonDesc")));
            this.SymmetricButton.ValueChangedFcn=@(~,~)this.AnalysisController.cb_ExtendSignalChanged();
            extendSignalColumn1.add(this.SymmetricButton);

            this.PeriodicButton=RadioButton(buttonGroup,string(getString(message("wavelet_tfanalyzer:toolstrip:periodicButton"))));
            this.PeriodicButton.Tag="periodicButton";
            this.PeriodicButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:periodicButtonDesc")));
            this.PeriodicButton.ValueChangedFcn=@(~,~)this.AnalysisController.cb_ExtendSignalChanged();
            extendSignalColumn1.add(this.PeriodicButton);
        end

        function addMorseParametersSection(this)
            import matlab.ui.internal.toolstrip.*;
            morseParametersSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:morseParametersSectionTitle"))));
            morseParametersSection.Tag="morseParametersSection";
            this.ScalogramTab.add(morseParametersSection);
            morseParametersColumn1=Column();
            morseParametersSection.add(morseParametersColumn1);
            morseParametersColumn2=Column("Width",this.ColumnWidth);
            morseParametersSection.add(morseParametersColumn2);


            this.TimeBandwidthProductLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:timeBandwidthProductLabel"))));
            this.TimeBandwidthProductLabel.Tag="timeBandwidthProductLabel";
            morseParametersColumn1.add(this.TimeBandwidthProductLabel);
            this.SymmetryLabel=Label(string(getString(message("wavelet_tfanalyzer:toolstrip:symmetryLabel"))));
            this.SymmetryLabel.Tag="symmetryLabel";
            morseParametersColumn1.add(this.SymmetryLabel);


            this.TimeBandwidthProductEditField=EditField();
            this.TimeBandwidthProductEditField.Tag="timeBandwidthProductEditField";
            this.TimeBandwidthProductEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:timeBandwidthProductEditFieldDesc")));
            this.TimeBandwidthProductEditField.ValueChangedFcn=@(~,args)this.AnalysisController.cb_TimeBandwidthProductChanged(args,this.getParams());
            morseParametersColumn2.add(this.TimeBandwidthProductEditField);

            this.SymmetryEditField=EditField();
            this.SymmetryEditField.Tag="symmetryEditField";
            this.SymmetryEditField.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:symmetryEditFieldDesc")));
            this.SymmetryEditField.ValueChangedFcn=@(~,args)this.AnalysisController.cb_SymmetryChanged(args,this.getParams());
            morseParametersColumn2.add(this.SymmetryEditField);
        end

        function addResetSection(this)
            import matlab.ui.internal.toolstrip.*;
            resetSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:resetSectionTitle"))));
            resetSection.Tag="resetSection";
            this.ScalogramTab.add(resetSection);
            resetColumn1=Column();
            resetSection.add(resetColumn1);


            this.ResetButton=Button(string(getString(message("wavelet_tfanalyzer:toolstrip:resetButton"))),Icon.RESTORE_24);
            this.ResetButton.Tag="resetButton";
            this.ResetButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:resetButtonDesc")));
            this.ResetButton.ButtonPushedFcn=@(~,~)this.AnalysisController.cb_ResetParameters();
            resetColumn1.add(this.ResetButton);
        end

        function addComputeSection(this)
            import matlab.ui.internal.toolstrip.*;
            computeSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:computeSectionTitle"))));
            computeSection.Tag="computeSection";
            this.ScalogramTab.add(computeSection);
            computeColumn1=Column();
            computeSection.add(computeColumn1);


            this.ComputeButton=Button(string(getString(message("wavelet_tfanalyzer:toolstrip:computeButton"))),Icon.RUN_24);
            this.ComputeButton.Tag="computeButton";
            this.ComputeButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:computeButtonDesc")));
            this.ComputeButton.ButtonPushedFcn=@(~,~)this.AnalysisController.cb_UpdateParameters(this.getParams());
            computeColumn1.add(this.ComputeButton);
        end

        function addScalogramExportSection(this)
            import matlab.ui.internal.toolstrip.*;
            exportSection=Section(string(getString(message("wavelet_tfanalyzer:toolstrip:exportSectionTitle"))));
            exportSection.Tag="exportSection";
            this.ScalogramTab.add(exportSection);
            exportColumn1=Column();
            exportSection.add(exportColumn1);


            this.ScalogramExportButton=SplitButton(string(getString(message("wavelet_tfanalyzer:toolstrip:exportButton"))),Icon.CONFIRM_24);
            this.ScalogramExportButton.Tag="scalogramExportButton";
            this.ScalogramExportButton.Description=string(getString(message("wavelet_tfanalyzer:toolstrip:exportButtonDesc")));
            this.ScalogramExportButton.ButtonPushedFcn=@(~,~)this.ExportController.cb_ExportScalogram(true);
            exportColumn1.add(this.ScalogramExportButton);


            this.ScalogramExportScalogram=ListItem(string(getString(message("wavelet_tfanalyzer:toolstrip:exportScalogram"))),Icon.EXPORT_16);
            this.ScalogramExportScalogram.Tag="scalogramExportScalogram";
            this.ScalogramExportScalogram.ItemPushedFcn=@(~,~)this.ExportController.cb_ExportScalogram(true);

            this.ScalogramGenerateScript=ListItem(string(getString(message("wavelet_tfanalyzer:toolstrip:generateScript"))),Icon.MATLAB_16);
            this.ScalogramGenerateScript.Tag="scalogramGenerateScript";
            this.ScalogramGenerateScript.ItemPushedFcn=@(~,~)this.ExportController.cb_GenerateScript();

            exportDropDown=PopupList();
            exportDropDown.add(this.ScalogramExportScalogram);
            exportDropDown.add(this.ScalogramGenerateScript);
            this.ScalogramExportButton.Popup=exportDropDown;
        end
    end
end
