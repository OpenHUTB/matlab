

classdef(Sealed)Float2FixedContributor<coder.report.Contributor




    properties(Constant)
        ID='coder-f2f'
        DATA_GROUP='f2f'
        ARTIFACT_GROUP='f2fFiles'
        TRACE_DATA_FILE=codergui.internal.ReportCodeTraceService.F2F_TRACE_DATA_FILE
    end

    methods
        function relevant=isRelevant(this,reportContext)
            relevant=~isempty(this.getFixedPointSummary(reportContext));
        end

        function contribute(this,reportContext,contribContext)
            fixptSummary=this.getFixedPointSummary(reportContext);

            dataStruct=fixptSummary;
            dataStruct.config=fixptSummary.data.config;
            dataStruct=rmfield(dataStruct,'data');

            if~isempty(fixptSummary.typeReport)
                if~contribContext.DryRun
                    [~,baseName,ext]=fileparts(fixptSummary.typeReport);
                    success=copyfile(fixptSummary.typeReport,fullfile(reportContext.ReportDirectory,[baseName,ext]));
                    if success
                        contribContext.linkArtifact(this.ARTIFACT_GROUP,'conversionTypeReport',...
                        'File',[baseName,ext],'Encoding','UTF-8');
                    end
                end
            end

            hasTraceability=false;
            if usejava('jvm')&&coder.internal.gui.Features.FixedPointTraceability.Enabled&&...
                isfield(fixptSummary.data,'traceability')&&~isempty(fixptSummary.data.traceability)
                traceData=this.processTraceability(contribContext,fixptSummary.data.traceability,...
                fixptSummary.data.report,reportContext.Report);
                if~isempty(traceData)
                    if~contribContext.DryRun
                        outputFile=fullfile(reportContext.ReportDirectory,this.TRACE_DATA_FILE);
                    else
                        outputFile=[];
                    end
                    this.serializeTraceability(traceData,outputFile);
                    if~contribContext.DryRun
                        contribContext.linkArtifact(this.ARTIFACT_GROUP,'conversionTraceData','File',this.TRACE_DATA_FILE);
                        hasTraceability=true;
                    end
                end
            end

            dataStruct.hasTraceability=hasTraceability;
            contribContext.addData(this.DATA_GROUP,'summary',dataStruct);
        end
    end

    methods(Static,Access=private)
        function data=processTraceability(contribContext,traceData,preReport,postReport)
            data=[];
            if~isfield(preReport,'inference')||~isa(preReport.inference,'eml.InferenceReport')...
                ||~isfield(postReport,'inference')||~isa(postReport.inference,'eml.InferenceReport')
                return;
            end

            preFuncs=preReport.inference.Functions;
            preScripts=preReport.inference.Scripts;
            preFcnOffset=numel(preFuncs);
            postFcns=postReport.inference.Functions;
            postScripts=postReport.inference.Scripts;

            traceableFcnNames=traceData.functionTraces(:,1);
            fcnScriptIds=[preFuncs([traceData.functionTraces{:,2}]).ScriptID];
            fcnIds=coder.report.contrib.Float2FixedContributor.resolveToFunctions(...
            postReport,traceableFcnNames);
            [classMethodIds,preInferenceIds]=coder.report.contrib.Float2FixedContributor.resolveToMethods(...
            postReport,traceData.classTraces);
            methodScriptIds=[preFuncs(preInferenceIds).ScriptID];

            preLineMaps=codergui.evalprivate('reportToLineMaps',preReport,...
            unique([fcnScriptIds,methodScriptIds]));
            sourceLocs=cell2struct(cell(0,7),...
            {'start','end','firstLine','lastLine','locationId','functionId','file'},2);
            targetLocs=sourceLocs;
            mappings=zeros(2,0);

            for i=1:size(traceData.functionTraces,1)
                processFunction(traceData.functionTraces{i,2:3},fcnIds{i});
            end
            for i=1:size(traceData.classTraces,1)
                methodTraces=traceData.classTraces{i,2};
                for j=1:size(methodTraces,1)
                    processFunction(methodTraces{j,2:3},classMethodIds{i}{j});
                end
            end

            data.sourceLocations=sourceLocs;
            data.targetLocations=targetLocs;
            data.mappings=mappings;


            function processFunction(preFcnId,traces,postFcnIds)
                sourceFun=preFuncs(preFcnId);
                sourceLineMap=preLineMaps{sourceFun.ScriptID};

                locCount=numel(traces);
                traceCount=locCount*numel(postFcnIds);
                postCount=numel(postFcnIds);

                saStart=numel(sourceLocs)+1;
                [sourceLocs(saStart:saStart+locCount-1).start]=deal(traces.origStart);
                [sourceLocs(saStart:saStart+locCount-1).end]=deal(traces.origEnd);
                [sourceLocs(saStart:saStart+locCount-1).functionId]=deal(preFcnId+preFcnOffset);
                ids=num2cell(saStart:(saStart+locCount));
                [sourceLocs(saStart:saStart+locCount-1).locationId]=ids{:};
                [sourceLocs(saStart:saStart+locCount-1).file]=deal(preScripts(sourceFun.ScriptID).ScriptPath);
                taStart=numel(targetLocs)+1;
                ids=num2cell(taStart:(taStart+traceCount));
                [targetLocs(taStart:taStart+traceCount-1).locationId]=ids{:};
                mappings(:,end+traceCount)=[0,0];

                for ii=1:locCount
                    trace=traces(ii);
                    sourceLocs(saStart-1+ii).firstLine=sourceLineMap(trace.origStart);
                    sourceLocs(saStart-1+ii).lastLine=sourceLineMap(trace.origEnd);
                end

                for ii=1:postCount
                    postFun=postFcns(postFcnIds(ii));
                    postLineMap=contribContext.LineMaps{postFun.ScriptID};
                    targetPath=postScripts(postFun.ScriptID).ScriptPath;
                    offset=taStart-1+(ii-1)*locCount;
                    for jj=1:locCount
                        trace=traces(jj);
                        targetLocs(offset+jj).start=trace.fixptStart;
                        targetLocs(offset+jj).end=trace.fixptEnd;
                        targetLocs(offset+jj).firstLine=postLineMap(trace.fixptStart);
                        targetLocs(offset+jj).lastLine=postLineMap(trace.fixptEnd);
                        targetLocs(offset+jj).functionId=postFcnIds(ii);
                        targetLocs(offset+jj).file=targetPath;
                        mappings(:,offset+jj)=[sourceLocs(saStart-1+jj).locationId,offset+jj];
                    end
                end
            end
        end

        function[resolved,scriptIds]=resolveToFunctions(report,whitelist,classname)
            whitelist=sort(whitelist);
            allFcns=report.inference.Functions;
            if nargin<3
                fcnIds=find(ismember({allFcns.FunctionName},whitelist));
            else
                fcnIds=find(strcmp({allFcns.ClassName},classname)&...
                ismember({allFcns.FunctionName},whitelist));
            end
            fcnRows=cell(numel(fcnIds),2);
            fcnRows(:,1)={allFcns(fcnIds).FunctionName};
            fcnRows(:,2)=num2cell(fcnIds);
            fcnRows=sortrows(fcnRows,[1,2]);

            resolved=cell(size(whitelist));
            fcnIdx=1;
            for i=1:numel(whitelist)
                whitelistFunc=whitelist{i};
                for j=fcnIdx:numel(fcnIds)
                    if strcmp(whitelistFunc,fcnRows{j})
                        resolved{i}(end+1)=fcnRows{j,2};
                        fcnIdx=fcnIdx+1;
                    else
                        break;
                    end
                end
            end

            scriptIds=[allFcns(fcnIds).ScriptID];
        end

        function[classMethodIds,preInferenceIds]=resolveToMethods(report,traceableClasses)
            classMethodIds=cell(size(traceableClasses,1),1);
            preInferenceIds=[];
            for i=1:size(traceableClasses,1)
                methodRows=traceableClasses{i,2};
                if~isempty(methodRows)
                    classMethodIds{i}=coder.report.contrib.Float2FixedContributor.resolveToFunctions(...
                    report,methodRows(:,1),traceableClasses{i,1});
                    preInferenceIds=[preInferenceIds,methodRows{:,2}];%#ok<AGROW>
                else
                    classMethodIds{i}=[];
                end
            end
        end

        function serializeTraceability(traceData,outputFile)
            javaHelper=com.mathworks.toolbox.coder.report.trace.ConversionTraceHelper();
            if~isempty(outputFile)
                javaHelper.withOutputFile(outputFile);
            end
            javaHelper.withSourceLocationIds([traceData.sourceLocations.locationId]);
            javaHelper.withSourceStarts([traceData.sourceLocations.start]);
            javaHelper.withSourceEnds([traceData.sourceLocations.end]);
            javaHelper.withSourceFirstLines([traceData.sourceLocations.firstLine]);
            javaHelper.withSourceLastLines([traceData.sourceLocations.lastLine]);
            javaHelper.withSourceFunctionIds([traceData.sourceLocations.functionId]);
            javaHelper.withSourceFiles({traceData.sourceLocations.file});
            javaHelper.withTargetLocationIds([traceData.targetLocations.locationId]);
            javaHelper.withTargetStarts([traceData.targetLocations.start]);
            javaHelper.withTargetEnds([traceData.targetLocations.end]);
            javaHelper.withTargetFirstLines([traceData.targetLocations.firstLine]);
            javaHelper.withTargetLastLines([traceData.targetLocations.lastLine]);
            javaHelper.withTargetFunctionIds([traceData.targetLocations.functionId]);
            javaHelper.withTargetFiles({traceData.targetLocations.file});
            javaHelper.withTraces(traceData.mappings);
            javaHelper.process();
        end
    end

    methods(Static)
        function fixptSummary=getFixedPointSummary(reportContext)
            fixptSummary=[];
            if~isempty(reportContext.CompilationContext)&&...
                ~isempty(reportContext.CompilationContext.FixptSummary)

                fixptSummary=reportContext.CompilationContext.FixptSummary;



            end
            if isempty(fixptSummary)||~isfield(fixptSummary,'data')||...
                ~isfield(fixptSummary.data,'report')
                fixptSummary=[];
            end
        end
    end
end

