function varargout=genReportData(rawReportContext,varargin)





























































    validateattributes(rawReportContext,{'coder.report.ReportContext'},{'scalar'});
    options=processOptions(varargin);
    if options.PrintDebugInfo
        outerTime=tic;
    else
        outerTime=0;
    end




    reportContext=rawReportContext.copy();

    reportType=codergui.ReportServices.getReportTypeFromContext(reportContext);
    reportContext.ClientType=reportType.ClientTypeValue;
    coder.internal.ddux.logger.logCoderEventData("reportGeneration",reportType.ClientTypeValue);


    [fcnIds,scriptIds]=getIncludedFunctions(reportContext.Report,ShowUserVisibleOnly=options.HideInternalFunctions);
    contribContext=coder.report.ContributionContext(...
    reportContext,...
    reportType,...
    fcnIds,...
    scriptIds,...
    'DryRun',options.DryRun,...
    'Properties',options.Properties,...
    'PrintDebugInfo',options.PrintDebugInfo,...
    'ValidationMode',options.ValidationMode,...
    'IsContainerFile',~isempty(options.ContainerFile)&&~options.VirtualMode,...
    'VirtualMode',options.VirtualMode);
    contribContext.debugPrint('--------------------------------------------------');
    contribContext.debugPrint('Beginning report generation...');


    if options.DiscoverContributors
        contributors=discoverReportContributors('instantiate');
        contribContext.debugPrint('Auto-discovered %d contributors.',numel(contributors));
    else
        contributors=options.Contributors;
        contribContext.debugPrint('Found %d explicitly provided contributors.',numel(contributors));
    end

    if~contribContext.DryRun
        if contribContext.VirtualMode
            reportContext.ReportDirectory=tempname();
        end
        if isfolder(reportContext.ReportDirectory)
            if~contribContext.DryRun&&contribContext.IsContainerFile
                containerFile=fullfile(reportContext.ReportDirectory,options.ContainerFile);
                if isfile(containerFile)


                    codergui.ReportViewer.closeAll(containerFile);
                end
            end
            if options.CleanDirectory
                warnState=warning('off');
                cleanup=onCleanup(@()warning(warnState));
                try
                    rmdir(reportContext.ReportDirectory,'s');
                    mkdir(reportContext.ReportDirectory);
                catch me
                    contribContext.debugPrint(me.getReport());
                end
                clear('cleanup');
            end
        else
            mkdir(reportContext.ReportDirectory);
            if contribContext.VirtualMode
                tempCleanup=onCleanup(@()silentlyDeleteTempFolder(reportContext));
            end
        end
    end

    if options.StoreTimingData
        times=cell(0,2);
    else
        times=[];
    end


    contribContext.debugPrint('\nCollecting report data from contributors...');
    contributorIds={};
    catastrophe=[];

    inferenceReportData=[];
    for i=1:numel(contributors)
        contributor=contributors{i};

        if contributor.isRelevant(reportContext)&&(~contribContext.VirtualMode||...
            contributor.isSupportsVirtualMode(reportContext))
            innerTime=tic;
            if options.PrintDebugInfo
                contribContext.debugPrint('\nProcessing contributor "%s" of type "%s".',...
                contributor.ID,class(contributor));
            end

            contribContext.setCurrentContributorId(contributor.ID);
            try
                contributor.contribute(reportContext,contribContext);
                if isa(contributor,'coder.report.contrib.InferenceReportContributor')
                    inferenceReportData=contributor.Data;
                end
            catch me
                if options.DebugStopIfCaught
                    keyboard;
                else
                    coder.internal.gui.asyncDebugPrint(me);
                end


                catastrophe=me;
            end
            contribContext.lockExistingGroups();
            contributorIds{end+1}=contributor.ID;%#ok<AGROW>

            innerTime=toc(innerTime);
            if options.PrintDebugInfo
                contribContext.debugPrint('Finished processing contributor "%s" in %0.3f seconds.',contributor.ID,innerTime);
            end
            if iscell(times)
                times(end+1,:)={contributor.ID,innerTime};%#ok<AGROW>
            end
        else
            contribContext.debugPrint('\nContributor "%s" of class "%s" not relevant.',...
            contributor.ID,class(contributor));
        end
    end

    if isempty(catastrophe)
        assert(numel(contributorIds)==numel(unique(contributorIds)),'Duplicate contributor IDs');


        contribContext.debugPrint('\nConstructing data schema for report...');
        contribContext.postProcess();

        if options.GenCodegenInfo
            info=[];
            try
                codegenInfoBuilder=codergui.internal.CodegenInfoBuilder(reportContext,inferenceReportData,contributors);
                info=codegenInfoBuilder.build();
            catch me
                if options.DebugStopIfCaught
                    keyboard;
                else
                    coder.internal.gui.asyncDebugPrint(me);
                end
                emlcprivate('ccwarningid','Coder:reportGen:CodegenInfoGenerationFailed');
            end
            if~isempty(info)
                contribContext.setManifestProperty('reportHasCodegenInfo',true);
            end
        end

        manifest=buildReportManifest(contribContext);
        partitions=constructPartitions(contribContext,manifest);
        contribContext.debugPrint('Writing manifest and %d data partitions to "%s"...',...
        numel(partitions),reportContext.ReportDirectory);
        fileResults=emitReportData(manifest,partitions,reportContext.ReportDirectory,...
        contribContext.DryRun,contribContext.VirtualMode,options.PrettyPrint);

        if~contribContext.DryRun
            if options.StoreTimingData
                contribContext.saveMatFile(fullfile(reportContext.ReportDirectory,'reportGenTimes.mat'),'times');
            end
            contribContext.saveMatFile(fullfile(reportContext.ReportDirectory,'manifest.mat'),'manifest');
            if options.GenCodegenInfo&&~isempty(info)
                contribContext.saveMatFile(fullfile(reportContext.ReportDirectory,'info.mat'),'info')
            end
        end
        if~contribContext.DryRun&&contribContext.IsContainerFile
            contribContext.debugPrint('\nGenerating MLDATX container file for report...');
            fileResults.reportFile=genReportContainer(contribContext,...
            'OutputFile',options.ContainerFile,...
            'PartitionDefinitions',manifest.Partitions);
        end
        if options.GenCodegenInfo
            fileResults.codegenInfo=info;
        end
        if contribContext.VirtualMode
            varargout={codergui.internal.VirtualReport(reportContext,manifest,...
            fileResults.manifestFile,manifest.Partitions,fileResults.partitions,...
            contribContext.VirtualMatFiles)};
        else
            varargout={fileResults};
        end
    else
        manifest=[];
        partitions=[];
        fileResults=[];
        varargout={};
    end

    [sinkDest,sinkType]=resolveLogSink(options.LogSink);
    if nargout>1||(~options.IsRerun&&~isempty(sinkDest))
        log.reportContext=rawReportContext;
        log.options=options;
        log.result=fileResults;
        log.manifest=manifest;
        log.partitions=partitions;
        log.contributionContext=contribContext;
        log.contributors=contributors;
        log.output=varargout;
        log.rerun=@rerun;

        if nargout>1

            varargout{end+1}=log;
        end
        if~options.IsRerun&&~isempty(sinkDest)
            switch sinkType
            case 'file'
                save(sinkDest,'log');
                contribContext.debugPrint('Saved state to MAT file "%s".',sinkDest);
            case 'variable'
                assignin('base',sinkDest,log);
                contribContext.debugPrint('Logged state to variable "%s".',sinkDest);
            case 'function_handle'
                sinkDest(log);
            end
        end
    end

    if~isempty(catastrophe)
        rethrow(catastrophe);
    end

    contribContext.debugExec(@()contribContext.debugPrint('Report generation finished in %0.3f seconds',toc(outerTime)));
    contribContext.debugPrint('--------------------------------------------------\n');



    function out=rerun(varargin)
        newOptions=options;
        if nargin==1
            if isstruct(varargin{1})

                newOptions=varargin{1};
            end
        else

            for j=1:2:nargin
                if ischar(varargin{j})
                    newOptions.(varargin{j})=varargin{j+1};
                end
            end
        end
        out=codergui.evalprivate('genReportData',reportContext,newOptions,...
        'IsRerun',true);
    end
