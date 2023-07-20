


classdef(Sealed)InstrumentedReportContributor<coder.report.Contributor

    properties(Constant)
        ID='coder-instrumentation'
        DATA_GROUP='instrumentationData'
        HISTOGRAM_MAT_PATH=codergui.internal.reportws.NtxLauncherService.HISTOGRAM_MAT_FILE
        MANIFEST_PROP=codergui.internal.reportws.NtxLauncherService.HISTOGRAM_PROPERTY
    end

    methods
        function relevant=isRelevant(~,reportContext)
            relevant=isfield(reportContext.Report,'InstrumentedData')&&...
            isfield(reportContext.Report.InstrumentedData,'InstrumentedFunctions');
        end

        function supported=isSupportsVirtualMode(~,~)
            supported=true;
        end

        function contribute(this,reportContext,contribContext)
            [data,histogramStruct,options]=codergui.evalprivate('processInstrumentedData',...
            reportContext.Report,contribContext.IncludedFunctionIds,contribContext.LineMaps);

            contribContext.addData(this.DATA_GROUP,'data',data);
            contribContext.addData(this.DATA_GROUP,'options',options);

            if~isempty(histogramStruct)
                if~contribContext.DryRun
                    dataDir=fileparts(fullfile(reportContext.ReportDirectory,this.HISTOGRAM_MAT_PATH));
                    if~isfolder(dataDir)
                        mkdir(dataDir);
                    end
                    save(fullfile(reportContext.ReportDirectory,this.HISTOGRAM_MAT_PATH),'histogramStruct');
                end
                contribContext.addData(this.DATA_GROUP,'histogramMatFile',this.HISTOGRAM_MAT_PATH);
            end
            contribContext.setManifestProperty(this.MANIFEST_PROP,~isempty(histogramStruct));
        end
    end

end
