classdef AntennaAnalysisTab<handle




    properties
AnalysisTab
FrequencySection
MeshSection
VectorAnalysis
ScalarAnalysis
UpdatePlots
OptimizerBtn
Settings
AnalysisExport
        UNITS=[{'Hz'};{'kHz'};{'MHz'};{'GHz'};{'THz'}];


        AnalysisEnableState=true;

        AnalysisIconPath=fullfile(matlabroot,'toolbox','shared','em_cad','+em',...
        '+internal','+pcbDesigner','+src');
    end

    properties(Dependent=true)
PlotFrequency
FrequencyRange
    end
    methods
        function self=AntennaAnalysisTab(tabGroupParent)
            if nargin==0
                return;
            end
            self.createAnalysisTab(tabGroupParent);
            self.addFrequencySection();
            self.addMeshSection();
            self.addVectorAnalysisSection();
            self.addScalarAnalysisSection();
            self.addSettingsSection();
            self.addUpdatePlotsSection();
            self.addOptimizerSection();
            self.addAnalysisExportSection()
        end

        function val=get.PlotFrequency(self)
            val=str2num(self.FrequencySection.PlotFrequencyEditField.Value);
            val=val*getValForUnits(self,self.FrequencySection.PlotFrequencyUnitDropdown.Value);
        end

        function val=get.FrequencyRange(self)
            val=str2num(self.FrequencySection.FrequencyRangeEditField.Value);
            val=val.*getValForUnits(self,self.FrequencySection.FrequencyRangeUnitDropdown.Value);
        end

        function set.PlotFrequency(self,val)
            if isempty(val)
                self.FrequencySection.PlotFrequencyEditField.Value='';
            else
                try
                    if all(val/1000<1)
                        self.FrequencySection.PlotFrequencyEditField.Value=mat2str(val);
                        self.FrequencySection.PlotFrequencyUnitDropdown.Value='Hz';
                    elseif all(val/1e6<1)
                        self.FrequencySection.PlotFrequencyEditField.Value=mat2str(val/1000);
                        self.FrequencySection.PlotFrequencyUnitDropdown.Value='kHz';
                    elseif all(val/1e9<1)
                        self.FrequencySection.PlotFrequencyEditField.Value=mat2str(val/1e6);
                        self.FrequencySection.PlotFrequencyUnitDropdown.Value='MHz';
                    elseif all(val/1e12<1)
                        self.FrequencySection.PlotFrequencyEditField.Value=mat2str(val/1e9);
                        self.FrequencySection.PlotFrequencyUnitDropdown.Value='GHz';
                    else
                        self.FrequencySection.PlotFrequencyEditField.Value=mat2str(val/1e12);
                        self.FrequencySection.PlotFrequencyUnitDropdown.Value='THz';
                    end
                catch me
                end
                frequencyChanged(self);
            end

        end

        function set.FrequencyRange(self,val)
            if isempty(val)
                self.FrequencySection.FrequencyRangeEditField.Value='';
            else
                if all(val/1000<1)
                    self.FrequencySection.FrequencyRangeEditField.Value=mat2str(val);
                    self.FrequencySection.FrequencyRangeUnitDropdown.Value='Hz';
                elseif all(val/1e6<1)
                    self.FrequencySection.FrequencyRangeEditField.Value=mat2str(val/1000);
                    self.FrequencySection.FrequencyRangeUnitDropdown.Value='kHz';
                elseif all(val/1e9<1)
                    self.FrequencySection.FrequencyRangeEditField.Value=mat2str(val/1e6);
                    self.FrequencySection.FrequencyRangeUnitDropdown.Value='MHz';
                elseif all(val/1e12<1)
                    self.FrequencySection.FrequencyRangeEditField.Value=mat2str(val/1e9);
                    self.FrequencySection.FrequencyRangeUnitDropdown.Value='GHz';
                else
                    self.FrequencySection.FrequencyRangeEditField.Value=mat2str(val/1e12);
                    self.FrequencySection.FrequencyRangeUnitDropdown.Value='THz';
                end
                frequencyChanged(self);
            end
        end

        function createAnalysisTab(self,tabGroupParent)
            import matlab.ui.internal.toolstrip.*
            tab=Tab("Analysis");
            tab.Tag="AnalysisTab";
            tabGroupParent.add(tab);
            self.AnalysisTab=tab;
        end

        function deleteAnalysisTab(self)
            self.AnalysisTab.delete;
        end

        function val=getValForUnits(self,units)

            switch units
            case 'Hz'
                val=1;
            case 'kHz'
                val=1e3;
            case 'MHz'
                val=1e6;
            case 'GHz'
                val=1e9;
            case 'THz'
                val=1e12;
            otherwise
                val=1e9;
            end

        end

        function resetAnalysisTab(self)
            self.VectorAnalysis.ImpedanceButton.Value=false;
            self.VectorAnalysis.SparameterButton.Value=false;
            self.MeshSection.MeshButton.Value=false;
            self.ScalarAnalysis.PatternButton.Value=false;
            self.ScalarAnalysis.CurrentButton.Value=false;
            self.ScalarAnalysis.AzimuthButton.Value=false;
            self.ScalarAnalysis.ElevationButton.Value=false;
        end

        function disableAnalysisTab(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.VectorAnalysis.ImpedanceButton.Enabled=val;
            self.VectorAnalysis.SparameterButton.Enabled=val;
            self.MeshSection.MeshButton.Enabled=val;
            self.ScalarAnalysis.PatternButton.Enabled=val;
            self.ScalarAnalysis.CurrentButton.Enabled=val;
            self.ScalarAnalysis.AzimuthButton.Enabled=val;
            self.ScalarAnalysis.ElevationButton.Enabled=val;
            self.Settings.Enabled=val;
            self.AnalysisExport.Button.Enabled=val;
            self.UpdatePlots.Enabled=val;
            self.OptimizerBtn.Enabled=val;
            self.MeshSection.MemoryEstimateButton.Enabled=val;
            self.AnalysisEnableState=val;

        end



        function addFrequencySection(self)
            import matlab.ui.internal.toolstrip.*
            self.FrequencySection.Section=self.AnalysisTab.addSection("Plot Frequency");
            labelcol=self.FrequencySection.Section.addColumn('Width',115);
            centerFreqlabel=Label('Center Frequency');
            centerFreqlabel.Tag='CenterFrequencylabel';
            labelcol.add(centerFreqlabel);

            inputSection=self.FrequencySection.Section;

            freqRangeLabel=Label('Frequency Range');
            freqRangeLabel.Tag='FrequencyRangeLabel';
            labelcol.add(freqRangeLabel);
            self.FrequencySection.LabelColumn=labelcol;
            editFieldColumn=self.FrequencySection.Section.addColumn('Width',95);
            self.FrequencySection.PlotFrequencyEditField=EditField('');

            self.FrequencySection.PlotFrequencyEditField.Tag='PlotFrequency';
            editFieldColumn.add(self.FrequencySection.PlotFrequencyEditField);
            self.FrequencySection.PlotFrequencyEditField.ValueChangedFcn=@(src,evt)validateFrequency(self,self.FrequencySection.PlotFrequencyEditField,evt);
            self.FrequencySection.FrequencyRangeEditField=EditField('');

            self.FrequencySection.FrequencyRangeEditField.Tag='FrequencyRange';
            self.FrequencySection.FrequencyRangeEditField.ValueChangedFcn=@(src,evt)validateFrequency(self,self.FrequencySection.FrequencyRangeEditField,evt);
            editFieldColumn.add(self.FrequencySection.FrequencyRangeEditField);
            self.FrequencySection.EditColumn=editFieldColumn;

            freqUnitCol=inputSection.addColumn('Width',65);
            self.FrequencySection.PlotFrequencyUnitDropdown=DropDown();

            self.FrequencySection.PlotFrequencyUnitDropdown.replaceAllItems(self.UNITS);
            self.FrequencySection.PlotFrequencyUnitDropdown.Tag='plotFrequencyUnitDropdown';
            self.FrequencySection.PlotFrequencyUnitDropdown.ValueChangedFcn=@(src,evt)validateFrequency(self,self.FrequencySection.PlotFrequencyUnitDropdown,evt);
            freqUnitCol.add(self.FrequencySection.PlotFrequencyUnitDropdown);

            self.FrequencySection.FrequencyRangeUnitDropdown=DropDown();

            self.FrequencySection.FrequencyRangeUnitDropdown.replaceAllItems(self.UNITS);
            self.FrequencySection.FrequencyRangeUnitDropdown.Tag='frequencyRangeUnitDropdown';
            self.FrequencySection.FrequencyRangeUnitDropdown.ValueChangedFcn=@(src,evt)validateFrequency(self,self.FrequencySection.FrequencyRangeUnitDropdown,evt);
            freqUnitCol.add(self.FrequencySection.FrequencyRangeUnitDropdown);
            self.FrequencySection.UnitsColumn=freqUnitCol;
        end

        function validateFrequency(self,src,evt)

            plotfreqerror=[];
            freqrangeerror=[];
            try
                validateattributes(str2num(self.FrequencySection.PlotFrequencyEditField.Value),...
                {'numeric'},{'nonempty','nonnan','real','finite',...
                'scalar','positive'},'','PlotFrequency');
                validateattributes((self.PlotFrequency),...
                {'numeric'},{'nonempty','nonnan','real','finite',...
                'scalar','positive','>',1e3},'','PlotFrequency');

            catch me
                plotfreqerror=me;
            end

            try
                validateattributes(str2num(self.FrequencySection.FrequencyRangeEditField.Value),...
                {'numeric'},{'nonempty','nonnan','real','finite',...
                'positive'},'','FrequencyRange');
                validateattributes((self.FrequencyRange),...
                {'numeric'},{'nonempty','nonnan','real','finite',...
                'positive','>',1e3},'','FrequencyRange');
            catch me
                freqrangeerror=me;
            end
            if any(strcmpi(src.Tag,{'PlotFrequency','plotFrequencyUnitDropdown'}))
                if~isempty(plotfreqerror)
                    errordlg(plotfreqerror.message,'Error','modal');
                end
            else
                if~isempty(freqrangeerror)
                    errordlg(freqrangeerror.message,'Error','modal');
                end
            end

            if isempty(plotfreqerror)&&isempty(freqrangeerror)
                disableAnalysisTab(self,true);
                frequencyChanged(self);
            else
                disableAnalysisTab(self,false);
            end
        end

        function deleteFrequencySection(self)
            self.FrequencySection.Section.delete;
            self.FrequencySection.LabelColumn.delete;
            self.FrequencySection.PlotFrequencyEditField.delete;
            self.FrequencySection.FrequencyRangeEditField.delete;
            self.FrequencySection.PlotFrequencyUnitDropdown.delete;
            self.FrequencySection.FrequencyRangeUnitDropdown.delete;
            self.FrequencySection.UnitsColumn.delete;
        end

        function frequencyChanged(self)
        end

        function addMeshSection(self)
            import matlab.ui.internal.toolstrip.*;


            viewMeshSection=Section('Mesh');
            viewMeshSection.Tag='MeshSection';
            self.AnalysisTab.add(viewMeshSection);

            self.MeshSection.MemoryEstimateButton=Button(['Memory',newline,'Estimate'],Icon(fullfile(self.AnalysisIconPath,'memoryEstimate_24.png')));
            self.MeshSection.MemoryEstimateButton.Tag='memoryEstimate';
            self.MeshSection.MemoryEstimateButton.Description=getString(message("antenna:pcbantennadesigner:MemoryEstimate"));
            tmpCol=viewMeshSection.addColumn();
            tmpCol.add(self.MeshSection.MemoryEstimateButton);

            self.MeshSection.MeshButton=ToggleButton('Mesh',Icon(fullfile(self.AnalysisIconPath,'viewMesh_24.png')));
            self.MeshSection.MeshButton.Tag='mesh';
            self.MeshSection.MeshButton.Description=getString(message("antenna:pcbantennadesigner:Mesh"));

            tmpCol=viewMeshSection.addColumn();
            tmpCol.add(self.MeshSection.MeshButton);
        end

        function deleteMeshSection(self)
            self.MeshSection.MeshButton.delete;
        end

        function addVectorAnalysisSection(self)
            import matlab.ui.internal.toolstrip.*;


            vectorInputSection=Section('Vector Frequency Analysis');
            vectorInputSection.Tag='vectorInputSection';
            self.AnalysisTab.add(vectorInputSection);

            iconPath=fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Impedance.png');
            self.VectorAnalysis.ImpedanceButton=ToggleButton('Impedance',iconPath);
            self.VectorAnalysis.ImpedanceButton.Tag='impedance';
            self.VectorAnalysis.ImpedanceButton.Description=getString(message("antenna:pcbantennadesigner:ImpedanceButton"));
            tmpCol=vectorInputSection.addColumn();
            tmpCol.add(self.VectorAnalysis.ImpedanceButton);

            iconPath=fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Sparameter.png');
            self.VectorAnalysis.SparameterButton=ToggleButton('S Parameter',iconPath);
            self.VectorAnalysis.SparameterButton.Tag='sparameter';
            self.VectorAnalysis.SparameterButton.Description=getString(message("antenna:pcbantennadesigner:SparameterButton"));
            tmpCol=vectorInputSection.addColumn();
            tmpCol.add(self.VectorAnalysis.SparameterButton);
        end

        function deleteVectorAnalysisSection(self)
            self.VectorAnalysis.ImpedanceButton.delete;
            self.VectorAnalysis.SparameterButton.delete;
        end

        function addScalarAnalysisSection(self)
            import matlab.ui.internal.toolstrip.*;

            scalarInputSection=Section('Scalar Frequency Analysis');
            scalarInputSection.Tag='scalarInputSection';
            self.AnalysisTab.add(scalarInputSection);

            iconPath=fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Current.png');
            self.ScalarAnalysis.CurrentButton=ToggleButton('Current',iconPath);
            self.ScalarAnalysis.CurrentButton.Tag='current';
            self.ScalarAnalysis.CurrentButton.Description=getString(message("antenna:pcbantennadesigner:CurrentButton"));
            tmpCol=scalarInputSection.addColumn();
            tmpCol.add(self.ScalarAnalysis.CurrentButton);

            iconPath=fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Pattern.png');
            self.ScalarAnalysis.PatternButton=ToggleButton('3D Pattern',iconPath);
            self.ScalarAnalysis.PatternButton.Tag='pattern';
            self.ScalarAnalysis.PatternButton.Description=getString(message("antenna:pcbantennadesigner:PatternButton"));
            tmpCol=scalarInputSection.addColumn();
            tmpCol.add(self.ScalarAnalysis.PatternButton);

            iconPath=fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Azimuth.png');
            self.ScalarAnalysis.AzimuthButton=ToggleButton('AZ Pattern',iconPath);
            self.ScalarAnalysis.AzimuthButton.Tag='azimuth';
            self.ScalarAnalysis.AzimuthButton.Description=getString(message("antenna:pcbantennadesigner:AzimuthButton"));
            tmpCol=scalarInputSection.addColumn();
            tmpCol.add(self.ScalarAnalysis.AzimuthButton);

            iconPath=fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Elevation.png');
            self.ScalarAnalysis.ElevationButton=ToggleButton('EL Pattern',iconPath);
            self.ScalarAnalysis.ElevationButton.Tag='elevation';
            self.ScalarAnalysis.ElevationButton.Description=getString(message("antenna:pcbantennadesigner:ElevationButton"));
            tmpCol=scalarInputSection.addColumn();
            tmpCol.add(self.ScalarAnalysis.ElevationButton);
        end

        function deleteScalarAnalysisSection(self)
            self.ScalarAnalysis.ElevationButton.delete;
            self.ScalarAnalysis.PatternButton.delete;
            self.ScalarAnalysis.AzimuthButton.delete;
            self.ScalarAnalysis.CurrentButton.delete;
        end

        function addSettingsSection(self)
            import matlab.ui.internal.toolstrip.*;


            settingsSection=Section('Settings');
            settingsSection.Tag='SettingsSection';
            self.AnalysisTab.add(settingsSection);
            self.Settings=Button(['Analysis',newline,'Settings'],Icon(fullfile(self.AnalysisIconPath,'analysisSettings_24.png')));
            self.Settings.Tag='AnalysisSettings';
            self.Settings.Description=getString(message("antenna:pcbantennadesigner:AnalysisSettingsButton"));
            tmpCol=settingsSection.addColumn();
            tmpCol.add(self.Settings);
        end

        function deleteSettingsSection(self)
            self.Settings.delete;
        end

        function addUpdatePlotsSection(self)
            import matlab.ui.internal.toolstrip.*;


            updateplots=Section('Update');
            updateplots.Tag='UpdatePlotsSection';
            self.AnalysisTab.add(updateplots);
            self.UpdatePlots=Button(['Update',newline,'Plots'],Icon(fullfile(self.AnalysisIconPath,'updatePlot_24.png')));
            self.UpdatePlots.Tag='updatebutton';
            self.UpdatePlots.Description=getString(message("antenna:pcbantennadesigner:UpdatePlotButton"));
            tmpCol=updateplots.addColumn();
            tmpCol.add(self.UpdatePlots);
        end

        function addOptimizerSection(self)
            import matlab.ui.internal.toolstrip.*;


            optimizerBtn=Section('Optimize');
            optimizerBtn.Tag='OptimizerSection';
            self.AnalysisTab.add(optimizerBtn);
            self.OptimizerBtn=Button('Optimize',Icon(fullfile(matlabroot,'toolbox',...
            'antenna','antenna','+em','+internal',...
            '+antennaExplorer','+src','Optimize.png')));
            self.OptimizerBtn.Tag='optimizerButton';
            self.OptimizerBtn.Description=getString(message("antenna:antennadesigner:OptimizeButton"));
            tmpCol=optimizerBtn.addColumn();
            tmpCol.add(self.OptimizerBtn);
        end

        function deleteUpdatePlotsSection(self)
            self.UpdatePlots.delete;
        end

        function deleteOptimizerSection(self)
            self.OptimizerBtn.delete;
        end

        function addAnalysisExportSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.AnalysisTab.addSection("Export");
            section.Tag="AnalysisExportShape";
            self.AnalysisExport.Section=section;

            column=section.addColumn();
            self.AnalysisExport.Column=column;
            button=SplitButton('Export',Icon.EXPORT_24);
            button.Tag="AnalysisExport";
            button.Description=getString(message('antenna:pcbantennadesigner:ExportButton'));
            column.add(button);
            self.AnalysisExport.Button=button;

            popup=PopupList;
            listItem=ListItem('Export to MATLAB workspace');
            self.AnalysisExport.ExportToWorkspace=listItem;
            popup.add(listItem);
            listItem.Tag='AnalysisExportToWorkspace';
            listItem.Description=getString(message('antenna:pcbantennadesigner:ExportWorkspace'));
            listItem=ListItem('Export as MATLAB Script');
            self.AnalysisExport.ExportScript=listItem;
            popup.add(listItem);
            listItem.Tag='AnalysisExportScript';
            listItem.Description=getString(message('antenna:pcbantennadesigner:ExportScript'));
            listItem=ListItem('Export as Gerber File');
            self.AnalysisExport.GerberExport=listItem;
            popup.add(listItem);
            listItem.Tag='AnalysisGerberExport';
            listItem.Description=getString(message('antenna:pcbantennadesigner:ExportGerber'));
            button.Popup=popup;
        end

        function deleteAnalysisExportSection(self)
            self.AnalysisExport.Section.delete;
            self.AnalysisExport.Column.delete;
            self.AnalysisExport.Button.delete;
            self.AnalysisExport.ExportToWorkspace.delete;
            self.AnalysisExport.ExportScript.delete;
            self.AnalysisExport.GerberExport.delete;
        end

        function deleteView(self)
            self.deleteAnalysisExportSection();
            self.deleteFrequencySection();
            self.deleteMeshSection();
            self.deleteScalarAnalysisSection();
            self.deleteSettingsSection();
            self.deleteUpdatePlotsSection();
            self.deleteOptimizerSection();
            self.deleteVectorAnalysisSection();
            self.deleteAnalysisTab();
        end

    end
end
