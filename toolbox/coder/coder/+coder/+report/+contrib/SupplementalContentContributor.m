


classdef(Sealed)SupplementalContentContributor<coder.report.Contributor

    properties(Constant)
        ID='coder-supplemental'
        DATA_GROUP='supplemental'
        ARTIFACT_GROUP='supplemental'
        HAS_BUILD_INFO_PROPERTY='reportHasBuildInfo'
        REPORT_TYPE_PROPERTY='reportType'
        BUILD_INFO_FILE=codergui.ReportServices.BUILD_INFO_FILE
        REPORT_INFO_FILE=codergui.ReportServices.REPORT_INFO_FILE
        DESCRIBED_CONFIG_KEY='describedConfigs'
        CODEGEN_CONFIG_KEY='codegenConfig'
        IS_BUILD_INSTRUMENTED_MEX='isBuildInstrumentedMex'
        CODE_METRICS_REPORT_STATE=codergui.internal.reportws.CodeMetricsReportService.CODE_METRICS_STATE
    end

    properties(Constant,Access=private)
        SUMMARY_FIELD_BLACKLIST={...
        'coderMessages','messageList','runtimeMessages','messageTree',...
        'buildInfo','potentialDifferences','mainhtml','buildResults'}
    end

    methods
        function supported=isSupportsVirtualMode(~,~)
            supported=true;
        end

        function contribute(this,reportContext,contribContext)
            codeMetricsState=this.getCodeMetricsReportState(reportContext,contribContext);
            if~isempty(reportContext.Config)
                this.generateLegacyAuxPages(reportContext,contribContext,strcmp(codeMetricsState,...
                codergui.internal.reportws.CodeMetricsReportService.STATE_GENERATED));
                this.contributeFilteredConfig(reportContext,contribContext);

                if isprop(reportContext.Config,'EnableAutoParallelizationReporting')&&...
                    reportContext.Config.EnableAutoParallelizationReporting&&...
                    reportContext.Report.summary.passed
                    this.contributeAutoParSourceMappings(reportContext,contribContext);
                end
            end
            contribContext.setManifestProperty(this.CODE_METRICS_REPORT_STATE,codeMetricsState);

            if~ismember(reportContext.ClientType,{'stateflow','systemblock'})
                this.contributeSummary(reportContext,contribContext);
                this.contributeBuildLogs(reportContext,contribContext);
            end

            contribContext.addData(this.DATA_GROUP,'reportContext',...
            reportContext.toReportSerializeableForm());
            contribContext.setManifestProperty(this.REPORT_TYPE_PROPERTY,reportContext.ClientType);

            canPack=this.contributeBuildInfo(reportContext,contribContext);
            this.saveContextualInformation(reportContext,contribContext,canPack);
            this.contributeDescribedConfigs(reportContext,contribContext);

            contribContext.setManifestProperty(this.IS_BUILD_INSTRUMENTED_MEX,~isempty(reportContext.FeatureControl)&&...
            strcmpi(reportContext.FeatureControl.LocationLogging,'mex'));
        end
    end

    methods(Access=private)
        function contributeSummary(this,reportContext,contribContext)
            summary=codergui.evalprivate('processReportSummary',reportContext,contribContext.ReportType);

            contribContext.addData(this.DATA_GROUP,'summary',rmfield(...
            summary,this.SUMMARY_FIELD_BLACKLIST(isfield(summary,this.SUMMARY_FIELD_BLACKLIST))));

            [otherScripts.mappings,omittedScripts]=this.mapScriptArrays(reportContext.Report);
            if~isempty(otherScripts.mappings)
                if~contribContext.Filtered
                    otherScripts.omittedScripts=omittedScripts;
                end
                contribContext.addData(this.DATA_GROUP,'otherScripts',otherScripts);
            end
        end

        function contributeBuildLogs(this,reportContext,contribContext)
            converted=this.processBuildResults(reportContext);
            if isempty(converted)
                return;
            end
            contribContext.addData(this.DATA_GROUP,'buildResults',converted);
        end

        function metrics=generateLegacyAuxPages(this,reportContext,contribContext,genCodeMetricsReport)
            pages={};
            metrics=[];
            metricsPage=[];

            if contribContext.DryRun
                return;
            end

            if genCodeMetricsReport
                pages{end+1}={'codeMetrics',coder.report.CodeMetrics(reportContext.BuildDirectory,true,reportContext.IsCpp)};
                metricsPage=pages{end}{2};
            end

            if this.hasCodeReplacements(reportContext)
                pages{end+1}={'codeReplacements',coder.report.CodeReplacements(reportContext.CodeReplacementLibrary)};
            end

            if~isempty(pages)

                reportFolder=reportContext.ReportDirectory;
                htmlLinkManager=coder.report.HTMLLinkManager(true);
                htmlLinkManager.BuildDir=reportContext.BuildDirectory;

                for i=1:length(pages)
                    pageId=pages{i}{1};
                    page=pages{i}{2};
                    page.setLinkManager(htmlLinkManager);
                    page.ReportFolder=reportFolder;

                    if page.isEnable(reportContext.Config)
                        if~contribContext.DryRun
                            page.generate();
                        end

                        if contribContext.VirtualMode
                            contribContext.embedArtifact(this.ARTIFACT_GROUP,pageId,...
                            'File',page.ReportFileName,...
                            'Content',fileread(fullfile(reportFolder,page.ReportFileName)));
                        else
                            contribContext.linkArtifact(this.ARTIFACT_GROUP,pageId,...
                            'File',page.ReportFileName,...
                            'Encoding','UTF-8');
                        end
                    end
                end

                if~isempty(metricsPage)


                    metrics=metricsPage.Data;
                end
            end
        end

        function canPack=contributeBuildInfo(this,reportContext,contribContext)
            hasBuildInfo=isfield(reportContext.Report.summary,'buildInfo')&&...
            ~isempty(reportContext.Report.summary.buildInfo);
            contribContext.setManifestProperty(this.HAS_BUILD_INFO_PROPERTY,hasBuildInfo);
            canPack=false;
            if hasBuildInfo
                buildInfo=reportContext.Report.summary.buildInfo;
                canPack=~buildInfo.Settings.DisablePackNGo;
                contribContext.saveMatFile(fullfile(reportContext.ReportDirectory,this.BUILD_INFO_FILE),'buildInfo');
            end
        end

        function saveContextualInformation(this,reportContext,contribContext,canPack)
            reportInfo.clientType=reportContext.ClientType;
            reportInfo.buildDirectory=reportContext.BuildDirectory;
            reportInfo.reportDirectory=reportContext.ReportDirectory;
            reportInfo.canPackage=canPack;
            report=reportContext.Report;

            if~isempty(reportContext.SimulinkModelName)
                reportInfo.modelName=reportContext.SimulinkModelName;
                reportInfo.modelPath=get_param(reportInfo.modelName,'filename');%#ok<STRNU>
                contribContext.setManifestProperty(codergui.ReportServices.SIMULINK_SID_PROPERTY,...
                reportContext.SimulinkSID);
            elseif isfield(report,'inference')&&~isempty(report.inference)

                scriptPaths={report.inference.Scripts(contribContext.IncludedScriptIds).ScriptPath};
                reportPath=codergui.internal.util.getCanonicalPath(reportContext.ReportDirectory);
                relPaths=containers.Map();
                for i=1:numel(scriptPaths)
                    parentPath=fileparts(scriptPaths{i});
                    if~relPaths.isKey(parentPath)
                        parentPath=codergui.internal.util.getCanonicalPath(parentPath);
                        try
                            relPath=codergui.internal.relativize(parentPath,reportPath);
                            if~isempty(relPath)
                                relPaths(char(parentPath))=relPath;
                            end
                        catch
                        end
                    end
                end
                try
                    reportInfo.relativeBuildDirectory=codergui.internal.relativize(...
                    codergui.internal.util.getCanonicalPath(reportContext.BuildDirectory),reportPath);
                catch
                end
                reportInfo.relativePaths=relPaths;%#ok<STRNU>
            end

            contribContext.saveMatFile(fullfile(reportContext.ReportDirectory,this.REPORT_INFO_FILE),'reportInfo');
        end

        function contributeDescribedConfigs(this,reportContext,contribContext)
            if isempty(reportContext.Config)
                return;
            end
            try
                described=codergui.evalprivate('describeConfig',reportContext.Config);
            catch me
                if contribContext.PrintDebugInfo
                    coder.internal.gui.asyncDebugPrint(me);
                end
                if contribContext.ValidationMode
                    me.rethrow();
                end
                return;
            end
            contribContext.addData(this.DATA_GROUP,this.DESCRIBED_CONFIG_KEY,described);
        end

        function contributeFilteredConfig(this,reportContext,contribContext)


            allProps=properties(reportContext.Config);
            for i=1:numel(allProps)
                value=reportContext.Config.(allProps{i});
                if isnumeric(value)||islogical(value)
                    if~isscalar(value)||issparse(value)||~isreal(value)||isobject(value)
                        continue;
                    end
                elseif~ischar(value)||~isstring(value)
                    continue;
                end
                filteredCfg.(allProps{i})=value;
            end
            contribContext.addData(this.DATA_GROUP,this.CODEGEN_CONFIG_KEY,filteredCfg);
        end

        function contributeAutoParSourceMappings(this,reportContext,contribContext)
            if isempty(reportContext.DesignInspectorResults)
                return
            end

            tagData=reportContext.DesignInspectorResults.getParsedResults('AUTOPAR_LOOP');
            locations=emlcprivate('extractLocations',tagData,'Coder:reportGen:autoParLabel',reportContext.Report);
            locations=emlcprivate('propagateLocations',locations,reportContext.Report);

            inference=contribContext.Report.inference;
            mappingsByFunc=cell(1,numel(inference.Functions));
            mappedFuncIds=[];

            for i=1:numel(locations)
                funcId=locations(i).FunctionID;
                outIdx=size(mappingsByFunc{funcId},1)+1;
                mappingsByFunc{funcId}(outIdx,:)={...
                double(locations(i).TextStart),...
                double(locations(i).TextStart+locations(i).TextLength)};
                if outIdx==1
                    mappedFuncIds(end+1)=funcId;%#ok<AGROW>
                end
            end

            mappedFuncIds=unique(mappedFuncIds);
            totalMappedFuncs=numel(mappedFuncIds);
            data.mappingsByFunction=cell2struct(cell(totalMappedFuncs,2),{'functionId','mappings'},2);
            outIdx=1;
            for i=1:totalMappedFuncs
                mappedFuncId=mappedFuncIds(i);
                mappingRows=sortrows(mappingsByFunc{mappedFuncId},[2,1]);
                scriptId=inference.Functions(mappedFuncId).ScriptID;
                intervals=cell2mat(mappingRows);
                data.mappingsByFunction(outIdx).functionId=mappedFuncId;
                data.mappingsByFunction(outIdx).mappings=cell2struct(...
                [mappingRows,num2cell([contribContext.positionToLine(scriptId,intervals(:,1)+1),...
                contribContext.positionToLine(scriptId,intervals(:,2))])],...
                {'start','end','startLine','endLine'},2);
                outIdx=outIdx+1;
            end
            if isscalar(data.mappingsByFunction)
                data.mappingsByFunction={data.mappingsByFunction};
            end

            contribContext.addData(this.DATA_GROUP,'autoParSourceMappings',data);
        end
    end

    methods(Static,Hidden)
        function cmState=getCodeMetricsReportState(reportContext,contribContext)
            import codergui.internal.reportws.CodeMetricsReportService;
            if~isempty(reportContext.Config)&&reportContext.IsEmbeddedCoder&&~contribContext.VirtualMode
                if reportContext.Config.GenerateCodeMetricsReport
                    cmState=CodeMetricsReportService.STATE_GENERATED;
                else
                    cmState=CodeMetricsReportService.STATE_SUPPORTED;
                end
            else
                cmState=CodeMetricsReportService.STATE_UNSUPPORTED;
            end
        end

        function yes=hasCodeReplacements(reportContext)
            yes=reportContext.IsEmbeddedCoder&&reportContext.Config.GenerateCodeReplacementReport;
        end

        function[mappings,omittedScripts]=mapScriptArrays(report)
            if~isfield(report,'inference')||~isfield(report,'scripts')||isempty(report.inference)
                mappings=[];
                omittedScripts=[];
                return;
            end


            infScripts=report.inference.Scripts;
            idsByPath=containers.Map();
            for i=1:numel(infScripts)
                idsByPath(infScripts(i).ScriptPath)=i;
            end



            reportScripts=report.scripts;
            mappings=zeros(size(reportScripts));
            for i=1:numel(reportScripts)
                scriptPath=reportScripts{i}.ScriptPath;
                if idsByPath.isKey(scriptPath)
                    mappings(i)=idsByPath(scriptPath);
                end
            end



            omittedScripts=repmat({{}},size(mappings));
            omittedIds=find(mappings==0);
            for i=1:numel(omittedIds)
                omittedScripts{i}.ReportScriptID=i;
                omittedScripts{i}.Name=reportScripts{i}.ScriptName;
                omittedScripts{i}.Path=reportScripts{i}.ScriptPath;
                omittedScripts{i}.Text=reportScripts{i}.ScriptText;
            end
        end

        function out=markupBuildLog(makeLog,compilerName)

            [~,lines]=regexp(makeLog,'[^\n]*\n?','tokens','match');
            out=cell2struct(cell(numel(lines),2),{'Type','Text'},2);
            for i=1:numel(lines)
                out(i).Type=emlcprivate('emcGetBuildLineClass',lines{i},compilerName);
                out(i).Text=regexprep(lines{i},'\n|\r','');
            end
        end

        function out=processBuildResults(reportContext)
            if isfield(reportContext.Report.summary,'buildResults')
                buildResults=reportContext.Report.summary.buildResults;
                out=cell2struct(cell(0,3),{'wrappedMakeCommand','makeCommand','logs'},2);
                for i=1:numel(buildResults)
                    buildResult=buildResults{i};

                    if isprop(buildResult,'wrappedMakeCmd')
                        wrappedCmd=buildResult.wrappedMakeCmd;
                    else
                        wrappedCmd='';
                    end
                    if isprop(buildResult,'makeCmd')
                        makeCmd=buildResult.makeCmd;
                    else
                        makeCmd='';
                    end
                    if isprop(buildResult,'Log')
                        logs=coder.report.contrib.SupplementalContentContributor.markupBuildLog(buildResult.Log,reportContext.CompilerName);
                    else
                        logs=[];
                    end

                    if~isempty(wrappedCmd)||~isempty(makeCmd)||~isempty(logs)
                        out(end+1).wrappedMakeCommand=wrappedCmd;%#ok<AGROW>
                        out(end).makeCommand=makeCmd;
                        out(end).logs=logs;
                    end
                end
            else
                out=[];
            end
        end
    end
end
