function createReport(inArgs) 
    try
        processingArgs(inArgs)
    catch me
        shutOffReportGeneration();
        rethrow(me);
    end
end

function processingArgs(inArgs)  
%
% Wrapper to call report generation utilities.
%
% Copyright 2014-2018 The MathWorks, Inc.
%
    errors.InvalidDataSelection = 'stm:reportOptionDialogText:InvalidDataSelection';
    errors.DataNotFound = 'stm:reportOptionDialogText:DataNotFound';
    errors.FailedToGetData = 'stm:reportOptionDialogText:FailedToGetData';
    errors.EmptyDataForReport = 'stm:reportOptionDialogText:EmptyDataForReport';
    errors.EmptyDataForReportPassed = 'stm:reportOptionDialogText:EmptyDataForReportPassed';
    errors.EmptyDataForReportFailed = 'stm:reportOptionDialogText:EmptyDataForReportFailed';
    errors.UnsupportedFileType = 'stm:reportOptionDialogText:UnsupportedFileType';
    errors.PDFNotSupportedDueToConverter = 'stm:reportOptionDialogText:PDFNotSupportedDueToConverter';
    errors.InvalidPathName = 'stm:reportOptionDialogText:InvalidPathName'; 
    errors.FailToCreateOutputFile = 'stm:reportOptionDialogText:FailToCreateOutputFile';
    errors.InvalidTemplatePath = 'stm:reportOptionDialogText:InvalidTemplatePath';
    
    %%%%%%%%%%%%%%%%%%%% check input data    
    resultObjList = {};
    if(isfield(inArgs,'hasInputData'))
        resultObjList = inArgs.hasInputData;
    elseif(isfield(inArgs,'selectedIDList') || isfield(inArgs,'resultSetID'))
        if(isfield(inArgs,'resultSetID'))
            selectedIDs = [inArgs.resultSetID];
        else
            selectedIDs = inArgs.selectedIDList;
        end
        
        % generate data content for report using input ID and data type
        resultObjList = cell(size(selectedIDs));
        for idx = 1 : length(selectedIDs)
            resultID = selectedIDs(idx);
            resultObj = sltest.testmanager.TestResult.getResultFromID(resultID);
            resultObjList{idx} = resultObj;
        end 
    end

    % customize report
    if strlength(inArgs.customReportClass) == 0
        inArgs.customReportClass = 'sltest.internal.TestResultReport';
    end
    reportClassName = inArgs.customReportClass;
    if(exist(reportClassName, 'class') == 0)        
        error(message('stm:reportOptionDialogText:ClassNotFound'));
    end
    
    % check output file
    outputFile = inArgs.reportPath;
    if(isempty(outputFile))
        error(message('stm:reportOptionDialogText:OutputFileEmpty'));
    end
    
    % this will be used if no extension is specified
    defaultFileFormat = '.pdf';
    if(isfield(inArgs,'reportFormat') && ~isempty(inArgs.reportFormat))
        defaultFileFormat = helperGetFileFormat(inArgs.reportFormat);
    end
    
    [outputFile, outputExt] = validateFilePath(outputFile, defaultFileFormat, true, errors);
    
    % error if extension is not recognized
    if(~strcmpi(outputExt,'.zip') && ~strcmpi(outputExt,'.docx') && ~strcmpi(outputExt,'.pdf'))
        error(message(errors.UnsupportedFileType));
    end
    
    % fix the file name in case of existing file with same name
    outputFile = stm.internal.report.incrementFilePath(outputFile);
      
    try
        report = feval(reportClassName,resultObjList, outputFile);    
    catch err
        error(message('stm:ReportContent:InvalidClassNameWithDetail', reportClassName, err.message));
    end
    if(isfield(inArgs,'authorName'))
        report.AuthorName = inArgs.authorName;
    end
    if(isfield(inArgs,'reportTitle'))
        report.ReportTitle = inArgs.reportTitle;	
    end
    if(isfield(inArgs,'includeMWVersion'))
        report.IncludeMWVersion = inArgs.includeMWVersion;
    end
    if(isfield(inArgs,'includeTestRequirement'))
        report.IncludeTestRequirement = inArgs.includeTestRequirement;
    end    
    if(isfield(inArgs,'showSimulationSignalPlots'))
        report.IncludeSimulationSignalPlots = inArgs.showSimulationSignalPlots;
    end        
    if(isfield(inArgs,'showComparisonSignalPlots'))
        report.IncludeComparisonSignalPlots = inArgs.showComparisonSignalPlots;
    end      
    if(isfield(inArgs,'showMATLABFigures'))
        report.IncludeMATLABFigures = inArgs.showMATLABFigures;
    end
    if(isfield(inArgs,'showFailingErrorMsg'))
        report.IncludeErrorMessages = inArgs.showFailingErrorMsg;
    end
    if(isfield(inArgs,'includeSimulationMetaData'))
        report.IncludeSimulationMetadata = inArgs.includeSimulationMetaData;
    end
    if(isfield(inArgs,'resultSetCoverage'))
        report.IncludeTestResults = inArgs.resultSetCoverage;
    end     
    if(isfield(inArgs,'launchReport'))
        report.LaunchReport = inArgs.launchReport;
    end       
    if(isfield(inArgs,'customTemplateFile'))
        report.CustomTemplateFile = inArgs.customTemplateFile;
    end
    if(isfield(inArgs,'fromCMD'))
        report.setReportGenerationType(inArgs.fromCMD);
    end
    if(isfield(inArgs, 'includeCoverageResult'))
        report.IncludeCoverageResult = inArgs.includeCoverageResult;
    end
    if(isfield(inArgs, 'numPlotRowsPerPage'))
       report.NumPlotRowsPerPage = inArgs.numPlotRowsPerPage; 
    end
    if(isfield(inArgs, 'numPlotColumnsPerPage'))
       report.NumPlotColumnsPerPage = inArgs.numPlotColumnsPerPage; 
    end
    report.updateReportGenerationStatus(0);
    report.createReport();

    % notify clients
    sltest.internal.Events.getInstance.notifyResultReportCreated([resultObjList{:}], outputFile);
