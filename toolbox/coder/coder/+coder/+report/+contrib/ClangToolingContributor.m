

classdef(Sealed)ClangToolingContributor<coder.report.Contributor
    properties(Constant)
        ID='coder-clangTooling';
    end

    properties(Access=public,Transient)


        LinksResult=[];



        TraceResult=[];
    end

    properties(Access=public)

        SourceFiles=[];
    end

    properties(Access=private,Transient)

        Model;
    end

    methods




        function contribute(this,reportContext,~)
            import coder.internal.clang.*;

            this.SourceFiles=codergui.evalprivate('findGeneratedSource',...
            reportContext.Report);
            if isempty(this.SourceFiles)

                return;
            end

            this.Model=mf.zero.Model;

            analyses=Analysis.empty();
            linksAnalysis=[];
            traceAnalysis=[];

            if isLinksAnalysisEnabled(reportContext)
                linksAnalysis=this.getLinksAnalysis(reportContext);
                analyses(end+1)=linksAnalysis;
            end

            if isTraceAnalysisEnabled(reportContext)
                traceAnalysis=this.getTraceAnalysis(reportContext);
                analyses(end+1)=traceAnalysis;
            end

            commands=getCompileCommands(this.Model,reportContext);

            try
                if~isempty(analyses)
                    Analysis.runAnalyses(commands,analyses);
                    this.populateLinksResults(linksAnalysis);
                    this.populateTraceResults(traceAnalysis);
                end
            catch ME
                coder.internal.ccwarningid('Coder:FE:ClangInvocationFailed',...
                ME.message);
            end

            fe=getOrCreateFeatureControl(reportContext);
            if fe.VerboseClangOutput
                this.displayEmittedClangDiags;
            end
        end
    end

    methods(Access=private)



        function displayEmittedClangDiags(this)
            if~isempty(this.LinksResult)&&~isempty(this.LinksResult.Diags)
                coder.internal.ccwarningid('Coder:FE:ClangDiagnosticsEmitted',...
                this.LinksResult.Diags);
            elseif~isempty(this.TraceResult)&&~isempty(this.TraceResult.Diags)
                coder.internal.ccwarningid('Coder:FE:ClangDiagnosticsEmitted',...
                this.TraceResult.Diags);
            end
        end





        function populateLinksResults(this,linksAnalysis)
            if~isempty(linksAnalysis)
                this.LinksResult=linksAnalysis.Output;
            else
                this.LinksResult=[];
            end
        end





        function populateTraceResults(this,traceAnalysis)
            if~isempty(traceAnalysis)
                this.TraceResult=traceAnalysis.Output;
            else
                this.TraceResult=[];
            end
        end




        function analysis=getLinksAnalysis(this,reportContext)
            import coder.internal.clang.*;




            config=reportContext.Config;
            traceLinkSupport=TraceLinkSupport.EXCLUDE_TRACE_LINKS;
            if(~isempty(config)&&isa(config,'coder.EmbeddedCodeConfig')...
                &&~isa(config,'coder.MexCodeConfig'))
                traceLinkSupport=TraceLinkSupport.INCLUDE_TRACE_LINKS;
            end

            allowedFiles=string([this.SourceFiles.Source;this.SourceFiles.Examples;...
            this.SourceFiles.Interfaces;this.SourceFiles.AutoVerify]');

            input=LinksInput(this.Model);
            for file=string(allowedFiles(:))'
                input.AllowedFiles.add(file);
            end
            input.TraceLinkSupport=traceLinkSupport;
            analysis=LinksAnalysis(this.Model);
            analysis.Input=input;
        end




        function analysis=getTraceAnalysis(this,~)
            import coder.internal.clang.*;
            analysis=TraceAnalysis(this.Model);
        end
    end
end




function commands=getCompileCommands(model,reportContext)
    import coder.internal.clang.*;
    buildInfo=reportContext.Report.summary.buildInfo;
    config=reportContext.Config;
    altBuildDir=reportContext.Report.summary.directory;
    commands=getCompileCommandsForProject(model,buildInfo,config,'AltBuildDir',altBuildDir);
end




function enabled=isLinksAnalysisEnabled(reportContext)
    fe=getOrCreateFeatureControl(reportContext);
    enabled=fe.EnableClangForReport&&...
    coder.internal.clang.Utils.isClangToolingAvailable;
end




function enabled=isTraceAnalysisEnabled(reportContext)
    fe=getOrCreateFeatureControl(reportContext);
    enabled=fe.EnableClangForReport&&...
    coder.internal.clang.Utils.isClangToolingAvailable&&...
    isa(reportContext.Config,'coder.EmbeddedCodeConfig');
end






function fe=getOrCreateFeatureControl(reportContext)
    fe=reportContext.FeatureControl;
    if isempty(fe)
        fe=coder.internal.FeatureControl;
    end
end
