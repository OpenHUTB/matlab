function testSpecReportWrapper(testObj,filePath,varargin)



    b=isa(testObj,'sltest.testmanager.Test');

    if(~b)
        error(message('stm:TestSpecReportContent:TestClassArgumentExpected','testObj'));
    end

    if any(string({testObj.Path}).endsWith('.m','IgnoreCase',true))
        error(message('stm:ScriptedTest:FunctionNotSupported','TestSpecReport'));
    end

    if isStringScalar(filePath)
        filePath=filePath.char;
    end

    if~ischar(filePath)
        error(message('stm:reportOptionDialogText:StringArgumentExpected','filePath'));
    end

    inArgs={};
    pvPairs=varargin{1};

    for i=1:2:length(pvPairs)
        propertyName=pvPairs{i};
        value=pvPairs{i+1};
        if(isempty(value))
            continue;
        end
        switch propertyName
        case 'Author'
            if(isStringScalar(value))
                value=value.char;
            end
            if(ischar(value))
                inArgs.authorName=value;
            else
                error(message('stm:reportOptionDialogText:StringArgumentExpected','Author'));
            end
        case 'Title'
            if(isStringScalar(value))
                value=value.char;
            end
            if(ischar(value))
                inArgs.reportTitle=value;
            else
                error(message('stm:reportOptionDialogText:StringArgumentExpected','Title'));
            end
        case 'IncludeTestDetails'
            if(islogical(value)&&isscalar(value))
                inArgs.includeTestDetails=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeTestDetails','logical'));
            end
        case 'IncludeTestFileOptions'
            if(islogical(value)&&isscalar(value))
                inArgs.includeTestFileOptions=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeTestFileOptions','logical'));
            end
        case 'IncludeCoverageSettings'
            if(islogical(value)&&isscalar(value))
                inArgs.includeCoverageSettings=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeCoverageSettings','logical'));
            end
        case 'IncludeSystemUnderTest'
            if(islogical(value)&&isscalar(value))
                inArgs.includeSystemUnderTest=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeSystemUnderTest','logical'));
            end
        case 'IncludeCallbackScripts'
            if(islogical(value)&&isscalar(value))
                inArgs.includeCallbackScripts=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeCallbackScripts','logical'));
            end
        case 'IncludeConfigSettingsOverrides'
            if(islogical(value)&&isscalar(value))
                inArgs.includeConfigSettingsOverrides=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeConfigSettingsOverrides','logical'));
            end
        case 'IncludeParameterOverrides'
            if(islogical(value)&&isscalar(value))
                inArgs.includeParameterOverrides=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeParameterOverrides','logical'));
            end
        case 'IncludeExternalInputs'
            if(islogical(value)&&isscalar(value))
                inArgs.includeExternalInputs=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeExternalInputs','logical'));
            end
            inArgs.includeInputSignals=value;
        case 'IncludeLoggedSignals'
            if(islogical(value)&&isscalar(value))
                inArgs.includeLoggedSignals=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeLoggedSignals','logical'));
            end
        case 'IncludeBaselineCriteria'
            if(islogical(value)&&isscalar(value))
                inArgs.includeBaselineCriteria=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeBaselineCriteria','logical'));
            end
        case 'IncludeEquivalenceCriteria'
            if(islogical(value)&&isscalar(value))
                inArgs.includeEquivalenceCriteria=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeEquivalenceCriteria','logical'));
            end
        case 'IncludeIterations'
            if(islogical(value)&&isscalar(value))
                inArgs.includeIterations=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeIterations','logical'));
            end
        case 'IncludeCustomCriteria'
            if(islogical(value)&&isscalar(value))
                inArgs.includeCustomCriteria=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeCustomCriteria','logical'));
            end
        case 'IncludeLogicalAndTemporalAssessments'
            if(islogical(value)&&isscalar(value))
                inArgs.includeLogicalAndTemporalAssessments=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','IncludeLogicalAndTemporalAssessments','logical'));
            end
        case 'LaunchReport'
            if(islogical(value)&&isscalar(value))
                inArgs.launchReport=value;
            else
                error(message('stm:reportOptionDialogText:ScalarArgumentExpected','LaunchReport','logical'));
            end
        case 'TestSuiteReporterTemplate'
            if(ischar(value))
                [~,~,ext]=fileparts(value);
                if(strcmp(ext,'.pdftx')||strcmp(ext,'.htmtx')||strcmp(ext,'.dotx'))
                    if(isfile(value))
                        inArgs.testSuiteReporterTemplate=value;
                    else
                        error(message('stm:TestSpecReportContent:TestSuiteReporterTemplateNotFound','TestSuiteReporterTemplate'));
                    end
                else
                    error(message('stm:TestSpecReportContent:ReporterTemplateExtError','TestSuiteReporterTemplate'));
                end
            else
                error(message('stm:reportOptionDialogText:StringArgumentExpected','TestSuiteReporterTemplate'));
            end
        case 'TestCaseReporterTemplate'
            if(ischar(value))
                [~,~,ext]=fileparts(value);
                if(strcmp(ext,'.pdftx')||strcmp(ext,'.htmtx')||strcmp(ext,'.dotx'))
                    if(isfile(value))
                        inArgs.testCaseReporterTemplate=value;
                    else
                        error(message('stm:TestSpecReportContent:TestCaseReporterTemplateNotFound','TestCaseReporterTemplate'));
                    end
                else
                    error(message('stm:TestSpecReportContent:ReporterTemplateExtError','TestCaseReporterTemplate'));
                end
            else
                error(message('stm:reportOptionDialogText:StringArgumentExpected','TestCaseReporterTemplate'));
            end
        otherwise
            error(message('stm:reportOptionDialogText:UnsupportedInputArgument',propertyName));
        end
    end

    inArgs.reportPath=filePath;

    if(iscell(testObj))
        inArgs.inputData=testObj;
    else
        inArgs.inputData=num2cell(testObj);
    end
    inArgs.fromCMD=true;

    stm.internal.report.createTestSpecReport(inArgs);

end