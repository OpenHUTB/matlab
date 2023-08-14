classdef ReportManager<handle





    properties

        ReportOutputFolder;
        ReportOutputFile;
        PreventOverwritingFile;
        ReportToCreate;
        ReportStyle;
        ReportTitle;
        ReportAuthor;
        ColumnsToReport;
        ShortenBlockPath;
        LaunchReport;
        SignalsToReport='ReportOnlyMismatchedSignals';
        AppName='sdi';
    end

    properties(Hidden=true)
        ReportBeingCreated=false;
    end

    properties(Access=private)
        SDIEngine;
        InspectSignalsReport;
        InspectSignalsReportSigAnalyzer;
        CompareSignalsReport;
        CompareRunsReport;
    end

    methods

        function obj=ReportManager(sdie)
            obj.SDIEngine=sdie;

            obj.ReportToCreate='Inspect';
            obj.ReportStyle='Printable';
            obj.ReportTitle='Default';
            obj.ReportAuthor='Default';
            obj.ReportOutputFile='SDI_report.html';
            obj.PreventOverwritingFile=true;
            obj.ShortenBlockPath=true;
            obj.LaunchReport=true;
        end

        function clearCachedFigures(this)
            if~isempty(this.InspectSignalsReport)
                delete(this.InspectSignalsReport);
                this.InspectSignalsReport=[];
            end
            if~isempty(this.InspectSignalsReportSigAnalyzer)
                delete(this.InspectSignalsReportSigAnalyzer);
                this.InspectSignalsReportSigAnalyzer=[];
            end
            if~isempty(this.CompareSignalsReport)
                delete(this.CompareSignalsReport);
                this.CompareSignalsReport=[];
            end
            if~isempty(this.CompareRunsReport)
                delete(this.CompareRunsReport);
                this.CompareRunsReport=[];
            end
        end

        function folder=get.ReportOutputFolder(obj)
            if isempty(obj.ReportOutputFolder)
                interface=Simulink.sdi.internal.Framework.getFramework();
                folder=interface.getReportFolder();
            else
                folder=obj.ReportOutputFolder;
            end
        end

        function set.ReportOutputFolder(obj,foldername)
            if~ischar(foldername)
                error(message('SDI:sdi:ValidateString'));
            end
            obj.ReportOutputFolder=foldername;
        end

        function set.ReportOutputFile(obj,filename)
            if~ischar(filename)
                error(message('SDI:sdi:ValidateString'));
            end
            [~,~,ext]=fileparts(filename);
            if~strcmpi(ext,'.html')
                obj.ReportOutputFile=[filename,'.html'];
            else
                obj.ReportOutputFile=filename;
            end
        end

        function set.PreventOverwritingFile(obj,value)
            if(~isa(value,'logical'))||(numel(value)>1)
                error(message('SDI:sdi:InvalidLogicalScalar'));
            end
            obj.PreventOverwritingFile=value;
        end

        function set.ReportToCreate(obj,value)
            if(~any(strcmp(value,...
                {'Inspect','Compare Signals','Compare'})))
                error(message('SDI:sdi:ValidateReportOption',value));
            end
            obj.ReportToCreate=value;
        end

        function set.ReportStyle(obj,value)
            if(~any(strcmp(value,...
                {'Printable','Interactive'})))
                error(message('SDI:sdi:ValidateReportOption',value));
            end
            obj.ReportStyle=value;
        end

        function set.ShortenBlockPath(obj,value)
            if(~isa(value,'logical'))||(numel(value)>1)
                error(message('SDI:sdi:InvalidLogicalScalar'));
            end
            obj.ShortenBlockPath=value;
        end

        function set.LaunchReport(obj,value)
            if(~isa(value,'logical'))||(numel(value)>1)
                error(message('SDI:sdi:InvalidLogicalScalar'));
            end
            obj.LaunchReport=value;
        end

        function createReport(obj)

            assert(isa(obj.SDIEngine,'Simulink.sdi.internal.Engine'));










            lastReport=[];
            reportToCreate=...
            strcmp(obj.ReportToCreate,...
            {'Inspect','Compare Signals','Compare'});

            i=find(reportToCreate==1,1);

            try
                rpt=obj.getReport(i);
                if~isempty(lastReport)
                    rpt.DocumentNode=lastReport.DocumentNode;
                    rpt.OutputFile=lastReport.OutputFile;
                end
                lastReport=rpt;

                rpt.ReportStyle=obj.ReportStyle;
                rpt.ReportTitle=obj.ReportTitle;
                rpt.ReportAuthor=obj.ReportAuthor;
                rpt.OutputFolder=obj.ReportOutputFolder;
                rpt.OutputFile=obj.ReportOutputFile;
                rpt.PreventOverwritingFile=obj.PreventOverwritingFile;
                rpt.CloseAfterWriting=false;
                if~isempty(obj.ColumnsToReport)
                    rpt.Columns=obj.ColumnsToReport;
                end
                rpt.IsBlockPathShortened=obj.ShortenBlockPath;
                if i==3

                    rpt.SignalsToReport=obj.SignalsToReport;
                end


                rpt.create();



                if~isempty(lastReport)

                    lastReport.close();


                    if obj.LaunchReport



                        web(fullfile(lastReport.OutputFolder,lastReport.OutputFile),'-browser');
                    end
                end

            catch me
                if~isempty(lastReport)

                    lastReport.close();
                end
                throw(me);
            end

        end

    end

    methods(Access=private)

        function rpt=getReport(obj,i)

            switch i
            case 1
                if strcmpi(obj.AppName,'sdi')
                    if isempty(obj.InspectSignalsReport)
                        obj.InspectSignalsReport=...
                        Simulink.sdi.internal.InspectSignalsReport(obj.SDIEngine);
                    end
                    rpt=obj.InspectSignalsReport;
                elseif strcmpi(obj.AppName,'siganalyzer')
                    if isempty(obj.InspectSignalsReportSigAnalyzer)
                        obj.InspectSignalsReportSigAnalyzer=...
                        signal.analyzer.InspectSignalsReport(obj.SDIEngine);
                    end
                    rpt=obj.InspectSignalsReportSigAnalyzer;
                end

            case 2
                if isempty(obj.CompareSignalsReport)
                    obj.CompareSignalsReport=...
                    Simulink.sdi.internal.CompareSignalsReport(obj.SDIEngine);
                end
                rpt=obj.CompareSignalsReport;

            case 3
                if isempty(obj.CompareRunsReport)
                    obj.CompareRunsReport=...
                    Simulink.sdi.internal.CompareRunsReport(obj.SDIEngine);
                end
                rpt=obj.CompareRunsReport;
            end
        end

    end

    methods(Hidden=true,Static=true)

        function validColumns=validateColumns(columns)

            validColumns={};
            if~isempty(columns)


                SD=Simulink.sdi.internal.StringDict;
                f=@(x)(isempty(x)||strcmp(x,SD.MGInspectColNamePlot)...
                ||strcmp(x,SD.mgLeft)||strcmp(x,SD.mgRight));
                rmv=cellfun(f,columns,'UniformOutput',false);
                rmv=~[rmv{:}];
                validColumns=columns(rmv);
            end
        end

        function columns=convertColumnNamesToSignalMetaDataElements(reportToCreate,columnNames)

            if isempty(columnNames)
                columns(1)=Simulink.sdi.SignalMetaData.SignalName;
            end

            for i=1:length(columnNames)
                switch(columnNames{i})

                case 'name'
                    if strcmpi(reportToCreate,'inspectSignals')
                        columns(i)=Simulink.sdi.SignalMetaData.SignalName;%#ok<*AGROW>
                    else
                        columns(i)=Simulink.sdi.SignalMetaData.SignalName1;
                    end
                case 'Description'
                    columns(i)=Simulink.sdi.SignalMetaData.SignalDescription;
                case 'color'
                    columns(i)=Simulink.sdi.SignalMetaData.Line;
                case 'units'
                    columns(i)=Simulink.sdi.SignalMetaData.Units;
                case 'dataType'
                    columns(i)=Simulink.sdi.SignalMetaData.SigDataType;
                case 'complexity'
                    columns(i)=Simulink.sdi.SignalMetaData.SigComplexity;
                case 'complexFormat'
                    columns(i)=Simulink.sdi.SignalMetaData.SigComplexFormat;
                case 'displayScaling'
                    columns(i)=Simulink.sdi.SignalMetaData.SigDisplayScaling;
                case 'displayOffset'
                    columns(i)=Simulink.sdi.SignalMetaData.SigDisplayOffset;
                case 'sampleTime'
                    columns(i)=Simulink.sdi.SignalMetaData.SigSampleTime;
                case 'model_source'
                    columns(i)=Simulink.sdi.SignalMetaData.Model;
                case 'block_name'
                    columns(i)=Simulink.sdi.SignalMetaData.BlockName;
                case 'block_source'
                    columns(i)=Simulink.sdi.SignalMetaData.BlockPath;
                case 'port'
                    columns(i)=Simulink.sdi.SignalMetaData.Port;
                case 'dimension'
                    columns(i)=Simulink.sdi.SignalMetaData.Dimensions;
                case 'channel'
                    columns(i)=Simulink.sdi.SignalMetaData.Channel;
                case 'run_name'
                    columns(i)=Simulink.sdi.SignalMetaData.Run;
                case 'abs'
                    columns(i)=Simulink.sdi.SignalMetaData.AbsTol;
                case 'rel'
                    columns(i)=Simulink.sdi.SignalMetaData.RelTol;
                case 'timeTol'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeTol;
                case 'overrideGlobalTol'
                    columns(i)=Simulink.sdi.SignalMetaData.OverrideGlobalTol;
                case 'interp'
                    columns(i)=Simulink.sdi.SignalMetaData.InterpMethod;
                case 'sync'
                    columns(i)=Simulink.sdi.SignalMetaData.SyncMethod;
                case 'root_source'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeSeriesRoot;
                case 'time_source'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeSource;
                case 'data_source'
                    columns(i)=Simulink.sdi.SignalMetaData.DataSource;


                case 'status'
                    columns(i)=Simulink.sdi.SignalMetaData.Result;
                case 'Compared_name'
                    columns(i)=Simulink.sdi.SignalMetaData.SignalName2;
                case 'Baseline_units'
                    columns(i)=Simulink.sdi.SignalMetaData.Units1;
                case 'Compared_units'
                    columns(i)=Simulink.sdi.SignalMetaData.Units2;
                case 'Baseline_dataType'
                    columns(i)=Simulink.sdi.SignalMetaData.SigDataType1;
                case 'Compared_dataType'
                    columns(i)=Simulink.sdi.SignalMetaData.SigDataType2;
                case 'Baseline_sampleTime'
                    columns(i)=Simulink.sdi.SignalMetaData.SigSampleTime1;
                case 'Compared_sampleTime'
                    columns(i)=Simulink.sdi.SignalMetaData.SigSampleTime2;
                case 'Baseline_run_name'
                    columns(i)=Simulink.sdi.SignalMetaData.Run1;
                case 'Compared_run_name'
                    columns(i)=Simulink.sdi.SignalMetaData.Run2;
                case 'alignedBy'
                    columns(i)=Simulink.sdi.SignalMetaData.AlignedBy;
                case 'Baseline_model_source'
                    columns(i)=Simulink.sdi.SignalMetaData.Model1;
                case 'Compared_model_source'
                    columns(i)=Simulink.sdi.SignalMetaData.Model2;
                case 'Baseline_block_name'
                    columns(i)=Simulink.sdi.SignalMetaData.BlockName1;
                case 'Compared_block_name'
                    columns(i)=Simulink.sdi.SignalMetaData.BlockName2;
                case 'Baseline_dimension'
                    columns(i)=Simulink.sdi.SignalMetaData.Dimensions1;
                case 'Compared_dimension'
                    columns(i)=Simulink.sdi.SignalMetaData.Dimensions2;
                case 'Baseline_block_source'
                    columns(i)=Simulink.sdi.SignalMetaData.BlockPath1;
                case 'Compared_block_source'
                    columns(i)=Simulink.sdi.SignalMetaData.BlockPath2;
                case 'Baseline_channel'
                    columns(i)=Simulink.sdi.SignalMetaData.Channel1;
                case 'Compared_channel'
                    columns(i)=Simulink.sdi.SignalMetaData.Channel2;
                case 'Baseline_root_source'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeSeriesRoot1;
                case 'Compared_root_source'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeSeriesRoot2;
                case 'Baseline_time_source'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeSource1;
                case 'Compared_time_source'
                    columns(i)=Simulink.sdi.SignalMetaData.TimeSource2;
                case 'Baseline_data_source'
                    columns(i)=Simulink.sdi.SignalMetaData.DataSource1;
                case 'Compared_data_source'
                    columns(i)=Simulink.sdi.SignalMetaData.DataSource2;
                case 'Baseline_color'
                    columns(i)=Simulink.sdi.SignalMetaData.Line1;
                case 'Compared_color'
                    columns(i)=Simulink.sdi.SignalMetaData.Line2;
                case 'Baseline_port'
                    columns(i)=Simulink.sdi.SignalMetaData.Port1;
                case 'Compared_port'
                    columns(i)=Simulink.sdi.SignalMetaData.Port2;
                case 'maxdiff'
                    columns(i)=Simulink.sdi.SignalMetaData.MaxDifference;
                end
            end
        end

    end

end

