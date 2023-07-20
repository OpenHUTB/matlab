


classdef(Sealed)GpuCoderContributor<coder.report.Contributor
    properties(Constant)
        ID='coder-gpucoder'
        DATA_GROUP='gpu'
        DATA_KEY_KERNELS='kernels'
        DATA_KEY_MAPPINGS='sourceMappings'
        DATA_KEY_DIAGNOSTICS='diagnostics'
        METRICS_REPORT_ID='gpuMetricsReport'
        USED_GPU_CODER_PROP='usedGpuCoder'
        HAS_METRICS_REPORT='hasGpuMetrics'
        MAT_KERNEL_VAR='cuda_Kernel'
        MAT_API_FUNCTION_VAR='cuda_API_Function'
        MAT_DIAGNOSTICS_VAR='diagnostics'
        METRICS_DEST_FOLDER='gpucoder'
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
        function this=GpuCoderContributor(inferenceContributor)
            if nargin>0&&~isempty(inferenceContributor)
                this.InferenceContributor=inferenceContributor;
            end
        end

        function relevant=isRelevant(this,reportContext)
            if isempty(reportContext.SimulinkModelName)
                relevant=~isempty(reportContext.Config)&&isprop(reportContext.Config,'GpuConfig')&&...
                ~isempty(reportContext.Config.GpuConfig)&&reportContext.Config.GpuConfig.Enabled;
            else
                relevant=this.isModelGpuAccelerated(reportContext);
            end
            if relevant
                matFile=this.getGpuDataFile(reportContext);
                relevant=isfile(matFile);
            end
        end

        function contribute(this,reportContext,contribContext)
            if isempty(reportContext.SimulinkModelName)
                contribContext.setManifestProperty(this.USED_GPU_CODER_PROP,true);

                this.contributeLocationData(reportContext,contribContext);

                this.contributeKernelData(reportContext,contribContext);

                this.contributeMetricsReport(reportContext,contribContext);
            end

            this.contributeDiagnosticsData(reportContext,contribContext);
        end

        function riContributor=getRIContributor(this,reportContext)
            if isempty(this.DiagnosticsData)
                fcnIds=codergui.evalprivate('getIncludedFunctions',reportContext.Report);
                this.DiagnosticsData=this.getDiagnostics(fcnIds,reportContext);
            end
            riContributor=coder.reportinfo.GpuCoderRIContributor(this);
        end
    end

    methods(Access=private)
        function contributeLocationData(this,reportContext,contribContext)
            matFile=this.getGpuDataFile(reportContext);
            fileInfo=whos('-file',matFile);

            if isfield(fileInfo,'name')
                if ismember(this.MAT_KERNEL_VAR,{fileInfo.name})
                    kernels=load(this.getGpuDataFile(reportContext),this.MAT_KERNEL_VAR);
                    kernels=kernels.(this.MAT_KERNEL_VAR);
                else
                    kernels=[];
                end
                if ismember(this.MAT_API_FUNCTION_VAR,{fileInfo.name})
                    apiFcns=load(this.getGpuDataFile(reportContext),this.MAT_API_FUNCTION_VAR);
                    apiFcns=apiFcns.(this.MAT_API_FUNCTION_VAR);
                else
                    apiFcns=[];
                end

                locations=this.mergeLocations(kernels,apiFcns);

                if isfield(locations,'sourceFileLocationData')&&isfield(contribContext.Report,'inference')&&...
                    ~isempty(contribContext.Report.inference)
                    mappingData=this.processKernelSourceData(contribContext,locations);
                    if isscalar(mappingData.mappingsByFunction)
                        mappingData.mappingsByFunction={mappingData.mappingsByFunction};
                    end
                    if isscalar(mappingData.partitionTypes)
                        mappingData.partitionTypes={mappingData.partitionTypes};
                    end
                    contribContext.addData(this.DATA_GROUP,this.DATA_KEY_MAPPINGS,mappingData);

                end
            end
        end

        function contributeKernelData(this,reportContext,contribContext)
            matFile=this.getGpuDataFile(reportContext);
            fileInfo=whos('-file',matFile);

            if isfield(fileInfo,'name')&&ismember(this.MAT_KERNEL_VAR,{fileInfo.name})
                kernels=load(this.getGpuDataFile(reportContext),this.MAT_KERNEL_VAR);
                kernels=this.normalizeFileSeparators(kernels.(this.MAT_KERNEL_VAR));
                if isfield(kernels,'sourceFileLocationData')
                    kernels=rmfield(kernels,'sourceFileLocationData');
                end
                if isscalar(kernels)
                    kernels={kernels};
                end
                contribContext.addData(this.DATA_GROUP,this.DATA_KEY_KERNELS,kernels);
            end
        end

        function contributeMetricsReport(this,reportContext,contribContext)
            metricsReportFile=emlcprivate('genGPUStaticMetricsFile',...
            reportContext.BuildDirectory,...
            reportContext.ReportDirectory);
            [~,fileName,ext]=fileparts(metricsReportFile);
            contribContext.linkArtifact(this.DATA_GROUP,this.METRICS_REPORT_ID,...
            'File',[fileName,ext],'Encoding','UTF-8');
            contribContext.setManifestProperty(this.HAS_METRICS_REPORT,true);
        end

        function contributeDiagnosticsData(this,reportContext,contribContext)
            this.DiagnosticsData=this.getDiagnostics(contribContext.IncludedFunctionIds,reportContext);
            if isempty(this.DiagnosticsData)
                return;
            end
            if isscalar(this.DiagnosticsData)
                contribContext.addData(this.DATA_GROUP,this.DATA_KEY_DIAGNOSTICS,{this.DiagnosticsData});
            else
                contribContext.addData(this.DATA_GROUP,this.DATA_KEY_DIAGNOSTICS,this.DiagnosticsData);
            end
        end

        function data=processKernelSourceData(this,contribContext,kernels)
            inference=contribContext.Report.inference;
            funcsWithGpu=[];
            mappingsByFunc=cell(1,numel(inference.Functions));
            mappedFuncIds=[];

            for i=1:numel(kernels)
                sourceInfos=kernels(i).sourceFileLocationData;
                if isstruct(sourceInfos)
                    allSourceFuncs=[kernels(i).sourceFileLocationData.rid];
                    for j=1:numel(sourceInfos)
                        funcId=sourceInfos(j).rid;
                        outIdx=size(mappingsByFunc{funcId},1)+1;
                        mappingsByFunc{funcId}(outIdx,:)={...
                        kernels(i).functionname,...
                        sourceInfos(j).start,...
                        sourceInfos(j).start+sourceInfos(j).length};
                        if outIdx==1
                            mappedFuncIds(end+1)=funcId;%#ok<AGROW>
                        end
                    end
                    curLen=numel(funcsWithGpu);
                    funcsWithGpu(curLen+1:curLen+numel(allSourceFuncs))=allSourceFuncs;
                end
            end

            mappedFuncIds=unique(mappedFuncIds);
            includedMask=ismember(mappedFuncIds,contribContext.IncludedFunctionIds);
            data.mappingsByFunction=cell2struct(cell(nnz(includedMask),2),{'functionId','mappings'},2);
            outIdx=1;
            for i=1:numel(mappedFuncIds)
                mappedFuncId=mappedFuncIds(i);
                mappingRows=sortrows(mappingsByFunc{mappedFuncId},[2,3,1]);
                intervals=cell2mat(mappingRows(:,2:3));
                if includedMask(i)
                    scriptId=inference.Functions(mappedFuncId).ScriptID;
                    data.mappingsByFunction(outIdx).functionId=mappedFuncId;
                    data.mappingsByFunction(outIdx).mappings=cell2struct(...
                    [mappingRows,num2cell([contribContext.positionToLine(scriptId,intervals(:,1)+1),...
                    contribContext.positionToLine(scriptId,intervals(:,2))])],...
                    {'kernelName','start','end','startLine','endLine'},2);
                    outIdx=outIdx+1;
                end


                mappingsByFunc{mappedFuncId}=unique(intervals,'rows');
            end

            data.partitionTypes=this.determinePartitionTypes(unique(funcsWithGpu),inference,mappingsByFunc);
        end

        function partitionTypes=determinePartitionTypes(this,gpuFunctions,inference,kernelIntervalsByFunc)
            partitionTypes=zeros(1,numel(inference.Functions));
            partitionTypes(gpuFunctions)=1;
            visited=false(size(partitionTypes));
            arrayfun(@checkIfMixed,gpuFunctions);

            function mixed=checkIfMixed(funcId)
                if~visited(funcId)
                    visited(funcId)=true;
                    if partitionTypes(funcId)==1
                        func=inference.Functions(funcId);
                        if partitionTypes(funcId)~=2&&...
                            this.hasNonKernelLocations(funcId,func,kernelIntervalsByFunc{funcId})



                            partitionTypes(funcId)=2;
                        end
                    end
                end
                mixed=partitionTypes(funcId)==2;
            end
        end

        function yes=hasNonKernelLocations(this,funcId,func,kernelIntervals)
            yes=false;
            intervalCount=size(kernelIntervals,1);
            if intervalCount==0
                return;
            end

            mlCodeInfo=[];
            filteredLocs=func.MxInfoLocations;
            if~isempty(this.InferenceContributor)
                mlCodeInfo=this.InferenceContributor.MatlabCodeInfo{funcId};
                if~isempty(mlCodeInfo)

                    if min(size(mlCodeInfo.functionBodyExtents))>0
                        filteredLocs=filteredLocs([filteredLocs.TextStart]>=mlCodeInfo.functionBodyExtents(1));
                    end
                end
            end
            if isempty(mlCodeInfo)
                filteredLocs=filteredLocs(cellfun(@isempty,...
                regexp({filteredLocs.NodeTypeName},'^var$|Var$','once')));
            end

            kIdx=1;
            kRow=kernelIntervals(kIdx,:);

            for i=1:numel(filteredLocs)
                locStart=filteredLocs(i).TextStart;
                while true
                    if locStart>=kRow(1)&&locStart<kRow(2)
                        break;
                    elseif kIdx+1>intervalCount||locStart<kRow(1)

                        yes=true;
                        return;
                    else

                        kIdx=kIdx+1;
                        kRow=kernelIntervals(kIdx,:);
                    end
                end
            end
        end
    end

    methods(Access=protected)
        function diagnostics=getDiagnostics(this,includedFunctionIds,reportContext)

            matFile=this.getGpuDataFile(reportContext);
            fileInfo=whos('-file',matFile);

            if~isempty(includedFunctionIds)&&isfield(fileInfo,'name')&&...
                ismember(this.MAT_DIAGNOSTICS_VAR,{fileInfo.name})
                rawData=load(matFile,this.MAT_DIAGNOSTICS_VAR);
                rawData=rawData.diagnostics;
                diagnostics=cellfun(@(f)processDiagnosticsCategory(f,rawData.(f)),...
                fieldnames(rawData),'UniformOutput',false);
                diagnostics=[diagnostics{:}];
            else
                diagnostics=[];
            end

            function category=processDiagnosticsCategory(categoryId,subCats)
                if isempty(subCats)||isempty(vertcat(subCats.locations))
                    category=[];
                    return;
                end
                assert(ismember(categoryId,{'kernelCreation','memory','pragma','designPattern','other'}),...
                'Unrecognized category ID. Changing category IDs require coordinated changes in several files');

                category.id=categoryId;
                category.checks=cell2struct(cell(0,3),{'msgId','msgText','occurrences'},2);

                for i=1:numel(subCats)
                    includedLocs=subCats(i).locations(ismember([subCats(i).locations.rid],includedFunctionIds));
                    if isempty(includedLocs)
                        continue;
                    end
                    scIdx=numel(category.checks)+1;
                    category.checks(scIdx).msgId=subCats(i).messageID;
                    category.checks(scIdx).msgText=subCats(i).message;

                    locationData=cell(numel(includedLocs),5);
                    funcIds=[includedLocs.rid];
                    temp=num2cell(funcIds);
                    [locationData{:,1}]=temp{:};
                    temp={reportContext.Report.inference.Functions(funcIds).ScriptID};
                    [locationData{:,2}]=temp{:};
                    temp={includedLocs.start};
                    [locationData{:,3}]=temp{:};
                    temp={includedLocs.length};
                    [locationData{:,4}]=temp{:};
                    temp={includedLocs.line};
                    [locationData{:,5}]=temp{:};


                    locationTable=cell2table(locationData,...
                    'VariableNames',{'FunctionID','ScriptID','TextStart','TextLength','TextLine'});
                    locationTable=unique(locationTable,'rows','stable');

                    category.checks(scIdx).occurrences=table2struct(locationTable);
                end

                if isempty(category.checks)
                    category=[];
                end
            end
        end
    end

    methods(Static,Access=private)
        function matFile=getGpuDataFile(reportContext)
            if coder.report.contrib.GpuCoderContributor.isModelGpuAccelerated(reportContext)
                try
                    blockObj=get_param(reportContext.SimulinkSID,'Object');
                    chartId=sfprivate('block2chart',blockObj.getFullName());
                    matFile=fullfile(reportContext.BuildDirectory,sprintf('c%d_codegen_info.mat',chartId));
                catch
                    matFile='';
                end
            else
                matFile=fullfile(reportContext.BuildDirectory,'gpu_codegen_info.mat');
            end
        end

        function gpuAccel=isModelGpuAccelerated(reportContext)
            gpuAccel=~isempty(reportContext.SimulinkModelName)&&...
            get_param(reportContext.SimulinkModelName,'GPUAcceleration')=="on";
        end

        function kernels=normalizeFileSeparators(kernels)
            if ispc()
                fileNames=strrep({kernels.fileName},'/','\');
                [kernels.fileName]=fileNames{:};
            end
        end

        function locations=mergeLocations(kernels,apiFcns)
            locations=[];
            if(isfield(kernels,'functionname')&&isfield(kernels,'sourceFileLocationData'))
                for i=1:numel(kernels)
                    locations(i).functionname=kernels(i).functionname;%#ok<AGROW>
                    locations(i).sourceFileLocationData=kernels(i).sourceFileLocationData;%#ok<AGROW>
                end
            end

            locSize=numel(locations);
            if(isfield(apiFcns,'functionname')&&isfield(apiFcns,'sourceFileLocationData'))
                for i=1:numel(apiFcns)
                    locations(i+locSize).functionname=apiFcns(i).functionname;%#ok<AGROW>
                    locations(i+locSize).sourceFileLocationData=apiFcns(i).sourceFileLocationData;%#ok<AGROW>
                end
            end
        end
    end
end
