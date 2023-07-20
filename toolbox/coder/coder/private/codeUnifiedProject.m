function[succeeded,result,inputFiles,errors,internalError,log,inference,potentialDifferences,restorationError]=codeUnifiedProject(varargin)








    report=[];
    result=[];
    manager=coder.internal.CoderGuiDataManager.getInstance();

    function doBuild(hdl,config,codeGenWrapper,~,fpAdapterForRestore)%#ok<DEFNU>        
        if~isempty(fpAdapterForRestore)
            fpBuildFloatingPointCode(fpAdapterForRestore);
        end

        config.forceLoadProfile();
        config.forceEnumOptionLoads();

        if hdl
            getHDLToolInfo('reset');
            emlhdlcoder.WorkFlow.Manager.instance.setupHdlState();
            report=emlhdlcoder.WorkFlow.Manager.instance.wfa_generateCodeWithConfig(char(config.getFile().getAbsolutePath()),config);
        else
            adapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(config);




            codegenArgs={'--javaConfig',config,'--codeGenWrapper',codeGenWrapper,...
            char(config.getFile().getAbsolutePath())};
            if adapter.isModeAutomatic()

                fxpCfg=coderprivate.Float2FixedManager.instance.fpc.fxpCfg;
                codegenArgs=[{'-fixPtData',fxpCfg},codegenArgs];

                dataStore=coder.internal.F2FGuiCallbackManager.getInstance();
                if~isempty(dataStore.ConversionSummary)
                    codegenArgs(end+1:end+2)={'--fromFixPtConversion',dataStore.ConversionSummary};
                end
            end

            report=coder.internal.gui.codegenWrapper(codegenArgs{:});
        end
    end

    function resultObj=buildResultObject(summary)
        function ext=getRTWFileExtension(target)
            ext='';
            if strcmp(target,'RTW:DLL')
                if ispc
                    ext='.dll';
                elseif ismac
                    ext='.dylib';
                else
                    ext='.so';
                end
            elseif strcmp(target,'RTW:LIB')
                if ispc
                    ext='.lib';
                else
                    ext='.a';
                end
            else
                if ispc
                    ext='.exe';
                end
            end
        end
        buildDir=pwd;
        if isfield(summary,'directory')
            buildDir=summary.directory;
        end

        fileList=[];
        if isfield(summary,'buildInfo')
            fileList=summary.buildInfo.getFullFileList();
        end

        htmlPath=[];
        if isfield(summary,'mainhtml')
            htmlPath=summary.mainhtml;
        end

        outPath=pwd;
        if strcmp(summary.codingTarget,'MEX')
            if isfield(summary,'outDirectory')&&isfield(summary,'fileName')
                filename=[summary.fileName,'.',mexext];
                outPath=fullfile(summary.outDirectory,filename);
            end
        else
            if isfield(summary,'fileName')
                outPath=fullfile(buildDir,[summary.fileName,getRTWFileExtension(summary.codingTarget)]);
            end
        end

        resultObj=com.mathworks.toolbox.coder.wfa.build.UnifiedBuildResult(...
        buildDir,fileList,htmlPath,outPath);
    end


    assert(nargin==3||nargin==6);
    trueBuild=nargin==6;
    commandOutput=[];
    config=[];
    restorationError=[];
    hdl=false;

    if trueBuild
        commandOutput=evalc('doBuild(varargin{1:5})');
        config=varargin{2};
        buildType=varargin{6};
        hdl=varargin{1};
    else
        [report,restorationError]=manager.restore(varargin{:});
        buildType=varargin{3};
    end

    summary=[];

    if isfield(report,'summary')
        summary=report.summary;
        result=buildResultObject(summary);
    end

    errors=[];
    potentialDifferences=[];
    inputFiles=java.util.ArrayList;
    log='';

    if~isempty(summary)
        try
            for i=1:numel(summary.buildResults)
                if~isempty(summary.buildResults{i})
                    if isa(summary.buildResults{i},'coder.internal.MakeResult')&&~isempty(summary.buildResults{i}.Log)
                        log=sprintf('%s\n%s\n',log,summary.buildResults{i}.Log);
                    elseif ischar(summary.buildResults{i})
                        log=sprintf('%s\n%s\n',log,summary.buildResults{i});
                    end
                end
            end
        catch

        end
    end


    if~isempty(commandOutput)
        log=sprintf('%s\n%s\n',log,commandOutput);
        assert(nargin==6);
    end

    if trueBuild&&~hdl
        manager.setGuiCodegenReport(config,buildType,report,commandOutput);
    end

    inference=[];
    if isfield(report,'inference')
        inference=flattenInferenceReportForJava(report);
    end

    internalError=[];
    if isfield(report,'internal')&&~isempty(report.internal)
        internalError=report.internal(1).message;
    end

    if isfield(summary,'passed')
        succeeded=logical(summary.passed);

        for i=1:numel(report.scripts)
            file=java.io.File(report.scripts{i}.ScriptPath);
            try
                file=file.getCanonicalFile();
            catch
            end
            inputFiles.add(file);
        end

        if isfield(report.summary,'coderMessages')
            errors=coderprivate.convertMessagesToJavaArray(report,report.summary.coderMessages);
        end

        if isfield(report,'inference')&&~isempty(report.inference)&&...
            isfield(report.summary,'potentialDifferences')
            potentialDifferences=flattenMessagesForJava(...
            report.summary.potentialDifferences,report.inference.Scripts,[],report.inference.Functions);
        end
    else
        succeeded=false;
    end

end