end



function partitions=constructPartitions(contribContext,manifest)
    partitionDefs=manifest.Partitions;
    partitions=cell2struct(cell(numel(partitionDefs),2),{'dataSets','artifactSets'},2);

    for i=1:numel(partitionDefs)
        constructPartition(partitionDefs(i),i);
    end

    function constructPartition(partitionDef,index)

        map=containers.Map();
        partitions(index).dataSets=map;
        ids=partitionDef.DataSetIds;
        for j=1:numel(ids)
            map(ids{j})=contribContext.DataSets(ids{j});
        end


        map=containers.Map();
        partitions(index).artifactSets=map;
        ids=partitionDef.ArtifactSetIds;
        for j=1:numel(ids)
            map(ids{j})=contribContext.EmbeddedArtifacts(ids{j});
        end
    end
end



function result=emitReportData(manifest,partitions,reportDir,dryRun,virtualMode,prettyPrint)
    partitionDefs=manifest.Partitions;
    result=struct('reportFile','','partitions',{cell(1,numel(partitions))});

    for i=1:numel(partitions)
        result.partitions{i}=writeAsJson(partitions(i),partitionDefs(i).File);
    end
    result.manifestFile=writeAsJson(manifest,coder.report.ContributionContext.MANIFEST_FILENAME);
    result.reportFile=result.manifestFile;

    function file=writeAsJson(arg,filename)
        file=fullfile(reportDir,filename);
        json=jsonencode(arg,PrettyPrint=prettyPrint);
        if~dryRun
            if~virtualMode
                fid=fopen(file,'w','n','UTF-8');
                fprintf(fid,'%s',json);
                fclose(fid);
            else
                file=json;
            end
        end
    end
