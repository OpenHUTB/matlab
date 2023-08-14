function loadProjectFile(CC,projectFile,mode)





    if~exist('mode','var')
        mode='codegen';
    else
        validatestring(mode,{'codegen','projectToScript'},'loadProjectFile','mode',3);
    end

    checkIssuesMex=false;


    warningState=warning();
    restoreWarnings=onCleanup(@()warning(warningState));
    warning('off','all');



    error(javachk('jvm'));

    loadProjectFileImpl(projectFile);




    function t=isEmbeddedProduction()
        t=CC.isEmbeddedProduction();
    end


    function t=isEmbeddedPrototype()
        t=CC.isEmbeddedPrototype();
    end


    function t=isEmbeddedTarget()
        t=CC.isEmbeddedTarget();
    end


    function addSearchPath(filepath)
        CC.addSearchPath(filepath);
    end


    function s=removeHtmlMarkup(text)
        s=regexprep(text,'<br( |/)*>','\n');
        s=regexprep(s,'<[^>]*>','');
    end


    function codegen=isCodegenContext()
        codegen=strcmp(mode,'codegen');
    end


    function loadProjectFileImpl(projectFile)
        if~isempty(fileparts(projectFile))&&isfile(projectFile)&&~java.io.File(projectFile).isAbsolute()

            projectFile=fullfile(pwd,projectFile);
        end
        [CC.Options.ProjectRoot,~,~]=fileparts(projectFile);
        com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse();

        if isempty(CC.JavaConfig)
            try
                coderRegistry=com.mathworks.toolbox.coder.app.CoderRegistry.getInstance();
                javaProject=coderRegistry.getOpenProject();
                isCurOpenPrj=strcmpi(javaProject.getFile,projectFile);
            catch
                isCurOpenPrj=false;
            end
            try
                if~isCurOpenPrj
                    javaProject=com.mathworks.project.impl.model.ProjectManager.load(...
                    java.io.File(projectFile),true,true);
                end
                javaProject.getConfiguration().forceEnumOptionLoads;
                CC.JavaConfig=javaProject.getConfiguration();
            catch
                if~isfile(projectFile)
                    ccdiagnosticid('Coder:common:ProjectFileNotFound',projectFile);
                else
                    ccdiagnosticid('Coder:common:ProjectFileInvalid',projectFile);
                end
            end
        else
            javaProject=CC.JavaConfig.getProject();
            CC.JavaConfig.forceLoadProfile;
        end

        messages=com.mathworks.project.impl.model.ProjectManager.validate(javaProject,false);
        iterator=messages.iterator();
        while iterator.hasNext()
            message=iterator.next();
            if message.getSeverity().equals(com.mathworks.project.api.Severity.ERROR)
                error(removeHtmlMarkup(char(message.getText())));
            end
        end

        javaConfig=javaProject.getConfiguration();

        if isFixedPtDesigner(javaConfig)
            loadFixedPointConverterProject(javaConfig);
        elseif coderprivate.isHDLCoderProject(javaConfig)




            loadHDLProjectFile(projectFile,javaConfig);


            loadFloat2FixedProjectSettings(javaConfig);
        else
            loadStdProjectFile(javaConfig);


            loadFloat2FixedProjectSettings(javaConfig);
        end

        CC.JavaConfig=javaConfig;

        function res=isFixedPtDesigner(javaConfig)
            res=com.mathworks.toolbox.coder.app.UnifiedTargetFactory.isFixedPointConverterProject(javaConfig);
        end
    end


    function loadFixedPointConverterProject(javaConfig)

        loadF2FProjectType(javaConfig);
        loadF2FProjectOptions(javaConfig);
        loadProjectWorkingDirectory(javaConfig);
        loadF2FProjectEntryPoints(javaConfig);
        loadF2FProjectGlobals(javaConfig);


        loadProjectOutputFile(javaConfig);
        loadProjectBuildDirectory(javaConfig);
        loadProjectSearchPaths(javaConfig);

        CC.ParsedProjectFile=true;


        function loadF2FProjectOptions(javaConfig)
            data=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);
            CC.ConfigInfo=buildFixPtConfig(data);
            CC.ConfigInfo.ProposeTypesMode=coder.FixPtConfig.MODE_FIXPT;
        end

        function loadF2FProjectType(~)
            CC.Project.Client='FIACCEL';
            CC.ClientType='FIACCEL';
        end
        function loadF2FProjectEntryPoints(javaConfig)
            fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',1);
            c=onCleanup(@()fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0));
            isFixedPtConvPrj=true;
            loadProjectEntryPoints(javaConfig,isFixedPtConvPrj);
        end
    end


    function hasF2FPrj=loadFloat2FixedProjectSettings(javaConfig)
        hasF2FPrj=coderprivate.isFixedPointConversionEnabled(javaConfig);
        if hasF2FPrj&&isempty(CC.FixptData)


            data=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);

            cfg=buildFixPtConfig(data);
            cfg.ProposeTypesMode=coder.FixPtConfig.MODE_C;

            CC.FixptData=cfg;
        end
    end


    function cfg=buildFixPtConfig(data)
        cfg=codergui.evalprivate('syncFixPtConfigWithJava','tocfg',[],data);
    end


    function loadHDLProjectFile(projectFile,javaConfig)





        xDoc=xmlread(projectFile);
        if~CC.isHDLCoderEnabled
            ccdiagnosticid('Coder:common:NoHDLCoderTargetEnabled');
        end
        CC.ConfigInfo=coder.config('hdl');
        CC.ParsedProjectFile=true;
        emlcHDLPrjParse(xDoc,CC.ConfigInfo);
        emlcHDLPrjParseTargetInterface(javaConfig,CC.ConfigInfo);

        CC.Project.CodingTarget='HDL';
        prjRoot=CC.Options.ProjectRoot;
        CC.Options.projectFile=projectFile;
        CC.HDLState=[];
        inst=emlhdlcoder.WorkFlow.Manager.instance();
        [dirInfo,defaultDirInfo]=inst.getDirInfoFromPrjFile(prjRoot,projectFile);



        CC.Options.defaultLogDir=defaultDirInfo.bldDir;
        CC.Options.defaultCodegenFolder=defaultDirInfo.codegenFolder;
        CC.Options.actualCodegenFolder=dirInfo.codegenFolder;

        adapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);
        fixptDone=adapter.isModeAutomatic();
        if fixptDone
            if(~isfolder(dirInfo.fxpBldDir))
                error(message('Coder:common:FixptDirMissingAfterFixptConversion',dirInfo.fxpBldDir));
            end
        end
        CC.Options.LogDirectory=expandProjectMacros(dirInfo.codegenFolder);




        loadHDLProjectEntryPoints(javaConfig);
        if CC.Project.EntryPoints.HasInputTypes&&isempty(CC.Project.EntryPoints(end).InputTypes)
            CC.Project.EntryPoints.HasInputTypes=false;
        end

        CC.Options.LogDirectory=expandProjectMacros(dirInfo.bldDir);
        CC.Project.OutDirectory=expandProjectMacros(dirInfo.workDir);

        dataAdapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);
        prjNameFromDepTool=inst.getDeployToolProjectInstance();
        if(~isempty(prjNameFromDepTool))
            if strcmp(prjNameFromDepTool.getFile.toString.toCharArray',projectFile)
                testFiles=dataAdapter.getTestFiles();
                if isempty(testFiles)
                    [~,tbName,ext]=fileparts(char(testFiles.last().getName()));
                    CC.ConfigInfo.TestBenchScriptName=[tbName,ext];
                end
            end
        end
        if~isempty(dirInfo.workDir)
            cd(dirInfo.workDir);
        end
        if fixptDone
            fixPtSuffix=char(dataAdapter.getGeneratedFileSuffix());

            CC.ConfigInfo.DesignFunctionName=[CC.ConfigInfo.DesignFunctionName,fixPtSuffix];

            CC.ConfigInfo.IsFixPtConversionDone=true;
            addpath(dirInfo.fxpBldDir);
            CC.Options.workDir=[];

            CC.HDLState.workDir=dirInfo.workDir;
            CC.HDLState.fxpBldDir=dirInfo.fxpBldDir;
            CC.HDLState.codegenDir=dirInfo.codegenFolder;
            [~,CC.HDLState.actualDesignName,~]=fileparts(char(dataAdapter.getEntryPoints().last()));

            uiFiTypes=com.mathworks.toolbox.coder.fixedpoint.ConversionModel.convertTypesToArray(javaConfig,true);
            CC.HDLState.fiTypes=emlcprivate('convertFromJava',uiFiTypes);
        end

        CC.ConfigInfo.DesignFunctionName=expandProjectMacros(CC.ConfigInfo.DesignFunctionName);
        CC.ConfigInfo.TestBenchScriptName=expandProjectMacros(CC.ConfigInfo.TestBenchScriptName);
        CC.Project.EntryPoints(1).Name=CC.ConfigInfo.DesignFunctionName;
        CC.Project.EntryPoints(1).UserInputName=CC.ConfigInfo.DesignFunctionName;



        CC.Options.outputfile='';
    end


    function loadStdProjectFile(javaConfig)
        checkIssuesMex=javaConfig.getParamAsBoolean(...
        com.mathworks.toolbox.coder.plugin.Utilities.PARAM_BUILD_TYPE_OVERRIDE);

        loadProjectType(javaConfig);
        loadProjectOptions(javaConfig);
        loadProjectWorkingDirectory(javaConfig);
        loadProjectEntryPoints(javaConfig);
        loadProjectGlobals(javaConfig);
        loadProjectOutputFile(javaConfig);
        loadProjectBuildDirectory(javaConfig);
        loadProjectSearchPaths(javaConfig);

        if(hasFixedPointDesigner())
            configureSinglesConversion(javaConfig);
        end

        CC.ParsedProjectFile=true;
    end


    function loadProjectType(javaConfig)


        artifact=char(javaConfig.getParamAsString('param.artifact'));

        if checkIssuesMex||strcmp(artifact,'option.target.artifact.mex')...
            ||strcmp(artifact,'option.target.artifact.mex.instrumented')
            CC.Project.CodingTarget='mex';
            CC.Options.ProjectTarget='mex';
        else
            useECoder=javaConfig.getParamAsBoolean('param.UseECoderFeatures');
            if useECoder
                CC.Options.ProjectTarget='production';
            else
                CC.Options.ProjectTarget='prototype';
            end

            if strcmp(artifact,'option.target.artifact.lib')
                CC.Project.CodingTarget='rtw:lib';
            elseif strcmp(artifact,'option.target.artifact.dll')
                CC.Project.CodingTarget='rtw:dll';
            else
                CC.Project.CodingTarget='rtw:exe';
            end
        end

        CC.Project.Client='CODEGEN';
        CC.ClientType='CODEGEN';
    end


    function loadProjectWorkingDirectory(javaConfig)
        workingDirOpt=char(javaConfig.getParamAsString('param.WorkingFolder'));
        workingDir='';
        switch workingDirOpt
        case 'option.WorkingFolder.Project'
            workingDir=CC.Options.ProjectRoot;
        case 'option.WorkingFolder.Specified'
            workingDir=char(javaConfig.getParamAsString(...
            'param.SpecifiedWorkingFolder'));
        end

        if~isempty(workingDir)
            if isCodegenContext()&&~java.io.File(workingDir).isAbsolute()

                workingDir=fullfile(pwd,workingDir);
            end
            CC.Project.OutDirectory=workingDir;
        end
    end

    function loadProjectOutputFile(javaConfig)
        if isEmbeddedTarget()
            outputFileTag='param.grt.outputfile';
        else
            outputFileTag='param.mex.outputfile';
        end
        outputFile=javaConfig.getParamAsString(outputFileTag);
        if~isempty(outputFile)
            CC.Options.outputfile=expandProjectMacros(char(outputFile));
        end
    end

    function loadProjectSearchPaths(javaConfig)
        searchPaths=javaConfig.getParamAsStringList('param.SearchPaths');
        if isempty(searchPaths)||searchPaths.isEmpty()
            return;
        end

        iterator=searchPaths.iterator();
        while iterator.hasNext()
            searchPath=iterator.next();
            if~isempty(searchPath)
                addSearchPath(expandProjectFolder(searchPath));
            end
        end
    end

    function loadProjectBuildDirectory(javaConfig)
        buildDirOpt=char(javaConfig.getParamAsString('param.BuildFolder'));
        switch buildDirOpt
        case 'option.BuildFolder.Project'
            buildDir=CC.Options.ProjectRoot;
            if~isempty(buildDir)
                CC.Options.LogDirectory=CC.nameLogDir(buildDir);
            end
        case 'option.BuildFolder.Specified'
            buildDir=javaConfig.getParamAsString('param.SpecifiedBuildFolder');
            if~isempty(buildDir)
                CC.Options.LogDirectory=expandProjectFolder(char(buildDir));
            end
            CC.Project.IsUserSpecifiedOutputDir=true;
        case 'option.BuildFolder.Current'
            CC.Options.LogDirectory=CC.nameLogDir(pwd());
            CC.Project.IsUserSpecifiedOutputDir=true;
        end
    end

    function loadProjectOptions(javaConfig)

        featureFlags=javaConfig.getParamAsString('param.FeatureFlags');
        fc=coder.internal.FeatureControl;
        if isprop(CC.Project,'CodeGenWrapper')&&~isempty(CC.Project.CodeGenWrapper)
            fc.EnableCodeCoverage=CC.Project.CodeGenWrapper.isCheckForIssuesBuild()&&isCRICoverageEnabled(javaConfig);
        end
        fc.HalfSupport=coder.internal.gui.Features.Half.isEnabled();
        CC.Project.FeatureControl=copyFeatureFlags(featureFlags,fc);

        if isEmbeddedProduction()
            object=coder.config('lib','ECoder',true);
            setOutputType(object);
        elseif isEmbeddedPrototype()
            object=coder.config('lib','Ecoder',false);
            setOutputType(object);
        else
            object=coder.config('mex');
        end

        copyProjectToConfigObject(javaConfig.getProject(),object);

        if checkIssuesMex


            object.GenCodeOnly=false;
            object.EnableJIT=javaConfig.getParamAsBoolean(...
            com.mathworks.toolbox.coder.plugin.Utilities.PARAM_CHECK_ISSUES_JIT);
            object.EnableJITSilentBailOut=true;


            object.EnableMexProfiling=false;
        end

        CC.ConfigInfo=expandObjectFolders(object);
    end


    function[boolean]=isCRICoverageEnabled(javaConfig)
        objective=com.mathworks.toolbox.coder.app.GenericArtifact.fromConfiguration(javaConfig);
        boolean=~strcmpi(char(objective),'gpu')&&javaConfig.getParamAsBoolean('param.EnableCRICodeCoverage');
    end


    function object=expandObjectFolders(object)
        object.CustomInclude=expandProjectFolders(object.CustomInclude);
    end

    function setOutputType(object)
        switch CC.codingTarget()
        case 'rtw:exe'
            object.OutputType='EXE';
        case 'rtw:dll'
            object.OutputType='DLL';
        otherwise
            object.OutputType='LIB';
        end
    end

    function loadF2FProjectGlobals(javaConfig)
        loadProjectGlobals(javaConfig,true);
    end


    function loadProjectGlobals(javaConfig,isFixedPtConverterPrj)
        if nargin<2
            isFixedPtConverterPrj=false;
        end
        paramGlobals=coder.internal.gui.GuiUtils.getGlobalsReader(javaConfig);
        if isempty(paramGlobals)
            return;
        end

        [xGlobalVar,idpTable]=coder.internal.gui.GuiUtils.getInputDataReader(paramGlobals);
        nGtcs=0;

        while xGlobalVar.isPresent()
            gtc=loadProjectGlobal(xGlobalVar,idpTable);
            nGtcs=nGtcs+1;
            gtcs{nGtcs}=gtc;%#ok<AGROW>
            xGlobalVar=xGlobalVar.next();
        end

        fxpMode=javaConfig.getParamAsString('param.FixedPointMode');
        if~isFixedPtConverterPrj&&fxpMode.equals('option.FixedPointMode.Automatic')...
            &&~isempty(CC.FixptData)
            fixptGlbTypes=CC.FixptData.getFixedGlobalTypes();
            for ii=1:length(fixptGlbTypes)
                nGtcs=nGtcs+1;
                gtcs{nGtcs}=fixptGlbTypes{ii};
            end
        end

        if nGtcs>0
            CC.Project.InitialGlobalValues=gtcs;
        end
    end


    function type=loadProjectGlobal(xGlobalVar,idpTable)
        globalName=char(xGlobalVar.readAttribute('Name'));
        type=xml2type(CC.getFeatureControl(),xGlobalVar,globalName,globalName,idpTable);
        if isa(type,'coder.Constant')
            gType=coder.typeof(type.Value);
            gType.Name=globalName;
            gType.InitialValue=type;
            type=gType;
        elseif~isempty(type.ValueConstructor)&&~strcmp(type.ValueConstructor,'[]')&&~type.contains(type.InitialValue)
            msgId='Coder:configSet:GlobalInitialValueTypeMismatch';
            ccdiagnosticid(msgId,globalName);
        end
    end


    function text=expandProjectMacros(text)
        text=CC.expandProjectMacros(text);
    end


    function folder=expandProjectFolder(folder)
        folder=strtrim(folder);
        if isempty(folder)
            return;
        end
        folder=expandProjectMacros(folder);
        quote='"';
        if folder(1)==quote&&folder(end)==quote
            folder=strtrim(folder(2:end-1));
            if isempty(folder)
                folder=[quote,quote];
                return;
            end
        end
        [pathstr,~,~]=fileparts(folder);
        isrelative=isempty(pathstr);
        if~isrelative
            if isunix
                isrelative=~strncmp(pathstr,'/',1);
            elseif ispc

                pat='^([\w]:[\\/]|\\\\|//)';
                isrelative=isempty(regexp(pathstr,pat,'once'));
            end
        end
        if isrelative

            folder=fullfile(CC.Options.ProjectRoot,folder);
        end
    end


    function newFolders=expandProjectFolders(oldFolders)
        folders=regexp(oldFolders,'\n','split');
        newFolders=cell(1,0);
        nl=newline;
        quote='"';
        for i=1:numel(folders)
            thisFolder=folders{i};
            if~isempty(thisFolder)
                thisFolder=expandProjectFolder(thisFolder);
                if contains(thisFolder,' ')
                    thisFolder=[quote,thisFolder,quote];%#ok<AGROW>
                end
                if i>1
                    thisFolder=[nl,thisFolder];%#ok<AGROW>
                end
                newFolders{end+1}=thisFolder;%#ok<AGROW>
            end
        end
        newFolders=[newFolders{:}];
        if isempty(newFolders)
            newFolders='';
        end
    end


    function loadHDLProjectEntryPoints(javaConfig)
        fileSet=javaConfig.getFileSet('fileset.entrypoints');
        entryPoints=fileSet.getFiles();
        iterator=entryPoints.iterator();
        CC.HDLState.origInputTypes={};
        index=1;
        while iterator.hasNext()
            file=iterator.next();
            CC.checkEntryPointFcnName(char(file.getAbsolutePath()));
            entryPoint=CC.Project.EntryPoints(index);
            usePreconditions=false;
            isFixedPtConverterPrj=false;
            CC.HDLState.origInputTypes{index}=loadEntryPointIDPs(javaConfig,file,index,usePreconditions,isFixedPtConverterPrj,getFiTypesMap(javaConfig,isFixedPtConverterPrj));


            inCount=coder.internal.Helper.getInOutParamCounts(entryPoint.UserInputName);
            dataPropsCount=length(entryPoint.InputTypes);
            if dataPropsCount~=0&&inCount~=dataPropsCount
                warning(message('Coder:common:HDLNotEnoughArgsSpecified',entryPoint.Name));
                CC.Project.EntryPoints(end).reset;
                CC.Project.EntryPoints(end).HasInputTypes=false;
            end
            index=index+1;
        end
    end


    function loadProjectEntryPoints(javaConfig,isFixedPtConverterPrj)
        if nargin<2
            isFixedPtConverterPrj=false;
        end

        fiTypesMap=getFiTypesMap(javaConfig,isFixedPtConverterPrj);

        fileSet=javaConfig.getFileSet('fileset.entrypoints');
        entryPoints=fileSet.getFiles();
        usePreconditions=javaConfig.getParamAsBoolean('param.UsePreconditions');
        iterator=entryPoints.iterator();
        index=1;
        while iterator.hasNext()
            file=iterator.next();
            CC.checkEntryPointFcnName(char(file.getAbsolutePath()));
            loadEntryPointIDPs(javaConfig,file,index,usePreconditions,isFixedPtConverterPrj,fiTypesMap);
            index=index+1;
        end

        if~isFixedPtConverterPrj&&coderprivate.isFixedPointConversionEnabled(javaConfig)


            updateEntryPointPathsForFixpt(javaConfig);
        end
    end



    function m=getFiTypesMap(javaConfig,isFixedPtConverterPrj)
        m=containers.Map();


        if~isFixedPtConverterPrj&&coderprivate.isFixedPointConversionEnabled(javaConfig)
            fiTypesFromGUI=com.mathworks.toolbox.coder.fixedpoint.ConversionModel.convertAllTypesToArray(javaConfig,true);
            for ii=1:length(fiTypesFromGUI)
                epTypes=fiTypesFromGUI(ii);
                fullEPName=epTypes(1);
                uiFiTypesStr=epTypes(2);
                m(fullEPName)=uiFiTypesStr;
            end
        end
    end

    function updateEntryPointPathsForFixpt(javaConfig)
        primaryEntryPointName=CC.Project.EntryPoints(1).Name;

        prjRoot=char(javaConfig.getFile().getParentFile().getAbsolutePath());
        data=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);
        buildPath=char(data.getBuildPath);
        workingPath=char(data.getWorkingPath);%#ok<NASGU>
        if data.isBuildFolderSpecified
            [buildDirRoot,codegenFolderName,~]=fileparts(buildPath);
            designFolderName=primaryEntryPointName;

            [~,fixptFilesOutputDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(buildDirRoot,codegenFolderName,designFolderName);
        else
            codegenFolderName='codegen';
            designFolderName=primaryEntryPointName;

            [~,fixptFilesOutputDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(prjRoot,codegenFolderName,designFolderName);
        end

        fileSet=javaConfig.getFileSet('fileset.entrypoints');
        entryPoints=fileSet.getFiles();
        iterator=entryPoints.iterator();
        index=1;
        while iterator.hasNext()
            iterator.next();

            origEntryPointName=CC.Project.EntryPoints(index).Name;
            fixPtSuffix=char(data.getGeneratedFileSuffix);
            newEntryPoint=[origEntryPointName,fixPtSuffix];


            [~,~,fileExt]=fileparts(CC.Project.EntryPoints(index).UserInputName);
            newUserInputName=fullfile(fixptFilesOutputDir,[newEntryPoint,fileExt]);


            CC.Project.EntryPoints(index).Name=newEntryPoint;
            CC.Project.EntryPoints(index).UserInputName=newUserInputName;

            index=index+1;
        end
    end


    function iTc=loadEntryPointIDPs(javaConfig,file,index,usePreconditions,isFixedPtConverterPrj,fiTypesMap)
        iTc=[];
        entryPoint=CC.Project.EntryPoints(index);

        if~isFixedPtConverterPrj&&coderprivate.isFixedPointConversionEnabled(javaConfig)
            CC.FixptState.OrigEntryPoints(index)=entryPoint.copy();
        end

        entryPoint.HasInputTypes=false;
        if usePreconditions


            return;
        end

        inputData=coder.internal.gui.GuiUtils.getInputRootReader(javaConfig,file);
        if~isempty(inputData)
            [xInput,idpTable]=coder.internal.gui.GuiUtils.getInputDataReader(inputData);
            nITyp=0;

            hasInputVars=false;
            while xInput.isPresent()
                inputName=char(xInput.readAttribute('Name'));
                inputs=xml2type(CC.getFeatureControl(),xInput,inputName,inputName,idpTable);
                for input=1:numel(inputs)
                    hasInputVars=true;
                    nITyp=nITyp+1;
                    if~isa(inputs,'cell')
                        iTc{nITyp}=inputs(input);%#ok<AGROW>
                    else
                        iTc{nITyp}=inputs{input};%#ok<AGROW>
                    end
                end
                xInput=xInput.next();
            end

            if hasInputVars



                if~isFixedPtConverterPrj&&coderprivate.isFixedPointConversionEnabled(javaConfig)
                    CC.FixptState.OrigEntryPoints(index).InputTypes=iTc;
                    dataAdapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(javaConfig);


                    uiFiTypes=fiTypesMap(entryPoint.UserInputName);
                    newTypes=emlcprivate('convertFromJava',uiFiTypes);

                    if(~isempty(newTypes)&&length(iTc)~=length(fieldnames(newTypes)))...
                        ||isempty(newTypes)&&~isempty(iTc)
                        ccdiagnosticid('Coder:common:MLCoderFixPtTypesMissing');
                    end

                    fimathStr=char(dataAdapter.getFimath);
                    iTcsPassed=iTc;
                    iTcsReturned=emlcprivate('convertTypesToFixPt',iTcsPassed,newTypes,fimathStr);
                    entryPoint.InputTypes=iTcsReturned;
                else
                    entryPoint.InputTypes=iTc;
                end
                entryPoint.HasInputTypes=true;
            end

            nargoutStr=inputData.readAttribute('nargout');
            if~isempty(nargoutStr)
                numOutputs=abs(str2double(nargoutStr));
                entryPoint.HasUserNumOutputs=true;
                entryPoint.UserNumOutputs=numOutputs;
            end
        end
    end


    function[bool]=hasFixedPointDesigner()
        bool=license('test','Fixed_Point_Toolbox')&&...
        ~isempty(which(fullfile(matlabroot,'toolbox','fixedpoint','fixedpoint','Contents.m')));
    end


    function configureSinglesConversion(javaConfig)
        if javaConfig.getParamAsString('param.FixedPointMode').equals('option.FixedPointMode.Singles')
            CC=coder.internal.configureForSinglesConversion(CC);
        end
    end

end
