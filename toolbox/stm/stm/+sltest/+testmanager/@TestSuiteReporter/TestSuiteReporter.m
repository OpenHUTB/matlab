classdef TestSuiteReporter < sltest.testmanager.TestReporter
      
    properties
       Object {mustBeInstanceOfMultiClass({'sltest.testmanager.TestFile','sltest.testmanager.TestSuite'}, Object)}= [];
       IncludeTestDetails {mustBeLogical} = true;
       IncludeCallbackScripts  {mustBeLogical} = true;
       IncludeCoverageSettings  {mustBeLogical} = true;
       IncludeTestFileOptions  {mustBeLogical} = false;
    end

    methods (Access = protected, Hidden)
        % Implemented externally
        result = openImpl(report, impl, varargin)
    end
    
    methods
        function h = TestSuiteReporter(varargin)
            if(nargin == 1)
                varargin = [ {"Object"} varargin ];
            end
            h = h@sltest.testmanager.TestReporter(varargin{:});

            % Create an inputParser object
            p = inputParser;

            % Add optional parameter name-value pair argument to input
            % parser scheme.
            % syntax: addParameter(p, paramName, defaultValue);

            addParameter(p, 'TemplateName', "TestSuiteReporter");
            addParameter(p, 'Object', []);
            addParameter(p, 'IncludeTestDetails', true);
            addParameter(p, 'IncludeCallbackScripts', true);
            addParameter(p, 'IncludeCoverageSettings', true);
            addParameter(p, 'IncludeTestFileOptions', false);

            % Parse the inputs
            parse(p, varargin{:});

            results = p.Results;
            h.Object = results.Object;
            h.TemplateName = results.TemplateName;
            h.IncludeTestDetails = results.IncludeTestDetails;
            h.IncludeCallbackScripts = results.IncludeCallbackScripts;
            h.IncludeCoverageSettings = results.IncludeCoverageSettings;
            h.IncludeTestFileOptions = results.IncludeTestFileOptions;
            
        end
        
        function set.Object(h, value)
             h.Object = value; 
        end

    end
    
    methods (Access = {?mlreportgen.report.ReportForm, ?sltest.testmanager.TestSuiteReporter})
        
        function content = getTestDetails(h, rpt)
            import mlreportgen.dom.*;
            content = [];
            if h.IncludeTestDetails    
                testObj = h.Object;                
                testDetailsTableData = getTestDetailsTableData(h, rpt, testObj);
                if(~isempty(testDetailsTableData))
                    heading = Heading4(getString(message('stm:TestSpecReportContent:TestDetails')));
                    heading.StyleName = 'TestDetailsHeading';
                    table = Table(testDetailsTableData);
                    table.StyleName = 'TestDetailsTable';
                    table = customizeTableWidthsForTable(h, table, 30);
                    content = [{heading}, {table}];
                end               
            end            
        end
        
        function content = getCallbacks(h, rpt)
            import mlreportgen.dom.*;
            content = [];            
            if h.IncludeCallbackScripts
               testObj = h.Object;
               if(~isempty(testObj.getProperty('setupcallback')))
                   setupCallbackPara = Paragraph();
                   if(isequal(rpt.Type,'docx'))
                       setupCallbackPara.WhiteSpace = 'preserve';
                   else
                       setupCallbackPara.StyleName = 'TestSetupCallbackScripts';
                   end
                   textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('setupcallback'));
                   if ~isempty(textNodes)
                       for i=1:numel(textNodes)
                           setupCallbackPara.append(clone(textNodes{i}));
                       end
                       heading = Heading4(getString(message('stm:TestSpecReportContent:SetupCallback')));
                       heading.StyleName = 'SetupCallbackHeading';
                       content = [{heading}, {setupCallbackPara}];
                   end
               end
               
               if(~isempty(testObj.getProperty('cleanupcallback')))
                   cleanupCallbackPara = Paragraph();
                   if(isequal(rpt.Type,'docx'))
                       cleanupCallbackPara.WhiteSpace = 'preserve'; 
                   else
                       cleanupCallbackPara.StyleName = 'TestCleanupCallbackScripts';
                   end
                   textNodes = createCallbackScriptTextObj(h, rpt, testObj.getProperty('cleanupcallback'));
                   if ~isempty(textNodes)
                       for i=1:numel(textNodes)
                           cleanupCallbackPara.append(clone(textNodes{i}));
                       end
                       heading = Heading4(getString(message('stm:TestSpecReportContent:CleanupCallback')));
                       heading.StyleName = 'CleanupCallbackHeading';
                       content = [content, {heading}, {cleanupCallbackPara}];
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
                     heading = Heading4(getString(message('stm:TestSpecReportContent:CoverageSettings')));
                     heading.StyleName = 'CoverageSettingsHeading';
                     table = Table(covSettingsTableData);
                     table.StyleName = 'CoverageSettingsTable';
                     table = customizeTableWidthsForTable(h, table, 35);  
                     content = [{heading} {table}];
                  end
               end                
            end

        end
        
        function content = getTestFileOptions(h, rpt)
            import mlreportgen.dom.*;
            content = [];
            if h.IncludeTestFileOptions
               testObj = h.Object; 
               optionsTableData = createOptionsTableData(h, rpt, testObj.getOptions); 
               if(~isempty(optionsTableData))
                   heading = Heading4(getString(message('stm:TestSpecReportContent:TestFileOptions')));
                   heading.StyleName = 'TestFileOptionsHeading';
                   table = Table(optionsTableData); 
                   table.StyleName = 'TestFileOptionsTable';
                   table = customizeTableWidthsForTable(h, table, 38);
                   content = [{heading} {table}];
               end
            end           
        end
        
        
    end
    
    methods (Access = private)         
        
        function optionsTableData = createOptionsTableData(h, rpt, opts)
            props = {getString(message('stm:TestSpecReportContent:CloseOpenFigures')),...
                     getString(message('stm:TestSpecReportContent:StoreMLFigures')),...
                     getString(message('stm:TestSpecReportContent:GenerateReport'))};
            if(opts.GenerateReport)
               props = [props {getString(message('stm:TestSpecReportContent:ReportGenOptions'))}];
            end
            optionsTableData = cell(length(props), 2);
            for i=1:length(props)
                optionsTableData{i,1} = props{i};
            end
            
            if opts.CloseFigures            
                optionsTableData{1,2} = 'true';
            else
                optionsTableData{1,2} = 'false';
            end
            
            if opts.SaveFigures            
                optionsTableData{2,2} = 'true';
            else
                optionsTableData{2,2} = 'false';
            end
            
            if opts.GenerateReport            
                optionsTableData{3,2} = 'true';
            else
                optionsTableData{3,2} = 'false';
            end

            if(opts.GenerateReport)
                optionsTableData{4,2} = createReportGenOptionsTable(h, rpt, opts); 
            end
            
        end
        
        function reportGenOptionsTable = createReportGenOptionsTable(h, ~, opts)
            import mlreportgen.dom.*;
            props = {getString(message('stm:TestSpecReportContent:ReportTitle'))};
            if (~isempty(opts.Author))
               props = [props {getString(message('stm:TestSpecReportContent:ReportAuthor'))}];
            end
            props = [props {getString(message('stm:TestSpecReportContent:IncludeMLVersion')),...
                            getString(message('stm:TestSpecReportContent:ResultsFor'))}];
            if(opts.IncludeTestRequirement || opts.IncludeComparisonSignalPlots ||...
                    opts.IncludeSimulationSignalPlots || opts.IncludeMATLABFigures ||...
                    opts.IncludeSimulationMetadata || opts.IncludeCoverageResult ||...
                    opts.IncludeErrorMessages)
           
                props = [props {getString(message('stm:TestSpecReportContent:IncludeInReport'))}];
             
            end
            props = [props {getString(message('stm:TestSpecReportContent:FileFormat')),...
                            getString(message('stm:TestSpecReportContent:FileName'))}];
            
            if(~isempty(opts.CustomTemplateFile))
                 props = [props {getString(message('stm:TestSpecReportContent:TemplateFile'))}];
            end
            
            if(~isempty(opts.CustomReportClass))
                 props = [props {getString(message('stm:TestSpecReportContent:ReportClass'))}];
            end
            
            reportGenOptionsData = cell(length(props),2);
            for i=1:length(props)
                reportGenOptionsData{i,1} = props{i};
                switch props{i}
                    case getString(message('stm:TestSpecReportContent:ReportTitle'))
                        reportGenOptionsData{i,2} = opts.Title;
                    case getString(message('stm:TestSpecReportContent:ReportAuthor'))
                        reportGenOptionsData{i,2} = opts.Author;
                    case getString(message('stm:TestSpecReportContent:IncludeMLVersion'))
                        if opts.IncludeMLVersion
                            reportGenOptionsData{i,2} = 'true';
                        else
                            reportGenOptionsData{i,2} = 'false';
                        end
                    case getString(message('stm:TestSpecReportContent:ResultsFor'))
                        reportGenOptionsData{i,2} = char(opts.IncludeTestResults);
                    case getString(message('stm:TestSpecReportContent:IncludeInReport'))
                        reportGenOptionsData{i,2} = createListOfReportIncludes(h, opts);
                    case getString(message('stm:TestSpecReportContent:FileFormat'))
                        reportGenOptionsData{i,2} = char(opts.ReportFormat);
                    case getString(message('stm:TestSpecReportContent:FileName'))
                        reportGenOptionsData{i,2} = char(opts.ReportPath);
                    case getString(message('stm:TestSpecReportContent:TemplateFile'))
                        reportGenOptionsData{i,2} = char(opts.CustomTemplateFile);
                    case getString(message('stm:TestSpecReportContent:ReportClass'))
                        reportGenOptionsData{i,2} = char(opts.CustomReportClass);
                end
            end
            
            reportGenOptionsTable = Table(reportGenOptionsData);
            reportGenOptionsTable.StyleName = 'ReportGenOptionsTable';
            reportGenOptionsTable = customizeTableWidthsForTable(h, reportGenOptionsTable, 45);

        end
        
        function rptIncludes = createListOfReportIncludes(~, opts)
            import mlreportgen.dom.*;
            rptIncludes = UnorderedList;
            if(opts.IncludeTestRequirement)
              rptText = Text(getString(message('stm:TestSpecReportContent:TestRequirements')));
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);
            end
            
            if(opts.IncludeComparisonSignalPlots)
              rptText = Text(getString(message('stm:TestSpecReportContent:CriteriaPlots')));
              rptText.WhiteSpace = 'preserve';
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);  
            end
            
            if(opts.IncludeSimulationSignalPlots)
              rptText = Text(getString(message('stm:TestSpecReportContent:SimPlots')));
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);  
            end
            
            if(opts.IncludeMATLABFigures)
              rptText = Text(getString(message('stm:TestSpecReportContent:MLFigures')));
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);  
            end
            
            if(opts.IncludeSimulationMetadata)
              rptText = Text(getString(message('stm:TestSpecReportContent:SimMetadata')));
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);  
            end
            
            if(opts.IncludeCoverageResult)
              rptText = Text(getString(message('stm:TestSpecReportContent:CoverageResults')));
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);  
            end   
            
            if(opts.IncludeErrorMessages)
              rptText = Text(getString(message('stm:TestFileXMLTagMapping:IncludeFailingErrorMessages')));
              rptListItem = ListItem(rptText);
              append(rptIncludes, rptListItem);  
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
            
            path = sltest.testmanager.TestSuiteReporter.getClassFolder();
            template = mlreportgen.report.ReportForm.createFormTemplate(...
                templatePath, type, path);
        end
        
        function classfile = customizeReporter(toClasspath)
                       
           classfile = mlreportgen.report.ReportForm.customizeClass(toClasspath,...
               "sltest.testmanager.TestSuiteReporter");
        end
        
    end
end

%---validators---
function mustBeInstanceOfMultiClass(varargin)
    mlreportgen.report.validators.mustBeInstanceOfMultiClass(varargin{:});
end
function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end
