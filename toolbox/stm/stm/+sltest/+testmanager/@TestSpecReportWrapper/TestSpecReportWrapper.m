classdef TestSpecReportWrapper < handle
    
    properties
        ReportTitle = 'Test Specification Report';
        content;
        outputFile = '';
        AuthorName = '';
        fromCMD = true;
        
        IncludeTestDetails = true;
        IncludeCoverageSettings = true;
        IncludeTestFileOptions = true;
        
        IncludeSystemUnderTest = true;
        IncludeConfigSettingsOverrides = true;
        IncludeCallbackScripts = true;
        IncludeParameterOverrides = true;
        IncludeExternalInputs = true;
        IncludeLoggedSignals = true;
        IncludeBaselineCriteria = true;
        IncludeEquivalenceCriteria = true;
        IncludeIterations = true;
        IncludeCustomCriteria = true;
        IncludeLogicalAndTemporalAssessments = true;
        
        LaunchReport = false;
        TestSuiteReporterTemplate = '';
        TestCaseReporterTemplate = '';       
    end
    
    properties (GetAccess=protected, SetAccess=protected)
       ReportGenStatus = 0; 
    end
    
    properties (Access = private)
                
        errorMSGID = '';
        errors = {};
        workingPath = '';    
        workingName = '';
        reportType = ''; 
        outputFileType = '';
        Report;
        reportGenerationSuccess = -1;
        reportGenProgressDlgShown = false;
        
    end
    
    methods(Access = private)
        function reportGenerationIsDone(obj, modelsAlreadyLoaded)
            if(isequal(obj.Report.Document.OpenStatus,'open'))
               close(obj.Report); 
            end
            listing = dir(obj.workingPath);
            for i=3:length(listing)
                [~,modelName,ext] = fileparts(listing(i).name);
                if(isequal(ext,'.slx'))
                    close_system(modelName,0);
                end
            end
            if(isfolder(obj.workingPath))
                rmdir(obj.workingPath, 's');
            end
            modelsCurrentlyLoaded = find_system('type','block_diagram');
            for i=1:length(modelsCurrentlyLoaded)
               if(~any(ismember(modelsAlreadyLoaded, modelsCurrentlyLoaded(i))))
                   close_system(modelsCurrentlyLoaded(i));
               end
            end
            
            stm.internal.setTestSpecReportGenerationStatus(0, 0); 
            virtualChannel = sprintf('TestSpecReport/Generation/DONE');
            payloadStruct = struct('VirtualChannel', virtualChannel, 'Payload', 0);
            message.publish('/stm/messaging', payloadStruct);
        end
        
    end
    
    methods (Sealed = true)
        
        function createReport(obj)
           modelsAlreadyLoaded = find_system('type','block_diagram');
           noRet = onCleanup(@()obj.reportGenerationIsDone(modelsAlreadyLoaded));
           obj.reportGenerationSuccess = 0;
           obj.setReportGenerationEnvironment();
           
           % Implemented Externally
           obj.layoutReport();           
           obj.finalizeReport();
           
           if(~obj.fromCMD)
              obj.LaunchReport = true; 
           end
           
           if(obj.LaunchReport && obj.ReportGenStatus <=2 && obj.reportGenerationSuccess == 2)
               import mlreportgen.dom.*;
               rptgen.rptview(obj.outputFile,obj.outputFileType);
           end
           obj.reportGenerationSuccess = -1;
        end
        
    end
        
    methods (Sealed = true, Access = protected, Hidden)
        
        function setReportGenerationEnvironment(obj)
           obj.errors.EmptyDataForReport = 'stm:reportOptionDialogText:EmptyDataForReport';             
           obj.errors.UnsupportedFileType = 'stm:reportOptionDialogText:UnsupportedFileType';
           
           if(isempty(obj.content))                             
               obj.errorMSGID = obj.errors.EmptyDataForReport;
               error(message(obj.errorMSGID));
           end
           
           obj.ReportGenStatus = 0;            
           stm.internal.setTestSpecReportGenerationStatus(1, -1);
           
           OSTempDir = tempdir();
           obj.workingPath = tempname(OSTempDir);
           mkdir(obj.workingPath);
           
           tmpStr = tempname(obj.workingPath);
           [~, tmpName, ~] = fileparts(tmpStr);
           obj.workingName = tmpName;
           
           [~, ~,outputExt] = fileparts(obj.outputFile); 
           
           if(strcmp(outputExt,'.zip'))
                obj.reportType = 'html';
                obj.outputFileType = 'html';
            elseif(strcmp(outputExt,'.pdf'))
                obj.reportType = 'pdf';
                obj.outputFileType = 'pdf';
            elseif(strcmp(outputExt,'.docx'))
                obj.reportType = 'docx';
                obj.outputFileType = 'docx';
            else
                obj.errorMSGID = obj.errors.UnsupportedFileType;
                error(message(obj.errorMSGID));
           end
           
           %Open the report file
           tmpOutputFile = fullfile(obj.workingPath,obj.workingName);
           obj.Report = sltest.testmanager.ReportUtility.TestSpecReport(tmpOutputFile, obj.reportType);
           obj.Report.Locale = 'en';
           open(obj.Report);
           obj.Report.CompileModelBeforeReporting = false;
                
        end
    end
    
    methods(Static)
        
        function [ReportGenStatus, reportGenProgressDlgShown] = getReportGenerationStatus()
            [ReportGenStatus, reportGenProgressDlgShown] = stm.internal.getTestSpecReportGenerationStatus();
        end
        
        function sendMSGToUI(value, msg, replaceLastLine)
            virtualChannel = sprintf('Update/TestSpecReport/Generation/Status');
            payload = struct('msg', msg, 'value', value,'replaceLastLine',replaceLastLine);
            payloadStruct = struct('VirtualChannel', virtualChannel, 'Payload', payload);
            message.publish('/stm/messaging', payloadStruct); 
        end
        
    end
    
    methods (Access = private, Sealed=true)
        
        function finalizeReport(obj)           
            import mlreportgen.report.*;
            close(obj.Report);
            
            if(strcmp(obj.outputFileType,'html'))
                tmpFile = fullfile(obj.workingPath,[obj.workingName '.htmx']);                
            elseif(strcmp(obj.outputFileType,'docx'))
                tmpFile = fullfile(obj.workingPath,[obj.workingName '.docx']);                
            elseif(strcmp(obj.outputFileType,'pdf'))
                 tmpFile = fullfile(obj.workingPath,[obj.workingName '.pdf']);
            end
            
            if(exist(tmpFile,'file'))
                copyfile(tmpFile,obj.outputFile,'f');
            end
            obj.reportGenerationSuccess = 2;                                 
        end
        
        % Implemented Externally
        createTestFileReportBody(obj, testObj, docPart);
        createTestSuiteReportBody(obj, testObj, docPart);
        createTestCaseReportBody(obj, testObj, docPart);
        
        function updateReportGenerationStatus(obj, percent)
            % Updates the percentage complete status message in the report generation
            % status dialog
            % Input:
            %   obj    : object of type sltest.testmanager.TestResultReport
            %   percent: percentage of report generation which is done
            if(obj.ReportGenStatus < 2)
                obj.sendMSGToUI(percent,'',false);
            end
        end
    
    end
   
end

