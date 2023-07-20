classdef TestCaseReporter < sltest.testmanager.TestReporter
    
    properties
        
        Object {mustBeInstanceOf('sltest.testmanager.TestCase',Object)} = [];
        ReportTempDir = '';
        
        IncludeTestDetails {mustBeLogical} = true;
        IncludeSystemUnderTest {mustBeLogical} = true;
        IncludeParameterOverrides {mustBeLogical} = true;
        IncludeCallbacks {mustBeLogical} = true;
        IncludeExternalInputs {mustBeLogical} = true;
        IncludeSimulationOutputs {mustBeLogical} = true;
        IncludeConfigSettingsOverrides {mustBeLogical} = true;
        IncludeBaselineCriteria {mustBeLogical} = true;
        IncludeEquivalenceCriteria {mustBeLogical} = false;
        IncludeCustomCriteria {mustBeLogical} = true;
        IncludeLogicalAndTemporalAssessments {mustBeLogical} = true;
        IncludeCoverageSettings {mustBeLogical} = true;
        IncludeIterations {mustBeLogical} = true;
        
    end
    
    methods (Access = protected, Hidden)       
        % Implemented externally
        result = openImpl(report, impl, varargin)
    end

    
    methods
        function h = TestCaseReporter(varargin)
            if(nargin == 1)
                varargin = [ {"Object"} {"ReportTempDir"} varargin ];
            end
            
            h = h@sltest.testmanager.TestReporter(varargin{:});
            
            % Create an inputParser object
            p = inputParser;

            % Add optional parameter name-value pair argument to input
            % parser scheme.
            % syntax: addParameter(p, paramName, defaultValue);

            addParameter(p, 'TemplateName', "TestCaseReporter");
            addParameter(p, 'Object', []);
            addParameter(p, 'ReportTempDir', tempdir);
            
            addParameter(p, 'IncludeTestDetails', true);
            addParameter(p, 'IncludeSystemUnderTest', true);
            addParameter(p, 'IncludeParameterOverrides', true);
            addParameter(p, 'IncludeCallbacks', true);
            addParameter(p, 'IncludeExternalInputs', true);
            addParameter(p, 'IncludeSimulationOutputs', true);
            addParameter(p, 'IncludeConfigSettingsOverrides', true);
            addParameter(p, 'IncludeBaselineCriteria', true);
            addParameter(p, 'IncludeEquivalenceCriteria', false);
            addParameter(p, 'IncludeCustomCriteria', true);
            addParameter(p, 'IncludeLogicalAndTemporalAssessments', true);
            addParameter(p, 'IncludeCoverageSettings', true);
            addParameter(p, 'IncludeIterations', true);
            

            % Parse the inputs
            parse(p, varargin{:});

            results = p.Results;
            h.Object = results.Object;
            h.ReportTempDir = results.ReportTempDir;
            h.TemplateName = results.TemplateName;
            
            h.IncludeTestDetails = results.IncludeTestDetails;
            h.IncludeSystemUnderTest = results.IncludeSystemUnderTest;
            h.IncludeParameterOverrides = results.IncludeParameterOverrides;
            h.IncludeCallbacks = results.IncludeCallbacks;
            h.IncludeExternalInputs = results.IncludeExternalInputs;
            h.IncludeSimulationOutputs = results.IncludeSimulationOutputs;
            h.IncludeConfigSettingsOverrides = results.IncludeConfigSettingsOverrides;
            h.IncludeBaselineCriteria = results.IncludeBaselineCriteria;
            h.IncludeEquivalenceCriteria = results.IncludeEquivalenceCriteria;
            h.IncludeCustomCriteria = results.IncludeCustomCriteria;
            h.IncludeLogicalAndTemporalAssessments = results.IncludeLogicalAndTemporalAssessments;
            h.IncludeCoverageSettings = results.IncludeCoverageSettings;                       
        end
        
        function set.Object(h, value)
           h.Object = value;
        end
        
    end
    
    methods (Access = {?mlreportgen.report.ReportForm, ?sltest.testmanager.TestCaseReporter})
        
        function content = getTestDetails(h, rpt)
            import mlreportgen.dom.*;
            content = [];
            if h.IncludeTestDetails
                testObj = h.Object;
                testDetailsTableData = getTestDetailsTableData(h, rpt, testObj);
                
                isTestCaseFromExternalFile = testObj.getProperty('istestdatareferenced') && ~isempty(testObj.getProperty('testdatapath'));
                if(~isempty(testDetailsTableData) || isTestCaseFromExternalFile)
                    heading = Heading4(getString(message('stm:TestSpecReportContent:TestDetails')));
                    content = [content {heading}];                    
                    heading.StyleName = 'TestCase_TestDetailsHeading';
                    
                    if (~isempty(testDetailsTableData))
                        table = Table(testDetailsTableData);
                        table.StyleName = 'TestCase_TestDetailsTable';
                        table = customizeTableWidthsForTable(h, table, 30);
                        content = [content {table}];
                    end
                    
                    if(isTestCaseFromExternalFile)     
                        extFileText = Text([getString(message('stm:general:CreateTestCaseFromExternalFileLabel')),': ',testObj.getProperty('testdatapath')]);
                        content = [content {extFileText}];
                    end                                        
                end
            end 
        end
        
        function content = getSystemUnderTest(h, rpt)
             import mlreportgen.dom.*;
             content = {};
             if h.IncludeSystemUnderTest
                 testObj = h.Object;
                 harnessModelPath = setupModelTempFolder(testObj, 1, h.ReportTempDir);
                 isEquivTest = isequal(testObj.TestType, 'equivalence');
                 
                 if(~isEquivTest)
                    heading = Heading4(getString(message('stm:TestSpecReportContent:SystemUnderTest')));
                 else
                    heading = Heading4([getString(message('stm:TestSpecReportContent:SystemUnderTestForSim')),' ','1']); 
                 end
                 heading.StyleName = 'SystemUnderTestHeading';
                 content = [content {heading}];
                 modelName = testObj.getProperty('model',1);
                 content = getSystemUnderTestData(h, rpt, content, testObj, 1, modelName, harnessModelPath);
                 
                 if isEquivTest
                    heading = Heading4([getString(message('stm:TestSpecReportContent:SystemUnderTestForSim')),' ','2']);
                    heading.StyleName = 'SystemUnderTestHeading';
                    content = [content {heading}];
                    harnessModelPath = setupModelTempFolder(testObj, 2, h.ReportTempDir);
                    modelName = testObj.getProperty('model',2);
                    content = getSystemUnderTestData(h, rpt, content, testObj, 2, modelName, harnessModelPath);
                 end   
             end            
        end
        
        function content = getParameterOverrides(h, rpt)            
             content = [];
             if h.IncludeParameterOverrides
                testObj = h.Object;
                isEquivTest = isequal(testObj.TestType, 'equivalence');
                content = getParamSetsData(h, rpt, content, testObj, 1, isEquivTest);                
                if(isEquivTest)
                   content = getParamSetsData(h, rpt, content, testObj, 2, isEquivTest);
                end
                 
             end
        end
        
        function content = getCallbacks(h, rpt)            
             content = [];
             if h.IncludeCallbacks
               testObj = h.Object;
               isEquivTest = isequal(testObj.TestType, 'equivalence');
               content = getCallbacksData(h, rpt, testObj, content, 1, isEquivTest);
               if(isEquivTest)
                  content = getCallbacksData(h, rpt, testObj, content, 2, isEquivTest); 
               end
             end
        end
        
        function content = getExternalInputs(h, rpt)
             content = [];
             if h.IncludeExternalInputs
                testObj = h.Object;
                isEquivTest = isequal(testObj.TestType, 'equivalence');
                content = getExternalInputsData(h, rpt, content, testObj, 1, isEquivTest);
                if(isEquivTest)
                   content = getExternalInputsData(h, rpt, content, testObj, 2, isEquivTest);
                end
             end
        end
        
        function content = getSimulationOutputs(h, rpt)
             content = [];
             if h.IncludeSimulationOutputs
                testObj = h.Object;
                isEquivTest = isequal(testObj.TestType, 'equivalence');
                content = getSimulationOutputsData(h, rpt, content, testObj, 1, isEquivTest);                
                if(isEquivTest)
                   content = getSimulationOutputsData(h, rpt, content, testObj, 2, isEquivTest);
                end
             end
        end
        
        function content = getConfigSettingsOverrides(h, ~)
             content = [];
             if h.IncludeConfigSettingsOverrides
                testObj = h.Object;
                isEquivTest = isequal(testObj.TestType, 'equivalence');
                content = getConfigSettingsOverridesData(h, content, testObj, 1, isEquivTest);
                if(isEquivTest)
                   content = getConfigSettingsOverridesData(h, content, testObj, 2, isEquivTest);
                end
             end
        end
        
        function content = getBaselineCriteria(h, ~)
             import mlreportgen.dom.*;
             content = [];
             if h.IncludeBaselineCriteria
                testObj = h.Object;
                if(~isempty(testObj.getBaselineCriteria))
                   baselineTableData = createBaselineTableData(h, testObj.getBaselineCriteria);
                   if(~isempty(baselineTableData))
                       table = FormalTable(baselineTableData);
                       table.StyleName = 'BaselineCriteriaTable';
                       table = customizeTableWidthsForTable(h, table, [50,10,10,15,15]);
                       tr = TableRow();
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:SignalName'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:AbsTol'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:RelTol'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:LeadingTol'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:LaggingTol'))));
                       append(table.Header, tr);
                       header = Heading4(getString(message('stm:TestSpecReportContent:BaselineCriteria')));
                       header.StyleName = 'BaselineCriteriaHeading';
                       content = [content {header} {table}];
                   end
                end
             end
        end
        
        function content = getEquivalenceCriteria(h, ~)
             import mlreportgen.dom.*;
             content = [];
             if h.IncludeEquivalenceCriteria
                testObj = h.Object;
                if(~isempty(testObj.getEquivalenceCriteria))
                   equivTableData = createEquivalenceTableData(h, testObj.getEquivalenceCriteria);
                   if(~isempty(equivTableData))
                       table = FormalTable(equivTableData);
                       table.StyleName = 'EquivalenceCriteriaTable';
                       table = customizeTableWidthsForTable(h, table, [50,10,10,15,15]);
                       tr = TableRow();
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:SignalName'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:AbsTol'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:RelTol'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:LeadingTol'))));
                       append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:LaggingTol'))));
                       append(table.Header, tr);
                       header = Heading4(getString(message('stm:TestSpecReportContent:EquivalenceCriteria')));
                       header.StyleName = 'EquivalenceCriteriaHeading';
                       content = [content {header} {table}];
                   end
                end
             end
        end
        
        function content = getCustomCriteria(h, rpt)
             import mlreportgen.dom.*;
             content = [];
             if h.IncludeCustomCriteria
                testObj = h.Object;
                if(testObj.getCustomCriteria.Enabled && ~isempty(testObj.getCustomCriteria.Callback))
                    customCriteriaPara = Paragraph();
                    if(isequal(rpt.Type,'docx'))
                       customCriteriaPara.WhiteSpace = 'preserve'; 
                    else
                       customCriteriaPara.StyleName = 'CustomCriteriaScripts'; 
                    end                    
                    textNodes = createCallbackScriptTextObj(h, rpt, testObj.getCustomCriteria.Callback);
                    if(~isempty(textNodes))
                        for i=1:numel(textNodes)
                            customCriteriaPara.append(clone(textNodes{i}));
                        end
                        header = Heading4(getString(message('stm:TestSpecReportContent:CustomCriteria')));
                        header.StyleName = 'CustomCriteriaHeading';
                        content = [content {header} {customCriteriaPara}];
                    end
                end
             end
        end
        
        function content = getLogicalAndTemporalAssessments(h, rpt)
           import mlreportgen.dom.*;
           content = [];
           if h.IncludeLogicalAndTemporalAssessments
              testObj = h.Object;
              def = sltest.internal.getAssessmentsDefinition(testObj.getID);
              if(~isempty(def))
                  if(~isempty(def.assessmentsDefinition) || ~isempty(def.symbolsDefinition) || ...
                      (strcmp(stm.internal.assessmentsFeature('ShowAssessmentsCallback'), 'on') && ~isempty(def.assessmentsCallback)))
                     header = Heading4(getString(message('sltest:assessments:editor:SectionTitle')));
                     header.StyleName = 'LogicalAndTemporalAssessmentsHeading';
                     content = [content {header}];
                  end
                  
                  if(isfield(def, 'assessmentsCallback') && ~isempty(def.assessmentsCallback))
                       % Callback is formatted similar to custom criteria.
                       assessmentsCallbackPara = Paragraph();
                        if(isequal(rpt.Type,'docx'))
                           assessmentsCallbackPara.WhiteSpace = 'preserve';
                        else
                            assessmentsCallbackPara.StyleName = 'AssessmentsCallbackScripts';
                        end
                        textNodes = createCallbackScriptTextObj(h, rpt, def.assessmentsCallback);
                        if ~isempty(textNodes)
                            for i=1:numel(textNodes)
                                assessmentsCallbackPara.append(clone(textNodes{i}));
                            end
                            header = Heading5(getString(message('stm:TestSpecReportContent:AssessmentsCallback')));
                            header.StyleName = 'AssessmentsCallbackHeading';
                            content = [content {header} {assessmentsCallbackPara}];
                        end
                  end
                  
                  if(isfield(def, 'assessmentsDefinition') && ~isempty(def.assessmentsDefinition))
                      % Create table for assessments
                      assessmentsTableData = createAssessmentsTableData(h, def.assessmentsDefinition);
                      if(~isempty(assessmentsTableData))
                         table = FormalTable(assessmentsTableData);
                         table.StyleName = 'AssessmentsTable';
                         tr = TableRow();
                         append(tr, TableHeaderEntry(getString(message('sltest:assessments:editor:EnabledLabel'))));
                         append(tr, TableHeaderEntry(getString(message('sltest:assessments:editor:NameLabel'))));
                         append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Definition'))));
                         append(tr, TableHeaderEntry(getString(message('sltest:assessments:editor:RequirementsLabel'))));
                         append(table.Header, tr);
                         header = Heading5(getString(message('stm:objects:Assessments')));
                         header.StyleName = 'AssessmentsHeading';
                         content = [content {header} {table}];
                      end
                  end

                  isEquivTest = isequal(testObj.TestType, 'equivalence');

                  if(isfield(def, 'symbolsDefinition') && ~isempty(def.symbolsDefinition))
                     % Create table for symbols                 
                     if(~isEquivTest)
                         heading = Heading5(getString(message('sltest:assessments:editor:SymbolsHeaderLabel')));
                     else
                         heading = Heading5([getString(message('stm:TestSpecReportContent:SymbolsForSim')),' ','1']); 
                     end
                     heading.StyleName = 'SymbolsHeading';
                     content = [content {heading}];

                     symbolsTableData = createSymbolsTableData(h, def.symbolsDefinition);
                     if(~isempty(symbolsTableData))
                        table = FormalTable(symbolsTableData);
                         table.StyleName = 'SymbolsTable';
                         tr = TableRow();
                         append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Symbol'))));
                         append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Scope'))));
                         append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Metadata'))));
                         append(table.Header, tr);
                         content = [content {table}]; 
                     end
                  end

                  if(isEquivTest)
                      % Create table for symbols for sim 2
                     if(isfield(def, 'SymbolInfo2') && ~isempty(def.SymbolInfo2))
                         heading = Heading5([getString(message('stm:TestSpecReportContent:SymbolsForSim')),' ','2']);
                         heading.StyleName = 'SymbolsHeading';
                         content = [content {heading}];

                         symbolsTableData = createSymbolsTableData(h, def.SymbolInfo2);
                         if(~isempty(symbolsTableData))
                             table = FormalTable(symbolsTableData);
                             table.StyleName = 'SymbolsTable';
                             tr = TableRow();
                             append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Symbol'))));
                             append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Scope'))));
                             append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Metadata'))));
                             append(table.Header, tr);
                             content = [content {table}]; 
                         end
                     end
                  end
              end
           end
        end
        
        function content = getCoverageSettings(h, ~)
            import mlreportgen.dom.*;
            content = [];
            if h.IncludeCoverageSettings
               testObj = h.Object; 
               if (testObj.getCoverageSettings.RecordCoverage || testObj.getCoverageSettings.MdlRefCoverage)
                  covSettingsTableData = createCovSettingsTableData(h, testObj); 
                  if(~isempty(covSettingsTableData))
                      table = FormalTable(covSettingsTableData);
                      table.StyleName = 'TestCase_CoverageSettingsTable';
                      table = customizeTableWidthsForTable(h, table, 35);
                      header = Heading4(getString(message('stm:TestSpecReportContent:CoverageSettings')));
                      header.StyleName = 'TestCase_CoverageSettingsHeading';
                      content = [{header} {table}];
                  end
               end                
            end
        end
        
        function content = getIterations(h, rpt)
            import mlreportgen.dom.*;
            content = [];
            if h.IncludeIterations
               testObj = h.Object;
               if(~isempty(testObj.getIterations))
                  [iterTableData, hasDescriptionEntry] = createIterationsTableData(h, testObj, rpt);
                  if(~isempty(iterTableData))
                      table = FormalTable(iterTableData);
                      table.StyleName = 'IterationsTable';
                      table.Border = 'single';
                      tr = TableRow();
                      append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Name'))));
                      if(hasDescriptionEntry)
                          append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Description'))));
                      end
                      append(tr, TableHeaderEntry(getString(message('stm:objects:Details'))));
                      append(table.Header, tr);
                      header = Heading4(getString(message('stm:TestSpecReportContent:Iterations')));
                      header.StyleName = 'IterationsHeading';
                      content = [content {header} {table}];
                  end
               end
               
               if(~isempty(testObj.getProperty('IterationScript')))
                   iterationsScriptPara = Paragraph();
                   if(isequal(rpt.Type,'docx'))
                       iterationsScriptPara.WhiteSpace = 'preserve';
                   else
                       iterationsScriptPara.StyleName = 'IterationsScripts';
                   end                  
                   textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('IterationScript'));
                   if ~isempty(textNodes)
                       for i=1:numel(textNodes)
                           iterationsScriptPara.append(clone(textNodes{i}));
                       end
                       heading = Heading4(getString(message('stm:TestSpecReportContent:IterationsScript')));
                       heading.StyleName = 'IterationScriptHeading';
                       content = [content {heading} {iterationsScriptPara}];
                   end
               end
            end
        end        
    end
    
    
    methods (Access = private)
        
        function content = getConfigSettingsOverridesData(h, content, testObj, simIdx, isEquivTest)
            import mlreportgen.dom.*;
            if(isEquivTest)
                heading = Heading4([getString(message('stm:TestSpecReportContent:ConfigSettingsOverridesForSim')), ' ', num2str(simIdx)]);
            else
                heading = Heading4(getString(message('stm:TestSpecReportContent:ConfigSettingsOverrides'))); 
            end
            heading.StyleName = 'ConfigurationSettingsOverridesHeading';
            content = [content {heading}];
            
            configSettingsData = {};
            configSetOverride = testObj.getProperty('ConfigSetOverrideSetting', simIdx);
            if(isequal(configSetOverride,1))
                configSettingsData{1,1} = Text(getString(message('stm:TestSpecReportContent:ConfigSettings')));
                configSettingsData{1,2} = Text(getString(message('stm:TestSpecReportContent:DoNotOverrideModelSettings')));
            elseif(isequal(configSetOverride,2))
                configSettingsData{1,1} = Text(getString(message('stm:TestSpecReportContent:ConfigSettings')));
                configSettingsData{1,2} = Text(getString(message('stm:TestSpecReportContent:OverrideModelSettings')));
                configSettingsData{2,1} = Text(getString(message('stm:TestSpecReportContent:ConfigSetName')));
                configSettingsData{2,2} = Text(testObj.getProperty('ConfigsetName', simIdx));
            elseif(isequal(configSetOverride,3))
                configSettingsData{1,1} = Text(getString(message('stm:TestSpecReportContent:ConfigSettings')));
                configSettingsData{1,2} = Text(getString(message('stm:TestSpecReportContent:OverrideModelSettings')));
                configSettingsData{2,1} = Text(getString(message('stm:TestSpecReportContent:ConfigFile')));
                configSettingsData{2,2} = Text(testObj.getProperty('ConfigSetFileLocation', simIdx));
                configSettingsData{3,1} = Text(getString(message('stm:TestSpecReportContent:ConfigVariableName')));
                configSettingsData{3,2} = Text(testObj.getProperty('ConfigSetVarName', simIdx));
            end
            
            configSettingsTable = Table(configSettingsData);
            configSettingsTable = customizeTableWidthsForTable(h, configSettingsTable, 40);
            configSettingsTable.StyleName = 'ConfigurationSettingsTable';
            content = [content {configSettingsTable}];
        end
        
        function content = getSimulationOutputsData(h, ~, content, tc, simIdx, isEquivTest)
            import mlreportgen.dom.*;
            loggedSignalSets = tc.getLoggedSignalSets(simIdx);
            if(~isempty(loggedSignalSets))
                loggedSignalsTableData = createLoggedSignalsTableData(h, loggedSignalSets);
                if(~isempty(loggedSignalsTableData))
                    table = FormalTable(loggedSignalsTableData);
                    table.StyleName = 'SimulationOutputsTable';
                    table = customizeTableWidthsForTable(h, table, [30,50,10,10]);
                    table.Border = 'single';
                    tr = TableRow();
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Name'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Source'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:PortIndex'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:PlotIndex'))));
                    append(table.Header, tr);
                    if(isEquivTest)
                        heading = Heading4([getString(message('stm:TestSpecReportContent:LoggedSignalsForSim')),' ', num2str(simIdx)]);
                    else
                        heading = Heading4(getString(message('stm:OutputView:Label_LoggedSignals'))); 
                    end
                    heading.StyleName = 'LoggedSignalsHeading';
                    content = [content {heading} {table}];
                end
            end
            if(~tc.RunOnTarget{simIdx} && tc.getProperty('OverrideModelOutputSettings', simIdx))
                overrideText = Text(getString(message('stm:OutputView:Label_OutputToWorkspace')));
                overrideVals = UnorderedList;
                hasOverrideValue = false;
                if(tc.getProperty('SaveState', simIdx))
                    valText = Text(getString(message('stm:OutputView:Label_States')));
                    listItem = ListItem(valText);
                    append(overrideVals, listItem);
                    hasOverrideValue = true;
                end
                if(tc.getProperty('SaveOutput', simIdx))
                    valText = Text(getString(message('stm:OutputView:Label_Output')));
                    listItem = ListItem(valText);
                    append(overrideVals, listItem);
                    hasOverrideValue = true;
                end
                if(tc.getProperty('SaveFinalState', simIdx))
                    valText = Text(getString(message('stm:OutputView:Label_FinalStates')));
                    listItem = ListItem(valText);
                    append(overrideVals, listItem);
                    hasOverrideValue = true;
                end
                if(tc.getProperty('DSMLogging', simIdx))
                    valText = Text(getString(message('stm:OutputView:Label_DataStores')));
                    listItem = ListItem(valText);
                    append(overrideVals, listItem);
                    hasOverrideValue = true;
                end
                if(tc.getProperty('SignalLogging', simIdx))
                    valText = Text(getString(message('stm:OutputView:Label_SignalLogging')));
                    listItem = ListItem(valText);
                    append(overrideVals, listItem);
                    hasOverrideValue = true;
                end
                if(hasOverrideValue)
                    heading = Heading4(getString(message('stm:OutputView:Label_SimulationOutputs')));
                    heading.StyleName = 'SimulationOutputsHeading';
                    content = [content {heading} {overrideText} {overrideVals}];
                end
            end
            if(slfeature('STMOutputTriggering') > 0)
                content = getOutputTriggerData(h, content, tc, simIdx, isEquivTest);
            end
        end

        function content = getOutputTriggerData(h, content, tc, simIdx, isEquivTest)
            import mlreportgen.dom.*;
            if isEquivTest
                heading = Heading4([getString(message('stm:TestSpecReportContent:OutputTriggerForSim')),' ', num2str(simIdx)]);
            else
                heading = Heading4(getString(message('stm:OutputView:Label_OutputTriggers')));
            end
            heading.StyleName = 'LoggedSignalsHeading';
            content = [content {heading} ];
            otiObject = tc.getOutputTrigger(simIdx);
            startTriggerMode = otiObject.StartLoggingMode;
            stopTriggerMode = otiObject.StopLoggingMode;
            triggerTableData = cell(2,2);
            triggerTableData{1, 1} = Text(getString(message('stm:OutputView:Label_StartTrigger')));
            if startTriggerMode == sltest.testmanager.TriggerMode.Condition
                triggerTableData{1, 2} = Text(getString(message('stm:OutputView:ComboBox_StartTriggerOnSignal')));
                triggerTableData{1, 3} = Text(otiObject.StartLoggingCondition);
            elseif startTriggerMode == sltest.testmanager.TriggerMode.Duration
                triggerTableData{1, 2} = Text(getString(message('stm:OutputView:ComboBox_StartTriggerAfterDuration')));
                triggerTableData{1, 3} = Text(otiObject.StartLoggingDuration);
            else
                triggerTableData{1, 2} = Text(getString(message('stm:OutputView:ComboBox_StartNoTriggering')));
            end
            triggerTableData{2, 1} = Text(getString(message('stm:OutputView:Label_StopTrigger')));
            if stopTriggerMode == sltest.testmanager.TriggerMode.Condition
                triggerTableData{2, 2} = Text(getString(message('stm:OutputView:ComboBox_StopTriggerOnSignal')));
                triggerTableData{2, 3} = Text(otiObject.StopLoggingCondition);
            elseif stopTriggerMode == sltest.testmanager.TriggerMode.Duration
                triggerTableData{2, 2} = Text(getString(message('stm:OutputView:ComboBox_StopTriggerAfterDuration')));
                triggerTableData{2, 3} = Text(otiObject.StopLoggingDuration);
            else
                triggerTableData{2, 2} = Text(getString(message('stm:OutputView:ComboBox_StopNoTriggering')));
            end
            triggerTable = FormalTable(triggerTableData);
            triggerTable = customizeTableWidthsForTable(h, triggerTable, 40);
            triggerTable.StyleName = 'SimulationOutputsTable';
            content = [content {triggerTable} ];

            if otiObject.ShiftToZero
                shiftTimeToZeroText = Text(getString(message('stm:OutputView:Label_ShiftTime')));
                content = [content {shiftTimeToZeroText} ];
            end

            if ~isempty(otiObject.Symbols)
                heading = Heading5(getString(message('sltest:assessments:editor:SymbolsHeaderLabel')));
                heading.StyleName = 'SymbolsHeading';
                content = [content {heading}];
                symbolsTableData = createSymbolsTableData(h, otiObject.Symbols);
                if(~isempty(symbolsTableData))
                    table = FormalTable(symbolsTableData);
                    table.StyleName = 'SymbolsTable';
                    tr = TableRow();
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Symbol'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Scope'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Metadata'))));
                    append(table.Header, tr);
                    content = [content {table}]; 
                 end
            end
        end
        
        function content = getExternalInputsData(h, ~, content, testObj, simIdx, isEquivTest)
            import mlreportgen.dom.*;
            inputs = testObj.getInputs(simIdx);
            if (~isempty(inputs))
                inputsTableData = createInputsTableData(h, inputs);
                [~,col] = size(inputsTableData);
                if(~isempty(inputsTableData))
                    if(isEquivTest)
                        heading = Heading4([getString(message('stm:TestSpecReportContent:ExtInputsForSim')),' ', num2str(simIdx)]);
                    else
                        heading = Heading4(getString(message('stm:TestSpecReportContent:ExtInputsHeading')));
                    end
                    heading.StyleName = 'ExternalInputsHeading';
                    table = FormalTable(inputsTableData);
                    table.StyleName = 'ExternalInputsTable';
                    table.Border = 'single';
                    tr = TableRow();
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Name'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:FilePath'))));
                    if(isequal(col,4))
                        append(tr, TableHeaderEntry(getString(message('stm:TestFileXMLTagMapping:Sheet'))));
                        append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Status'))));
                        table = customizeTableWidthsForTable(h, table, [20,50,20,20]);
                    else
                        append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Status'))));
                        table = customizeTableWidthsForTable(h, table, [25,55,20]);
                    end
                    append(table.Header, tr);
                    content = [content {heading} {table}];
                end
            end 
            if(testObj.getProperty('UseSignalBuilderGroups', simIdx))
                if(isempty(testObj.getProperty('SignalBuilderGroup', simIdx)))
                    sigBuilderText = Text([getString(message('stm:InputsView:SignalBuilderGroupLabel')),': '...
                        getString(message('stm:general:Label_ModelSettings'))]);
                else
                    sigBuilderText = Text([getString(message('stm:InputsView:SignalBuilderGroupLabel')),': '...
                        testObj.getProperty('SignalBuilderGroup', simIdx)]);
                end
                content = [content {sigBuilderText}];
            end
            if(~isempty(testObj.getProperty('TestSequenceBlock', simIdx)))
                testSequenceBlockText = Text([getString(message('stm:InputsView:TestSequenceBlockLabel')), ' ', ...
                        testObj.getProperty('TestSequenceBlock', simIdx)]);
                if(isempty(testObj.getProperty('TestSequenceScenario', simIdx)))
                    testSequenceText = Text([getString(message('stm:InputsView:TestSequenceScenarioLabel')),' '...
                        getString(message('stm:general:Label_ModelSettings'))]);
                else
                    testSequenceText = Text([getString(message('stm:InputsView:TestSequenceScenarioLabel')),' '...
                        testObj.getProperty('TestSequenceScenario', simIdx)]);
                end
                content = [content {testSequenceBlockText} {testSequenceText}];
            end
        end
        
        function content = getParamSetsData(h, ~, content, tc, simIdx, isEquivTest)
            import mlreportgen.dom.*;
            paramSets = tc.getParameterSets(simIdx);
            if(~isempty(paramSets))
                paramSetsTableData = createParamSetsTableData(h, paramSets);
                if(~isempty(paramSetsTableData))
                    if(isEquivTest)
                        heading = Heading4([getString(message('stm:TestSpecReportContent:ParamSetsForSim')),' ',num2str(simIdx)]);
                    else
                        heading = Heading4(getString(message('stm:TestSpecReportContent:ParamSets')));
                    end
                    heading.StyleName = 'ParameterSetsHeading';
                    table = FormalTable(paramSetsTableData);
                    table.StyleName = 'ParameterSetsTable';
                    table = customizeTableWidthsForTable(h, table, [33,20,13]);
                    tr = TableRow();
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:WorkspaceVariable'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:OverrideValue'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:Source'))));
                    append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:ModelElements'))));
                    append(table.Header, tr);
                    table.Header.TableEntriesVAlign = 'middle';
                    table.Header.TableEntriesHAlign = 'center';
                    content = [content {heading} {table}];
                end
            end
        end
        
        function content = getCallbacksData(h, rpt, testObj, content, simIdx, isEquivTest)
            import mlreportgen.dom.*;
            if(~isempty(testObj.getProperty('PreloadCallback', simIdx)))
                preLoadCallbackPara = Paragraph();
                if(isequal(rpt.Type,'docx'))
                    preLoadCallbackPara.WhiteSpace = 'preserve';
                else
                    preLoadCallbackPara.StyleName = 'PreLoadCallbackScripts';
                end                
                textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('PreloadCallback', simIdx));   
                if ~isempty(textNodes)
                    for i=1:numel(textNodes)
                        preLoadCallbackPara.append(clone(textNodes{i}));
                    end
                    if(isEquivTest)
                        heading = Heading4([getString(message('stm:TestSpecReportContent:PreLoadCallbackForSim')),' ',num2str(simIdx)]);
                    else
                        heading = Heading4(getString(message('stm:TestSpecReportContent:PreLoadCallback')));
                    end
                    heading.StyleName = 'PreLoadCallbackHeading';
                    content = [content {heading} {preLoadCallbackPara}];
                end
           end

           if(~isempty(testObj.getProperty('PostloadCallback', simIdx)))
               postLoadCallbackPara = Paragraph();
               if(isequal(rpt.Type,'docx'))
                    postLoadCallbackPara.WhiteSpace = 'preserve';
               else
                    postLoadCallbackPara.StyleName = 'PostLoadCallbackScripts';
               end
               textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('PostloadCallback', simIdx));
               if ~isempty(textNodes)
                   for i=1:numel(textNodes)
                       postLoadCallbackPara.append(clone(textNodes{i}));
                   end
                   if(isEquivTest)
                       heading = Heading4([getString(message('stm:TestSpecReportContent:PostLoadCallbackForSim')),' ',num2str(simIdx)]);
                   else
                       heading = Heading4(getString(message('stm:TestSpecReportContent:PostLoadCallback')));
                   end
                   heading.StyleName = 'PostLoadCallbackHeading';
                   content = [content {heading} {postLoadCallbackPara}];
               end
           end

           if(testObj.RunOnTarget{simIdx})
               if(~isempty(testObj.getProperty('PreStartRealTimeApplicationCallback', simIdx)))
                   realTimeCallbackPara = Paragraph();
                   if(isequal(rpt.Type,'docx'))
                      realTimeCallbackPara.WhiteSpace = 'preserve';
                   else
                      realTimeCallbackPara.StyleName = 'RealTimeCallbackScripts';
                   end
                   textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('PreStartRealTimeApplicationCallback', simIdx));
                   if ~isempty(textNodes)
                       for i=1:numel(textNodes)
                           realTimeCallbackPara.append(clone(textNodes{i}));
                       end
                       if(isEquivTest)
                           heading = Heading4([getString(message('stm:TestSpecReportContent:RealTimeCallbackForSim')),' ',num2str(simIdx)]);
                       else
                           heading = Heading4(getString(message('stm:TestSpecReportContent:RealTimeCallback')));
                       end
                       heading.StyleName = 'PreStartRealTimeCallbackHeading';
                       content = [content {heading} {realTimeCallbackPara}];
                   end
               end
           end

           if(~isempty(testObj.getProperty('CleanupCallback', simIdx)))
               cleanupCallbackPara = Paragraph();
               if(isequal(rpt.Type,'docx'))
                  cleanupCallbackPara.WhiteSpace = 'preserve';
               else
                  cleanupCallbackPara.StyleName = 'CleanupCallbackScripts';
               end
               textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('CleanupCallback', simIdx));
               if ~isempty(textNodes)
                   for i=1:numel(textNodes)
                       cleanupCallbackPara.append(clone(textNodes{i}));
                   end
                   if(isEquivTest)
                       heading = Heading4([getString(message('stm:TestSpecReportContent:CleanupCallbackForSim')),' ',num2str(simIdx)]);
                   else
                       heading = Heading4(getString(message('stm:TestSpecReportContent:CleanupCallback')));
                   end
                   heading.StyleName = 'CleanupCallbackHeading';
                   content = [content {heading} {cleanupCallbackPara}];
               end
           end
        end
        
        function content = getSystemUnderTestData(h, rpt, content, testObj, simIdx, modelName, harnessModelPath)
            import mlreportgen.dom.*;
            if(testObj.RunOnTarget{simIdx})
                heading = Heading5(getString(message('stm:TestSpecReportContent:TargetSettings')));
                heading.StyleName = 'TargetSettingsHeading';
                content = [content {heading}];
                targetData = {};
                targetData{1,1} = getString(message('stm:TestSpecReportContent:LoadAppFrom'));
                if(testObj.getProperty('LoadAppFrom',simIdx) == 1)
                   model = testObj.getProperty('model',simIdx);
                   targetData{1,2} = getString(message('stm:TestSpecReportContent:Model'));
                   targetData{2,1} = getString(message('stm:TestSpecReportContent:ModelEntry'));
                   targetData{2,2} = model;
                   targetData{3,1} = getString(message('stm:TestSpecReportContent:TargetCompEntry'));
                   targetData{3,2} = testObj.getProperty('TargetComputer',simIdx);
                elseif (testObj.getProperty('LoadAppFrom',simIdx) == 2)                   
                   targetData{1,2} = getString(message('stm:TestSpecReportContent:TargetApp'));
                   targetData{2,1} = getString(message('stm:TestSpecReportContent:TargetAppEntry'));
                   targetData{2,2} = testObj.getProperty('TargetApplication',simIdx);
                   targetData{3,1} = getString(message('stm:TestSpecReportContent:TargetCompEntry'));
                   targetData{3,2} = testObj.getProperty('TargetComputer',simIdx);
                elseif (testObj.getProperty('LoadAppFrom',simIdx) == 3)
                   targetData{1,2} = getString(message('stm:TestSpecReportContent:TargetComp'));
                   targetData{2,1} = getString(message('stm:TestSpecReportContent:TargetCompEntry'));
                   targetData{2,2} = testObj.getProperty('TargetComputer',simIdx);
                end
                targetTable = Table(targetData);
                targetTable.StyleName = 'TargetSettingsTable';
                targetTable = customizeTableWidthsForTable(h, targetTable, 35);
                content = [content {targetTable}];
                
            end
            if(~isempty(modelName))
                modelHeading = Heading5([getString(message('stm:TestSpecReportContent:ModelNameEntry')), ' ']);
                if(isequal(rpt.Type,'html'))
                    modelText = ExternalLink(['matlab:open_system(''',modelName,''')'], modelName);
                else
                    modelText = Text(modelName);
                end
                append(modelHeading, modelText);
                modelHeading.StyleName = 'ModelNameHeading';
                content = [content {modelHeading}];
                if ~bdIsLoaded(modelName)
                    load_system(modelName);
                end
                modelImage = slreportgen.report.Diagram(modelName);
                content = [content {modelImage}];
                if(~isempty(harnessModelPath))
                    harnessName = testObj.getProperty('HarnessName',simIdx);
                    harnessHeading = Heading5([getString(message('stm:TestSpecReportContent:HarnessNameEntry')),' ']);
                    harnessHeading.StyleName = 'HarnessNameHeading';
                    content = [content {harnessHeading}];
                    [~,harnessModelName,~] = fileparts(harnessModelPath);
                    if ~bdIsLoaded(harnessModelName)
                        load_system(harnessModelPath);
                    end
                    harnessImage = slreportgen.report.Diagram(harnessModelName);
                    content = [content {harnessImage}];
                    harness = sltest.harness.find(modelName, 'Name', harnessName);
                    if(isequal(rpt.Type, 'html') && ~isempty(harness))
                        harnessText = ExternalLink(['matlab:open_system(''',modelName,''');sltest.harness.open(''',harness.ownerFullPath,''',''',harness.name,''')'], harnessName);
                    else
                        harnessText = Text(harnessName);
                    end
                    append(harnessHeading, harnessText);
                    
                    if slfeature('STMTestSpecRptMaskParam') > 0
                        content = createMaskParamsContent(h,content,harness);                    
                    end
                    
                    status = license('test','simulink_report_gen');
                    load_system(harnessModelPath);
                    testSeqBlocks = find(sfroot,'-isa','Stateflow.ReactiveTestingTableChart');
                    if(logical(status) && ~isempty(testSeqBlocks))
                        testSeqDataString = getString(message('stm:TestSpecReportContent:TestSeqData'));
                        testSeqBlocksLength = length(testSeqBlocks);
                        for i=1:testSeqBlocksLength
                            if isequal(testSeqBlocks(i).Machine.Name,harnessModelName)
                                testSeqRptr = slreportgen.report.TestSequence(testSeqBlocks(i).Path);
                                blockPathForHeading = strrep(testSeqBlocks(i).Path,harnessModelName,harnessName);
                                testSeqHeading = Heading6([testSeqDataString,': ',blockPathForHeading]);
                                testSeqHeading.StyleName = 'TestSequenceHeading';
                                content = [content {testSeqHeading} {testSeqRptr}];
                            end
                        end
                    end
                end  
            end 
            if(~testObj.RunOnTarget{simIdx})
                heading = Heading5(getString(message('stm:TestSpecReportContent:SimSettingsOverrides')));
                heading.StyleName = 'SimulationSettingsHeading';
                content = [content {heading}];
                simMode = testObj.getProperty('SimulationMode',simIdx);
                simSettingsContent = {};
                idx = 1;
                simSettingsContent{idx,1} = Text(getString(message('stm:TestSpecReportContent:SimMode')));
                if(~isempty(simMode))
                    simModeText = Text(simMode);
                else
                    simModeText = Text(getString(message('stm:general:Label_ModelSettings')));
                end
                simSettingsContent{idx,2} = simModeText;

                releases = testObj.getProperty('Release',simIdx);
                if(~isempty(releases))
                    idx = idx+1;
                    simSettingsContent{idx,1} = Text(getString(message('stm:TestSpecReportContent:Releases')));                        
                    simSettingsContent{idx,2} = strjoin(releases, ', ');
                end
                
                if(testObj.getProperty('OverrideStartTime',simIdx))
                    startTime = testObj.getProperty('StartTime',simIdx);
                    if(~isempty(startTime))
                        idx = idx+1;
                        simSettingsContent{idx,1} = Text(getString(message('stm:TestSpecReportContent:StartTime')));
                        startTimeText = Text(num2str(startTime));
                        simSettingsContent{idx,2} = startTimeText;
                    end
                end

                if(testObj.getProperty('OverrideStopTime',simIdx))
                    stopTime = testObj.getProperty('StopTime',simIdx);
                    if(~isempty(stopTime))
                        idx = idx+1;
                        simSettingsContent{idx,1} = Text(getString(message('stm:TestSpecReportContent:StopTime')));
                        stopTimeText = Text(num2str(stopTime));
                        simSettingsContent{idx,2} = stopTimeText;
                    end
                end

                if(testObj.getProperty('OverrideInitialState',simIdx))
                    initState = testObj.getProperty('InitialState',simIdx);
                    if(~isempty(initState))
                        idx = idx+1;
                        simSettingsContent{idx,1} = Text(getString(message('stm:TestSpecReportContent:InitialState')));
                        initStateText = Text(initState);
                        simSettingsContent{idx,2} = initStateText;
                    end
                end  
                
                simSettingsTable = Table(simSettingsContent);
                simSettingsTable.StyleName = 'SimulationSettingsTable';
                simSettingsTable = customizeTableWidthsForTable(h, simSettingsTable, 35);
                
                content = [content {simSettingsTable}];
                
                if(testObj.getProperty('overridesilpilmode', simIdx))
                   silPilModeText = Text(getString(message('stm:SystemUnderTestView:SILPILModeOverriddenLabel')));
                   content = [content {silPilModeText}];
                end     
            else
                if(testObj.getProperty('OverrideStopTime', simIdx))
                    stopTime = testObj.getProperty('StopTime',simIdx);
                    if(~isempty(stopTime))
                        heading = Heading5(getString(message('stm:TestSpecReportContent:SimSettingsOverrides')));
                        heading.StyleName = 'SimulationSettingsHeading';
                        content = [content {heading}];
                        simSettingsContent = {};
                        simSettingsContent{1,1} = Text(getString(message('stm:TestSpecReportContent:StopTime')));
                        stopTimeText = Text(num2str(stopTime));
                        simSettingsContent{1,2} = stopTimeText;
                        simSettingsTable = Table(simSettingsContent);
                        simSettingsTable.StyleName = 'SimulationSettingsTable';
                        simSettingsTable = customizeTableWidthsForTable(h, simSettingsTable, 35);
                        content = [content {simSettingsTable}];
                    end
                end
            end
        end
        
        function content = createMaskParamsContent(~,content,harness)
           import mlreportgen.dom.*;
           harnessToClose = [];
           if ~bdIsLoaded(harness.name)
               stm.internal.util.loadHarness(harness.ownerFullPath,harness.name);
               harnessToClose = harness.name;
           end
           oc = onCleanup(@()close_system(harnessToClose,0));
           compUnderTest = Simulink.harness.internal.getActiveHarnessCUT(bdroot(harness.ownerFullPath));
           
           if ~isempty(compUnderTest)
               maskVars = get_param(compUnderTest,'MaskWSVariables');
               if ~isempty(maskVars)
                   maskParamsData = cell(length(maskVars),2);
                   for idx = 1:length(maskVars)
                       maskParamsData{idx,1} = Text(maskVars(idx).Name);
                       [~,value,dataType] = stm.internal.util.getDisplayValue(maskVars(idx).Value);
                       maskParamsData{idx,2} = Text([value,' (',dataType,')']);
                   end                  
                   table = FormalTable(maskParamsData);
                   table.StyleName = 'ParameterSetsTable';
                   tr = TableRow();
                   append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:WorkspaceVariable'))));
                   append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:DefaultValue'))));
                   append(table.Header, tr);
                   table.Header.TableEntriesVAlign = 'middle';
                   table.Header.TableEntriesHAlign = 'center';
                   paramsHeading = Heading5(getString(message('stm:TestSpecReportContent:MaskParams',...
                       compUnderTest)));
                   paramsHeading.StyleName = 'HarnessNameHeading';
                   content = [content {paramsHeading} {table}];
               end
           end
        end
        
        function paramSetsTableData = createParamSetsTableData(~, paramSets)
            import mlreportgen.dom.*;
            paramSetsTableData = {};
            rowIdx = 1;
            for i = 1:length(paramSets)
                if(paramSets(i).Active)
                    paramSetsTableData{rowIdx,1} = Text(message('stm:TestSpecReportContent:TestDataActive',...
                        paramSets(i).Name ).string); 
                else
                    paramSetsTableData{rowIdx,1} = Text(paramSets(i).Name);
                end
                paramOverrides = paramSets(i).getParameterOverrides;
                if(~isempty(paramOverrides))
                    for j = 1:length(paramOverrides)
                        paramSetsTableData{rowIdx+j, 1} = [char(9642),' ',paramOverrides(j).Name];
                        val = paramOverrides(j).getDisplayValue;
                        paramSetsTableData{rowIdx+j,2} = val;
                        paramSetsTableData{rowIdx+j, 3} = Text(paramOverrides(j).SourceType);
                        modelElems = stm.internal.getParameterModelElements(paramOverrides(j).id);
                        if(isequal(length(modelElems),1))
                            paramSetsTableData{rowIdx+j, 4} = modelElems{1};
                        else
                            elemsList = UnorderedList;
                            for k = 1:length(modelElems)
                                elemText = Text(modelElems{k});
                                listItem = ListItem(elemText);
                                append(elemsList, listItem);
                            end
                            paramSetsTableData{rowIdx+j, 4} = elemsList;
                        end
                    end
                    rowIdx = rowIdx+j+1;
                else
                    rowIdx = rowIdx+1;
                end
            end       
        end
        
        function inputsTableData = createInputsTableData(~, inputs)
            import mlreportgen.dom.*;
            inputsTableData = cell(length(inputs),3);
            for i = 1:length(inputs)
                if(inputs(i).Active)
                    inputsTableData{i,1} =  Text( message('stm:TestSpecReportContent:TestDataActive',...
                        inputs(i).Name ).string );
                else
                    inputsTableData{i,1} =  Text(inputs(i).Name);
                end
                inputsTableData{i,2} =  Text(inputs(i).FilePath);
                if(~isempty(inputs(i).ExcelSpecifications))
                    inputsTableData{i,3} =  Text(inputs(i).ExcelSpecifications.Sheet);
                    inputsTableData{i,4} =  Text(inputs(i).MappingStatus);
                else
                    inputsTableData{i,3} =  Text(inputs(i).MappingStatus);
                end
            end
        end
        
        function loggedSignalsTableData = createLoggedSignalsTableData(~, signalSets)
            import mlreportgen.dom.*;
            loggedSignalsTableData = {};
            rowIdx = 1;
            for i = 1:length(signalSets)
                loggedSignalsTableData{rowIdx,1} = Text(signalSets(i).Name);
                signals = signalSets(i).getLoggedSignals;
                if(~isempty(signals))
                    for j = 1:length(signals)
                        sigName = UnorderedList;
                        sigText = Text(signals(j).Name);
                        listItem = ListItem(sigText);
                        append(sigName, listItem);
                        loggedSignalsTableData{rowIdx+j,1} = sigName;
                        loggedSignalsTableData{rowIdx+j,2} = Text(signals(j).Source);
                        portIndex = signals(j).PortIndex;
                        if(~isequal(portIndex,0))
                            loggedSignalsTableData{rowIdx+j,3} = Text(signals(j).PortIndex);
                        end
                        loggedSignalsTableData{rowIdx+j,4} = Text(string(signals(j).PlotIndices));
                    end
                    rowIdx = rowIdx+j+1;
                else
                    rowIdx = rowIdx+1;
                end
            end            
        end
        
        function baselineTableData = createBaselineTableData(~, data)
            import mlreportgen.dom.*;
            baselineTableData = {};
            rowIdx = 1;
            for i = 1:length(data)
                if(data(i).Active)
                    baselineTableData{rowIdx,1} = Text(message('stm:TestSpecReportContent:TestDataActive',...
                        data(i).Name ).string);
                else
                    baselineTableData{rowIdx,1} = Text(data(i).Name);
                end
                baselineTableData{rowIdx,2} = Text(data(i).AbsTol);
                baselineTableData{rowIdx,3} = Text(data(i).RelTol);
                baselineTableData{rowIdx,4} = Text(data(i).LeadingTol);
                baselineTableData{rowIdx,5} = Text(data(i).LaggingTol);
                signals = data(i).getSignalCriteria;
                if(~isempty(signals))
                    for j = 1:length(signals)
                        sigName = UnorderedList;
                        if(signals(j).Enabled)
                            sigText = Text(message('stm:TestSpecReportContent:TestDataActive',...
                                signals(j).Name ).string);
                        else
                            sigText = Text(signals(j).Name);
                        end
                        
                        listItem = ListItem(sigText);
                        append(sigName, listItem);
                        baselineTableData{rowIdx+j,1} = sigName;
                        baselineTableData{rowIdx+j,2} = Text(signals(j).AbsTol);
                        baselineTableData{rowIdx+j,3} = Text(signals(j).RelTol);
                        baselineTableData{rowIdx+j,4} = Text(signals(j).LeadingTol);
                        baselineTableData{rowIdx+j,5} = Text(signals(j).LaggingTol);
                    end
                    rowIdx = rowIdx+j+1;
                else
                    rowIdx = rowIdx+1;
                end
            end
        end
        
        function equivTableData = createEquivalenceTableData(~, data)
            import mlreportgen.dom.*;
            equivTableData = cell(length(data),5);
            signals = data.getSignalCriteria;
            for i = 1:length(signals)
                if(signals(i).Enabled)
                    equivTableData{i,1} = Text(message('stm:TestSpecReportContent:TestDataActive',...
                        signals(i).Name ).string);
                else
                    equivTableData{i,1} = Text(signals(i).Name);
                end
                equivTableData{i,2} = Text(signals(i).AbsTol);
                equivTableData{i,3} = Text(signals(i).RelTol);
                equivTableData{i,4} = Text(signals(i).LeadingTol);
                equivTableData{i,5} = Text(signals(i).LaggingTol);
            end
        end
        
        function [iterTableData, hasDescriptionEntry] = createIterationsTableData(h, tc, rpt)
            iterTableData = {};
            iter = tc.getIterations;
            numIter = length(iter);
            rowIdx = 1;
            hasDescriptionEntry = any(strlength({iter.Description}) > 0);
            for i=1:numIter               
               detailsTable = createIterationDetailsTable(h, iter(i), tc, rpt);
               iterTableData{rowIdx,1} = iter(i).Name;
               if(~isempty(iter(i).Description) || hasDescriptionEntry)
                   iterTableData{rowIdx,3} = detailsTable;
                   hasDescriptionEntry = true;
                   if(~isempty(iter(i).Description))
                       desc = mlreportgen.dom.HTML(iter(i).Description);
                       iterTableData{rowIdx,2} = getDescriptionTable(h,desc.Children);
                   end
               else
                   iterTableData{rowIdx,2} = detailsTable;
               end
               rowIdx = rowIdx+1;
            end
        end
        
        function iterDetailsTableWrapper = createIterationDetailsTable(h, iter, tc, rpt)
           import mlreportgen.dom.*;
           iterDetailsTableWrapper = {};
           
           modelParams = iter.ModelParams;
           modelParamsTable = {};
           if ~isempty(modelParams)
               modelParamsData = {};
               for i=1:length(modelParams)
                   modelParamsData{i,1} = modelParams{i}{1};
                   modelParamsData{i,2} = modelParams{i}{2};
                   modelParamsData{i,3} = modelParams{i}{3};
               end
               modelParamsTable = FormalTable(modelParamsData);
               modelParamsTable.StyleName = 'IterationDetailsTable';
               tr = TableRow();
               append(tr, TableHeaderEntry(getString(message('stm:objects:System'))));
               append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:ParamName'))));
               append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:ParamValue'))));
               append(modelParamsTable.Header, tr);
           end
           
           isBaselineTest = isequal(tc.TestType, 'baseline');
           isEquivTest = isequal(tc.TestType, 'equivalence');
               
           detailsData = {};
           tp = iter.TestParams;
           if(isEquivTest)
               detailsData = createIterationsDetailsTableHelper(h, tp, 14, tc, detailsData);
           else
               % For baseline test and simulation test
               detailsData = createIterationsDetailsTableHelper(h, tp, 7, tc, detailsData);           
               if(isBaselineTest)
                   baselineCell = tp{8};
                   if(~isempty(baselineCell{2}) || ~isempty(tc.getBaselineCriteria))
                       paramName = getString(message('stm:ResultsTree:Baseline'));
                       simIdx = baselineCell{3};
                       value = '';
                       if(~isempty(baselineCell{2}))
                           value = baselineCell{2};
                       else
                           baseline = tc.getBaselineCriteria;
                           if(~isempty(find([baseline.Active],1)))
                               value = baseline(find([baseline.Active],1)).Name;
                           end
                       end
                       if(~isempty(value))
                           dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
                           detailsData = [detailsData {dataStruct}];
                       end
                   end
               end
           end
           
           % Extract contents of detailsData into a tabular format
           detailsTableData = {};
           for i=1:length(detailsData)
               detailsTableData{i,1} = detailsData{i}.dataParamName;
               detailsTableData{i,2} = detailsData{i}.dataValue;
               if(isEquivTest)
                  detailsTableData{i,3} = detailsData{i}.dataSimIdx; 
               end
           end
           
           iterDetailsTable = {};
           if(~isempty(detailsTableData))
               iterDetailsTable = FormalTable(detailsTableData);
               iterDetailsTable.StyleName = 'IterationDetailsTable';
               tr = TableRow();
               append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:ParamName'))));
               append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:ParamValue'))));
               if(isEquivTest)
                  append(tr, TableHeaderEntry(getString(message('stm:TestSpecReportContent:SimIdx')))); 
               end
               append(iterDetailsTable.Header, tr);
           end
           
           rowIdx = 1;
           iterDetailsTableWrapperContent = {};
           if ~isempty(modelParamsTable)
               iterDetailsTableWrapperContent{rowIdx,1} = {Text(getString(message('stm:objects:ModelOverrides')))};
               iterDetailsTableWrapperContent{rowIdx+1,1} = modelParamsTable;
               rowIdx = rowIdx+2;
           end
           
           if ~isempty(iterDetailsTable)
               iterDetailsTableWrapperContent{rowIdx,1} = {Text(getString(message('stm:objects:TestOverrides')))};
               iterDetailsTableWrapperContent{rowIdx+1,1} = iterDetailsTable;
           end
           
           if ~isempty(iterDetailsTableWrapperContent)
               iterDetailsTableWrapper = FormalTable(iterDetailsTableWrapperContent);
               if ~isequal(rpt.Type,'docx')
                   iterDetailsTableWrapper.Border = 'hidden';
                   iterDetailsTableWrapper.RowSep = 'hidden';
               end
           end
        end
        
        function detailsData = createIterationsDetailsTableHelper(h, tp, iterRange, tc, detailsData)
            for i=1:iterRange
                switch tp{i}{1}
                    case 'ConfigSet'
                        detailsData = appendConfigSetIterStruct(h, tp{i}, tc, detailsData);
                    case 'SignalBuilderGroup'
                        detailsData = appendSigBuilderIterStruct(h, tp{i}, tc, detailsData);
                    case 'ExternalInput'
                        detailsData = appendExtInputsIterStruct(h, tp{i}, tc, detailsData);
                    case 'ParameterSet'
                        detailsData = appendParamSetIterStruct(h, tp{i}, tc, detailsData);
                    case 'LoggedSignalSet'
                        detailsData = appendLoggedSignalSetIterStruct(h, tp{i}, tc, detailsData);
                    case 'Assessments'
                        detailsData = appendAssessmentsIterStruct(h, tp{i}, tc, detailsData);
                    case 'TestSequenceScenario'
                        detailsData = appendTestSequenceIterStruct(h, tp{i}, tc, detailsData);
                end
            end
        end
        
        function detailsData = appendConfigSetIterStruct(~, configSetCell, tc, detailsData)
            simIdx = configSetCell{3};
            if tc.RunOnTarget{simIdx}
                return; % SLRT does not have configset option
            elseif ~isempty(configSetCell{2}) || ~isempty(tc.getProperty('ConfigsetName', simIdx))
               paramName = getString(message('stm:TestSpecReportContent:ConfigSet'));
               value = configSetCell{2};
               dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
               detailsData = [detailsData {dataStruct}];
           end
        end

        function detailsData = appendSigBuilderIterStruct(~, sigBuilderCell, tc, detailsData)
            if(~isempty(sigBuilderCell{2}) || ~isempty(tc.getProperty('signalbuildergroup',sigBuilderCell{3})))
               paramName = getString(message('stm:TestSpecReportContent:SigBuilderGroup'));
               simIdx = sigBuilderCell{3};
               if(~isempty(sigBuilderCell{2}))
                   value = sigBuilderCell{2};
               else
                   value = tc.getProperty('signalbuildergroup',simIdx);
               end
               dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
               detailsData = [detailsData {dataStruct}];
           end
        end
        
        function detailsData = appendExtInputsIterStruct(~, extInputsCell, tc, detailsData)
            if(~isempty(extInputsCell{2}) || ~isempty(tc.getInputs(extInputsCell{3})))
               paramName = getString(message('stm:TestSpecReportContent:ExtInputs'));
               simIdx = extInputsCell{3};
               value = '';
               if(~isempty(extInputsCell{2}))
                   value = extInputsCell{2};
               else
                   extInputs = tc.getInputs(simIdx);
                   for j=1:length(extInputs)
                      if(extInputs(j).Active)
                         value = extInputs(j).Name;
                         break;
                      end
                   end
               end
               if ~isempty(value)
                   dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
                   detailsData = [detailsData {dataStruct}];
               end
           end
        end
        
        function detailsData = appendParamSetIterStruct(~, paramSetCell, tc, detailsData)
            if(~isempty(paramSetCell{2}) || ~isempty(tc.getParameterSets(paramSetCell{3})))
               paramName = getString(message('stm:TestSpecReportContent:ParamSet'));
               simIdx = paramSetCell{3};
               value = '';
               if(~isempty(paramSetCell{2}))
                   value = paramSetCell{2};
               else
                   paramSets = tc.getParameterSets(simIdx);
                   for j=1:length(paramSets)
                      if(paramSets(j).Active)
                         value = paramSets(j).Name;
                         break;
                      end
                   end
               end
               if ~isempty(value)
                   dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
                   detailsData = [detailsData {dataStruct}];
               end
           end
        end
        
        function detailsData = appendLoggedSignalSetIterStruct(~, loggedSignalSetCell, tc, detailsData)
            if(~isempty(loggedSignalSetCell{2}) || ~isempty(tc.getLoggedSignalSets(loggedSignalSetCell{3})))
               paramName = getString(message('stm:TestSpecReportContent:LoggedSignalSet'));
               simIdx = loggedSignalSetCell{3};
               value = '';
               if(~isempty(loggedSignalSetCell{2}))
                   value = loggedSignalSetCell{2};
               else
                   loggedSignalSets = tc.getLoggedSignalSets(simIdx);
                   for j=1:length(loggedSignalSets)
                      if(loggedSignalSets(j).Active)
                         value = loggedSignalSets(j).Name;
                         break;
                      end
                   end
               end
               if ~isempty(value)
                   dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
                   detailsData = [detailsData {dataStruct}];
               end
           end
        end
        
        function detailsData = appendAssessmentsIterStruct(~, assessmentsCell, tc, detailsData)
            if(~isempty(assessmentsCell{2}))
               paramName = getString(message('stm:objects:Assessments'));
               simIdx = assessmentsCell{3};
               value = assessmentsCell{2};
               match = ["[","]",""""];
               value = erase(value,match);
               dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
               detailsData = [detailsData {dataStruct}];
            end
        end
        
        function detailsData = appendTestSequenceIterStruct(~, testSequenceCell, tc, detailsData)
            if(~isempty(testSequenceCell{2}) || ~isempty(tc.getProperty('testsequencescenario',testSequenceCell{3})))
               paramName = getString(message('stm:objects:TestSequenceScenario'));
               simIdx = testSequenceCell{3};
               if(~isempty(testSequenceCell{2}))
                   value = testSequenceCell{2};
               else
                   value = tc.getProperty('testsequencescenario',simIdx);
               end
               dataStruct = struct('dataParamName',paramName,'dataValue',value,'dataSimIdx',simIdx);
               detailsData = [detailsData {dataStruct}];
           end
        end
        
        function tableData = createAssessmentsTableData(~, def)
            import mlreportgen.dom.*;
            tableData = cell(length(def),4);
            for i=1:length(def)
               if(def(i).enabled)
                  tableData{i,1} =  Text(getString(message('stm:TestSpecReportContent:True')));
               else
                  tableData{i,1} =  Text(getString(message('stm:TestSpecReportContent:False'))); 
               end               
               tableData{i,2} = Text(def(i).assessmentName);
               str = def(i).formattedLabel;
               tableData{i,3} = HTML(str).Children;
               tableData{i,4} = Text(def(i).requirements);
            end
        end
        
        function tableData = createSymbolsTableData(h, def)
            import mlreportgen.dom.*;
            tableData = cell(length(def),3);
            for i = 1:length(def)
               tableData{i,1} = Text(def{i}.Name);
               tableData{i,2} = Text(def{i}.Scope);
               tableData{i,3} = createSymbolsMetaDataTable(h, def{i}.Value);
            end
        end
        
        function metaDataTable = createSymbolsMetaDataTable(~, metaData)
           import mlreportgen.dom.*;  
           metaDataTable = {};
           if(~isempty(metaData))
               if(isfield(metaData, 'FieldElement'))
                  metaDataTableData = cell(4,2);
                  metaDataTableData{1,1} = Text(getString(message('sltest:assessments:editor:NameLabel')));
                  % making sure the properties do exist before accessing
                  % if not existing, leave blank in report
                  if(isfield(metaData, 'Name'))
                    metaDataTableData{1,2} = Text(metaData.Name);
                  end
                  metaDataTableData{2,1} = Text(getString(message('stm:TestSpecReportContent:Path')));
                  if(isfield(metaData, 'Path'))
                    metaDataTableData{2,2} = Text(metaData.Path);
                  end
                  metaDataTableData{3,1} = Text(getString(message('stm:TestSpecReportContent:PortIndex')));
                  if(isfield(metaData, 'PortIndex'))
                    metaDataTableData{3,2} = Text(metaData.PortIndex);
                  end
                  metaDataTableData{4,1} = Text(getString(message('stm:TestSpecReportContent:FieldElement')));
                  if(isfield(metaData, 'FieldElement'))
                    metaDataTableData{4,2} = Text(metaData.FieldElement);
                  end
                  metaDataTable = Table(metaDataTableData);
                  metaDataTable.StyleName = 'SymbolsMetadataTable';
               elseif(isfield(metaData, 'Mapping'))
                  metaDataTable = Text(metaData.Mapping);
               elseif(isfield(metaData, 'Expression'))
                  metaDataTable = Text(metaData.Expression);
               end
           end         
        end
        
    end
       
    methods (Static)
        
        function path = getClassFolder()
           % path = getClassFolder() returns the folder location which
           % contains this class.  
           [path] = fileparts(mfilename('fullpath')); 
        end
        
        function template = createTemplate(templatePath, type)
            
            path = sltest.testmanager.TestCaseReporter.getClassFolder();
            template = mlreportgen.report.ReportForm.createFormTemplate(...
                templatePath, type, path);
        end
        
        function classfile = customizeReporter(toClasspath)
                       
           classfile = mlreportgen.report.ReportForm.customizeClass(toClasspath,...
               "sltest.testmanager.TestCaseReporter");
        end
        
    end  
end

%---------Validators--------------------------

function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end

function mustBeInstanceOf(varargin)
    mlreportgen.report.validators.mustBeInstanceOf(varargin{:});
end

function harnessModelPath = setupModelTempFolder(testObj, simIdx, workingPath)
    harnessModelPath = [];
    modelName = testObj.getProperty('model',simIdx);
    if(~isempty(modelName))
        if(isempty(which(modelName)))
            error('stm:general:ModelNotFoundOnPath', getString(message('stm:general:ModelNotFoundOnPath',modelName)));
        end
        if ~bdIsLoaded(modelName)
           load_system(modelName);
        end        
        harnessName = testObj.getProperty('HarnessName', simIdx);
        if(~isempty(harnessName))
           harness = sltest.harness.find(modelName, 'Name', harnessName);
           if(isempty(harness))
              error('stm:general:InvalidHarness', getString(message('stm:general:InvalidHarness', modelName, harnessName))); 
           end
           if harness.isOpen
               harnessModelPath = harness.name;
               return;
           end           
           [~,tempHarnessName,~] = fileparts(tempname(workingPath));
           try
               Simulink.harness.internal.load_harness_from_file(modelName, harness.name, tempHarnessName);
               sigs = get_param(tempHarnessName,'InstrumentedSignals');
           catch me
               if(isequal(me.identifier, 'Simulink:Commands:InputArgInvalid'))
                   error('stm:TestSpecReportContent:SaveHarnessBeforeReportGen', ...
                       getString(message('stm:TestSpecReportContent:SaveHarnessBeforeReportGen', harness.name)));
               else
                   rethrow(me);
               end
           end
           tempHarnessPath = fullfile(workingPath, tempHarnessName);
           try
               save_system(tempHarnessName, tempHarnessPath);
               set_param(tempHarnessName,'InstrumentedSignals',sigs);
               save_system(tempHarnessName, tempHarnessPath);
           catch ex
               newException = MException('stm:TestSpecReportContent:SaveSystemError', ...
                   getString(message('stm:TestSpecReportContent:SaveSystemError', harness.name)));
               newException = addCause(newException,ex);
               throw(newException);
           end
           close_system(tempHarnessName);           
           harnessModelPath = tempHarnessPath;
        end
    end 
end















