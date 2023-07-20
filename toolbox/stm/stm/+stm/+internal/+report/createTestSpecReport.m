function createTestSpecReport(inArgs)
    try
        processingArgs(inArgs);
    catch me
        shutOffReportGeneration();
        rethrow(me);
    end
end

function processingArgs(inArgs)
    % check input data
    if(isfield(inArgs, 'selectedIDList'))
       selectedIDs = inArgs.selectedIDList;      
       % generate data content for report using ID's
       testObjList = cell(size(selectedIDs));
       for idx = 1 : length(selectedIDs)
          testID = selectedIDs(idx);
          testObj = sltest.testmanager.Test.getTestObjFromID(testID);
          testObjList{idx} = testObj;
       end 
    else
        testObjList = inArgs.inputData;
    end
    
    % check output file
    outputFile = inArgs.reportPath;
    if(isempty(outputFile))
        error(message('stm:reportOptionDialogText:OutputFileEmpty'));
    end

    % Used if no extension is specified
    fileFormat = '.pdf';
    if(isfield(inArgs,'reportFormat') && ~isempty(inArgs.reportFormat))
        if strcmpi(inArgs.reportFormat, 'pdf')
             fileFormat = '.pdf';
        elseif strcmpi(inArgs.reportFormat, 'zip')
             fileFormat = '.zip';
        elseif strcmpi(inArgs.reportFormat, 'docx')
             fileFormat = '.docx';
        else
             error(message('stm:reportOptionDialogText:UnsupportedFileType'));
        end 
    end

    [outputFile, outputExt] = validateFilePath(outputFile, fileFormat, true);

    % error if extension is not recognized
    if(~strcmpi(outputExt,'.zip') && ~strcmpi(outputExt,'.docx') && ~strcmpi(outputExt,'.pdf'))
        error(message('stm:reportOptionDialogText:UnsupportedFileType'));
    end

    % fix the file name in case of existing file with same name
    outputFile = stm.internal.report.incrementFilePath(outputFile);


    % create an instance of sltest.testmanager.TestSpecReportWrapper class
    report = sltest.testmanager.TestSpecReportWrapper;
    report.outputFile = outputFile;
    report.content = testObjList;

    if(isfield(inArgs, 'authorName'))
        report.AuthorName = inArgs.authorName;
    end

    if(isfield(inArgs, 'reportTitle'))
        report.ReportTitle = inArgs.reportTitle;
    end

    if(isfield(inArgs, 'includeTestDetails'))
        report.IncludeTestDetails = inArgs.includeTestDetails;
    end
    
    if(isfield(inArgs, 'includeTestFileOptions'))
        report.IncludeTestFileOptions = inArgs.includeTestFileOptions;
    end
    
    if(isfield(inArgs, 'includeCoverageSettings'))
        report.IncludeCoverageSettings = inArgs.includeCoverageSettings;
    end
    
    if(isfield(inArgs, 'includeSystemUnderTest'))
        report.IncludeSystemUnderTest = inArgs.includeSystemUnderTest; 
    end
    
    if(isfield(inArgs, 'includeConfigSettingsOverrides'))
        report.IncludeConfigSettingsOverrides = inArgs.includeConfigSettingsOverrides;
    end

    if(isfield(inArgs, 'includeCallbackScripts'))
        report.IncludeCallbackScripts = inArgs.includeCallbackScripts;
    end

    if(isfield(inArgs, 'includeParameterOverrides'))
        report.IncludeParameterOverrides = inArgs.includeParameterOverrides;
    end

    if(isfield(inArgs, 'includeExternalInputs'))
        report.IncludeExternalInputs = inArgs.includeExternalInputs;
    end

    if(isfield(inArgs, 'includeLoggedSignals'))
        report.IncludeLoggedSignals = inArgs.includeLoggedSignals;
    end

    if(isfield(inArgs, 'includeBaselineCriteria'))
        report.IncludeBaselineCriteria = inArgs.includeBaselineCriteria;
    end

    if(isfield(inArgs, 'includeEquivalenceCriteria'))
        report.IncludeEquivalenceCriteria = inArgs.includeEquivalenceCriteria;
    end

    if(isfield(inArgs, 'includeIterations'))
        report.IncludeIterations = inArgs.includeIterations;
    end

    if(isfield(inArgs, 'includeCustomCriteria'))
        report.IncludeCustomCriteria = inArgs.includeCustomCriteria;
    end
    
    if(isfield(inArgs, 'includeLogicalAndTemporalAssessments'))
        report.IncludeLogicalAndTemporalAssessments = inArgs.includeLogicalAndTemporalAssessments;
    end

    if(isfield(inArgs, 'launchReport'))
        report.LaunchReport = inArgs.launchReport;
    end
    
    if(isfield(inArgs, 'testSuiteReporterTemplate'))
        report.TestSuiteReporterTemplate = inArgs.testSuiteReporterTemplate;
    end
    
    if(isfield(inArgs, 'testCaseReporterTemplate'))
        report.TestCaseReporterTemplate = inArgs.testCaseReporterTemplate;
    end
    
    if(isfield(inArgs, 'fromCMD'))
       report.fromCMD = inArgs.fromCMD; 
    end
    
    report.createReport();
    
end

function shutOffReportGeneration()
    stm.internal.setTestSpecReportGenerationStatus(0, 0); 
    virtualChannel = sprintf('TestSpecReport/Generation/DONE');
    payloadStruct = struct('VirtualChannel', virtualChannel, 'Payload', 0);
    message.publish('/stm/messaging', payloadStruct);
end

function [filePath, outputExt] = validateFilePath(filePath, defaultExtension, isReport)
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
            error(message('stm:reportOptionDialogText:InvalidPathName'));
        else
            error(message('stm:reportOptionDialogText:InvalidTemplatePath'));
        end
    elseif(ret == -2 || ret == -3)        
        error(message('stm:reportOptionDialogText:FailToCreateOutputFile'));
    end
end