function report(obj,varargin)

































    import Simulink.sdi.internal.StringDict;
    if~obj.ReportManager.ReportBeingCreated
        reportFolder=fullfile(pwd,'sdireports');


        p=inputParser;
        p.addParameter('ReportToCreate','Inspect',...
        @(x)ischar(validatestring(x,...
        {'Inspect','Compare','Inspect Signals',...
        'Compare Runs','Compare Signals'})));
        p.addParameter('ReportType','Inspect',...
        @(x)ischar(validatestring(x,...
        {'Inspect','Compare','Inspect Signals',...
        'Compare Runs','Compare Signals'})));
        p.addParameter('ReportStyle','Printable',...
        @(x)ischar(validatestring(x,...
        {'Printable','Interactive'})));
        p.addParameter('ReportTitle','Default',...
        @(x)validateattributes(x,{'char'},{'scalartext'}));
        p.addParameter('ReportAuthor','Default',...
        @(x)validateattributes(x,{'char'},{'scalartext'}));
        p.addParameter('ReportOutputFolder',reportFolder,@ischar);
        p.addParameter('ReportOutputFile','SDI_report.html',@ischar);
        p.addParameter('PreventOverwritingFile',true,@islogical);
        p.addParameter('ColumnsToReport',[],@(x)(isa(x,'Simulink.sdi.SignalMetaData')));
        p.addParameter('ShortenBlockPath',true,@islogical);
        p.addParameter('LaunchReport',true,@islogical);
        p.addParameter('SignalsToReport','ReportOnlyMismatchedSignals',...
        @(x)ischar(validatestring(x,{'ReportOnlyMismatchedSignals','ReportAllSignals'})));

        p.parse(varargin{:});
        results=p.Results;


        if any(strcmp(varargin,'ReportToCreate'))
            if~any(strcmp(varargin,'ReportType'))
                results.ReportType=results.ReportToCreate;
            end
        end
        if strcmp(results.ReportType,'Compare Runs')
            results.ReportType='Compare';
        end
        if strcmp(results.ReportType,'Inspect Signals')
            results.ReportType='Inspect';
        end

        obj.ReportManager.ReportOutputFolder=results.ReportOutputFolder;
        obj.ReportManager.ReportOutputFile=results.ReportOutputFile;
        obj.ReportManager.PreventOverwritingFile=results.PreventOverwritingFile;
        obj.ReportManager.ReportStyle=results.ReportStyle;
        obj.ReportManager.ReportToCreate=results.ReportType;
        obj.ReportManager.ReportTitle=results.ReportTitle;
        obj.ReportManager.ReportAuthor=results.ReportAuthor;
        obj.ReportManager.ColumnsToReport=results.ColumnsToReport;
        obj.ReportManager.ShortenBlockPath=results.ShortenBlockPath;
        obj.ReportManager.LaunchReport=results.LaunchReport;
        obj.ReportManager.SignalsToReport=results.SignalsToReport;


        obj.ReportManager.ReportBeingCreated=true;
        try
            obj.ReportManager.createReport();
            obj.ReportManager.ReportBeingCreated=false;
        catch me
            obj.ReportManager.ReportBeingCreated=false;
            rethrow(me);
        end
    end