end

function shutOffReportGeneration()
    stm.internal.setReportGenerationStatus(0, 0); 
    virtualChannel = sprintf('Report/Generation/DONE');
    payloadStruct = struct('VirtualChannel', virtualChannel, 'Payload', 0);
    message.publish('/stm/messaging', payloadStruct);
end

function [filePath, outputExt] = validateFilePath(filePath, defaultExtension, isReport, errors)
    [outputPath,outputName,outputExt] = fileparts(filePath);
    if(isempty(outputPath))
        outputPath = pwd();
    end
    if(isempty(outputExt))
        filePath = fullfile(outputPath,strcat(outputName,defaultExtension));
        outputExt = defaultExtension;
    end
    
    ret = stm.internal.report.checkFilePath(filePath, isReport);
    if(ret == -1)
        if(isReport)
            error(message(errors.InvalidPathName));
        else
            error(message(errors.InvalidTemplatePath));
        end
    elseif(ret == -2 || ret == -3)        
        error(message(errors.FailToCreateOutputFile));
    end
end

function format = helperGetFileFormat(reportFileFormat)
    % for some reason the UI sends reportFileFormat as string and new test
    % file reporting infrastructure sends numbers
    
    if (isnumeric(reportFileFormat) && isscalar(reportFileFormat))
        if (reportFileFormat == 0)
            format = '.zip';
        elseif(reportFileFormat == 1)
            format = '.docx';
        elseif(reportFileFormat == 2)
            format = '.pdf';
        else
            error(message('stm:reportOptionDialogText:UnsupportedFileType'));
        end
    elseif (ischar(reportFileFormat))
         if strcmpi(reportFileFormat, 'pdf')
             format = '.pdf';
         elseif strcmpi(reportFileFormat, 'zip')
             format = '.zip';
         elseif strcmpi(reportFileFormat, 'docx')
             format = '.docx';
         else
             error(message('stm:reportOptionDialogText:UnsupportedFileType'));
         end 
    else
        error(message('stm:reportOptionDialogText:UnsupportedFileType'));
    end
end
