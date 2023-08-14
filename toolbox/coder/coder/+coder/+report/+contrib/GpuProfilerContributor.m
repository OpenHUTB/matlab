



classdef(Sealed)GpuProfilerContributor<coder.report.Contributor
    properties(Constant)
        ID='coder-gpucoder-profiler'
        DATA_GROUP='gpuprofiler'
        DATA_KEY_PROFILING='profiling'
        DATA_KEY_DIAGNOSTICS='diagnostics'
        DATA_KEY_OVERALL='overall'
        USED_GPU_PROFILER='usedGpuProfiler'
    end

    properties(Constant,Hidden)
        InjectedDependencies={'coder.report.contrib.InferenceReportContributor'}
    end

    properties(SetAccess=immutable,GetAccess=private)
InferenceContributor
    end

    properties
DiagnosticsData
    end

    methods
        function this=GpuProfilerContributor(inferenceContributor)
            if nargin>0&&~isempty(inferenceContributor)
                this.InferenceContributor=inferenceContributor;
            end
        end

        function relevant=isRelevant(this,reportContext)
            relevant=true;
            if relevant
                jsonFile=this.getGpuProfilingDataFile(reportContext);
                relevant=isfile(jsonFile);
            end
        end

        function contribute(this,reportContext,contribContext)
            contribContext.setManifestProperty(this.USED_GPU_PROFILER,true);
            this.contributeProfilingData(reportContext,contribContext);
        end
    end

    methods(Access=private)
        function contributeProfilingData(this,reportContext,contribContext)
            jsonFile=this.getGpuProfilingDataFile(reportContext);
            [labels,gpuTrace]=gpucoder.internal.profiling.parseNsysJson(jsonFile);
            [data,diagnostics,overall]=gpucoder.internal.profiling.NsysTraceDataProcessor.getProcessedData(labels,gpuTrace,true);
            contribContext.addData(this.DATA_GROUP,this.DATA_KEY_PROFILING,data);
            contribContext.addData(this.DATA_GROUP,this.DATA_KEY_DIAGNOSTICS,diagnostics);
            contribContext.addData(this.DATA_GROUP,this.DATA_KEY_OVERALL,overall);
        end
    end

    methods(Static,Access=private)
        function jsonFile=getGpuProfilingDataFile(reportContext)
            if(isfield(reportContext.Report.summary,'outDirectory'))
                jsonFile=fullfile(reportContext.Report.summary.outDirectory,'mw_nsysData.json');
            else
                jsonFile="";
            end
        end
    end
end
