classdef TestFileOptions<handle



    properties(Constant,Hidden)
        OptionsClass='stm.Options'
        CloseFiguresProperty='CloseFigures'
        SaveFiguresProperty='SaveFigures'
        GenerateReportProperty='GenerateReport'
        TitleProperty='Title'
        AuthorProperty='Author'
        IncludeMATLABVersionProperty='IncludeMATLABVersion'
        IncludedTestsProperty='IncludedTests'
        IncludeRequirementsProperty='IncludeTestRequirement'
        IncludeCriteriaAssesmentPlotsProperty='IncludeComparisonSignalPlots'
        IncludeSimulationOutputPlotsProperty='IncludeSimulationSignalPlots'
        NumPlotRowsPerPageProperty='NumPlotRowsPerPage'
        NumPlotColumnsPerPageProperty='NumPlotColumnsPerPage'
        IncludeMATLABFiguresProperty='IncludeManuallyCreatedFigures'
        IncludeFailingErrorMessagesProperty='IncludeFailingErrorMessages'
        IncludeSimulationMetadataProperty='IncludeSimulationMetadata'
        IncludeCoverageResultsProperty='IncludeCoverageResults'
        ReportFormatProperty='ReportFormat'
        ReportLocationProperty='ReportPath'
        TemplateFileProperty='TemplateFilePath'
        ReportClassNameProperty='ReportClassName'
        IncludePassingDiagnosticsProperty='IncludePassingDiagnostics';
    end


    methods(Access=protected)
        function setOptionsHelper(obj,propName,value)
            if~obj.isTestFile
                error(message('stm:reportOptionDialogText:CannotChangeOptions'));
            end
            stm.internal.setOptionsProperty(obj.optionsID,propName,value);
        end

        function setReportOptionsHelper(obj,propName,value)
            if~obj.isTestFile
                error(message('stm:reportOptionDialogText:CannotChangeOptions'));
            end
            stm.internal.setReportOptionsProperty(obj.optionsID,propName,value);
        end
    end
end