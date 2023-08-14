
%

%   Copyright 2013-2019 The MathWorks, Inc.

classdef SyntaxCorrectorToMATLAB < handle
    
    properties
        chartId = 0;
        warningChartList=[];
        finalConvertedChartList = [];
        stage ='';
    end
    
    methods (Static)
        
        function inst = currentConverterInstance(currentInst)
            persistent converterObj;
            if nargin == 1
                converterObj = currentInst;
            end
            inst = converterObj;
        end
        
        function warningChartRowSchema = getWarningChartRow(chart)
            
            warningChartRowSchema.Type = 'panel';
            
            chartUDD = sfprivate('idToHandle', sfroot, chart.id);
            chartPath = chartUDD.Path;
            
            chartHyper.Type = 'hyperlink';
            chartHyper.Name = chartPath;
            chartHyper.MatlabMethod = 'open_system';
            chartHyper.MatlabArgs = {chartPath};
            chartHyper.RowSpan =[1 1];
            chartHyper.ColSpan =[1 1];
            
            warningHyper.Type = 'hyperlink';
            warningHyper.Tag = 'warning_hyperlink';
            numWarnings = length(chart.warnings);
            warningHyper.Name = strcat('(', num2str(numWarnings), ' warnings)');
            warningHyper.MatlabMethod = 'Stateflow.Tools.SyntaxCorrectorToMATLAB.showWarningsOnClick';
            warningHyper.MatlabArgs = {chart};
            
            warningChartRowSchema.LayoutGrid= [1 3];
            warningChartRowSchema.ColStretch =[1 5 5];
            warningChartRowSchema.Items = {chartHyper, warningHyper};
        end
        
        function convertChartsWithWarning(dialogH)
            obj = dialogH.getDialogSource;
            obj.stage = 'Final_Summary_Stage';
            chartsList = getChartsWithWarningsForConversion(obj);
            
            if ~isempty(chartsList)
                if (chartsList(1).checked == 1)
                    %                     editor = StateflowDI.SFDomain.getLastActiveEditorForChart(obj.chartId );
                    %                     undoStr = 'Syntax correction to MATLAB';
                    %                     editor.createMCommand( undoStr, @Stateflow.Tools.SyntaxCorrectorToMATLAB.forceConvertChart,{dialogH});
                    Stateflow.Tools.SyntaxCorrectorToMATLAB.forceConvertChart(dialogH);
                end
            end
            
            dialogH.refresh;
        end
        
        function forceConvertChart(dialogH)
            obj = dialogH.getDialogSource;
            chart = idToHandle(sfroot, obj.chartId);
            sf('set', chart.id, '.actionLanguage', 1); %temporarily for conversion
            converterObj = Stateflow.Tools.Classic2MALConverter(chart);
            Stateflow.Tools.SyntaxCorrectorToMATLAB.currentConverterInstance(converterObj);
            c = onCleanup(@() Stateflow.Tools.SyntaxCorrectorToMATLAB.currentConverterInstance([]));
            converterObj.forceUpdate = 1;
            converterObj.convert;
            obj.finalConvertedChartList(1) = chart.id;
            
        end
        
        function convertChart(converterObj)
            converterObj.forceUpdate =1;
            converterObj.convert;
        end
        
        function showWarningsOnClick(chart)
            
            warningsList = chart.warnings;
            numWarnings = length(warningsList);
            chartH = sfprivate('idToHandle', sfroot, chart.id);
            chartFullName = chartH.Path;            
            
            machineId = sf( 'get', chart.id, '.machine' );
            modelH = sf( 'get', machineId, '.simulinkModel' );
            modelName = get(modelH, 'Name' );
            
            my_stage = Simulink.output.Stage('Conversion Warnings', 'ModelName', modelName, 'UIMode', true);
            Stateflow.Diagnostics.reportWarning(chart.id,'Stateflow:dialog:WarnMsg',chartFullName, numWarnings);
            
            for k = 1:numWarnings
                if ~isempty(warningsList(k).Args)
                    Stateflow.Diagnostics.reportWarning(warningsList(k).ObjectId, warningsList(k).MessageId, warningsList(k).Args{:});
                else
                    Stateflow.Diagnostics.reportWarning(warningsList(k).ObjectId, warningsList(k).MessageId);
                end
            end
            
            my_stage.delete;
        end
        
        function OnCancel(dialogH)
            delete(dialogH);
        end
        
    end
    methods
        
        function self = SyntaxCorrectorToMATLAB(aChartId, wasCBitOperationsEnabled, disableUndoRedo)
            % constructor
            
            if nargin < 3
                disableUndoRedo = false;
            end
            
            chart = sfprivate('idToHandle',sfroot, aChartId);
            
            % Model must not be locked
            model = chart.Machine.up;
            isEditable = ~isequal(model.Lock, 'on');
            
            % Machine must not be locked or iced
            isEditable = isEditable && ~chart.Machine.Locked && ~chart.Machine.Iced;
            
            if ~isEditable
                errordlg(DAStudio.message('Stateflow:dialog:MachineLockedDuringConversion'),...
                    DAStudio.message('Stateflow:dialog:ActionLangConversionError'));
                return;
            end
            
            self.chartId = aChartId;
            
            % Temporarily set the action language on the chart being
            % invoked to 'C' because we invoke the language conversion
            % wizard on the pre-apply callback where the action language
            % has already been committed to 'MATLAB'.
            if (sf('get', chart.id ,'.actionLanguage') ~=1) && (sf('get', chart.id ,'.actionLanguage') ~=0)
                if wasCBitOperationsEnabled
                    sf('set', chart.id, '.actionLanguage', 1);
                else
                    sf('set', chart.id, '.actionLanguage', 0);
                end
                restoreActionLang = onCleanup(@() sf('set', chart.id, '.actionLanguage', 2));
            end
            
            converterObj = Stateflow.Tools.Classic2MALConverter(chart);
            Stateflow.Tools.SyntaxCorrectorToMATLAB.currentConverterInstance(converterObj);
            % remove the current converter instance when done converting or
            % when an error occurs.
            c = onCleanup(@() Stateflow.Tools.SyntaxCorrectorToMATLAB.currentConverterInstance([]));
            converterObj.findInitialWarnings;
            converterObj.migrateCstyleCommentsAndDeclareExtrinsicFcns;
            warnings =  converterObj.getWarningsList;
            if  isempty(warnings)
                if ~disableUndoRedo
                    undoStr = 'Syntax correction to MATLAB';
                    editor = StateflowDI.SFDomain.getLastActiveEditorForChart(chart.id);
                    
                    h = @Stateflow.Tools.SyntaxCorrectorToMATLAB.convertChart;
                    editor.createMCommand( undoStr, undoStr, h, {converterObj});
                    
                    if isa(chart, 'Stateflow.StateTransitionTableChart')
                        
                        sttId = chart.Id;
                        sttMan = Stateflow.STT.StateEventTableMan(sttId);
                        
                        objIds = unique(converterObj.ModifiedObjectIds);
                        for objId = objIds(:)'
                            objH = sf('IdToHandle', objId);
                            [row, col] =  Stateflow.STT.StateEventTableMan.getMappingInfoForObj(sttId, objId);
                            if isa(objH, 'Stateflow.Transition')
                                
                                if row == -1 || col == -1
                                    continue;
                                end
                                
                                astNode = Stateflow.Ast.getContainer(objH);
                                
                                conditionSection = astNode.conditionSection;
                                actionSection = astNode.conditionActionSection;
                                transitionActionSection = astNode.transitionActionSection;
                                
                                conditionCellText = '';
                                
                                if ~isempty(conditionSection)
                                    sections = conditionSection{1}.roots;
                                    
                                    if length(sections) == 1
                                        conditionCellText = sections{1}.sourceSnippet;
                                    elseif length(sections) == 2
                                        triggerText = sections{1}.sourceSnippet;
                                        conditionText = sections{2}.sourceSnippet;
                                        conditionCellText = [triggerText '[' conditionText ']'];
                                    end
                                end
                                
                                actionCellText = '';
                                if ~isempty(actionSection)
                                    sections = actionSection{1}.roots;
                                    
                                    if length(sections) == 1
                                        actionCellText = sections{1}.sourceSnippet;
                                    elseif length(sections) == 2
                                        firstSection = sections{1}.sourceSnippet;
                                        secondSection = sections{2}.sourceSnippet;
                                        actionCellText = ['{' firstSection ' ' secondSection '}'];
                                    end
                                end
                                
                                if ~isempty(transitionActionSection)
                                    actionCellText = [actionCellText  '/{' transitionActionSection{1}.roots{1}.sourceSnippet '}']; %#ok<AGROW>
                                end
                                
                                if col == 1
                                    sttMan.setValueAt(row, col, objH.LabelString, '', true);
                                else
                                    sttMan.setValueAt(row, col, conditionCellText, 'condition');
                                    sttMan.setValueAt(row, col, actionCellText, 'action');
                                end
                                
                            else
                                sttMan.setValueAt(row, col, objH.LabelString);
                            end
                        end
                    end
                    
                    result = strcmp(converterObj.status, converterObj.Success);
                    if (result == 1)
                        if ~isempty(editor)
                            editor.deliverInfoNotification('Stateflow:MAL:SuccessNotification',...
                                DAStudio.message('Stateflow:studio:SyntaxConverted'));
                        end
                    end
                end
            else
                % Chart has warnings, bring up Dialog with Warnings
                self.stage = 'Conversion_Status_Stage';
                self.warningChartList(1).id = chart.id;
                self.warningChartList(1).warnings = warnings;
                self.warningChartList(1).checked = 0;
                warningDialogH = DAStudio.Dialog(self);
                
                closeListener = Simulink.listener(chart, 'ObjectBeingDestroyed', @closeDialog);
                setappdata(warningDialogH, 'StateflowGlobalWizardDialog', closeListener);
            end
            
            % Setup a listener on the chart Udd handle so that when the
            % chart udd gets cleared, its corresponding action language wizard also
            % disappears
            function closeDialog(varargin)
                delete(warningDialogH);
                setappdata(0, 'StateflowGlobalWizardDialog', []);
            end
        end
        
        function schema = getDialogSchema(self)
            % GETDIALOGSCHEMA Return the schema for the language converter
            % wizard
            if strcmp(self.stage, 'Conversion_Status_Stage')
                schema = self.getConversionStageSchema;
            elseif strcmp(self.stage, 'Final_Summary_Stage')
                schema = self.getFinalStageSchema;
            end
            
            schema.DialogTag = ['DDG_Stateflow_Syntax_Correction_Wizard: ' self.stage];
        end
        
        
        function schema = getConversionStageSchema(self)
            
            schema.DialogTitle =  DAStudio.message('Stateflow:dialog:ConversionWizardTitle', 'MATLAB');
            
            schema.Items = {};
            warningPanel.Type = 'panel';
            
            if ~isempty(self.warningChartList)
                warningNote.Type = 'text';
                warningNote.Name = DAStudio.message('Stateflow:dialog:ConvertConfirmationMsg');
                
                warningList = self.getWarningChartsList;
                
                warningPanel.LayoutGrid =[ 1 2];
                
                warningImage.Type = 'image';
                warningImage.FilePath = fullfile(matlabroot, 'toolbox','shared' ,'dastudio', 'resources' ,'warningicon.gif');
                warningImage.RowSpan =[ 1 1];
                warningImage.ColSpan =[1 1];
                
                warningNote.RowSpan= [1 1];
                warningNote.ColSpan = [ 2 2];
                
                warningPanel.Items = {warningImage, warningNote};
                schema.Items = {warningPanel, warningList};
                
            end
            
            buttonPanel.Type = 'panel';
            buttonPanel.LayoutGrid = [1 3];
            cancelButton.Type = 'pushbutton';
            cancelButton.Name = 'Cancel';
            cancelButton.RowSpan = [1 1];
            cancelButton.ColSpan = [ 2 2];
            cancelButton.MatlabMethod = 'Stateflow.Tools.SyntaxCorrectorToMATLAB.OnCancel';
            cancelButton.MatlabArgs = {'%dialog'};
            
            helpButton.Type = 'pushbutton';
            helpButton.Name = 'Help';
            helpButton.RowSpan = [1 1];
            helpButton.ColSpan = [3 3];
            helpButton.MatlabMethod = 'sfhelp';
            helpButton.MatlabArgs = {'convert_the_action_language'};
            helpButton.Tag = 'Help_Button';
            
            schema.StandaloneButtonSet = buttonPanel;
            schema = addStretchRow(schema);
            
            if ~isempty(self.warningChartList)
                nextButton.Type = 'pushbutton';
                nextButton.Name = 'Next';
                nextButton.Alignment =10; %Bottom right
                nextButton.MatlabMethod = 'Stateflow.Tools.SyntaxCorrectorToMATLAB.convertChartsWithWarning';
                nextButton.MatlabArgs= {'%dialog'};
                nextButton.Tag = 'Convert_Button';
                
                buttonPanel.Items = {nextButton, cancelButton, helpButton};
                schema.StandaloneButtonSet = buttonPanel;
                
            else
                schema.StandaloneButtonSet = {'OK'};
            end
        end
        
        function schema = getFinalStageSchema(self)
            
            schema.DialogTitle = DAStudio.message('Stateflow:dialog:ConversionWizardTitle', 'MATLAB');
            schema.Items = {};
            
            warningSummaryPanel.Type = 'panel';
            
            warningImage.Type = 'image';
            warningImage.FilePath = fullfile(matlabroot, 'toolbox','shared' ,'dastudio', 'resources' ,'warningicon.gif');
            warningImage.RowSpan =[ 1 1];
            warningImage.ColSpan =[1 1];
            
            warningNote.Type = 'text';
            warningNote.Name = DAStudio.message('Stateflow:dialog:WithWarnings');
            warningNote.RowSpan= [1 1];
            warningNote.ColSpan = [2 2];
            
            warningHeaderPanel.Type = 'panel';
            warningHeaderPanel.LayoutGrid = [1 2];
            warningHeaderPanel.Items = {warningImage, warningNote};
            warningHeaderPanel.ColStretch = [1 20];
            
            chartsWithWarnings = self.finalConvertedChartList;
            warningsChartList.Type = 'panel';
            warningsChartList.Items = {};
            for i = 1:length(chartsWithWarnings)
                chartUDD = sfprivate('idToHandle', sfroot, chartsWithWarnings(i));
                chartPath = chartUDD.Path;
                chartHyper.Type = 'hyperlink';
                chartHyper.Name = chartPath;
                chartHyper.MatlabMethod = 'open_system';
                chartHyper.MatlabArgs = {chartPath};
                warningsChartList.Items = [warningsChartList.Items, chartHyper];
            end
            if ~isempty(chartsWithWarnings)
                warningSummaryPanel.Items = {warningHeaderPanel, warningsChartList};
            end
            
            schema.StandaloneButtonSet = {'OK'};
            schema.Items = [schema.Items, warningSummaryPanel];
            
            if isempty(chartsWithWarnings)
                finalNote.Type = 'text';
                finalNote.Name = DAStudio.message('Stateflow:dialog:NoChartsConverted');
                schema.Items = [schema.Items, finalNote];
            end
            schema = addStretchRow(schema);
        end
        
        
        function chartList = getChartsWithWarningsForConversion(self)
            chartList =struct('id',{},'warnings',{}, 'checked', {});
            k=1;
            for i = 1:length(self.warningChartList)
                self.warningChartList(i).checked = 1;
                chartList(k) = self.warningChartList(i);
                k = k+1;
            end
        end
        
        function schema = getWarningChartsList(self)
            
            schema.Type = 'panel';
            schema.Items ={};
            chartsWithWarnings = self.warningChartList;
            
            for i = 1:length(chartsWithWarnings)
                chartRowSchema =  Stateflow.Tools.SyntaxCorrectorToMATLAB.getWarningChartRow(chartsWithWarnings(i));
                schema.Items = [schema.Items, chartRowSchema];
            end
        end
    end
end

function schema = addStretchRow(schema)
    emptyPanel.Type = 'panel';
    schema.Items = [schema.Items emptyPanel];
    schema.LayoutGrid = [length(schema.Items) 1];
    schema.RowStretch = zeros(size(schema.Items));
    schema.RowStretch(end) = 1;
end
