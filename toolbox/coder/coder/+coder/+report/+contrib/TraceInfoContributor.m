

classdef(Sealed)TraceInfoContributor<coder.report.Contributor


    properties(Constant)
        ID='coder-traceInfo'
        DATA_GROUP='traceability'
        InjectedDependencies={'coder.report.contrib.ClangToolingContributor'};
    end

    properties(Constant,Hidden)
        TRACE_DATA_FILE=codergui.internal.ReportCodeTraceService.C_TRACE_DATA_FILE
    end

    properties(SetAccess=private)
TraceInfo
    end

    properties(Access=private)


ClangContributor
    end

    methods
        function obj=TraceInfoContributor(aClangContributor)
            obj.ClangContributor=aClangContributor;
        end

        function relevant=isRelevant(this,reportContext)
            relevant=reportContext.IsEmbeddedCoder&&...
            ((~reportContext.IsStateflow&&isfile(this.getTraceInfoFile(reportContext)))||...
            (reportContext.IsStateflow&&~isempty(codergui.evalprivate('getFunctionBlockTraceInfo',reportContext.SimulinkSID))));
        end

        function contribute(this,reportContext,contribContext)

            if isempty(this.ClangContributor.TraceResult)
                return
            end

            scriptIds=contribContext.IncludedScriptIds;
            isMLFB=reportContext.IsStateflow;
            if isempty(scriptIds)
                return;
            elseif~isMLFB

                traceInfoFile=this.getTraceInfoFile(reportContext);
                traceInfo=coder.trace.TraceInfoBuilder('');
                try


                    evalc('traceInfo.loadFrom(traceInfoFile);');
                    srcs=traceInfo.files';
                    cm=traceInfo.getCodeToModelRecords();
                catch
                    return;
                end
                if isempty(cm)
                    return;
                end
            else

                traceInfoFile='';
                try
                    traceInfo=codergui.evalprivate('getFunctionBlockTraceInfo',reportContext.SimulinkSID);
                    mc=traceInfo.getModelToCode(sprintf('%s:0-%d',reportContext.SimulinkSID,intmax('int32')));
                    if isempty(mc.tokens)
                        return;
                    end
                    srcs=traceInfo.files';
                    indices=unique([mc.tokens.fileIdx]);
                    cm=[];
                    for i=1:numel(indices)
                        file=srcs{indices(i)+1};
                        cm=[cm,traceInfo.getCodeToModelRecords(file)];%#ok<AGROW>
                    end
                catch
                    return;
                end
            end


            if isMLFB
                client=coderapp.internal.reportgentools.trace.ClientType.MLFB;
            else
                client=coderapp.internal.reportgentools.trace.ClientType.CODER;
            end


            config=reportContext.Config;
            if coder.internal.isGpuConfigEnabled(config)
                language=coderapp.internal.reportgentools.trace.TargetLanguage.CUDA;
            elseif~isempty(config)&&strcmp(config.TargetLang,'C')
                language=coderapp.internal.reportgentools.trace.TargetLanguage.C;
            else
                language=coderapp.internal.reportgentools.trace.TargetLanguage.CPP;
            end


            if isfield(reportContext.Report.summary,'buildInfo')&&~isempty(reportContext.Report.summary.buildInfo)
                includePaths=reportContext.Report.summary.buildInfo.getIncludePaths(true);
            else
                includePaths={};
            end
            includePaths{end+1}=fullfile(matlabroot,'toolbox','rtw','rtw','+rtw','+codemetrics','@C_CodeMetrics','include');


            if contribContext.DryRun
                outputFile=[];
            else
                outputFile=fullfile(reportContext.ReportDirectory,this.TRACE_DATA_FILE);
                contribContext.linkArtifact(this.DATA_GROUP,'traceData','File',this.TRACE_DATA_FILE);
            end

            scripts=reportContext.Report.inference.Scripts(scriptIds);

            model=mf.zero.Model();

            traceHelper=coderapp.internal.reportgentools.trace.TraceInfoProcessor(model,struct(...
            'BuildDir',string(reportContext.BuildDirectory),...
            'IncludePaths',string(includePaths),...
            'OutputFile',string(outputFile),...
            'Client',client,...
            'Language',language,...
            'IsDebugMode',contribContext.PrintDebugInfo||contribContext.DryRun,...
            'ModelFiles',string({scripts.ScriptPath})));

            scriptLineMaps=contribContext.LineMaps(scriptIds);
            for i=1:numel(scriptLineMaps)
                scriptLineMaps{i}=int32(scriptLineMaps{i});
            end
            traceHelper.ModelLineMaps=scriptLineMaps;
            traceHelper.SourceFileList=srcs;
            traceHelper.CodeToModelRecords=cm;

            traceHelper.ClangAnalysisResults=this.ClangContributor.TraceResult;
            traceHelper.process();



            if~contribContext.PrintDebugInfo&&~contribContext.DryRun&&~isempty(traceInfoFile)
                delete(traceInfoFile);
            end
        end
    end

    methods(Static,Access=private)
        function traceInfoFile=getTraceInfoFile(reportContext)
            traceInfoFile=fullfile(reportContext.BuildDirectory,'traceInfo');
        end
    end
end


