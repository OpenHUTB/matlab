




function fullOk=runSldvAnalysis(this,options,varargin)

    if nargin<2||~isstruct(options)
        options=struct();
    end

    options.ModelName=this.ModelName;
    fullOk=false;

    isATS=~isempty(this.AtsHarnessInfo);
    if isATS
        slObjKind='subsystem';
    else
        slObjKind='model';
    end


    this.extractCodeConfig();
    if isempty(this.CodeGenFolder)
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelSILCodeGenFolderNotFound'));
    end

    codeInfoStruct=this.getCodeDescriptor();
    if isempty(codeInfoStruct)||isempty(codeInfoStruct.codeInfo)
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelSILCodeDescriptionNotFound'));
    end



    moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(this.ModelName,char(this.SimulationMode));
    trDataFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName,this.CodeGenFolderInfo);
    if~isfile(trDataFile)
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelSILCodeCovInstrumNotFound'));
    end
    try
        trData=sldv.code.xil.internal.TraceabilityDb(trDataFile);
        instrumInfo=trData.getInstrumInfo();
    catch
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelSILCodeCovInstrumNotFound'));
    end

    if isempty(instrumInfo)
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelSILCodeCovInstrumNotFound'));
    end


    tmpDir=tempname;
    polyspace.internal.makeParentDir(fullfile(tmpDir,'.'));
    if sldv.code.internal.feature('debug')
        fprintf(1,'### Debug: Keeping temporary directory %s\n',tmpDir);
    else
        cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
    end


    entryNames=this.getEntriesNames();
    if numel(entryNames)~=1||numel(this.getInstanceInfos(entryNames{1}))~=1
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelCodeCovMultpleInstances',slObjKind));
    end
    instanceInfo=getInstanceInfos(this,entryNames{1});
    instanceInfo.createIRMapping();


    try
        xilWrapperUtils=this.getXilInfo();

        clrXilObj=onCleanup(@()delete(xilWrapperUtils));
    catch Me
        error(...
        message('sldv_sfcn:sldv_sfcn:analyzingModelCodeUnexpectedError',...
        Me.message));
    end

    try
        instrSubFolder=instrumInfo.InstrumentationSubFolder;



        [buildInfo,buildOpts]=coder.make.internal.loadBuildInfo...
        (fullfile(this.CodeGenFolder,instrSubFolder,'buildInfo.mat'));






        codeInstrInfo=load...
        (fullfile(xilWrapperUtils.getComponentArgs.getApplicationCodePath,...
        'codeInstrInfo.mat'));
        moduleNames=codeInstrInfo.moduleNames;
        moduleObjFolders=codeInstrInfo.moduleObjFolders;
        coder.internal.updateReferencedModelLinkables(buildInfo,this.CodeGenFolder,...
        moduleNames,moduleObjFolders)

        isCpp=buildOpts.isCpp;



        evalc('buildInfo.updateFilePathsAndExtensions()');
        evalc('buildInfo.updateFileSeparator(filesep)');
        evalc('buildInfo.findIncludeFiles()');
    catch Me
        error(...
        message('sldv_sfcn:sldv_sfcn:analyzingModelCodeUnexpectedError',...
        Me.message));
    end

    try
        feOpts=trData.getFrontEndOptions();
        compilerInfo=trData.getCompilerInfo(feOpts);
        if isCpp
            compilerInfo.language='c++';
        end
    catch
        error(message('sldv_sfcn:sldv_sfcn:analyzingModelSILCodeCovInstrumNotFound'));
    end


    if isCpp
        fExt='.cpp';
    else
        fExt='.c';
    end
    fileName=fullfile(tmpDir,[this.ModelName,'_sldv',fExt]);
    if this.SimulationMode==SlCov.CovMode.ModelRefSIL
        dvWriter=sldv.code.xil.internal.SldvModelBlockTargetInterface(xilWrapperUtils,fileName);
    else
        if this.CoderConfig.getParam('AutosarCompliant')=="on"
            strategy=coder.internal.connectivity.AutosarInterfaceStrategy(xilWrapperUtils);
        else
            strategy=coder.internal.connectivity.TargetInterfaceStrategy(xilWrapperUtils);
        end
        if isempty(this.AtsHarnessInfo)
            dvWriter=sldv.code.xil.internal.SldvStandaloneTargetInterface(xilWrapperUtils,...
            fileName,'InterfaceStrategy',strategy);
        else
            dvWriter=sldv.code.xil.internal.SldvAtomicSubsystemTargetInterface(xilWrapperUtils,...
            fileName,'InterfaceStrategy',strategy);
        end
    end
    if isfield(options,'exportFcnInfo')&&~isempty(options.exportFcnInfo.FcnTriggerPortVarName)
        dvWriter.setExportFcnInfo(options.exportFcnInfo);
    end
    dvWriter.initCallerAndServerFunctions();
    dvWriter.writeOutput(false,false,false);


    dataIdx=dvWriter.InportInfo.keys();
    inputs=cell(numel(dataIdx),1);
    for ii=1:numel(dataIdx)
        dataInfo=dvWriter.InportInfo(dataIdx{ii});
        inputs{dataIdx{ii}}=dataInfo.sldvInterfaceVar;
        instanceInfo.IRMapping.addInputName(dataInfo.sldvInterfaceVar);
    end


    slFcnNames=dvWriter.ExportFcnInfo.SlFcnNames;
    for ii=1:numel(slFcnNames)
        mappingInfo=dvWriter.ExportFcnInfo.SlFcnMapping(slFcnNames{ii});
        dataIdx=mappingInfo.InportInfo.keys();
        for jj=1:numel(dataIdx)
            dataInfo=mappingInfo.InportInfo(dataIdx{jj});
            inputs{end+1}=dataInfo.sldvInterfaceVar;%#ok<AGROW>
            instanceInfo.IRMapping.addInputName(dataInfo.sldvInterfaceVar);
        end
    end
    inputs(cellfun(@isempty,inputs))=[];


    dataIdx=dvWriter.OutportInfo.keys();
    for ii=1:numel(dataIdx)
        dataInfo=dvWriter.OutportInfo(dataIdx{ii});
        instanceInfo.IRMapping.addOutputName(dataInfo.sldvInterfaceVar);
    end


    dataIdx=dvWriter.ParamInfo.keys();
    params=cell(numel(dataIdx),1);
    for ii=1:numel(dataIdx)
        dataInfo=dvWriter.ParamInfo(dataIdx{ii});
        params{dataIdx{ii}}=dataInfo.sldvInterfaceVar;
        instanceInfo.IRMapping.addParameterName(dataInfo.sldvInterfaceVar);
        instanceInfo.IRMapping.addParameterGraphicalName(dataInfo.graphicalName);
    end
    params(cellfun(@isempty,params))=[];


    if dvWriter.TaskSchedulingInfo.numAsyncTasks>0&&~isempty(dvWriter.TaskSchedulingInfo.asyncVarName)
        inputs{end+1}=dvWriter.TaskSchedulingInfo.asyncVarName;
        instanceInfo.IRMapping.addInputName(dvWriter.TaskSchedulingInfo.asyncVarName);
    end


    allFcns=dvWriter.InterfaceFunction.keys();
    for ii=1:numel(allFcns)
        fcn=dvWriter.InterfaceFunction(allFcns{ii});
        instanceInfo.IRMapping.setFunctionName(fcn{1},allFcns{ii});
    end
    delete(dvWriter);


    validExtensions={'.c','.cpp','.cxx','.cc','.c++'};
    srcFiles=buildInfo.getFullFileList('source');
    srcFiles=unique(srcFiles,'stable');

    filesToIgnore={...
    fullfile(matlabroot,'rtw','c','src','common','rt_main.c'),...
    fullfile(matlabroot,'rtw','c','src','common','rt_malloc_main.c'),...
    fullfile(matlabroot,'rtw','c','src','common','rt_cppclass_main.cpp')
    };

    keepIdx=true(1,numel(srcFiles));
    for ii=1:numel(srcFiles)
        [~,fname,fext]=fileparts(srcFiles{ii});

        if strcmpi(fname,'ert_main')||~any(strcmpi(fext,validExtensions(:)))||...
            contains(srcFiles{ii},filesToIgnore)
            keepIdx(ii)=false;
        end
    end
    srcFiles=srcFiles(keepIdx);


    psOptions=options;
    psOptions.language=compilerInfo.language;
    psOptions.Dialect=compilerInfo.dialect;
    psOptions.stdVersion=compilerInfo.stdVersion;
    psOptions.TargetTypes=compilerInfo.targetTypes;
    psOptions.tmpDir=tmpDir;
    psOptions.InVars=inputs(:);
    psOptions.OutVars={};
    psOptions.ProtectedVars=params(:);
    psOptions.InlineProcs={};
    psOptions.CodeProcs=allFcns(:);
    psOptions.Includes=[feOpts.Preprocessor.SystemIncludeDirs(:);feOpts.Preprocessor.IncludeDirs(:)];
    psOptions.Includes{end+1}=fullfile(matlabroot,'toolbox','rtw','targets','pil','c');
    psOptions.Defines=feOpts.Preprocessor.Defines(:);

    sourceFiles=[{fileName};srcFiles(:)];





    sourceFilesNoPath=cellfun(@i_getFileNameNoPath,sourceFiles,...
    'UniformOutput',false);
    [~,uniqueIdx]=unique(sourceFilesNoPath,'stable');
    sourceFiles=sourceFiles(uniqueIdx);


    genMainOnly=isfield(options,'genMainOnly')&&options.genMainOnly;
    if genMainOnly||sldv.code.internal.feature('keepXilMainFile')
        copyfile(fileName,pwd,'f');
        if genMainOnly
            return
        end
    end

    [cgelOutput,this.FullLog]=sldv.code.internal.sourceAnalysis(...
    tmpDir,...
    psOptions,...
    sourceFiles,...
    sldv.code.internal.PosConverter(),...
    'functionLinkErrorId','functionCodeLinkError',...
    'unexpectedAnalysisErrorId','unexpectedCodeAnalysisError',...
    'forXIL',true);

    if this.FullLog.isOk()
        this.setFullIR(cgelOutput,false);
        fullOk=true;
    end


    function name=i_getFileNameNoPath(name)
        [~,f,e]=fileparts(name);
        name=[f,e];