end



function options=processOptions(args)
    ip=inputParser();

    ip.addParameter('HideInternalFunctions',coder.internal.gui.globalconfig('FilterFunctionsInReport'),@islogical);
    ip.addParameter('Contributors',{},...
    @(val)all(cellfun(@(c)isa(c,'coder.report.Contributor'),val)));
    ip.addParameter('DiscoverContributors',true,@islogical);
    ip.addParameter('DryRun',false,@islogical);
    ip.addParameter('CleanDirectory',true,@islogical);
    ip.addParameter('Properties',{},@validatePropertiesArg);
    ip.addParameter('PrettyPrint',coder.internal.gui.globalconfig('PrettyPrintReportData'),@islogical);
    ip.addParameter('PrintDebugInfo',coder.internal.gui.globalconfig('ReportGenPrintDebugInfo'),@islogical);
    ip.addParameter('LogSink','',@(v)isempty(v)||ischar(v)||nargin(v)~=0);
    ip.addParameter('IsRerun',false,@islogical);
    ip.addParameter('ValidationMode',coder.internal.gui.globalconfig('ReportGenValidationMode'),@islogical);
    ip.addParameter('ContainerFile',coder.internal.gui.globalconfig('ReportGenContainerFile'),...
    @(v)validateattributes(v,{'char','logical'},{}));
    ip.addParameter('VirtualMode',false,@islogical);
    ip.addParameter('DebugStopIfCaught',coder.internal.gui.globalconfig('DebugStopIfCaught'),@islogical);
    ip.addParameter('StoreTimingData',false,@islogical);
    ip.addParameter('GenCodegenInfo',false,@islogical);

    ip.parse(args{:});
    options=ip.Results;

    if~isempty(options.Contributors)

        options.DiscoverContributors=false;
    end
    options.StoreTimingData=options.StoreTimingData||options.ValidationMode||options.PrintDebugInfo;

    if~isa(options.Properties,'containers.Map')
        options.Properties=containers.Map('KeyType','char','ValueType','any');
        cellProps=ip.Results.Properties;
        if~isempty(cellProps)
            if~iscell(cellProps{1})
                cellProps={cellProps};
            end
            for i=1:numel(cellProps)
                kvPair=cellProps{i};
                options.Properties(kvPair{1})=kvPair{2};
            end
        end
    end

    if~isempty(options.ContainerFile)&&islogical(options.ContainerFile)
        if options.ContainerFile
            options.ContainerFile='report.mldatx';
        else
            options.ContainerFile='';
        end
    end
end



function valid=validatePropertiesArg(arg)
    if isa(arg,'containers.Map')
        valid=true;
    elseif iscell(arg)&&numel(arg)==2
        valid=ischar(arg{1});
    elseif iscell(arg)&&~isempty(arg)
        valid=all(cellfun(@(v)iscell(v)&&numel(v)==2&&ischar(v{1}),v));
    else
        valid=isempty(arg);
    end
end



function silentlyDeleteTempFolder(reportContext)
    try
        rmdir(reportContext.ReportDirectory,'s');
    catch
    end
    reportContext.ReportDirectory='';
end



function[sinkDest,sinkType]=resolveLogSink(argSink)
    if~isempty(argSink)
        if ischar(argSink)
            [~,~,ext]=fileparts(argSink);
            if strcmp(ext,'.mat')
                sinkType='file';
            else
                sinkType='variable';
            end
        else
            assert(isa(argSink,'function_handle'),'Not a valid log sink value');
            sinkType='function_handle';
        end
        sinkDest=argSink;
    else
        sinkType=coderapp.internal.globalconfig('ReportGenLogType');
        switch sinkType
        case 'file'
            sinkDest=coderapp.internal.globalconfig('ReportGenLogFile');
        case 'variable'
            sinkDest=coderapp.internal.globalconfig('ReportGenLogVariable');
        otherwise
            sinkDest='';
        end
    end
end
