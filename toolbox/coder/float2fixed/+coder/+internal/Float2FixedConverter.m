



classdef Float2FixedConverter<handle

    properties(Access='public')

fxpCfg
    end

    properties(Access='public')

DesignFunctionNames





loggedIOValuesFromFloatingPointSim
loggedIOValuesFromFixedPointSim
plottedFigureHandles







coderLoggedDataVarInfo

floatToFixedNameMap

        coderLoggedFloatingPtData=coder.internal.Float2FixedConverter.LOGGED_DATA_DEFAULT;
        coderLoggedFixedPtData=coder.internal.Float2FixedConverter.LOGGED_DATA_DEFAULT;
coderLoggedErrorData

InstrLoggedFloatVars
InstrLoggedFixedVars


        pauseAfterEachWorkFlowStep=false;
        generateMATLAB=true;
        generateC=false;


        typeProposalSettings;


        actualFunctionName;

        dutInterface;


        fcnInfoRegistry;


tbFcnInfoRegistryMap
        tbExpressionInfoMap;





        designExprInfoMap;


        fixptFcnInfoRegistry;
        fixptExpressionInfo;


        fixptSDFcnInfoRegistry;
        fixptSDExpressionInfo;


        tbDepContsMap;


        floatInVals;
        floatOutVals;


        fixedInVals;
        fixedOutVals;


        inVals;
        outVals;

inputTypeSpecifications
varInfoTable







inputTypes


floatGlobalTypes

fixedGlobalTypes





globalUniqNameMap


floatMexFileName






        StaticRangeAnalysisLoopUnrollingThreshold=1024;
        StaticRangeAnalysisSubLoopUnrollingThreshold=1024;

UseCoderForCodegen

StateLoaded

ComputedCodeCoverageInfo

isGUIWorkflow
FlattenedReport
    end

    properties(Hidden)

functionCodeMaps
methodCodeMaps
    end

    properties(Constant)

        INBUILT_PLOT_FUNCTION=@coder.internal.plotting.inBuiltPlotFunction;
        INBUILT_PLOT_FUNCTION_CLI=@coder.internal.plotting.inBuiltPlotFunctionCLI;
        NUMERICTYPEDOCPAGE='<a href="matlab: doc(''numerictype'')">numerictype</a>';

        LOGGED_DATA_DEFAULT=coder.internal.lib.Map();
    end


    properties
        MLFB=struct(...
        'isConvertingMLFB',false,...
        'mlfbH',[],...
        'fixptMlfbH',[]...
        );
    end

    methods

        function set.floatGlobalTypes(this,value)
            if isempty(value)
                value={};
            end
            assert(isa(value,'cell'));
            this.floatGlobalTypes=value;
        end

        function set.loggedIOValuesFromFloatingPointSim(this,value)
            if isempty(value)&&~isa(value,'containers.Map')
                value=coder.internal.lib.Map.empty();
            end
            assert(isa(value,'containers.Map'));
            this.loggedIOValuesFromFloatingPointSim=value;
        end

        function set.loggedIOValuesFromFixedPointSim(this,value)
            if isempty(value)&&~isa(value,'containers.Map')
                value=coder.internal.lib.Map.empty();
            end
            assert(isa(value,'containers.Map'));
            this.loggedIOValuesFromFixedPointSim=value;
        end

        function set.UseCoderForCodegen(this,value)
            this.UseCoderForCodegen=value;
        end

        function value=get.UseCoderForCodegen(this)
            value=this.UseCoderForCodegen;
        end
    end

    properties(Access=private)

coderConstIndices





        forcePushEntryPointMFileName;
    end

    methods(Access=public)










        function this=Float2FixedConverter(dutNameOrCfg,tbNames,customerDesignFolderName,rootDir,codegenFolderName)
            if isa(dutNameOrCfg,'coder.FixPtConfig')
                this.fxpCfg=dutNameOrCfg;
                dutNames=this.fxpCfg.DesignFunctionName;

                tbNames=this.fxpCfg.TestBenchName;
            else
                dutNames=dutNameOrCfg;
                if coder.FixPtConfig.DoubleToSingleInFxpApp
                    this.fxpCfg=coder.config('double2single');
                else
                    this.fxpCfg=coder.config('fixpt');
                end
                if(nargin==1)
                    tbNames={};
                end
            end

            if(nargin<=3)
                rootDir=pwd;
            end
            if(nargin<=4)
                codegenFolderName='codegen';
            end

            if ischar(tbNames)
                if~isempty(tbNames)
                    tbNames={tbNames};
                else
                    tbNames={};
                end
            end

            this.tbDepContsMap=coder.internal.DependencyContainerMap();

            assert(1~=isempty(dutNames),'Design cannot be empty');
            if ischar(dutNames)
                dutNames={dutNames};
            end
            dutPaths=findDesign(dutNames);
            emptyDuts=cellfun(@(x)isempty(x),dutPaths,'UniformOutput',true);
            if any(emptyDuts)
                error(message('Coder:FXPCONV:InvalidDesignFile',strjoin(dutNames(emptyDuts),', ')));
            end

            if~isempty(tbNames)
                for kk=1:length(dutNames)
                    coder.internal.MTREEUtils.validateDesign(dutNames{kk},0);
                end
                this.validateTBs(tbNames);
            end


            for kk=1:length(dutPaths)
                dPath=dutPaths{kk};
                try
                    coder.internal.Helper.checkPathForToolboxPath(dPath);
                catch ex
                    if strcmp(ex.identifier,'Coder:FXPCONV:invalidDirLoc')
                        newEx=MException(message('Coder:FXPCONV:invalidDesignTbxLoc',dPath));
                        newEx.addCause(ex);
                        throw(newEx);
                    else
                        rethrow(ex);
                    end
                end

                try
                    this.checkForFileNameMismatch(dPath);
                catch ex
                    if~strcmp(ex.identifier,'Coder:FXPCONV:topFcnNameMismatch')
                        disp(ex.message);
                    else
                        rethrow(ex);
                    end
                end



                this.checkForShadowedFiles(dutNames,tbNames);
            end

            if~isempty(tbNames)
                [~,tbns,~]=cellfun(@(tb)fileparts(coder.internal.Helper.which(tb)),tbNames,'UniformOutput',false);
            else
                tbns='';
            end







            this.DesignFunctionNames=dutNames;


            [dDir,dn,~]=fileparts(dutPaths{1});

            this.fxpCfg.DesignDirectory=dDir;

            if(nargin<=2)
                desFolderName=dn;
            else
                if(~isempty(customerDesignFolderName))
                    desFolderName=customerDesignFolderName;
                else
                    desFolderName=dn;
                end
            end
            if isempty(this.fxpCfg.CodegenDirectory)
                this.fxpCfg.CodegenDirectory=fullfile(rootDir,codegenFolderName);
            end
            if this.fxpCfg.DoubleToSingle
                this.fxpCfg.CodegenWorkDirectory=fullfile(this.fxpCfg.CodegenDirectory,desFolderName,'single','tmp');
                this.fxpCfg.OutputFilesDirectory=fullfile(this.fxpCfg.CodegenDirectory,desFolderName,'single');
            else
                this.fxpCfg.CodegenWorkDirectory=fullfile(this.fxpCfg.CodegenDirectory,desFolderName,'fixpt','fxptmp');
                this.fxpCfg.OutputFilesDirectory=fullfile(this.fxpCfg.CodegenDirectory,desFolderName,'fixpt');
            end

            dns=cell(size(dutPaths));
            for ii=1:length(dutPaths)
                [~,dns{ii},~]=fileparts(dutPaths{ii});
            end

            this.DesignFunctionNames=dns;
            this.fxpCfg.TestBenchName=tbns;

import coder.internal.lib.Map;
            this.loggedIOValuesFromFloatingPointSim=Map();
            this.loggedIOValuesFromFixedPointSim=Map();
            this.coderLoggedDataVarInfo=coder.internal.lib.Map();
            this.floatToFixedNameMap=coder.internal.lib.Map();
            this.coderLoggedErrorData=coder.internal.Float2FixedConverter.getErrorStruct();
            this.plottedFigureHandles=coder.internal.lib.Map();

            this.floatInVals={};
            this.floatOutVals={};
            this.fixedInVals={};

            this.inVals={};
            this.outVals={};

            this.inputTypeSpecifications={};this.coderConstIndices=[];
            this.varInfoTable={};

            this.fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry.empty();
            this.fixptFcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry.empty();
            this.fixptSDFcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry.empty();

            this.tbFcnInfoRegistryMap=coder.internal.lib.Map();
            this.tbExpressionInfoMap=coder.internal.lib.Map();

            this.designExprInfoMap=coder.internal.lib.Map();


            this.inputTypes=cell(1,length(this.DesignFunctionNames));

            this.floatGlobalTypes={};
            this.fixedGlobalTypes={};

            this.floatMexFileName='';

            if dig.isProductInstalled('MATLAB Coder')

                this.UseCoderForCodegen=true;
            else

                this.UseCoderForCodegen=false;
            end

            this.forcePushEntryPointMFileName=fullfile(matlabroot,'toolbox','eml','lib','fixedpoint','forcePushIntoCloud.m');

            this.StateLoaded=false;

            this.ComputedCodeCoverageInfo=false;

            this.isGUIWorkflow=false;

            if this.DoubleToSingle
                this.sanitizeSingleConfig();
            end


            function dPaths=findDesign(dNames)
                dPaths=cell(1,length(dNames));
                for mm=1:length(dNames)
                    dName=dNames{mm};
                    dPaths{mm}=coder.internal.Helper.which(dName);
                    [~,tmpName,~]=fileparts(dPaths{mm});
                    [~,actName,~]=fileparts(dName);



                    if~strcmp(tmpName,actName)
                        dPaths{mm}=[];
                    end
                end
            end
        end

        function delete(~)
        end

        function sanitizeSingleConfig(this)
            this.fxpCfg.DetectFixptOverflows=false;
            this.fxpCfg.ComputeDerivedRanges=false;
        end
    end

    methods(Static)




        function res=isCodegenSuccess(coderReport)
            res=~isempty(coderReport)&&isfield(coderReport,'summary')&&coderReport.summary.passed;
        end



        function res=checkFixedPointCodeName(design,suffix)
            res=isvarname([design,suffix]);
        end



        function isGoldName(name)
            [~,~,c]=fileparts(name);
            assert(isempty(c),'Not expecting a filename here');
        end



        function dif=getDIF(fcnName)

            [inportNames,outportNames]=coder.internal.Float2FixedConverter.getFcnInterface(fcnName);

            dif.inportNames=inportNames;
            dif.outportNames=outportNames;
            dif.numIn=length(inportNames);
            dif.numOut=length(outportNames);
        end




        function fixPtTbNames=createFixPtTBs(fxpCfg)
            tbNames=fxpCfg.TestBenchName;
            if ischar(tbNames)
                tbNames={tbNames};
            end
            destinationDir=fxpCfg.OutputFilesDirectory;
            dNames=fxpCfg.DesignFunctionName;
            wrapperName=getFixPtWrapperNameFromConfig(fxpCfg);
            fixPtTbNames=coder.internal.Float2FixedConverter.createFixPtTBsWithCallToWrappers(tbNames,destinationDir,dNames,wrapperName,fxpCfg.FixPtFileNameSuffix);

            function fixPtWrapperName=getFixPtWrapperNameFromConfig(fxpCfg)
                dNames=fxpCfg.DesignFunctionName;
                if ischar(dNames)
                    dNames={dNames};
                end
                fixPtSuffix=fxpCfg.FixPtFileNameSuffix;
                wrapper_suffix=coder.internal.Float2FixedConverter.getDefaultWrapperSuffix();

                fixPtWrapperName=cellfun(@(d)[d,wrapper_suffix,fixPtSuffix],dNames,'UniformOutput',false);
            end
        end



        function fixPtTbNames=createFixPtTBsWithCallToWrappers(tbNames,destinationDir,dNames,wrapperNames,fixPtSuffix)
            d=dir(destinationDir);
            if isempty(d)
                mkdir(destinationDir);
            end

            if ischar(dNames)
                dNames={dNames};
            end

            if ischar(wrapperNames)
                wrapperNames={wrapperNames};
            end
            fixPtTbNames=cellfun(@(tb)closure(tb,dNames,wrapperNames),tbNames,'UniformOutput',false);
            function tbNameFixPt=closure(tb,dNames,wrapperNames)
                tbNameFixPt=[tb,fixPtSuffix];
                outTBPath=fullfile(destinationDir,[tbNameFixPt,'.m']);

                coder.internal.Helper.fileCopy(coder.internal.Helper.which(tb)...
                ,fullfile(outTBPath));


                coder.internal.Helper.changeIdInFile(outTBPath...
                ,tb...
                ,tbNameFixPt);


                cellfun(@(d,w)coder.internal.Helper.changeIdInFile(outTBPath...
                ,d...
                ,w)...
                ,dNames,wrapperNames);
            end
        end





        function[fcnName,deleteFcnName]=createEvalTBSimFunction(tbSimFileName,outputDir)
            if(~isFunction(tbSimFileName))
                fcnName='evalTBSim';
                deleteFcnName=true;

                code=['function ',fcnName,' \n '...
                ,'eval(''',tbSimFileName,''');'];
                code=strrep(code,'\n',newline);

                coder.internal.Helper.createMATLABFile(outputDir,fcnName,code);




                tmp=coder.internal.Helper.which(fcnName);%#ok
            else
                fcnName=tbSimFileName;
                deleteFcnName=false;
            end
            clear(fcnName);


            function isFunction=isFunction(tb)
                fileMTree=mtree(fileread(coder.internal.Helper.which(tb)));
                [hasInputParams,isFunction]=coder.internal.MTREEUtils.hasInputParams(fileMTree);
                if(hasInputParams)
                    error(message('Coder:FXPCONV:tbmustbescript',tb));
                end
            end
        end










        function loggedVals=runTestBenchToLogDataNew(workDirectory,outputFilesDirectory,dName,tbNames,exInputs,simLimit,coderConstIndices,coderConstVals)
            loggedVals=[];
            [setupInfo]=doSetup(outputFilesDirectory,workDirectory);
            cleanup=onCleanup(@()runCleanup(setupInfo,workDirectory,outputFilesDirectory));

            mexFileName=buildDesign(dName,workDirectory,exInputs,coderConstIndices,coderConstVals);
            for idx=1:length(tbNames)
                tb=tbNames{idx};

                isMexInDesignPath=false;
                isEntryPointCompiled=true;
                tbExecCfg=coder.internal.TestBenchExecConfig(isMexInDesignPath,isEntryPointCompiled);


                runSimFcn=@runSimulation;
                dif=coder.internal.Float2FixedConverter.getDIF(dName);
                runSimFcn=withLogging(runSimFcn,dif,workDirectory,simLimit,coderConstIndices);


                outDirForEvalTBSim=pwd;
                runSimFcn=withScopeProtection(runSimFcn,outDirForEvalTBSim);

                runSimFcn(tbExecCfg,tb,dName,mexFileName);
            end


            function runCleanup(setupInfo,workDirectory,outputFilesDirectory)



                path(setupInfo.pathBak);
                cd(setupInfo.currDir);
                makeGeneratedFilesReadOnly(workDirectory,outputFilesDirectory);

clear mex;%#ok<*CLMEX>
                coder.internal.Helper.changeBacktraceWarning('reset',setupInfo.warnState);
                fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0);

                function makeGeneratedFilesReadOnly(workDirectory,outputFilesDirectory)
                    mlFileList=dir(fullfile(workDirectory,'*.m'));
                    if(0<length(mlFileList))
                        fileattrib(fullfile(workDirectory,'*.m'),'-w');
                    end
                    try
                        files=what(outputFilesDirectory);
                        if~isempty(files)
                            for jj=1:length(files.m)
                                mFile=files.m{jj};
                                fileattrib(fullfile(outputFilesDirectory,mFile),'-w');
                            end
                        end
                    catch err
                        if(strcmp(err.identifier,'MATLAB:FILEATTRIB:CannotFindFile'))

                        else
                            rethrow(err);
                        end
                    end
                end
            end

            function[setupInfo]=doSetup(outputDir,workingDir)
                if 7~=exist(outputDir,'dir')
                    mkdir(outputDir);
                end

                setupInfo.currDir=pwd;
                setupInfo.pathBak=path;
                setupInfo.projectDir=workingDir;
clear mex;
                [~,~,~]=rmdir(workingDir,'s');
                [~,~,~]=mkdir(workingDir);
                addpath(workingDir);
                setupInfo.warnState=coder.internal.Helper.changeBacktraceWarning('off');
            end


            function fcn=withScopeProtection(runSimFcn,outDirForEvalTBSim)
                fcn=@runSimWithTBEvalSimFcn;
                function runSimWithTBEvalSimFcn(tbExecCfg,tb,dName,mexFileName)

                    simFile=tb;
                    try


                        [simFile,deleteSimFile]=coder.internal.Float2FixedConverter.createEvalTBSimFunction(tb,outDirForEvalTBSim);

                        simFilePath=fullfile(outDirForEvalTBSim,[simFile,'.m']);
                        c=onCleanup(@()deleteEvalSimFcn(deleteSimFile,simFilePath));

                        runSimFcn(tbExecCfg,simFile,dName,mexFileName);
                    catch ex
                        simEx=MException(ex.identifier,strrep(ex.message,simFile,tb));
                        simEx.addCause(ex);
                        throw(simEx);
                    end

                    function deleteEvalSimFcn(doDelete,simFilePath)
                        if doDelete
                            coder.internal.Helper.deleteFile(simFilePath);
                        end
                    end
                end
            end


            function fcn=withLogging(runSimFcn,dif,workDir,simulationLimit,coderConstIndices)
                fcn=@runSimWithLogged;
                function runSimWithLogged(tbExecCfg,tb,dName,mexFileName)
                    initAllLogIOState();
                    bailoutEarly=false;
                    if simulationLimit~=Inf&&simulationLimit>=0
                        bailoutEarly=true;
                    end
                    if bailoutEarly
                        bailoutExceptionIdentifier='Coder:FXPCONV:MATLABSimBailOut';
                        inVals={};outVals={};
                        logDataFcnName=coder.internal.LoggerService.createLocalLogDataFunctionFile(dif,workDir,coderConstIndices,[],[],bailoutEarly,bailoutExceptionIdentifier,inVals,outVals,simulationLimit);
                    else
                        logDataFcnName=coder.internal.LoggerService.createLocalLogDataFunctionFile(dif,workDir,coderConstIndices);
                    end


                    tbExecCfg.setLogFcnName(dName,logDataFcnName);
                    outputParamCount=length(dif.outportNames);
                    inputParamCount=length(dif.inportNames);
                    tbExecCfg.setOutputParamCount(dName,outputParamCount);
                    tbExecCfg.setInputOutputLogIndices(dName,ones(1,inputParamCount),ones(1,outputParamCount));
                    tbExecCfg.setSuppressOutput(true);

                    try
                        if nargin==4
                            runSimFcn(tbExecCfg,tb,dName,mexFileName);
                        else
                            runSimFcn(tbExecCfg,tb,dName);
                        end
                    catch ex

                        if~isempty(strfind(ex.message,'Return early for input computation'))
                        else
                            rethrow(ex)
                        end
                    end

                    loggedVals=collectLoggedValues(dif);
                    function loggedValues=collectLoggedValues(dif)
                        loggedValues=coder.internal.LoggerService.packageLoggedValues(dif);
                        coder.internal.LoggerService.clearLogValues(dif);
                    end
                end

                function initAllLogIOState()
                    coder.internal.LoggerService.clearLogValues(dif);
                    coder.internal.LoggerService.defineSimLogValues(dif);
                end
            end

            function runSimulation(tbExecCfg,tb,dName,mexFcn)
                try
                    if nargin==4
                        coder.internal.runTest(tbExecCfg,tb,dName,mexFcn);
                    else
                        coder.internal.runTest(tbExecCfg,tb,dName);
                    end
                catch evalEx



                    customexp=MException('Coder:FXPCONV:SimulationException',strrep(evalEx.getReport('basic','hyperlinks','on'),'\','/'));
                    throw(customexp);
                end
            end





            function mexFileName=buildDesign(dName,outPath,exInputs,coderConstIndices,coderConstVals)
                mexFileName=[dName,'_hdl_mex'];
                try
                    exInputs=injectCoderConstants(exInputs,coderConstIndices,coderConstVals);
                    mexOutputFile=fullfile(outPath,mexFileName);
                    mexFilesOutputDir=fullfile(outPath,dName);

                    cfg=coder.config('mex');
                    cfg.ConstantInputs='Remove';
                    emlcprivate('emlckernel','codegen','-config',cfg,'-args',exInputs,'-o',mexOutputFile,'-d',mexFilesOutputDir,dName);
                catch me
                    disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:examineErrorReport').getString));
                    rethrow(me);
                end

                function exInputs=injectCoderConstants(exInputs,coderConstIndices,coderConstVals)
                    assert(length(coderConstIndices)==length(coderConstVals));
                    for ii=1:length(coderConstIndices)
                        exInputs{coderConstIndices(ii)}=coder.Constant(coderConstVals{ii});
                    end
                end
            end
        end













        function[workDir,outputDir]=getWorkingAndOutputDir(rootDir,codegenFolderName,designFolderName)
            if isempty(rootDir)
                rootDir=pwd;
            end
            if isempty(codegenFolderName)
                codegenFolderName='codegen';
            end

            codeGenDir=fullfile(rootDir,codegenFolderName);

            workDir=fullfile(codeGenDir,designFolderName,'fixpt','fxptmp');
            outputDir=fullfile(codeGenDir,designFolderName,'fixpt');
        end


        function[inputTypeSpecifications,coderConstantIndices]=convertTypesToExArgs(inputTypes)
            coderConstantIndices=[];


            inputTypeSpecifications={};
            for ii=1:length(inputTypes)
                dataProp=inputTypes{ii};
                inputTypeSpecifications{end+1}=dataProp;
                if isa(dataProp,'coder.Constant')
                    coderConstantIndices(end+1)=ii;
                end
            end
        end
    end


    methods(Static,Access=public)


        function[s,wlen,flen,err]=getTypeInfoFromStr(dt)
            err=false;
            s=false;wlen=0;flen=0;

            try
                nt=numerictype(dt);
                s=nt.SignednessBool;
                wlen=nt.WordLength;
                flen=nt.FractionLength;
            catch
                err=true;
            end
        end


        function[inputArgNames,outputArgNames]=getFcnInterface(designName)

            dPath=coder.internal.Helper.which(designName);
            if isempty(dPath)
                error(message('Coder:FXPCONV:missingdesignfile',designName));
            end

            [~,dn,ext]=fileparts(dPath);
            if~strcmp(ext,'.m')
                error(message('Coder:FXPCONV:badid_invalidfcnext',[dn,ext]));
            end

            mTF=mtree(fileread(dPath));
            rootFcnMT=root(mTF);

            subTF=mtfind(mTF,'Kind','FUNCTION');
            if isempty(subTF.strings)
                error(message('Coder:FXPCONV:badid_invalidfcn'));
            end

            [inputArgNames,outputArgNames]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(dPath,rootFcnMT);
        end

        function fWrapper=getDefaultWrapperSuffix()
            fWrapper='_wrapper';
        end

        function fExt=getMext()
            fExt='.m';
        end

        function fixptDesignName=buildFixPtDesignName(designNameGold,ext)
            coder.internal.Float2FixedConverter.isGoldName(designNameGold);
            fixptDesignName=[designNameGold,ext];
        end

        function fixptTestBenchName=buildFixPtTestBenchName(tbNameGold,ext)
            coder.internal.Float2FixedConverter.isGoldName(tbNameGold);
            fixptTestBenchName=[tbNameGold,ext];
        end

        function fixPtWrapperName=buildFixPtWrapperName(dName,ext)
            fixPtSuffix=ext;
            wrapper_suffix=coder.internal.Float2FixedConverter.getDefaultWrapperSuffix();

            fixPtWrapperName=[dName,wrapper_suffix,fixPtSuffix];
        end

        function fiMatFileName=getFiInputMatFileName(dName)
            fiMatFileName=[dName,'_exInput.mat'];
        end

        function fiMatFileName=getFiOutputMatFileName(dName)
            fiMatFileName=[dName,'_exOutput.mat'];
        end

        function fiMatFileName=getFiValMatFileName(dName)
            fiMatFileName=[dName,'_args.mat'];
        end

        function typeProposalSettings=getTypeSettingsForApproximation()


            typeProposalSettings.proposeTargetContainerTypes=false;
            typeProposalSettings.defaultWL=coder.FixPtConfig.DEFAULTWORDLENGTH;
            typeProposalSettings.defaultFL=coder.FixPtConfig.DEFAULTFRACTIONLENGTH;
            typeProposalSettings.defaultSignedness=[];
            typeProposalSettings.optimizeWholeNumber=true;
            typeProposalSettings.proposeWLForDefFL=false;
            typeProposalSettings.proposeFLForDefWL=true;
            typeProposalSettings.safetyMargin=coder.FixPtConfig.SAFETYMARGIN;
        end
    end

    methods(Access='private')

        function cleanupFixedPtGlobals(this)




            for pp=1:length(this.fixedGlobalTypes)
                type=this.fixedGlobalTypes{pp};
                clear('global',type.Name);
            end
        end



        function constructDefaultCoderEnabledLogList(this)
            this.coderLoggedDataVarInfo=coder.internal.lib.Map();

            dNames=this.DesignFunctionNames;
            for ii=1:length(dNames)
                dN=dNames{ii};
                fcnInfos=this.fcnInfoRegistry.getFunctionTypeInfosByName(dN);
                fcnInfos=[fcnInfos{:}];
                epFcnInfo=fcnInfos([fcnInfos.isDesign]);
                origIpNames=epFcnInfo.inputVarNames;
                origOpNames=epFcnInfo.outputVarNames;

                convertedIpNames=epFcnInfo.convertedFunctionInterface.inputParams;
                convertedOpNames=epFcnInfo.convertedFunctionInterface.outputParams;

                s.originalInputsToLog=origIpNames;
                s.originalOutputsToLog=origOpNames;
                s.convertedInputsToLog=convertedIpNames;
                s.convertedOutputsToLog=convertedOpNames;

                s.origGUIVarsToPlot={};
                s.origFcnName=epFcnInfo.functionName;
                s.origSpecializationId=epFcnInfo.specializationId;
                s.convertedFcnName=epFcnInfo.convertedFunctionInterface.convertedName;
                s.origFcnScriptPath=epFcnInfo.scriptPath;
                s.convertedFcnScriptPath=epFcnInfo.convertedFunctionInterface.convertedFilePath;
                s.convertedSpecializationId=epFcnInfo.convertedFunctionInterface.convertedSpecializationID;

                sanitizedPath=coder.internal.ASCIIConversion.sanitize(epFcnInfo.uniqueFullName());
                this.coderLoggedDataVarInfo(sanitizedPath)=s;
            end
        end



        function handlePlot(this,scriptPath,dName,fcnSplNum,isPrimaryEP,floatVals,fixedVals,sdiRunSuffix,plotsManager)

            [inputFigs,outputFigs]=this.handlePlotsImpl(dName,floatVals,fixedVals,plotsManager,isPrimaryEP,sdiRunSuffix);

            fcnUniqKey=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(scriptPath,dName,fcnSplNum);
            this.plottedFigureHandles(fcnUniqKey)=struct('inputs',inputFigs,'outputs',outputFigs);
        end


        function generatePlotImpl(this,scriptPath,fcnName,fcnSplNum,variableName,exprType)
import coder.internal.lib.StructHelper;

            dNames=this.DesignFunctionNames;
            isPrimaryEP=strcmp(fcnName,dNames{1});
            uniqueFullName=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(scriptPath,fcnName,fcnSplNum);
            [floatVals,fixedVals]=this.fetchFloatFixedLoggedValsNew(uniqueFullName);
            if isempty(floatVals)||isempty(fixedVals)
                return;
            end
            [floatVals,fixedVals]=modifyDataForVariable(floatVals,fixedVals,exprType,variableName);

            plotsManager=coder.internal.PlotsManager();
            [inputFig,outputFig]=this.handlePlotsImpl(fcnName,floatVals,fixedVals,plotsManager,isPrimaryEP);

            if~isKey(this.plottedFigureHandles,uniqueFullName)
                this.plottedFigureHandles(uniqueFullName)=struct('inputs',struct,'outputs',struct);
            end

            fcnInfo=this.plottedFigureHandles(uniqueFullName);
            switch exprType
            case coder.internal.ComparisonPlotService.INPUT_EXPR
                if StructHelper.hasFieldVal(inputFig,variableName)
                    figHndl=StructHelper.getFieldVal(inputFig,variableName);
                    fcnInfo.inputs=StructHelper.setFieldVal(fcnInfo.inputs,variableName,figHndl);
                end
            case coder.internal.ComparisonPlotService.OUTPUT_EXPR
                if StructHelper.hasFieldVal(outputFig,variableName)
                    figHndl=StructHelper.getFieldVal(outputFig,variableName);
                    fcnInfo.outputs=StructHelper.setFieldVal(fcnInfo.outputs,variableName,figHndl);
                end
            end
            this.plottedFigureHandles(uniqueFullName)=fcnInfo;

            function[floatVals,fixedVals]=modifyDataForVariable(floatVals,fixedVals,exprType,variableName)
import coder.internal.lib.StructHelper;




                switch exprType
                case coder.internal.ComparisonPlotService.INPUT_EXPR


                    floatVals.outputs=struct;
                    fixedVals.outputs=struct;


                    tmp=StructHelper.getFieldVal(floatVals.inputs,variableName);
                    if~isempty(tmp)
                        floatVals.inputs=struct;
                        floatVals.inputs=StructHelper.setFieldVal(floatVals.inputs,variableName,tmp);
                    else
                        return;
                    end
                    tmp=StructHelper.getFieldVal(fixedVals.inputs,variableName);
                    if~isempty(tmp)
                        fixedVals.inputs=struct;
                        fixedVals.inputs=StructHelper.setFieldVal(fixedVals.inputs,variableName,tmp);
                    else
                        return;
                    end
                case coder.internal.ComparisonPlotService.OUTPUT_EXPR


                    floatVals.inputs=struct;
                    fixedVals.inputs=struct;


                    tmp=StructHelper.getFieldVal(floatVals.outputs,variableName);
                    if~isempty(tmp)
                        floatVals.outputs=struct;
                        floatVals.outputs=StructHelper.setFieldVal(floatVals.outputs,variableName,tmp);
                    else
                        return;
                    end
                    tmp=StructHelper.getFieldVal(fixedVals.outputs,variableName);
                    if~isempty(tmp)
                        fixedVals.outputs=struct;
                        fixedVals.outputs=StructHelper.setFieldVal(fixedVals.outputs,variableName,tmp);
                    else
                        return;
                    end
                end
            end
        end



        function[floatVals,fixedVals]=cleanFloatFixedLoggedVals(this,fcnUniqueFullName,floatVals,fixedVals)
            assert(2==coder.internal.f2ffeature('MEXLOGGING'));





            if this.isGUIWorkflow
                if isKey(this.coderLoggedDataVarInfo,fcnUniqueFullName)
                    varsSelectedToPlot=this.coderLoggedDataVarInfo(fcnUniqueFullName).origGUIVarsToPlot;
                    idx=cellfun(@(x)contains(x,'.'),varsSelectedToPlot,'UniformOutput',true);
                    structFieldsToPlot=varsSelectedToPlot(idx);
                else
                    structFieldsToPlot={};
                end
            end


            fcnInfo=this.coderLoggedDataVarInfo(fcnUniqueFullName);





            originalInputNames=fcnInfo.originalInputsToLog;
            convertedInputNames=fcnInfo.convertedInputsToLog;
            for ii=1:length(convertedInputNames)
                convInName=convertedInputNames{ii};
                origInName=originalInputNames{ii};

                if isfield(fixedVals.inputs,convInName)
                    tmp=fixedVals.inputs.(convInName);
                    fixedVals.inputs=rmfield(fixedVals.inputs,convInName);
                    fixedVals.inputs.(origInName)=tmp;
                end


                if this.isGUIWorkflow&&isfield(floatVals.inputs,origInName)&&isstruct(floatVals.inputs.(origInName))
                    removeFieldsNoPlots(origInName,'inputs',structFieldsToPlot);
                end
            end

            originalOutputNames=fcnInfo.originalOutputsToLog;
            for ii=1:length(originalOutputNames)
                origOutName=originalOutputNames{ii};

                if this.isGUIWorkflow&&isfield(floatVals.outputs,origOutName)&&isstruct(floatVals.outputs.(origOutName))
                    removeFieldsNoPlots(origOutName,'outputs',structFieldsToPlot);
                end
            end

            floatVals.exprs=[];
            fixedVals.exprs=[];

            this.buildCoderLoggedErrorData(fcnUniqueFullName,floatVals,fixedVals);



            function removeFieldsNoPlots(fieldName,inputOrOutput,structFieldsToPlot)
                [isChanged,newVal]=removeStructFieldValues(fieldName,floatVals.(inputOrOutput).(fieldName),structFieldsToPlot);
                if isChanged
                    floatVals.(inputOrOutput)=rmfield(floatVals.(inputOrOutput),fieldName);


                    if~isempty(newVal)
                        floatVals.(inputOrOutput).(fieldName)=newVal;
                    end
                end

                [isChanged,newVal]=removeStructFieldValues(fieldName,fixedVals.(inputOrOutput).(fieldName),structFieldsToPlot);
                if isChanged
                    fixedVals.(inputOrOutput)=rmfield(fixedVals.(inputOrOutput),fieldName);


                    if~isempty(newVal)
                        fixedVals.(inputOrOutput).(fieldName)=newVal;
                    end
                end
            end





            function[isChanged,out]=removeStructFieldValues(structName,loggedStruct,structFieldsToPlot)
                isChanged=false;
                out=loggedStruct;

                fields=fieldnames(loggedStruct);
                numFields=length(fields);
                if 0==numFields
                    return;
                end

                for jj=1:numFields
                    fld=fields{jj};
                    if isstruct(loggedStruct.(fld))
                        [fldIsChanged,fldOut]=removeStructFieldValues([structName,'.',fld],loggedStruct.(fld),structFieldsToPlot);
                        if fldIsChanged
                            out=rmfield(out,fld);

                            if~isempty(fldOut)
                                out.(fld)=fldOut;
                            end
                        end
                        isChanged=fldIsChanged||isChanged;
                    else


                        fullFieldName=[structName,'.',fld];
                        if~any(strcmp(fullFieldName,structFieldsToPlot))
                            out=rmfield(out,fld);
                            isChanged=true;
                        end
                    end
                end

                if isempty(fieldnames(out))


                    out=[];
                end
            end
        end

        function[floatVals,fixedVals]=fetchFloatFixedLoggedValsNew(this,fcnUniqueFullName)
            floatVals=[];
            fixedVals=[];
            if this.floatToFixedNameMap.isKey(fcnUniqueFullName)
                fixedPointKey=this.floatToFixedNameMap(fcnUniqueFullName);
                if this.coderLoggedFloatingPtData.isKey(fcnUniqueFullName)...
                    &&this.coderLoggedFixedPtData.isKey(fixedPointKey)

                    floatVals=this.coderLoggedFloatingPtData(fcnUniqueFullName);
                    fixedVals=this.coderLoggedFixedPtData(fixedPointKey);
                    floatVals.exprs=[];
                    fixedVals.exprs=[];


                    [floatVals,fixedVals]=this.cleanFloatFixedLoggedVals(fcnUniqueFullName,floatVals,fixedVals);
                end
            end
        end

        function[inputFigs,outputFigs]=handlePlotsImpl(this,dName,floatVals,fixedVals,plotsManager,isPrimaryEP,sdiRunSuffix)
            inputFigs=[];
            outputFigs=[];
            plotFunction=this.fxpCfg.PlotFunction;
            isCLIWorkflow=~this.isGUIWorkflow;
            if~isempty(plotFunction)



                enableSDIOLDPlot=false;
                if 2==coder.internal.f2ffeature('MEXLOGGING')
                    if floatVals.specializationNumber~=internal.mtree.FunctionTypeInfo.DEFAULTSPECIALIZATIONID
                        functionName=[dName,'>',num2str(floatVals.specializationNumber)];
                    else
                        functionName=dName;
                    end
                    [inputFigs,outputFigs]=coder.internal.ComparisonPlotService.customCompareFixedPtAndFloatingPlots(functionName,floatVals,fixedVals,this.fxpCfg.LogIOForComparisonPlotting,plotFunction,enableSDIOLDPlot,@this.getMessageText,this.fxpCfg.DoubleToSingle,isCLIWorkflow);
                else
                    coder.internal.ComparisonPlotService.compareFixedPtAndFloatingPlots(dName,floatVals,fixedVals,this.fxpCfg.LogIOForComparisonPlotting,plotFunction,enableSDIOLDPlot,this);
                end
            elseif this.fxpCfg.EnableSDIPlotting
                selectSignal=isPrimaryEP;
                coder.internal.ComparisonPlotService.plotUsingSDI(dName,floatVals,fixedVals,selectSignal,sdiRunSuffix,this);
            else
                if this.isGUIWorkflow
                    plotFunction=coder.internal.Float2FixedConverter.INBUILT_PLOT_FUNCTION;
                else
                    plotFunction=coder.internal.Float2FixedConverter.INBUILT_PLOT_FUNCTION_CLI;
                end



                enableSDIOLDPlot=false;
                plotsManager.newGroup({'',this.getPlotTitleFixedPointDescription()});
                if 2==coder.internal.f2ffeature('MEXLOGGING')
                    if floatVals.specializationNumber~=internal.mtree.FunctionTypeInfo.DEFAULTSPECIALIZATIONID
                        functionName=[dName,'>',num2str(floatVals.specializationNumber)];
                    else
                        functionName=dName;
                    end
                    [inputFigs,outputFigs]=coder.internal.ComparisonPlotService.customCompareFixedPtAndFloatingPlots(functionName,floatVals,fixedVals,this.fxpCfg.LogIOForComparisonPlotting,plotFunction,enableSDIOLDPlot,@this.getMessageText,this.fxpCfg.DoubleToSingle,isCLIWorkflow);
                else
                    coder.internal.ComparisonPlotService.compareFixedPtAndFloatingPlots(dName,floatVals,fixedVals,this.fxpCfg.LogIOForComparisonPlotting,plotFunction,enableSDIOLDPlot,this);
                end
            end
        end


        function reportPath=printTypeReportBase(this,reportName,showreport,annotations,fcnInfoRegistry,fcnNames,isFixPtReport)
            if nargin<2
                showreport=true;
            end

            reportPath='';


            if~isempty(this.typeProposalSettings)
                fileName=fullfile(this.fxpCfg.OutputFilesDirectory,reportName);

                if(~isempty(annotations))
                    proposedTypesCustomizations=this.addAnnotationsFromPlugin(annotations);
                else

                    proposedTypesCustomizations=this.propagateTypeSpecifications();

                    this.propagateDesignRangeSpecifications();
                end

                if isempty(this.tbFcnInfoRegistryMap)...
                    ||isFixPtReport
                    includeSimCoverage=false;
                else
                    includeSimCoverage=this.fxpCfg.ComputeCodeCoverage;
                end

                if~this.ComputedCodeCoverageInfo
                    includeSimCoverage=false;
                end
                if this.fxpCfg.DoubleToSingle
                    if isempty(this.fxpCfg.TestBenchName)||~this.fxpCfg.ComputeSimulationRanges
                        hasBeenSimulated=false;
                    else
                        hasBeenSimulated=true;
                    end
                else

                    hasBeenSimulated=true;
                end

                reportPath=coder.internal.printFixptReport(fcnNames,this.typeProposalSettings,fcnInfoRegistry,proposedTypesCustomizations,fileName,isFixPtReport,includeSimCoverage,hasBeenSimulated);
                webLink=['<a href="matlab:web(''',reportPath,''', ''-new'')">',reportName,'</a>'];
                if isFixPtReport
                    msgID='Coder:FxpConvDisp:FXPCONVDISP:genFixPtTypeReport';
                else
                    msgID='Coder:FxpConvDisp:FXPCONVDISP:genFixPtTypePropReport';
                end
                disp(sprintf('### %s',this.getMessageText(msgID,strjoin(fcnNames,', '),webLink)));%#ok<*DSPS>
                if showreport&&(~isempty(reportPath))
                    web(reportPath);
                end
            end
        end

        function msgs=validateTBs(this,tbNames)
            msgs=coder.internal.lib.Message().empty();
            dutNames=this.DesignFunctionNames;
            if~isempty(tbNames)
                if ischar(tbNames)
                    tbNames={tbNames};
                end

                cellfun(@(tb)addMessage(coder.internal.MTREEUtils.validateScript(tb,dutNames,0,this.fxpCfg.SupportMLXTestBench)),...
                tbNames);
                if coder.internal.lib.Message.containErrorMsgs(msgs)
                    return;
                end

                cellfun(@(tb)this.tbDepContsMap.add(tb,...
                this.buildDependencyContainerForTB(tb)),...
                tbNames,...
                'UniformOutput',false);
            end

            function addMessage(msg)
                if~isempty(msg)
                    msgs(end+1)=msg;
                end
            end
        end

        function[inputVarDimIndices,outputVarDimIdices]=getVarDimIncides(this,dName)
            inputVarDimIndices=[];
            outputVarDimIdices=[];

            fcnTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfo(dName);
            dif=this.createDIF(dName);
            inVars=dif.inportNames;
            outVars=dif.outportNames;

            for ii=1:length(inVars)
                inVar=inVars{ii};
                varInfo=fcnTypeInfo.getVarInfo(inVar);
                if~isempty(varInfo)&&varInfo.isInputArg...
                    &&isVarDim(varInfo)
                    inputVarDimIndices(end+1)=ii;
                end
            end

            for ii=1:length(outVars)
                outVar=outVars{ii};
                varInfo=fcnTypeInfo.getVarInfo(outVar);
                if~isempty(varInfo)&&varInfo.isOutputArg...
                    &&isVarDim(varInfo)
                    outputVarDimIdices(end+1)=ii;
                end
            end

            function res=isVarDim(varInfo)
                res=any(varInfo.inferred_Type.Size(:)==-1)...
                ||any(varInfo.inferred_Type.SizeDynamic);
            end
        end

        function fixptDesignName=getFixPtDesignName(this,designNameGold)
            coder.internal.Float2FixedConverter.isGoldName(designNameGold);
            ext=this.fxpCfg.FixPtFileNameSuffix;
            fixptDesignName=[designNameGold,ext];
        end

        function fixptTestBenchName=getFixPtTestBenchName(this,tbNameGold)
            coder.internal.Float2FixedConverter.isGoldName(tbNameGold);
            ext=this.fxpCfg.FixPtFileNameSuffix;
            fixptTestBenchName=[tbNameGold,ext];
        end

        function fixPtWrapperName=getFixPtWrapperName(this,designNameGold)
            coder.internal.Float2FixedConverter.isGoldName(designNameGold);
            ext=this.fxpCfg.FixPtFileNameSuffix;
            wrapper_prefix=coder.internal.Float2FixedConverter.getDefaultWrapperSuffix();

            fixPtWrapperName=[designNameGold,wrapper_prefix,ext];
        end



        function tbDepContsMap=getDependencyContainerForTB(this,createContainerAgain)
            if(nargin<=1)
                createContainerAgain=false;
            end
            if(isempty(this.tbDepContsMap)||createContainerAgain)
                oldPath=pwd;
                cd(this.fxpCfg.DesignDirectory)
                tbNames=this.fxpCfg.TestBenchName;
                dName=this.DesignFunctionNames;
                cellfun(@(tb)this.tbDepContsMap.add(tb,...
                this.buildDependencyContainerForTB(tb,dName)),...
                tbNames,...
                'UniformOutput',false);
                cd(oldPath);
            end
            tbDepContsMap=this.tbDepContsMap;
        end



        function tbDepCont=buildDependencyContainerForTB(this,tbName)
            depContOptions=struct('checkFileNameMismatch',false,'checkFncHandles',false);
            [~,tbName,mExt]=fileparts(which(tbName));
            tbDepCont=coder.internal.DependencyContainer(fullfile(this.fxpCfg.DesignDirectory,[tbName,mExt]),this.fxpCfg.DesignDirectory,depContOptions,this.fxpCfg.DoubleToSingle);
        end


        function copyDependentFilesForTBToWorkDir(this,tbDc,mExt)
            for ii=1:length(tbDc.depFuncNames)
                depFunName=tbDc.depFuncNames{ii};
                projectDirFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,[depFunName,mExt]);


                OrigFileWithPath=tbDc.depFunPaths{ii};
                if((2~=exist(projectDirFilePath,'file'))&&(2==exist(OrigFileWithPath,'file')))
                    coder.internal.Helper.fileCopy(OrigFileWithPath,projectDirFilePath);
                end
            end
        end


        function insertHeaders(this,mlFileList)
            proposeTypesMode=this.fxpCfg.ProposeTypesMode;

            if(0<length(mlFileList))
                insertHeadersForFileList(proposeTypesMode,mlFileList);
            end
            function insertHeadersForFileList(proposeTypesMode,mlFileList)
                headerText=strrep(coder.internal.Helper.getHeader(proposeTypesMode),'\n',newline);
                for ii=1:length(mlFileList)
                    fileName=mlFileList{ii};
                    text=fileread(fileName);
                    if(~contains(text,headerText))
                        code=[headerText,text];
                        coder.internal.Helper.writeFile(fileName,code);
                    end
                end
            end
        end


        function runCleanup(this,setupInfo)



            path(setupInfo.pathBak);
            cd(setupInfo.currDir);
            makeGeneratedFilesReadOnly(this);

clear mex;
            coder.internal.Helper.changeBacktraceWarning('reset',setupInfo.warnState);
            fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0);

            function makeGeneratedFilesReadOnly(this)
                mlFileList=dir(fullfile(this.fxpCfg.CodegenWorkDirectory,'*.m'));
                if(0<length(mlFileList))
                    fileattrib(fullfile(this.fxpCfg.CodegenWorkDirectory,'*.m'),'-w');
                end
                try
                    files=what(this.fxpCfg.OutputFilesDirectory);
                    if~isempty(files)
                        for ii=1:length(files.m)
                            mFile=files.m{ii};
                            fileattrib(fullfile(this.fxpCfg.OutputFilesDirectory,mFile),'-w');
                        end
                    end
                catch err
                    if(strcmp(err.identifier,'MATLAB:FILEATTRIB:CannotFindFile'))

                    else
                        rethrow(err);
                    end
                end
            end
        end


        function dif=createDIF(this,fcnName)

            [inportNames,outportNames]=coder.internal.Float2FixedConverter.getFcnInterface(fcnName);

            dif.inportNames=inportNames;
            dif.outportNames=outportNames;
            dif.numIn=length(inportNames);
            dif.numOut=length(outportNames);

            this.dutInterface=dif;
        end


        function checkForShadowedFiles(this,designNames,tbNames)
            numDesigns=numel(designNames);
            numTBs=numel(tbNames);
            filesToCheck=cell(1,2*numDesigns+numTBs);

            for i=1:numDesigns

                [~,dn,~]=fileparts(designNames{i});
                filesToCheck{i*2-1}=this.getFixPtDesignName(dn);
                filesToCheck{i*2}=this.getFixPtWrapperName(dn);
            end

            for i=1:numTBs

                [~,tbn,~]=fileparts(tbNames{i});
                filesToCheck{numDesigns*2+i}=this.getFixPtTestBenchName(tbn);
            end

            for i=1:numel(filesToCheck)
                fname=filesToCheck{i};

                if exist([fname,'.m'],'file')
                    error(message('Coder:FXPCONV:ShadowedFile',fname));
                end
            end
        end


        function checkForFileNameMismatch(this,designPath)

            assert(strcmp(coder.internal.Helper.which(designPath),designPath),...
            'checkForFileNameMismatch requires design path.');

            [~,dName,c]=fileparts(designPath);
            if~strcmp(c,'.m')&&~strcmp(c,'.mlx')
                error(message('Coder:FXPCONV:CantReadFile',designPath));
            end


            mTF=mtree(fileread(designPath));
            subTF=mtfind(mTF,'Kind','FUNCTION');
            if isempty(subTF)
                error(message('Coder:FXPCONV:CantFindFunctionDecl',dName));
            end

            indices=subTF.indices;
            designFcnIndex=indices(1);
            designFcnNode=subTF.select(designFcnIndex);




            this.actualFunctionName=designFcnNode.Fname.string;
            if~strcmp(this.actualFunctionName,dName)
                error(message('Coder:FXPCONV:topFcnNameMismatch',...
                this.actualFunctionName,coder.internal.Helper.getFileLink(dName)));
            end

        end


        function userWrittenFunctions=getUserWrittenFunctions(this,inferenceReport)
            inferenceReportFunctions=inferenceReport.Functions;
            inferenceReportScripts=inferenceReport.Scripts;

            userWrittenFunctions=containers.Map;
            for ii=1:length(inferenceReportFunctions)
                fcnInfo=inferenceReportFunctions(ii);
                fcnName=fcnInfo.FunctionName;

                if(fcnInfo.ScriptID<1)||...
                    (fcnInfo.ScriptID>length(inferenceReportScripts))
                    continue;
                end

                if~inferenceReportScripts(fcnInfo.ScriptID).IsUserVisible


                    continue;
                end

                [p,n,e]=fileparts(inferenceReportScripts(fcnInfo.ScriptID).ScriptPath);
                if strcmp(fullfile(p,[n,e]),this.forcePushEntryPointMFileName)
                    continue;
                end






                userWrittenFunctions(fcnName)=true;
            end
        end
    end

    methods(Access='public')

        function[report,outputSummary]=doFixPtConversion(this)
            try
                if this.DoubleToSingle&&this.fxpCfg.DoNotRunConversionYet




                    this.fxpCfg.DoNotRunConversionYet=false;
                    this.fxpCfg.ConverterInstance=this;
                    outputSummary=[];
                else
                    outputSummary=this.run();
                end

                report=struct;
                report.scripts={};
                report.summary.passed=true;
                report.summary.messageList={};
                report.summary.buildFailed=false;
            catch ex
                if strcmp(ex.identifier,'Coder:FXPCONV:floatingPointSimulationException')
                    rethrow(ex);
                elseif strfind(ex.identifier,'Coder:FXPCONV:')
                    newEx=MException(ex.identifier,'%s',ex.message);
                    throw(newEx);
                else

                    rethrow(ex);
                end
            end
        end
    end


    methods(Access='public')

        function setFimathString(this,fimathStr)
            if~isempty(fimathStr)
                fm=fimathStr;
            else
                fm='hdlfimath';
            end
            this.fxpCfg.fimath=fm;

            if~isempty(this.fcnInfoRegistry)
                if ischar(fm)
                    fm=eval(fm);
                end
                this.fcnInfoRegistry.setFimath(fm);
            end
        end


        function clearSimulationData(this)
            if isempty(this.fcnInfoRegistry)
                return;
            end

            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearSimulationData();
                end
            end
        end


        function clearStaticAnalysisData(this)
            if isempty(this.fcnInfoRegistry)
                return;
            end

            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearStaticAnalysisData();
                end
            end
        end


        function clearAnnotations(this)
            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearAnnotations();
                end
            end
        end

        function addProposedType(this,fcnName,varName,varType)
            fcn=this.fcnInfoRegistry.getFunctionTypeInfo(fcnName);
            varInfos=fcn.getVarInfosByName(varName);
            annotatedType=[];
            if isnumerictype(varType)
                annotatedType=varType;
            else
                try
                    [~,annotatedType]=evalc(varType);
                catch
                    [s,wlen,flen,err]=coder.internal.Float2FixedConverter.getTypeInfoFromStr(varType);
                    if err==0
                        annotatedType=numerictype(s,wlen,flen);
                    else
                        if ischar(varType)
                            switch varType
                            case{'double','single','logical',...
                                'uint8','uint16','uint32','uint64',...
                                'int8','int16','int32','int64'}

                                annotatedType=varType;
                            otherwise
                                disp(message('Coder:FXPCONV:invalidTypeAnnotation',varType,coder.internal.Float2FixedConverter.NUMERICTYPEDOCPAGE).getString());
                            end
                        end
                    end
                end
            end

            if~isempty(annotatedType)
                for ii=1:length(varInfos)
                    var=varInfos{ii};
                    if var.isStruct()||var.isVarInSrcCppSystemObj()
                        prop=coder.internal.Helper.extractPropertyName(varName);
                        var.setStructScalarProp(prop,'proposed_Type',annotatedType);
                    else
                        var.proposed_Type=annotatedType;
                    end
                end
            end
        end


        function addDataFromUI(this,xmlReader)

            if isempty(xmlReader)||isempty(this.fcnInfoRegistry)
                return;
            end

            functionReader=xmlReader.getChild('Function');
            while functionReader.isPresent()
                functionName=functionReader.readAttribute('name').toCharArray';
                specializationName=functionReader.readAttribute('specialization');
                if~isempty(specializationName)
                    specializationName=specializationName.toCharArray';
                else
                    specializationName=functionName;
                end
                uniqueId=specializationName;
                variableReader=functionReader.getChild('Variable');
                functionTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfo(uniqueId);

                while(variableReader.isPresent&&~isempty(functionTypeInfo))
                    variableName=extractVariableName(variableReader);
                    varInfos=functionTypeInfo.getVarInfosByName(variableName);

                    if~isempty(varInfos)
                        varInfo=[];
                        variableContents=coder.internal.lib.Map();

                        fieldReader=variableReader.getChild('Column');
                        while fieldReader.isPresent
                            fieldName=char(fieldReader.readAttribute('property').toCharArray);
                            fieldValue=char(fieldReader.readAttribute('value'));
                            fieldType=char(fieldReader.readAttribute('type'));

                            switch fieldType
                            case 'Double'
                                fieldValue=str2double(fieldValue);
                            case 'Integer'
                                fieldValue=str2num(fieldValue);
                            case 'Boolean'
                                fieldValue=logical(str2num(fieldValue));
                            otherwise

                            end

                            variableContents(fieldName)=fieldValue;
                            fieldReader=fieldReader.next();
                        end

                        variableType=[];
                        designMin=[];
                        designMax=[];
                        var=[];
                        fieldNames=variableContents.keys();
                        for kk=1:length(fieldNames)
                            fieldName=fieldNames{kk};
                            fieldValue=variableContents(fieldName);

                            for ll=1:length(varInfos)
                                var=varInfos{ll};
                                isStruct=var.isStruct||var.isVarInSrcCppSystemObj();
                                if(strcmp(fieldName,'ProposedType'))
                                    variableType=fieldValue;
                                else




                                    varInfo.(fieldName)=fieldValue;


                                    if strcmp(fieldName,'IsInteger')
                                        if isStruct
                                            prop=coder.internal.Helper.extractPropertyName(variableName);
                                            var.setStructScalarProp(prop,'DesignIsInteger',fieldValue);
                                        else
                                            var.DesignIsInteger=fieldValue;
                                        end
                                    elseif(strcmp(fieldName,'RoundMode'))
                                        if isempty(varInfo.RoundMode)
                                            continue;
                                        end
                                        if isStruct
                                            prop=coder.internal.Helper.extractPropertyName(variableName);
                                            [fm,isField]=var.getStructScalarProp(prop,'fimath');



                                            if isField&&~strcmp(fm.RoundingMethod,varInfo.RoundMode)
                                                fm.RoundingMethod=varInfo.RoundMode;
                                                var.setStructScalarProp(prop,'fimath',fm);
                                            end
                                        else
                                            fm=var.getFimath();
                                            if~strcmp(fm.RoundingMethod,varInfo.RoundMode)
                                                fm.RoundingMethod=varInfo.RoundMode;
                                                var.setFimath(fm);
                                            end
                                        end
                                    elseif(strcmp(fieldName,'OverflowMode'))
                                        if isempty(varInfo.OverflowMode)
                                            continue;
                                        end
                                        if isStruct
                                            prop=coder.internal.Helper.extractPropertyName(variableName);
                                            [fm,isField]=var.getStructScalarProp(prop,'fimath');



                                            if isField&&~strcmp(fm.OverflowAction,varInfo.OverflowMode)
                                                fm.OverflowAction=varInfo.OverflowMode;
                                                var.setStructScalarProp(prop,'fimath',fm);
                                            end
                                        else
                                            fm=var.getFimath();
                                            if~strcmp(fm.OverflowAction,varInfo.OverflowMode)
                                                fm.OverflowAction=varInfo.OverflowMode;
                                                var.setFimath(fm);
                                            end
                                        end
                                    elseif any(strcmp({'ProductMode','ProductWordLength','ProductFractionLength',...
                                        'SumMode','SumWordLength','SumFractionLength',...
                                        'CastBeforeSum'},fieldName))
                                        if isempty(varInfo.(fieldName))
                                            continue;
                                        end
                                        if isStruct
                                            prop=coder.internal.Helper.extractPropertyName(variableName);



                                            [fm,isField]=var.getStructScalarProp(prop,'fimath');
                                            if isField&&~strcmp(fm.(fieldName),varInfo.(fieldName))
                                                fm.(fieldName)=varInfo.(fieldName);
                                                var.setStructScalarProp(prop,'fimath',fm);
                                            end
                                        else
                                            fm=var.getFimath();
                                            if~strcmp(fm.(fieldName),varInfo.(fieldName))
                                                fm.(fieldName)=varInfo.(fieldName);
                                                var.setFimath(fm);
                                            end
                                        end
                                    elseif(strcmp(fieldName,'SimMin'))

                                    elseif(strcmp(fieldName,'SimMax'))

                                    elseif(strcmp(fieldName,'DesignMin'))
                                        designMin=str2num(varInfo.DesignMin);
                                        var.DesignMin=designMin;
                                    elseif(strcmp(fieldName,'DesignMax'))
                                        designMax=str2num(varInfo.DesignMax);
                                        var.DesignMax=designMax;
                                    elseif(strcmp(fieldName,'DerivedMin'))

                                    elseif(strcmp(fieldName,'DerivedMax'))

                                    end
                                end
                            end
                        end









                        if(~isempty(variableType))
                            this.addProposedType(specializationName,variableName,variableType);
                        end
                        if~isempty(designMin)&&~isempty(designMax)&&~var.isStruct()&&~var.isVarInSrcCppSystemObj()
                            this.fxpCfg.addDesignRangeSpecification(functionTypeInfo.functionName,variableName,designMin,designMax);
                        end
                    end
                    variableReader=variableReader.next();
                end
                functionReader=functionReader.next();
            end
        end


        function proposedTypesCustomizations=addAnnotationsFromPlugin(this,xmlReader)

            if isempty(xmlReader)
                return;
            end

            this.clearAnnotations();
            this.fxpCfg.clearDesignRangeSpecifications();
            proposedTypesCustomizations=this.loadAnnotationsFromProjectUserData(xmlReader,this.fxpCfg);


            this.coerceIncorrectDerivedRangesToInfs();

            if~isempty(this.fcnInfoRegistry.classMap)
                coder.internal.FcnInfoRegistryBuilder.updateAnnotationsForClassMembers(this.fcnInfoRegistry.classMap);
            end
            this.fcnInfoRegistry.updateAnnotationsForGlobals();
        end

        function TFlat=flattenTypesTable(this,T,prefix,TFlat)
            if nargin==2
                prefix='';
                TFlat=containers.Map();
            end
            entries=fields(T);
            for ii=1:length(entries)
                entryName=entries{ii};
                entryVal=T.(entryName);
                if isstruct(entryVal)
                    this.flattenTypesTable(entryVal,[prefix,entryName,'.'],TFlat);
                else
                    TFlat([prefix,entryName])=entryVal;
                end
            end
        end


        function proposedTypesCustomizations=propagateTypeSpecifications(this)
            proposedTypesCustomizations=containers.Map;

            fcnList=this.fxpCfg.getTypeSpecifiedFunctions();
            for ii=1:length(fcnList)
                functionName=fcnList{ii};
                typeSpecifiedVars=this.fxpCfg.getTypeSpecifiedVars(functionName);

                variableContentsMap=containers.Map();




                functionNameAndIds=strsplit(functionName,',');
                if numel(functionNameAndIds)>1
                    classdefUID=str2num(functionNameAndIds{2});
                    specializationID=str2num(functionNameAndIds{3});
                    functionTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfoByNameAndIDs(...
                    functionNameAndIds{1},classdefUID,specializationID);
                else

                    functionTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfo(functionName);
                end
                for jj=1:length(typeSpecifiedVars)
                    varName=typeSpecifiedVars{jj};
                    variableContent=getVariableContentFor(varName,functionTypeInfo,functionName);
                    if~isempty(variableContent)
                        variableContentsMap(varName)=variableContent;
                    end
                end

                proposedTypesCustomizations(functionName)=variableContentsMap;
            end

            if~isempty(this.fxpCfg.TypesTable)
                fcnInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();

                for ii=1:length(fcnInfos)
                    fcnInfo=fcnInfos{ii};

                    if isfield(this.fxpCfg.TypesTable,fcnInfo.functionName)
                        T=this.fxpCfg.TypesTable.(fcnInfo.functionName);
                    elseif isfield(this.fxpCfg.TypesTable,fcnInfo.specializationName)
                        T=this.fxpCfg.TypesTable.(fcnInfo.specializationName);
                    else

                        continue;
                    end
                    if isempty(T)

                        continue;
                    end

                    assert(isstruct(T));
                    typesTable=this.flattenTypesTable(T);
                    functionName=fcnInfo.functionName;
                    if proposedTypesCustomizations.isKey(functionName)
                        variableContentsMap=proposedTypesCustomizations(functionName);
                    else
                        variableContentsMap=containers.Map();
                    end

                    varNames=typesTable.keys();
                    for jj=1:length(varNames)
                        varName=varNames{jj};
                        egVal=typesTable(varName);

                        varInfos=fcnInfo.getVarInfosByName(varName);
                        assert(~isempty(varInfos));
                        assert(isnumerictype(egVal)||isfi(egVal),'Entries in the type table must be fi or numerictype objects.');

                        if isfi(egVal)
                            NT=numerictype(egVal);
                        else
                            NT=egVal;
                        end
                        ntStr=coder.internal.getNumericTypeStr(NT);

                        typeSpec=coder.FixPtTypeSpec();
                        typeSpec.ProposedType=ntStr;


                        for ll=1:length(varInfos)
                            var=varInfos{ll};
                            variableContent=givenTypeAndVarReturnVariableContent(varName,typeSpec,var);
                        end
                        variableContentsMap(varName)=variableContent;
                    end
                    proposedTypesCustomizations(functionName)=variableContentsMap;
                end
            end

            if~isempty(this.fcnInfoRegistry.classMap)
                coder.internal.FcnInfoRegistryBuilder.updateAnnotationsForClassMembers(this.fcnInfoRegistry.classMap);
            end

            this.fcnInfoRegistry.updateAnnotationsForGlobals();

            function variableContent=getVariableContentFor(varName,functionTypeInfo,functionName)
                variableContent=[];
                if isempty(functionTypeInfo)
                    functionTypeInfos=this.fcnInfoRegistry.getFunctionTypeInfosByName(functionName);
                else
                    functionTypeInfos={functionTypeInfo};
                end

                typeSpec=this.fxpCfg.getTypeSpecification(functionName,varName);
                for xx=1:length(functionTypeInfos)
                    functionTypeInfo=functionTypeInfos{xx};
                    varInfos=functionTypeInfo.getVarInfosByName(varName);
                    if isempty(varInfos)

                        variableContent=[];
                        return;
                    end

                    getVariableContent=false;
                    for kk=1:length(varInfos)
                        var=varInfos{kk};
                        if length(varInfos)==kk
                            getVariableContent=true;
                        end
                        variableContent=givenTypeAndVarReturnVariableContent(varName,typeSpec,var,getVariableContent);
                    end
                end
            end


            function variableContents=givenTypeAndVarReturnVariableContent(varName,typeSpec,var,getVariableContent)
                variableContents=[];
                prop='';
                if var.isStruct()
                    prop=coder.internal.Helper.extractPropertyName(varName);
                end

                if typeSpec.IsIntegerSet
                    val=typeSpec.IsInteger;
                    if var.isStruct()||var.isVarInSrcCppSystemObj()
                        var.setStructScalarProp(prop,'DesignIsInteger',val);
                    else
                        var.DesignIsInteger=val;
                    end
                end

                if typeSpec.ProposedTypeSet
                    addAnnotation(varName,var,typeSpec.ProposedType);
                end

                if typeSpec.RoundingMethodSet
                    val=typeSpec.RoundingMethod;
                    if var.isStruct()||var.isVarInSrcCppSystemObj()
                        fm=var.getStructScalarProp(prop,'fimath');
                    else
                        fm=var.getFimath();
                    end
                    if~strcmp(fm.RoundingMethod,val)
                        fm.RoundingMethod=val;
                        if var.isStruct()||var.isVarInSrcCppSystemObj()
                            var.setStructScalarProp(prop,'fimath',fm);
                        else
                            var.setFimath(fm);
                        end
                    end
                end

                if typeSpec.OverflowActionSet
                    val=typeSpec.OverflowAction;
                    if var.isStruct()||var.isVarInSrcCppSystemObj()
                        fm=var.getStructScalarProp(this,prop,'fimath');
                    else
                        fm=var.getFimath();
                    end
                    if~strcmp(fm.OverflowAction,val)
                        fm.OverflowAction=val;
                        if var.isStruct()||var.isVarInSrcCppSystemObj()
                            var.setStructScalarProp(prop,'fimath',fm);
                        else
                            var.setFimath(fm);
                        end
                    end
                end

                if typeSpec.FimathSet
                    val=typeSpec.fimath;
                    if var.isStruct()||var.isVarInSrcCppSystemObj()
                        fm=var.getStructScalarProp(this,prop,'fimath');
                    else
                        fm=var.getFimath();
                    end
                    if~isequal(fm,val)
                        if var.isStruct()||var.isVarInSrcCppSystemObj()
                            var.setStructScalarProp(prop,'fimath',val);
                        else
                            var.setFimath(val);
                        end
                    end
                end



                if getVariableContent
                    variableContents=containers.Map();
                    if typeSpec.IsIntegerSet
                        variableContents('IsInteger')=typeSpec.IsInteger;
                    end
                    if typeSpec.ProposedTypeSet
                        variableContents('ProposedType')=typeSpec.ProposedType;
                    end
                    if typeSpec.RoundingMethodSet
                        variableContents('RoundMode')=typeSpec.RoundingMethod;
                    end
                    if typeSpec.OverflowActionSet
                        variableContents('OverflowMode')=typeSpec.OverflowAction;
                    end
                    if typeSpec.FimathSet
                        variableContents('Fimath')=typeSpec.fimath;
                    end
                    if this.fxpCfg.hasDesignRangeSpecification(functionName,varName)
                        [designMin,designMax]=this.fxpCfg.getDesignRangeSpecification(functionName,varName);
                        if~isempty(designMin)
                            variableContents('DesignMin')=designMin;
                        end
                        if~isempty(designMax)
                            variableContents('DesignMax')=designMax;
                        end
                    end
                end
            end


            function addAnnotation(varName,varInfos,annotation)
                if isnumerictype(annotation)
                    annotatedType=annotation;
                else
                    try
                        [~,annotatedType]=evalc(annotation);
                    catch
                        [s,wlen,flen,err]=coder.internal.Float2FixedConverter.getTypeInfoFromStr(annotation);
                        annotatedType=numerictype(s,wlen,flen);
                        if err
                            disp(message('Coder:FXPCONV:invalidTypeAnnotation',annotation,coder.internal.Float2FixedConverter.NUMERICTYPEDOCPAGE).getString);
                            return;
                        end
                    end
                end

                for mm=1:length(varInfos)
                    aVarInfo=varInfos(mm);
                    if aVarInfo.isStruct()||aVarInfo.isVarInSrcCppSystemObj()
                        prop=coder.internal.Helper.extractPropertyName(varName);
                        aVarInfo.setStructScalarProp(prop,'userSpecifiedAnnotation',annotatedType);
                    else
                        aVarInfo.userSpecifiedAnnotation=annotatedType;
                    end
                end
            end
        end


        function replacements=getUserFunctionReplacements(this)
            replacements=this.fxpCfg.getFunctionReplacementMap;
        end


        function addFunctionReplacementsFromPlugin(this,xmlReader)
            this.loadFunctionReplacementsFromProject(xmlReader,this.fxpCfg);
        end


        function addUserPath(this,pathName)
            this.fxpCfg.UserFunctionTemplatePath=pathName;
        end
    end

    methods(Access='public')

        function addTestBench(this,newTB)
            [~,tbName,~]=fileparts(newTB);
            tbAlreadyPresent=any(strcmp(this.fxpCfg.TestBenchName,tbName));
            if~tbAlreadyPresent
                this.validateTBs(newTB);
                this.tbDepContsMap.add(tbName,...
                this.buildDependencyContainerForTB(tbName));
                this.fxpCfg.TestBenchName=this.tbDepContsMap.keys;
            end
        end

        function typeProposalSettings=getTypeProposalSettings(this)

            typeProposalSettings.proposeTargetContainerTypes=this.fxpCfg.ProposeTargetContainerTypes;
            typeProposalSettings.defaultWL=this.fxpCfg.DefaultWordLength;
            typeProposalSettings.defaultFL=this.fxpCfg.DefaultFractionLength;
            defSigned=this.fxpCfg.DefaultSignedness;
            switch defSigned
            case coder.FixPtConfig.AutoSignedness
                s=[];
            case coder.FixPtConfig.SignedSignedness
                s=true;
            case coder.FixPtConfig.UnsignedSignedness
                s=false;
            otherwise
                assert(false,'Incorrect default singnedness value');
            end
            typeProposalSettings.defaultSignedness=s;
            typeProposalSettings.optimizeWholeNumber=this.fxpCfg.OptimizeWholeNumber;
            typeProposalSettings.proposeWLForDefFL=this.fxpCfg.ProposeWordLengthsForDefaultFractionLength;
            typeProposalSettings.proposeFLForDefWL=this.fxpCfg.ProposeFractionLengthsForDefaultWordLength;
            typeProposalSettings.safetyMargin=this.fxpCfg.SafetyMargin;

            typeProposalSettings.defaultFimath=eval(this.fxpCfg.fimath);
            typeProposalSettings.codingForHDL=this.fxpCfg.CodingForHDL;
            typeProposalSettings.useSimulationRanges=this.fxpCfg.UseSimulationRanges;
            typeProposalSettings.useDerivedRanges=this.fxpCfg.UseDerivedRanges;
            typeProposalSettings.DoubleToSingle=this.fxpCfg.DoubleToSingle;
            typeProposalSettings.proposeAggregateStructTypes=this.fxpCfg.ProposeAggregateStructureTypes;
            typeProposalSettings.Config=this.fxpCfg;
        end


        function fimathStr=getFimathString(this)
            fimathStr=this.fxpCfg.fimath;
        end


        function outputSummary=run(this)

            dName=this.DesignFunctionNames;
            tbNames=this.fxpCfg.TestBenchName;

            if ischar(tbNames)
                tbNames={tbNames};
            end

            if ischar(dName)
                dName={dName};
            end

            fprintf(1,'===================================================\n');
            cellfun(@(d)fprintf(1,'Design Name: %s\n',coder.internal.Helper.getFileLink(d)),dName);
            if~isempty(tbNames)
                cellfun(@(tb)fprintf(1,'Test Bench Name: %s\n',coder.internal.Helper.getFileLink(tb)),tbNames);
            end
            fprintf(1,'===================================================\n\n');

            needToPause=this.pauseAfterEachWorkFlowStep;


            inferMsgs=this.inferTypes();
            handleF2FMessages(inferMsgs);

            enlableInstrumentation=true;
            [coderReport,f2fCompatibilityMessages]=this.buildDesign(enlableInstrumentation);
            if~this.StateLoaded
                codegenSucess=~isempty(coderReport)&&~isempty(coderReport.summary)&&coderReport.summary.passed;
                if~codegenSucess
                    errMsg=message('Coder:FXPCONV:floatingPointBuildFailed');
                    throw(MException(errMsg.Identifier,errMsg.getString));
                end
                compatibilitySucess=isempty(f2fCompatibilityMessages);
                if~compatibilitySucess
                    for ii=1:length(f2fCompatibilityMessages)
                        compatibleMessage=f2fCompatibilityMessages(ii);
                        disp(compatibleMessage.text);
                    end
                    if this.fxpCfg.DoubleToSingle
                        errMsg=message('Coder:FXPCONV:DesignF2FIncompatible_DTS');
                    else
                        errMsg=message('Coder:FXPCONV:DesignF2FIncompatible');
                    end
                    throw(MException(errMsg.Identifier,errMsg.getString));
                end
            end



            try
                internal.mtree.analysis.ConstAnnotator.run(this.fcnInfoRegistry,true,30);
            catch ex
                if this.fxpCfg.DebugEnabled
                    internal.mtree.utils.errorWithContext(ex,'Constant folding error: ');
                end
            end

            this.ComputedCodeCoverageInfo=false;


            this.propagateDesignRangeSpecifications();



            if~this.fxpCfg.ComputeDerivedRanges&&~this.fxpCfg.ComputeSimulationRanges
                if this.fxpCfg.DoubleToSingle

                else
                    return;
                end
            end

            skipSim=this.fxpCfg.DoubleToSingle&&isempty(this.fxpCfg.TestBenchName);
            if this.fxpCfg.ComputeSimulationRanges&&~skipSim
                [~,simMessages]=this.computeSimulationRanges;
                for ii=1:length(simMessages)
                    simMsg=simMessages(ii);
                    disp(simMsg.text);
                end
                if~isempty(simMessages)
                    errMsg=message('Coder:FXPCONV:SimulationFailureSeeMessages');
                    throw(MException(errMsg.Identifier,errMsg.getString));
                end
            end

            if this.fxpCfg.ComputeDerivedRanges


                [success,derivedMinMaxCompatibilityMessages]=this.computeDerivedRanges;
                if~success
                    for ii=1:length(derivedMinMaxCompatibilityMessages)
                        compatibleMessage=derivedMinMaxCompatibilityMessages(ii);
                        disp(compatibleMessage.text);
                    end
                    errMsg=message('Coder:FXPCONV:DvoIncompatible');
                    throw(MException(errMsg.Identifier,errMsg.getString));
                end
            end

            if(needToPause)
                keyboard;
            end


            [~,~,msgs]=this.proposeTypes();
            msgs=arrayfun(@(msg)msg.toStruct(),msgs);
            if~isempty(msgs)
                handleF2FMessages(msgs);
            end



            this.propagateTypeSpecifications();


            origReport=coderReport;
            [coderReport,outputSummary,~,msgs]=this.generateFixedPointCode();
            outputSummary.data.report=origReport;
            msgs=arrayfun(@(msg)msg.toStruct(),msgs);
            if~isempty(msgs)
                handleF2FTranslationMessages(msgs)
            end

            codegenSucess=~isempty(coderReport)&&isfield(coderReport,'summary')&&~isempty(coderReport.summary)&&coderReport.summary.passed;
            if~codegenSucess
                errMsg=message('Coder:FXPCONV:fixedPointBuildFailed');
                throw(MException(errMsg.Identifier,errMsg.getString));
            end

            launchReport=this.fxpCfg.LaunchNumericTypesReport;
            outputSummary.typeReport=this.printTypeReport(launchReport);
            outputSummary.reports{end+1}=outputSummary.typeReport;

            if(needToPause)
                keyboard;
            end

            if(needToPause)
                keyboard;
            end


            if~isempty(tbNames)&&this.fxpCfg.TestNumerics
                this.constructDefaultCoderEnabledLogList();
                msgs=this.verifyFixedPoint;
                handleF2FMessages(msgs);
            end


            fprintf(1,'\n===================================================\n');

            function handleF2FMessages(msgs)
                warnState=coder.internal.Helper.changeBacktraceWarning('off');
                restoreBackTrace=onCleanup(@()coder.internal.Helper.changeBacktraceWarning('reset',warnState));

                for kk=1:length(msgs)
                    msg=msgs(kk);
                    disp(char);
                    switch msg.type
                    case coder.internal.translator.Phase1.DISP
                        disp(msg.text);
                    case coder.internal.translator.Phase1.WARN
                        msg=message(msg.id,msg.params{:});
                        warning(msg);
                    case coder.internal.translator.Phase1.ERR
                        error(msg.text);
                    end
                end
            end

            function handleF2FTranslationMessages(msgs)
                handleF2FMessages(msgs);
                msg=this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:unsupportedConstructsDuringF2FConv');
                if this.fxpCfg.SuppressErrorMessages
                    disp(msg);
                else
                    if this.fxpCfg.DoubleToSingle
                        mExp=MException('Coder:FXPCONV:suppressedErrors_DTS',msg);
                    else
                        mExp=MException('Coder:FXPCONV:suppressedErrors',msg);
                    end
                    throw(mExp);
                end
            end
        end



        function msgs=inferTypes(this)
            msgs=coder.internal.lib.Message.empty();


            typesUnAvailIndices=cellfun(@(c)isempty(c)&&~iscell(c),this.inputTypes,'UniformOutput',true);
            if isempty(this.inputTypes)||any(typesUnAvailIndices)

                if isempty(this.inputTypes)

                    typesUnAvailIndices=ones(1,length(this.DesignFunctionNames));
                    unAvailTypesDesigns=this.DesignFunctionNames;
                else

                    unAvailTypesDesigns=this.DesignFunctionNames(typesUnAvailIndices);
                end
                if~isempty(this.fxpCfg.TestBenchName)
                    if this.fxpCfg.InferTypesWithLogging

                        this.inputTypeSpecifications={};
                        logInputTypesAndBailOut=true;
                        dontMex=true;
                        isFixptDone=false;
                        [exInputs,~]=cellfun(@(d)this.runTestBenchToLogData(this.fxpCfg.DesignDirectory,d,this.fxpCfg.TestBenchName,logInputTypesAndBailOut,dontMex,isFixptDone),unAvailTypesDesigns,'UniformOutput',false);
                        this.inputTypeSpecifications(typesUnAvailIndices)=exInputs;




                        this.coderConstIndices=cell(1,length(this.DesignFunctionNames));
                        resetWorkDir(this.fxpCfg.CodegenWorkDirectory);
                    else
                        [ipTypes,inferMsgs]=inferTypesImpl(unAvailTypesDesigns);
                        assert(sum(typesUnAvailIndices)==length(ipTypes));
                        count=0;
                        for ii=1:length(typesUnAvailIndices)
                            if typesUnAvailIndices(ii)
                                count=count+1;
                                this.inputTypes(ii)=ipTypes(count);
                            end
                        end
                        assert(count==length(ipTypes));
                        msgs=[msgs,inferMsgs];
                    end
                else


                    for ii=1:length(unAvailTypesDesigns)
                        this.inputTypes{ii}={};
                    end
                end
            end

            this.updateInputTypeSpecificationsFromInputTypes();


            function[inputTypes,inferMsgs]=inferTypesImpl(dNames)
                tbNames=this.fxpCfg.TestBenchName;
                tbName=tbNames{1};
                disp(message('Coder:FxpConvDisp:FXPCONVDISP:InferringTypes',strjoin(dNames,', '),tbName).getString());
                [inputTypes,inferMsgs]=usingCoderArgTypes(tbName,dNames);

                function[iptypes,warnMsgs]=usingCoderArgTypes(tbName,dNames)
                    warnMsgs=coder.internal.lib.Message().empty();


                    [~,result]=evalc('coder.internal.getArgTypes(tbName, dNames, ''uniform'', true)');
                    for kk=1:length(dNames)
                        dn=dNames{kk};
                        dif=this.createDIF(dn);
                        ipType=result.(dn);
                        if isempty(ipType)&&dif.numIn>0
                            msg=coder.internal.lib.Message();
                            msg.type=coder.internal.lib.Message.WARN;
                            msg.id='Coder:FXPCONV:InputTypesNotinferred';
                            msg.params={dn,tbName,tbName};
                            msg.text=message(msg.id,msg.params{:}).getString();
                            warnMsgs(end+1)=msg;
                        end
                        iptypes{kk}=ipType;
                    end
                end
            end

            function resetWorkDir(workingDir)
clear mex;
                [~,~,~]=rmdir(workingDir,'s');
                [~,~,~]=mkdir(workingDir);
            end
        end






        function updateInputTypeSpecificationsFromInputTypes(this)
            if isempty(this.inputTypeSpecifications)
                this.inputTypeSpecifications=cell(size(this.inputTypes));
                this.coderConstIndices=cell(size(this.inputTypes));
                for ii=1:length(this.inputTypes)
                    [this.inputTypeSpecifications{ii},this.coderConstIndices{ii}]=coder.internal.Float2FixedConverter.convertTypesToExArgs(this.inputTypes{ii});
                end
            end

            this.fxpCfg.InputArgs=this.inputTypeSpecifications;
        end

        function m=message(this,msgId,varargin)
            if this.fxpCfg.DoubleToSingle
                switch msgId
                case{'Coder:FxpConvDisp:FXPCONVDISP:step1Header',...
                    'Coder:FxpConvDisp:FXPCONVDISP:step1aHeader',...
                    'Coder:FxpConvDisp:FXPCONVDISP:beginFPSimInstrumentedHeader',...
                    'Coder:FxpConvDisp:FXPCONVDISP:beginFPSimHeader',...
                    'Coder:FxpConvDisp:FXPCONVDISP:FPSimDuration',...
                    'Coder:FxpConvDisp:FXPCONVDISP:step2Header',...
                    'Coder:FxpConvDisp:FXPCONVDISP:step3Header',...
                    'Coder:FxpConvDisp:FXPCONVDISP:unsupportedConstructsDuringF2FConv',...
                    'Coder:FxpConvDisp:FXPCONVDISP:genFixPtMLCode',...
                    'Coder:FxpConvDisp:FXPCONVDISP:genFixPtWrapper',...
                    'Coder:FxpConvDisp:FXPCONVDISP:step4Header',...
                    'Coder:FxpConvDisp:FXPCONVDISP:beginFixPtSim',...
                    'Coder:FxpConvDisp:FXPCONVDISP:elapsedFixPtSimTime',...
                    'Coder:FxpConvDisp:FXPCONVDISP:WritingLogMessageFailed',...
                    'Coder:FxpConvDisp:FXPCONVDISP:Float2FixedConversionLog',...
                    'Coder:FxpConvDisp:FXPCONVDISP:beginFixptErrAnalysis',...
                    'Coder:FxpConvDisp:FXPCONVDISP:errF2FValues',...
                    'Coder:FxpConvDisp:FXPCONVDISP:notFoundInFPSimResults',...
                    'Coder:FxpConvDisp:FXPCONVDISP:notFoundInFixptSimResults',...
                    'Coder:FxpConvDisp:FXPCONVDISP:mismatch4FixPtAndFloatingPt',...
                    'Coder:FxpConvDisp:FXPCONVDISP:loggedValsUnequalLength',...
'Coder:FxpConvDisp:FXPCONVDISP:genFixPtTypeReport'...
                    }
                    msgId=[msgId,'_DTS'];
                end
            end
            m=message(msgId,varargin{:});
        end





        function[coderReport,f2fCompatibilityMessages,callerCalleeList]=buildDesign(this,~)
            if this.fxpCfg.IncrementalConversion
                if this.loadConverterState()


                    coderReport=[];
                    f2fCompatibilityMessages=[];
                    callerCalleeList=[];
                    disp(sprintf('\n============= %s ==============\n',this.message('Coder:FxpConvDisp:FXPCONVDISP:step1Header').getString));
                    disp('Incremental conversion: Loaded cached information');
                    return;
                end
            end


            f2fCompatibilityMessages=[];
            callerCalleeList={};
            dName=this.DesignFunctionNames;

            function setupInfo=doSetup(workingDir)
                setupInfo.currDir=pwd;
                setupInfo.pathBak=path;
                setupInfo.projectDir=workingDir;
clear mex;
                [~,~,~]=rmdir(workingDir,'s');
                [~,~,~]=mkdir(workingDir);
                addpath(workingDir);

                setupInfo.warnState=coder.internal.Helper.changeBacktraceWarning('off');
            end
            setupInfo=doSetup(this.fxpCfg.CodegenWorkDirectory);
            cleanup=onCleanup(@()this.runCleanup(setupInfo));

            disp(sprintf('\n============= %s ==============\n',this.message('Coder:FxpConvDisp:FXPCONVDISP:step1Header').getString));
            coder.internal.Helper.checkPathForToolboxPath(this.fxpCfg.OutputFilesDirectory);

            [coderReport,this.floatMexFileName,exprMappingInfo]=mexDesignToGenerateInferenceInfo(dName);

            if(isfield(coderReport,'internal')&&isa(coderReport.internal,'MException'))
                throw(coderReport.internal);
            end

            if~coderReport.summary.passed

                return
            end



            this.InstrLoggedFloatVars=exprMappingInfo;

            userWrittenFunctions=getUserWrittenFunctions(this,coderReport.inference);

            logs=getLocationInformation();
            if this.StateLoaded


                inferenceBldrMsgs=[];

                this.StateLoaded=false;
            else
                this.fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;

                this.fcnInfoRegistry.setFimath(eval(this.fxpCfg.fimath));
                [inferenceBldrMsgs,this.designExprInfoMap]=coder.internal.FcnInfoRegistryBuilder.populateFcnInfoRegistryFromInferenceInfo(coderReport.inference...
                ,this.DesignFunctionNames...
                ,userWrittenFunctions...
                ,this.fcnInfoRegistry...
                ,this.floatGlobalTypes...
                ,this.fxpCfg.DebugEnabled...
                ,logs);
            end
            f2fCompatibilityMessages=[inferenceBldrMsgs,f2fCompatibilityMessages];
            callerCalleeList=coder.internal.Float2FixedConverter.BuildCallerCalleeTripes(this.fcnInfoRegistry);

            if isempty(this.fcnInfoRegistry.registry)
                assert(false,'No functions detected for conversion.');
            end

            buildFloatGlobalTypesFromWorkspace();
            removeUnusedGlobalTypes();




            globalsSupported=~(this.isGUIWorkflow&&strcmp(this.fxpCfg.ProposeTypesMode,coder.FixPtConfig.MODE_HDL));
            constrainerDriver=coder.internal.Float2FixedConstrainerDriver(this.fcnInfoRegistry,this.DesignFunctionNames);
            constrainerDriver.setFillCompiledMxInfo(true);
            constrainerDriver.setCompiledExprInfoMap(this.designExprInfoMap);
            [constrainerMessages]=constrainerDriver.constrain(globalsSupported,this.fxpCfg.DoubleToSingle);

            runDMMChecks=false;
            [compatible,fcnInfoCheckMsgs]=this.checkIfDesignIsF2FCompatible(runDMMChecks);
            f2fCompatibilityMessages=[constrainerMessages,fcnInfoCheckMsgs,f2fCompatibilityMessages];

            compatible=compatible&&~coder.internal.lib.Message.containErrorMsgs(f2fCompatibilityMessages);
            if~compatible
                return;
            end


            function[coderReport,mexFileName,exprMappingInfo]=mexDesignToGenerateInferenceInfo(dNames)
                exprMappingInfo=[];

                this.FlattenedReport=[];

                primaryEP=dNames{1};
                mexFileName=[primaryEP,'_float_mex'];
                exInputs=this.inputTypeSpecifications;
                mexOutputFile=fullfile(this.fxpCfg.OutputFilesDirectory,mexFileName);
                mexFilesOutputDir=fullfile(this.fxpCfg.CodegenWorkDirectory,primaryEP);
                isHistogramLoggingEnabled=this.fxpCfg.HistogramLogging;

                fCtrl=coder.internal.FeatureControl;





                fCtrl.EnableCodeCoverage=this.fxpCfg.ComputeCodeCoverage;
                fCtrl.ForceHomogeneousMajorityForEntryPoints=false;

                options={};
                if isHistogramLoggingEnabled
                    options{end+1}='-histogram';
                end
                if this.UseCoderForCodegen
                    options{end+1}='-coder';
                    cfg=this.fxpCfg.F2FMexConfig;
                    cfg.ConstantInputs='Remove';
                else
                    cfg=coder.mexconfig;
                end


                cfg.EnableRuntimeRecursion=false;




                fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',1);

                designsArgsList=cell(1,3*length(dNames));
                for ii=1:length(dNames)
                    designsArgsList{(ii-1)*3+1}=dNames{ii};
                    designsArgsList{(ii-1)*3+2}='-args';
                    designsArgsList{(ii-1)*3+3}=exInputs{ii};
                end
                if 2==coder.internal.f2ffeature('MEXLOGGING')

                    designsArgsList{end+1}=coder.internal.LoggerService.LOGSTMTS_ENTRY_POINT;
                    designsArgsList{end+1}='-args';
                    designsArgsList{end+1}=coder.internal.LoggerService.LOGSTMTS_ENTRY_POINT_EXAMPLE_INPUTS;


                    designsArgsList{end+1}=coder.internal.LoggerService.FETCH_CODER_LOGGER_ENTRY_POINT;
                    designsArgsList{end+1}='-args';
                    designsArgsList{end+1}=coder.internal.LoggerService.FETCH_CODER_LOGGER_ENTRY_POINT_EXAMPLE_INPUTS;%#ok<NASGU>

                    cppcfg=internal.float2fixed.F2FConfig;
                    cppcfg.F2FEnabled=true;
                    cppcfg.ApplyTypeAnnotations=false;
                    cppcfg.TransformOperators=false;
                    cppcfg.LogFunctionExpressions=true;
                    cppcfg.LogFunctionInputsAndOutputs=false;
                    cfg.F2FConfig=cppcfg;
                end

                options=[options,{'-feature',fCtrl,'-config',cfg,'-o',mexOutputFile,'-d',mexFilesOutputDir}];
                if~isempty(this.floatGlobalTypes)
                    options=[options,{'-globals',coder.internal.Helper.getGlobalCodegenArgs(this.floatGlobalTypes)}];%#ok<NASGU>
                end
                [outTxt,coderReport]=evalc('coder.internal.cachedCodegen(@fixed.internal.buildInstrumentedMex, options{:}, designsArgsList{:}, this.forcePushEntryPointMFileName)');
                if isfield(coderReport,'summary')
                    disp(outTxt);
                end
                fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0);

clear mex;
                if isfield(coderReport,'inference')
                    this.FlattenedReport=emlcprivate('flattenInferenceReportForJava',coderReport.inference);
                else
                    this.FlattenedReport=[];
                end

                if 2==coder.internal.f2ffeature('MEXLOGGING')&&...
                    isfield(coderReport,'summary')&&...
                    coderReport.summary.passed

                    exprMappingInfo=coder.internal.Helper.fevalInPath(@()custom_logger_lib('get_all_loggable_expr_info',mexFileName)...
                    ,this.fxpCfg.OutputFilesDirectory);
                end
            end


            function logs=getLocationInformation()







                [~,entryPoint,~]=fileparts(this.forcePushEntryPointMFileName);
                addpath(this.fxpCfg.OutputFilesDirectory);
                feval(this.floatMexFileName,entryPoint);
                rmpath(this.fxpCfg.OutputFilesDirectory);
                logs=fixed.internal.pullLog(this.floatMexFileName);
clear mex;
            end




            function removeUnusedGlobalTypes()
                nonRelevantGlbIndices=[];
                for ii=1:length(this.floatGlobalTypes)
                    glbName=this.floatGlobalTypes{ii}.Name;
                    if~this.fcnInfoRegistry.globalVarMap.isKey(glbName)
                        nonRelevantGlbIndices(end+1)=ii;
                        continue;
                    end
                end
                this.floatGlobalTypes(nonRelevantGlbIndices)=[];
                assert(length(this.floatGlobalTypes)==length(this.fcnInfoRegistry.getGlobalVars));
            end






            function buildFloatGlobalTypesFromWorkspace()
                glbNames=this.fcnInfoRegistry.getGlobalVars;








                typesAvailSet=cell(1,length(this.floatGlobalTypes));
                for ll=1:length(this.floatGlobalTypes)
                    typ=this.floatGlobalTypes{ll};
                    assert(~isempty(typ));
                    typesAvailSet{ll}=typ.Name;
                    if isempty(typ.InitialValue)
                        glbVal=coder.internal.Helper.getGlobalValueHelper(typ.Name);
                        typ.InitialValue=glbVal;


                        this.floatGlobalTypes{ll}=typ;
                    end
                end


                typesNotAvailSet=setdiff(glbNames,typesAvailSet);
                for ll=1:length(typesNotAvailSet)
                    glbName=typesNotAvailSet{ll};
                    glbVal=coder.internal.Helper.getGlobalValueHelper(glbName);
                    tp=emlcprivate('example2type'...
                    ,glbVal...
                    ,glbName);
                    tp.Name=glbName;
                    tp.InitialValue=glbVal;
                    this.floatGlobalTypes{end+1}=tp;
                end
            end
        end

        function flatReport=getInferenceForGUI(this)
            flatReport=this.FlattenedReport;
        end



        function resetSimulationAndDerivedInfo(this)
            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.DerivedMin=[];
                    var.DerivedMax=[];
                    var.DerivedMinMaxComputed=[];
                    var.SimMin=[];
                    var.SimMax=[];
                    var.IsAlwaysInteger=false;
                end
            end
        end


        function annotateMTreeWithCoverageInfo(this,coverageInfo)
            fcnInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            scriptFcnMap=containers.Map();
            success=true;
            for ii=1:length(fcnInfos)
                fcnInfo=fcnInfos{ii};
                if scriptFcnMap.isKey(fcnInfo.scriptPath)
                    v=scriptFcnMap(fcnInfo.scriptPath);
                else
                    v={};
                end
                v{end+1}=fcnInfo;
                scriptFcnMap(fcnInfo.scriptPath)=v;
            end

            for ii=1:length(coverageInfo)
                try
                    fid=coder.internal.safefopen(coverageInfo(ii).Path);
                    if fid==-1
                        continue;
                    end
                    code=fread(fid,'*char')';
                    fclose(fid);
                    code=strrep(code,char(13),'');
                    pst=coder.internal.MatlabPST(code,coverageInfo(ii).Path);

                    if~scriptFcnMap.isKey(coverageInfo(ii).Path)
                        continue;
                    end
                    fcnInfos=scriptFcnMap(coverageInfo(ii).Path);
                    for jj=1:length(fcnInfos)
                        fcnInfo=fcnInfos{jj};

                        annotateBasicBlocks(ii);
                        annotateFunctions(ii);
                        annotateIfs(ii);
                        annotateFors(ii);
                        annotateWhiles(ii);
                        annotateSwitches(ii);
                    end

                catch ex %#ok<NASGU>
                    success=false;

                end
            end

            if~isempty(this.tbFcnInfoRegistryMap)&&this.fxpCfg.ComputeCodeCoverage
                addedCfolds={};
                fcnInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos;
                for ii=1:length(fcnInfos)
                    functionId=fcnInfos{ii}.uniqueId;
                    fcnTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfo(functionId);
                    mtreeAttributes=fcnTypeInfo.treeAttributes;

                    prePass=coder.internal.translator.PrePass(this.fcnInfoRegistry,fcnTypeInfo.tree,mtreeAttributes,fcnTypeInfo);
                    newCfolds=prePass.run();

                    if~isempty(newCfolds)
                        addedCfolds={addedCfolds{1:end},newCfolds{1:end}};
                    end
                end

                checkRecursiveConstantFolding(addedCfolds);
            end

            function checkRecursiveConstantFolding(CFoldedTypeInfos)
                if isempty(CFoldedTypeInfos)
                    return
                end

                for i=1:length(CFoldedTypeInfos)
                    fInfo=CFoldedTypeInfos{i};
                    node=fInfo.tree.Body;
                    callSites=fInfo.callSites;

                    additionalCFolds=recursiveConstantFoldingHelper(node,callSites);
                end

                checkRecursiveConstantFolding(additionalCFolds);
            end

            function newCFolds=recursiveConstantFoldingHelper(node,callSites)
                newCFolds={};
                if isempty(node)
                    return
                end

                switch node.kind
                case 'EXPR'
                    tree=Tree(node);
                case 'IF'
                    tree=[];
                    newCFolds=recursiveConstantFoldingHelper(node.Arg,callSites);
                case{'IFHEAD','ELSEIF','ELSE','WHILE','SPMD','SWITCH'}
                    tree=Tree(node.Left);
                case{'FOR','PARFOR'}
                    tree=Tree(node.Vector);
                case 'TRY'
                    tree=[];
                    newCFolds=recursiveConstantFoldingHelper(node.Try,callSites);
                case{'RETURN','CONTINUE','BREAK'}
                    return
                otherwise
                    tree=[];
                end

                if~isempty(tree)
                    for i=1:length(callSites)
                        callNode=callSites{i}{1};
                        callFcn=callSites{i}{2};

                        if callNode.ismember(tree)
                            if callFcn.isDead
                                callFcn.isDead=false;
                                callFcn.isConstantFolded=true;
                                newCFolds={newCFolds{1:end},callFcn};
                            else
                                root=node.root;
                                while~isempty(root)&&~strcmp(root.kind,'FUNCTION')
                                    root=root.Next;
                                end
                                if isempty(root)
                                    FcnName='FUNCTION NOT FOUND';
                                else
                                    FcnName=root.Fname.string;
                                end

                                disp(['F2F WARNING: live function ',callFcn.functionName,' called from constant folded function ',FcnName]);
                            end
                        end
                    end
                end

                nextCFolds=recursiveConstantFoldingHelper(node.Next,callSites);
                newCFolds={newCFolds{1:end},nextCFolds{1:end}};
            end

            function annotateBasicBlocks(index)
                basicBlockConstraint1=length(coverageInfo(index).BasicBlockInfos)==length(pst.BasicBlocks);
                if~basicBlockConstraint1

                    assert(basicBlockConstraint1);
                end
                for i=1:length(coverageInfo(index).BasicBlockInfos)
                    basicBlockConstraint2=match(pst.BasicBlocks(i),coverageInfo(index).BasicBlockInfos(i));
                    if~basicBlockConstraint2

                        assert(basicBlockConstraint2);
                    end
                    node=pst.BasicBlocks(i).basicBlockStart;
                    basicBlockEnd=pst.BasicBlocks(i).basicBlockEnd;



                    fcnInfo.treeAttributes(node).FormattedCode=pst.BasicBlocks(i).code;

                    while true
                        hits=coverageInfo(index).BasicBlockInfos(i).Hits;
                        fcnInfo.treeAttributes(node).SimulationHitCount=hits;
                        fcnInfo.treeAttributes(node).HitOrCallCount=hits;

                        if hits>0
                            fcnInfo.treeAttributes(node).isExecutedInSimulation=true;
                        end

                        if node==basicBlockEnd
                            if~fcnInfo.treeAttributes(node).isExecutedInSimulation
                                fcnInfo.treeAttributes(pst.BasicBlocks(i).basicBlockStart).isDeadCodeStart=true;
                                fcnInfo.treeAttributes(node).isDeadCodeEnd=true;
                            end

                            break;
                        end
                        node=node.Next;
                    end
                end

                function r=match(pstBB,cppBB)


                    if pstBB.charEndIdx<(cppBB.charStartIdx+1)||...
                        pstBB.charStartIdx>(cppBB.charEndIdx+1)
                        r=false;
                    else
                        r=true;
                    end
                end
            end

            function annotateFunctions(index)
                for i=1:length(coverageInfo(index).FcnInfos)
                    node=pst.Fcns(i).node;

                    hits=coverageInfo(index).FcnInfos(i).Calls;
                    fcnInfo.treeAttributes(node).HitOrCallCount=hits;

                    if hits>0
                        fcnInfo.treeAttributes(node).isExecutedInSimulation=true;
                    elseif strcmp(fcnInfo.functionName,node.Fname.string)
                        fcnInfo.isDead=true;
                    end
                end
            end

            function annotateIfs(index)
                for i=1:length(coverageInfo(index).IfInfos)
                    node=pst.Ifs(i).node;
                    ifCode=pst.Ifs(i).code;

                    hits=coverageInfo(index).IfInfos(i).TrueCount;
                    fcnInfo.treeAttributes(node).HitOrCallCount=hits;

                    if hits>0
                        fcnInfo.treeAttributes(node).isExecutedInSimulation=true;
                    end

                    if(~isempty(node.Next))&&(strcmp(node.Next.kind,'ELSE'))
                        elseIdx=pst.Ifs(i).charElseStartIdx-pst.Ifs(i).charStartIdx+1;
                        fcnInfo.treeAttributes(node.Next).HitOrCallCount=coverageInfo(index).IfInfos(i).FalseCount;
                        fcnInfo.treeAttributes(node.Next).FormattedCode=ifCode(elseIdx:end);
                    end

                    fcnInfo.treeAttributes(node).FormattedCode=ifCode;
                end
            end

            function annotateFors(index)
                for i=1:length(coverageInfo(index).ForInfos)
                    node=pst.Fors(i).node;
                    forCode=pst.Fors(i).code;

                    hits=coverageInfo(index).ForInfos(i).EntryCount;
                    fcnInfo.treeAttributes(node).HitOrCallCount=hits;
                    fcnInfo.treeAttributes(node).FormattedCode=forCode;

                    if hits>0
                        fcnInfo.treeAttributes(node).isExecutedInSimulation=true;
                    end
                end
            end

            function annotateWhiles(index)
                for i=1:length(coverageInfo(index).WhileInfos)
                    node=pst.Whiles(i).node;
                    whileCode=pst.Whiles(i).code;

                    hits=coverageInfo(index).WhileInfos(i).HitCount;
                    fcnInfo.treeAttributes(node).HitOrCallCount=hits;
                    fcnInfo.treeAttributes(node).FormattedCode=whileCode;

                    if hits>0
                        fcnInfo.treeAttributes(node).isExecutedInSimulation=true;
                    end
                end
            end

            function annotateSwitches(index)
                for i=1:length(coverageInfo(index).SwitchInfos)
                    switchNode=pst.Switches(i).node;
                    switchCode=pst.Switches(i).code;

                    hitSum=0;
                    for j=1:length(coverageInfo(index).SwitchInfos(i).cases)
                        node=pst.Switches(i).cases(j).node;


                        if~isempty(node)
                            caseCode=pst.Switches(i).cases(j).code;

                            hits=coverageInfo(index).SwitchInfos(i).cases(j).HitCount;
                            fcnInfo.treeAttributes(node).HitOrCallCount=hits;
                            hitSum=hitSum+hits;

                            fcnInfo.treeAttributes(node).FormattedCode=caseCode;

                            if hits>0
                                fcnInfo.treeAttributes(node).isExecutedInSimulation=true;
                            end
                        end
                    end

                    if hitSum>0
                        fcnInfo.treeAttributes(switchNode).isExecutedInSimulation=true;
                    end

                    fcnInfo.treeAttributes(switchNode).HitOrCallCount=hitSum;
                    fcnInfo.treeAttributes(switchNode).FormattedCode=switchCode;
                end
            end

            if success
                this.ComputedCodeCoverageInfo=true;
            else
                if this.fxpCfg.DebugEnabled
                    disp(['### ',message('Coder:FxpConvDisp:FXPCONVDISP:MtreeAnnotationFailed').getString()]);
                end
            end
        end





        function[coverageInfo,msgs]=computeSimulationRanges(this,tbNames,enableInstrumentation)
            coverageInfo=[];

            assert(~isempty(this.fcnInfoRegistry),'Build Design must be called first');
            if nargin<2
                tbNames=this.fxpCfg.TestBenchName;
            end
            if nargin<3
                enableInstrumentation=true;
            end
            tRunSim=tic;
            if ischar(tbNames)
                tbNames={tbNames};
            end

            disp(sprintf('\n============= %s ==============\n',this.message('Coder:FxpConvDisp:FXPCONVDISP:step1aHeader').getString));

            if isempty(tbNames)||(iscell(tbNames)&&isempty(tbNames{1}))
                error(message('Coder:FXPCONV:TbMissing'));
            end

            msgs=this.validateTBs(tbNames);
            if~isempty(msgs)
                return;
            end

            coder.internal.Helper.checkPathForToolboxPath(this.fxpCfg.OutputFilesDirectory);

            bLogIOForComparisionPlotting=false;
            coverageInfo=runFloatingPointSimulation(this,tbNames,enableInstrumentation,bLogIOForComparisionPlotting);
            coverageInfo=coder.internal.patchCoverageInfo(coverageInfo);
            this.annotateMTreeWithCoverageInfo(coverageInfo);


            this.coerceIncorrectDerivedRangesToInfs();

            disp(sprintf('### %s: %18.4f %s'...
            ,message('Coder:FxpConvDisp:FXPCONVDISP:elapsedTime').getString...
            ,toc(tRunSim)...
            ,message('Coder:FxpConvDisp:FXPCONVDISP:sec').getString));
        end




        function coverageInfo=runFloatingPointSimulation(this,tbNames,enableInstrumentation,bLogIOForComparisonPlotting,plotsManager)
            if nargin<5||isempty(plotsManager)
                plotsManager=coder.internal.PlotsManager();
            end

            plotsManager.newGroup({'Testbench:','float'});

            if this.StateLoaded&&~this.isGUIWorkflow

                coverageInfo=[];
                fprintf('Incremental conversion: Skipping floating point verification.\n\n');
                return;
            end

            if nargin<2
                tbNames=this.fxpCfg.TestBenchName;
            end
            dNames=this.DesignFunctionNames;

            disp(sprintf('### %s ''%s''',message('Coder:FxpConvDisp:FXPCONVDISP:analyzeDesignStatus').getString,strjoin(dNames,', ')));
            disp(sprintf('### %s ''%s''',message('Coder:FxpConvDisp:FXPCONVDISP:analyzeTbStatus').getString,strjoin(tbNames,', ')));

            [setupInfo,postBuildSetup]=doSetup(this.fxpCfg.CodegenWorkDirectory,this.fxpCfg.OutputFilesDirectory);
            cleanup=onCleanup(@()this.runCleanup(setupInfo));

            pEP=dNames{1};
            mexFileName=[pEP,'_float_mex'];
            postBuildSetup([mexFileName,'.',mexext]);

            if enableInstrumentation
                disp(sprintf('### %s',this.message('Coder:FxpConvDisp:FXPCONVDISP:beginFPSimInstrumentedHeader').getString));
            else
                disp(sprintf('### %s',this.message('Coder:FxpConvDisp:FXPCONVDISP:beginFPSimHeader').getString));
            end

            if this.fxpCfg.ComputeCodeCoverage
                covrtEnableCoverageLogging(true);
                disableCoverage=onCleanup(@()covrtEnableCoverageLogging(false));
            end

            isMexInDesignPath=false;
            isEntryPointCompiled=true;
            tbExecCfg=coder.internal.TestBenchExecConfig(isMexInDesignPath,isEntryPointCompiled);
            tbExecCfg.setSuppressOutput(true);

            if bLogIOForComparisonPlotting
                setupDataLogging(tbExecCfg,mexFileName,dNames,this.fxpCfg.CodegenWorkDirectory);
            end

            inputArgNames=cellfun(@(d)this.createDIF(d).inportNames,dNames,'UniformOutput',false);
            tRunSim=tic;
            for ii=1:length(tbNames)
                tb=tbNames{ii};


                runSimFcn=@runSimulation;
                if enableInstrumentation
                    runSimFcn=withInstrumentation(runSimFcn,inputArgNames,this.coderConstIndices);
                end

                outDirForEvalTBSim=this.fxpCfg.DesignDirectory;
                runSimFcn=withScopeProtection(runSimFcn,outDirForEvalTBSim);

                runSimFcn(tbExecCfg,tb,dNames,mexFileName);
            end

            if bLogIOForComparisonPlotting
                collectLoggedData(mexFileName,dNames);
            end

            coverageInfo=[];
            if this.fxpCfg.ComputeCodeCoverage
                project=coder.internal.Project;
                props=project.getMexFcnProperties(which(mexFileName));
                coverageInfo=props.CoverageInfo;
            end

            disp(sprintf('### %s %8.4f %s'...
            ,this.message('Coder:FxpConvDisp:FXPCONVDISP:FPSimDuration').getString...
            ,toc(tRunSim)...
            ,message('Coder:FxpConvDisp:FXPCONVDISP:sec').getString));

            if this.fxpCfg.IncrementalConversion
                this.saveConverterState();
            end



            function[setupInfo,postBuildSetup]=doSetup(workingDir,outputDir)
                setupInfo.currDir=pwd;
                setupInfo.pathBak=path;
                setupInfo.projectDir=workingDir;
clear mex;
                [~,~,~]=rmdir(workingDir,'s');
                [~,~,~]=mkdir(workingDir);
                addpath(workingDir);
                setupInfo.warnState=coder.internal.Helper.changeBacktraceWarning('off');

                postBuildSetup=@copyMexToOutputDir;
                function copyMexToOutputDir(mexFileName)
                    src=fullfile(outputDir,mexFileName);
                    dst=fullfile(workingDir,mexFileName);
                    coder.internal.Helper.fileCopy(src,dst);
                end
            end


            function fcn=withScopeProtection(runSimFcn,outDirForEvalTBSim)
                fcn=@runSimWithTBEvalSimFcn;
                function runSimWithTBEvalSimFcn(tbExecCfg,tb,dNames,mexFileName)
                    simFile=tb;
                    try


                        [simFile,deleteSimFile]=coder.internal.Float2FixedConverter.createEvalTBSimFunction(tb,outDirForEvalTBSim);

                        simFilePath=fullfile(outDirForEvalTBSim,[simFile,'.m']);
                        c=onCleanup(@()deleteEvalSimFcn(deleteSimFile,simFilePath));

                        runSimFcn(tbExecCfg,simFile,dNames,mexFileName);
                    catch ex

                        msg=strrep(ex.message,simFile,tb);
                        causesLen=length(ex.cause);
                        if causesLen>0
                            msgList=cell(1,causesLen);
                            for mm=1:causesLen
                                exp=ex.cause{mm};
                                msgList{mm}=exp.message;
                            end
                            msg=[msg,'\n',strjoin(msgList,'\n')];
                        end
                        simEx=MException(ex.identifier,msg).addCause(ex);
                        throw(simEx);
                    end
                    function deleteEvalSimFcn(doDelete,simFilePath)
                        if doDelete
                            coder.internal.Helper.deleteFile(simFilePath);
                        end
                    end
                end
            end

            function fcn=withInstrumentation(runSimFcn,inputArgNames,coderConstIndices)
                fcn=@runSimWithInstrumentation;
                function runSimWithInstrumentation(tbExecCfg,tb,dNames,mexFileName)
                    runSimFcn(tbExecCfg,tb,dNames,mexFileName);
                    instrument(tb,dNames,mexFileName,inputArgNames,coderConstIndices);
                end
            end

            function runSimulation(tbExecCfg,tb,dNames,mexFcn)
                try
                    coder.internal.runTest(tbExecCfg,tb,dNames,mexFcn);
                catch evalEx



                    customexp=MException('Coder:FXPCONV:floatingPointSimulationException',strrep(evalEx.getReport('basic','hyperlinks','on'),'\','/'));
                    throw(customexp);
                end
            end



            function instrument(tb,dNames,mexFileName,inputArgNames,coderConstIndicies)
                [this.tbFcnInfoRegistryMap(tb),this.tbExpressionInfoMap(tb)]=updateFunctionRegistry(this,tb,mexFileName,dNames,inputArgNames,coderConstIndicies);


                clearInstrumentationResults(mexFileName);

                function[fcnRegistry,exprInfoMap]=updateFunctionRegistry(that,tb,mexFileName,dNames,inputArgNames,coderConstIndicies)
                    try
                        [~,coderReport]=fixed.internal.getInstrumentedVariables(mexFileName);

                        [fcnRegistry,exprInfoMap,this.floatGlobalTypes]=coder.internal.FcnInfoRegistryBuilder.updateFunctionInfoRegistry(that.fcnInfoRegistry,coderReport,dNames,tb,inputArgNames,coderConstIndicies,this.floatGlobalTypes,this.fxpCfg.DebugEnabled);
                    catch me
                        newEx=MException(message('Coder:FXPCONV:incorrectFcnInstrumentation',mexFileName)).addCause(me);
                        throw(newEx);
                    end
                end
            end

            function setupDataLogging(tbExecCfg,mexFileName,dNames,workDir)
                initAllLogIOState(dNames);
                if 2~=coder.internal.f2ffeature('MEXLOGGING')
                    cellfun(@(dName,constIndices)logSetupAndUpdateTbExecConfig(dName,constIndices,tbExecCfg,workDir)...
                    ,dNames,this.coderConstIndices);
                end
                if 2==coder.internal.f2ffeature('MEXLOGGING')


                    fcnsToLog=this.coderLoggedDataVarInfo.keys;
                    numFcns=length(fcnsToLog);
                    fcnScriptPaths=cell(1,numFcns);
                    fcnNames=cell(1,numFcns);

                    varsToLogStr='';
                    for jj=1:length(fcnsToLog)
                        fcnToLog=fcnsToLog{jj};

                        fcnInfo=this.coderLoggedDataVarInfo(fcnToLog);
                        fcnNames{jj}=fcnInfo.origFcnName;
                        fcnScriptPaths{jj}=fcnInfo.origFcnScriptPath;

                        varsToLog=[fcnInfo.originalInputsToLog,fcnInfo.originalOutputsToLog];
                        t=strjoin(varsToLog,'<>');
                        if isempty(t)
                            t=' ';
                        end
                        if 1==jj
                            varsToLogStr=[varsToLogStr,t];
                        else
                            varsToLogStr=[varsToLogStr,',',t];
                        end
                    end
                    custom_logger_lib('enable_location_logging_for_functions'...
                    ,mexFileName...
                    ,strjoin(fcnNames,',')...
                    ,strjoin(fcnScriptPaths,',')...
                    ,varsToLogStr);
                end



                function logSetupAndUpdateTbExecConfig(dName,constIndices,tbExecCfg,workDir)
                    dif=createLoggingDIF(dName);

                    [inputVarDimIndices,outputVarDimIndices]=this.getVarDimIncides(dName);
                    logDataFcnName=coder.internal.LoggerService.createLocalLogDataFunctionFile(dif,workDir,constIndices,inputVarDimIndices,outputVarDimIndices);


                    tbExecCfg.setLogFcnName(dName,logDataFcnName);
                    inputParamCount=length(dif.inportNames);
                    outputParamCount=length(dif.outportNames);
                    tbExecCfg.setOutputParamCount(dName,outputParamCount);

                    inLogIndices=ones(1,inputParamCount);
                    inLogIndices(inputVarDimIndices)=0;
                    outLogIndices=ones(1,outputParamCount);
                    outLogIndices(outputVarDimIndices)=0;
                    tbExecCfg.setInputOutputLogIndices(dName,inLogIndices,outLogIndices);
                end

                function initAllLogIOState(dNames)
                    if 2~=coder.internal.f2ffeature('MEXLOGGING')
                        for nn=1:length(dNames)
                            dName=dNames{nn};
                            dif=createLoggingDIF(dName);
                            coder.internal.LoggerService.clearLogValues(dif);
                            coder.internal.LoggerService.defineSimLogValues(dif);
                        end
                        this.loggedIOValuesFromFixedPointSim=[];
                    end
                end
            end


            function collectLoggedData(mexFileName,dNames)
                if 2==coder.internal.f2ffeature('MEXLOGGING')



                    primaryEP=dNames{1};
                    collectData(primaryEP,mexFileName);
                else
                    cellfun(@(dName)collectData(dName,mexFileName),dNames);
                end

                function collectData(dName,mexFileName)
                    dif=createLoggingDIF(dName);
                    [inputVarDimIndices,outputVarDimIndices]=this.getVarDimIncides(dName);


                    nonVarDimDif=dif;
                    nonVarDimDif.outportNames(outputVarDimIndices)=[];
                    nonVarDimDif.inportNames(inputVarDimIndices)=[];
                    this.loggedIOValuesFromFloatingPointSim(dName)=collectLoggedValues(nonVarDimDif,dif);

                    if 2==coder.internal.f2ffeature('MEXLOGGING')
                        this.coderLoggedFloatingPtData=collectCoderLogValues(mexFileName,dif);
                    end
                end

                function loggedValues=collectLoggedValues(nonVarDimDif,dif)
                    loggedValues=coder.internal.LoggerService.packageLoggedValues(nonVarDimDif);
                    coder.internal.LoggerService.clearLogValues(dif);
                end

                function data=collectCoderLogValues(mexFileName,dif)
                    rawData=custom_logger_lib('get_logged_data',mexFileName);
                    data=coder.internal.LoggerService.convertToMapFormat(rawData,dif);
                end
            end

            function dif=createLoggingDIF(dName)
                dif=this.createDIF(dName);


                dif.logFcnSuffix=['_',dName];


                dif.logFcnVarSuffix=['_',dName];
            end
        end

        function[mexFileName,gatewayFcnName,inputArgNames,outputArgNames]=GatewayCreationHandler(~,caller,dName,isInplaceGateway,projectDir,coderConstIndices,coderConstVals)
            gatewayBuilder=coder.internal.GatewayBuilder;
            [gatewayFcnName,inputArgNames,outputArgNames]=gatewayBuilder.createGateWay(coder.internal.Helper.which(caller),dName,isInplaceGateway,projectDir,coderConstIndices,coderConstVals);
            mexFileName=dName;
        end


        function propagateDesignRangeSpecifications(this)



            if this.fxpCfg.DoubleToSingle
                return;
            end
            fcnTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                fcnName=fcnInfo.functionName;
                varInfos=fcnInfo.getAllVarInfos();
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};
                    varName=varInfo.SymbolName;
                    if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()
                        for kk=1:length(varInfo.loggedFields)
                            fullPropName=varInfo.loggedFields{kk};
                            asgnDesignRangeSpec(fcnName,fullPropName,kk);
                        end
                    else
                        asgnDesignRangeSpec(fcnName,varName,1);
                    end
                end
            end

            function asgnDesignRangeSpec(fcnName,varName,idx)
                if this.fxpCfg.DoubleToSingle
                    return;
                end
                if this.fxpCfg.hasDesignRangeSpecification(fcnName,varName)
                    [designMin,designMax]=this.fxpCfg.getDesignRangeSpecification(fcnName,varName);
                    if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()
                        varInfo.DesignMin(idx)=designMin;
                        varInfo.DesignMax(idx)=designMax;
                    else
                        varInfo.DesignMin=designMin;
                        varInfo.DesignMax=designMax;
                    end



                    varInfo.DesignRangeSpecified=true;
                else


                    varInfo.DesignRangeSpecified=false;
                    if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()
                        varInfo.DesignMin(idx)=-Inf;
                        varInfo.DesignMax(idx)=Inf;
                    else
                        varInfo.DesignMin=[];
                        varInfo.DesignMax=[];
                    end
                end
            end
        end










        function[varIdMap,varIDMapkeyBldr,getNextIntegerID]=buildVarInfoTable(this)
            varIdMap=containers.Map();
            getNextIntegerID=@()length(varIdMap.keys())+1;
            this.varInfoTable={};
            fcnTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            varIDMapkeyBldr=@(fcnN,SymbolN)[fcnN,'#',SymbolN];
            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                varInfos=fcnInfo.getAllVarInfos();
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};
                    key=varIDMapkeyBldr(fcnInfo.functionName,varInfo.SymbolName);
                    if varIdMap.isKey(key)
                        integerId=varIdMap(key);
                    else
                        integerId=getNextIntegerID();
                        varIdMap(key)=integerId;
                        this.varInfoTable{integerId}={};
                    end
                    this.varInfoTable{integerId}{end+1}=varInfo;
                    varInfo.IntegerId=integerId;
                end
            end
        end





        function cfg=createDvoRangeAnalysisConfig(this,designName)
            cfg=coder.config('dvora');
            cfg.DesignFunctionName=designName;
            cfg.TestBenchScriptName='';
            cfg.DVOOutputDirectory=this.fxpCfg.CodegenWorkDirectory;
            cfg.DVOFileName=designName;
            cfg.BasicBlockAnalysisIterations=this.fxpCfg.BasicBlockAnalysisIterations;

            for ii=1:length(this.varInfoTable)
                var=this.varInfoTable{ii}{1};
                functionName=var.functionInfo.functionName;
                cfg.setVarIntegerId(functionName,var.SymbolName,var.IntegerId);
            end

            this.fxpCfg.transferDesignRangeSpecifications(cfg);
            coder.internal.registerSystemObjectReplacementFunctions(cfg);
        end


        function bbaResult=analyzeDVO(this,dvoFileName)


            if ispc
                dvoCmd='dvofxp.exe';
            else
                dvoCmd='dvofxp';
            end

            dvoOptions='';

            if~isempty(this.fxpCfg.StaticAnalysisTimeoutMinutes)&&...
                this.fxpCfg.StaticAnalysisTimeoutMinutes~=Inf
                timeOutInSecs=this.fxpCfg.StaticAnalysisTimeoutMinutes*60;
                if timeOutInSecs>0
                    dvoOptions=sprintf('%s -ps-t %d ',dvoOptions,timeOutInSecs);
                end
            end

            quickMode=this.fxpCfg.StaticAnalysisQuickMode;
            if quickMode
                dvoOptions=sprintf('%s -ps-quick ',dvoOptions);
            end





            dvoOptions=[dvoOptions,' -ps-float-semantics any '];






            subLoopUnrollingThreshold=num2str(this.StaticRangeAnalysisSubLoopUnrollingThreshold);
            dvoOptions=[dvoOptions,' -ps-sub-loop-unrolling-threshold ',subLoopUnrollingThreshold,' '];





            loopUnrollingThreshold=num2str(this.StaticRangeAnalysisLoopUnrollingThreshold);
            dvoOptions=[dvoOptions,' -ps-loop-unrolling-threshold ',loopUnrollingThreshold,' '];

            dvoFileName=[dvoFileName,'.dvo'];
            args=[dvoOptions,dvoFileName];

            tPolyRun=tic;
            [~,result]=system(['"',fullfile(matlabroot,'bin',computer('arch'),dvoCmd),'"',' ',args]);
            disp(sprintf('%s: %18.4f %s'...
            ,message('Coder:FxpConvDisp:FXPCONVDISP:elapsedStaticRangeAnalysisTime').getString...
            ,toc(tPolyRun)...
            ,message('Coder:FxpConvDisp:FXPCONVDISP:sec').getString));

            bbaResult=this.readPSpaceResults(result);
        end

        function bbaResult=processBasicBlockAnalysisResults(this,idRangeMap)
            bbaResult=[];
            if this.fxpCfg.BasicBlockAnalysisIterations<=0
                return;
            end
            scriptPaths=containers.Map();
            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                scriptPaths(func.scriptPath)=true;
            end

            scriptPaths=scriptPaths.keys();
            for ii=1:length(scriptPaths)
                scriptPath=scriptPaths{ii};
                fid=coder.internal.safefopen(scriptPath);
                if fid==-1
                    continue;
                end

                code=fread(fid,'*char')';
                fclose(fid);
                code=strrep(code,char(13),'');
                pst=coder.internal.MatlabPST(code,scriptPath);

                bbaResult(ii).ScriptPath=scriptPath;
                bbaResult(ii).BasicBlocks=pst.BasicBlocks;
                for jj=1:length(bbaResult(ii).BasicBlocks)
                    bbaResult(ii).BasicBlocks(jj).MaxHits=0;
                end
            end

            ids=idRangeMap.keys();
            for ii=1:length(ids)
                id=ids{ii};
                if coder.DvoRangeAnalysisConfig.isBasicBlockId(id)
                    scriptIdx=coder.DvoRangeAnalysisConfig.getAlphabeticScriptNumFromBasicBlockId(id);
                    basicBlockIdx=coder.DvoRangeAnalysisConfig.getBasicBlockNumFromBasicBlockId(id);

                    r=idRangeMap(id);

                    bbaResult(scriptIdx).BasicBlocks(basicBlockIdx).MaxHits=r.up;

                    idRangeMap.remove(id);
                end
            end

            fprintf(1,'If the design was run %d times\n',this.fxpCfg.BasicBlockAnalysisIterations);
            for ii=1:length(bbaResult)
                fprintf(1,'File : %s\n',bbaResult(ii).ScriptPath);
                for jj=1:length(bbaResult(ii).BasicBlocks)
                    if bbaResult(ii).BasicBlocks(jj).MaxHits==1
                        fprintf(1,'\tBasic Block %d  will be executed ONCE.\n',jj);
                    elseif bbaResult(ii).BasicBlocks(jj).MaxHits==0
                        fprintf(1,'\tBasic Block %d  will NEVER be executed.\n',jj);
                    else
                        fprintf(1,'\tBasic Block %d  will be executed %d times.\n',jj,bbaResult(ii).BasicBlocks(jj).MaxHits);
                    end
                end
            end
        end


        function bbaResult=readPSpaceResults(this,str)
            for ii=1:length(this.varInfoTable)
                varInfos=this.varInfoTable{ii};
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};
                    if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()
                        feildCount=length(varInfo.loggedFields);
                        varInfo.DerivedMin=-Inf(1,feildCount);
                        varInfo.DerivedMax=Inf(1,feildCount);
                    else
                        varInfo.DerivedMin=-Inf;
                        varInfo.DerivedMax=+Inf;
                    end
                    varInfo.DerivedMinMaxComputed=false;

                    if varInfo.DesignRangeSpecified
                        varInfo.DerivedMin=varInfo.DesignMin;
                        varInfo.DerivedMax=varInfo.DesignMax;
                        varInfo.DerivedMinMaxComputed=true;
                    end
                end
            end

            tokens=regexp(str,'RANGE\(([^\)]*)\);','tokens');
            idRangeMap=containers.Map('KeyType','double','ValueType','any');
            for i=1:length(tokens)
                this.findNarrowestRangeForId(tokens{i}{1},idRangeMap);
            end


            bbaResult=this.processBasicBlockAnalysisResults(idRangeMap);



            keys=idRangeMap.keys();
            for ii=1:length(keys)
                pspaceId=keys{ii};
                r=idRangeMap(pspaceId);
                this.addRange(pspaceId,r.lb,r.up);
            end

            for ii=1:length(this.varInfoTable)
                varInfos=this.varInfoTable{ii};
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};

                    if varInfo.DerivedMinMaxComputed


                        try
                            if strcmp(varInfo.inferred_Type.Class,'embedded.fi')
                                nt=varInfo.inferred_Type.NumericType;
                                varInfo.DerivedMin=double(fi(0,nt,'int',varInfo.DerivedMin));
                                varInfo.DerivedMax=double(fi(0,nt,'int',varInfo.DerivedMax));
                            end
                        catch ex %#ok<NASGU> % ignore
                        end

                        if(varInfo.DerivedMin==varInfo.DerivedMax)&&...
                            (floor(varInfo.DerivedMin)==varInfo.DerivedMin)
                            varInfo.IsAlwaysInteger=true;
                        elseif isempty(varInfo.SimMin)
                            varInfo.IsAlwaysInteger=false;
                        end

                    end



                    if varInfo.isEnum()
                        varInfo.DerivedMin=[];
                        varInfo.DerivedMax=[];
                        varInfo.DerivedMinMaxComputed=false;
                    end
                end
            end

            for ii=1:length(this.varInfoTable)
                varInfos=this.varInfoTable{ii};
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};
                    if varInfo.DerivedMinMaxComputed&&...
                        reallyCloseToZero(varInfo.DerivedMin)&&...
                        reallyCloseToZero(varInfo.DerivedMax)
                        varInfo.DerivedMin=0;
                        varInfo.DerivedMax=0;
                    end
                end
            end




            function r=reallyCloseToZero(val)
                if~isempty(val)&&(abs(val)<0.000000000000000001)
                    r=true;
                else
                    r=false;
                end
            end
        end







        function findNarrowestRangeForId(~,str,idRangeMap)
            try




                rTokens=regexp(str,'(\d+)| ([^,]+), ([^,]+)','tokens');
                if length(rTokens)>=2
                    pspaceId=str2double(rTokens{1}{1});
                    lb=str2double(strrep(rTokens{2}{1},'~','-'));
                    up=str2double(strrep(rTokens{2}{2},'~','-'));


                    for i=3:length(rTokens)
                        lb=min(lb,str2double(rTokens{i}{1}));
                        up=max(up,str2double(rTokens{i}{2}));
                    end

                    if~idRangeMap.isKey(pspaceId)


                        r.lb=lb;
                        r.up=up;
                    else

                        r=idRangeMap(pspaceId);
                    end


                    r.lb=max(r.lb,lb);
                    r.up=min(r.up,up);
                    idRangeMap(pspaceId)=r;%#ok<NASGU>
                end
            catch ex %#ok<NASGU>

            end
        end



        function addRange(this,pspaceId,lb,up)
            try
                varIntegerId=coder.DvoRangeAnalysisConfig.getVarIntegerIdFromPSpaceId(pspaceId);
                varInfos=this.varInfoTable{varIntegerId};

                for ii=1:length(varInfos)
                    var=varInfos{ii};

                    if true
                        if var.DerivedMin==-Inf
                            var.DerivedMin=lb;
                        else
                            var.DerivedMin=min(var.DerivedMin,lb);
                        end
                        var.DerivedMinMaxComputed=true;
                    end

                    if true
                        if var.DerivedMax==Inf
                            var.DerivedMax=up;
                        else
                            var.DerivedMax=max(var.DerivedMax,up);
                        end
                        var.DerivedMinMaxComputed=true;
                    end
                end
            catch MEx %#ok<NASGU>

            end
        end


        function coerceIncorrectDerivedRangesToInfs(this)
            funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.coerceIncorrectDerivedRangesToInfs();
                end
            end
        end


        function[compatible,messages]=checkIfDesignIsF2FCompatible(this,runDMMChecks)
            compatible=true;
            assert(~isempty(this.fcnInfoRegistry));

            fcnTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();



            dvoCfg=this.createDvoRangeAnalysisConfig('');
            processedClasses=containers.Map();
            isMLFBWorkflow=false;

            messages=coder.internal.lib.Message.empty();
            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                [fcn_is_compatible,messages]=fcnInfo.isF2FCompatible(messages,runDMMChecks,dvoCfg,processedClasses,this.fxpCfg.DoubleToSingle,this.fxpCfg.EnableArrayOfStructures,isMLFBWorkflow,this.fxpCfg.isNonScalarSupportedForDVO());
                compatible=compatible&&fcn_is_compatible;
            end
            entryPointsCalledByOthers=coder.internal.detectEntryPointsCallingEachother(this.DesignFunctionNames,this.fcnInfoRegistry);
            if~isempty(entryPointsCalledByOthers)
                messages=[entryPointsCalledByOthers(:),messages];
                compatible=false;
            end
        end


        function varInfos=gatherAllVarsNeedingDesignRange(this)
            assert(~isempty(this.fcnInfoRegistry));

            varInfos={};
            mlFcnInfosMap=coder.internal.lib.Map();


            fcnTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            for ii=1:length(fcnTypeInfos)

                fcnTypeInfo=fcnTypeInfos{ii};

                if~mlFcnInfosMap.isKey(fcnTypeInfo.functionName)
                    script=fcnTypeInfo.scriptPath;
                    mlFcnInfosForScript=coder.internal.tools.MLFcnInfo(script);
                    mlFcnInfosMap.update(mlFcnInfosForScript);
                end

                mlFcnInfo=mlFcnInfosMap(fcnTypeInfo.functionName);

                for jj=1:length(mlFcnInfo.persistentVars)
                    varName=mlFcnInfo.persistentVars{jj};
                    varInfo=fcnTypeInfo.getVarInfo(varName);%#ok<NASGU>


                end
            end


            designNames=this.DesignFunctionNames;

            for mm=1:length(designNames)
                designName=designNames{mm};
                designMLFcnInfo=mlFcnInfosMap(designName);
                designFcnTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfo(designName);
                for jj=1:length(designMLFcnInfo.inputVars)
                    varName=designMLFcnInfo.inputVars{jj};
                    varInfo=designFcnTypeInfo.getVarInfo(varName);
                    if isempty(varInfo)

                        varInfo=struct();
                        varInfo.functionInfo=designFcnTypeInfo;
                        varInfo.SymbolName=varName;
                    end
                    varInfos{end+1}=varInfo;
                end
            end
        end


        function varsMissingDesignRange=gatherVarsMissingDesignRange(this)
            varsNeedingDesignRange=this.gatherAllVarsNeedingDesignRange();
            varsMissingDesignRange={};

            for ii=1:length(varsNeedingDesignRange)
                var=varsNeedingDesignRange{ii};
                if~this.fxpCfg.hasDesignRangeSpecification(var.functionInfo.functionName,var.SymbolName)
                    varsMissingDesignRange{end+1}=var;
                end
            end
        end


        function r=assertDesignRangesSpecified(this)
            r=true;
            varsMissingDesignRange=this.gatherVarsMissingDesignRange();
            if~isempty(varsMissingDesignRange)
                msg='';
                for ii=1:length(varsMissingDesignRange)
                    var=varsMissingDesignRange{ii};
                    msg=message('Coder:FxpConvDisp:FXPCONVDISP:missingVarDesignRange',msg,var.SymbolName,var.functionInfo.functionName).getString;
                end
                disp(msg);
                r=false;
            end
        end


        function[success,f2fCompatibilityMessages,bbaResult]=computeDerivedRanges(this)
            success=false;
            f2fCompatibilityMessages=coder.internal.lib.Message.empty();
            bbaResult=[];
            if~this.fxpCfg.ComputeDerivedRanges
                return;
            end

            if isempty(this.fcnInfoRegistry)
                enableInstrumentation=false;
                this.buildDesign(enableInstrumentation);
            end

            runDMMChecks=true;
            [compatible,f2fCompatibilityMessages]=this.checkIfDesignIsF2FCompatible(runDMMChecks);
            if~compatible
                disp(message('Coder:FXPCONV:DvoIncompatible').getString());
                return;
            end

            if~this.assertDesignRangesSpecified()
                return;
            end

            disp(sprintf('\n============= %s ==============\n',message('Coder:FxpConvDisp:FXPCONVDISP:step1bHeader').getString));
            coder.internal.Helper.checkPathForToolboxPath(this.fxpCfg.OutputFilesDirectory);

            dNames=this.DesignFunctionNames;
            cgInfo=setup(dNames);
            c=onCleanup(cgInfo.cleanup);













            function cgInfo=setup(dNames)
                workDir=this.fxpCfg.CodegenWorkDirectory;
clear mex;
                [~,~,~]=rmdir(workDir,'s');
                [~,~,~]=mkdir(workDir);
                designDir=this.fxpCfg.DesignDirectory;




                for ii=1:length(dNames)
                    dName=dNames{ii};
                    currentDir=pwd;
                    [designPath,~,~]=fileparts(coder.internal.Helper.which(dName));
                    assert(strcmp(currentDir,designPath),['Cannot find design name in the current directory ',currentDir]);
                end

                [dName,inTypes,isPsuedoDesign,cleanUpFcn]=createMasterEntryPoint(dNames,designDir);


                cgInfo.config=buildConfig(dName,isPsuedoDesign);
                cgInfo.exInputs=inTypes;
                cgInfo.cleanup=cleanUpFcn;


                function[master,ipTypes,isMaster,cleanUpFcn]=createMasterEntryPoint(dNames,mDir)
                    cleanUpFcn=@()[];
                    ipTypes=coder.internal.lib.ListHelper.flatten(this.inputTypeSpecifications);
                    isMaster=1<length(dNames);
                    if~isMaster
                        master=dNames{1};
                        return;
                    end

                    uniqifier=coder.internal.lib.DistinctNameService(dNames);

                    MASTER_NAME='master';
                    master=uniqifier.distinguishName(MASTER_NAME);

                    masterInVarNames={};

                    masterOutVarNames={};

                    masterBodyStmts={};
                    for jj=1:length(dNames)
                        dN=dNames{jj};

                        fcnInfo=this.fcnInfoRegistry.getFunctionTypeInfo(dN);
                        inVars=cellfun(@(n)getPsuedoVarNames(fcnInfo.uniqueId,n)...
                        ,fcnInfo.inputVarNames...
                        ,'UniformOutput',false);
                        outVars=cellfun(@(n)getPsuedoVarNames(fcnInfo.uniqueId,n)...
                        ,fcnInfo.outputVarNames...
                        ,'UniformOutput',false);

                        masterInVarNames=[masterInVarNames,inVars];
                        masterOutVarNames=[masterOutVarNames,outVars];

                        callStmt=coder.internal.Helper.getFcnInterfaceSignature(dN,inVars,outVars);
                        masterBodyStmts{end+1}=callStmt;
                    end

                    masterFcnHeader=sprintf('function %s',coder.internal.Helper.getFcnInterfaceSignature(master,masterInVarNames,masterOutVarNames));

                    code=[masterFcnHeader,';'...
                    ,strjoin(masterBodyStmts,';')];
                    fullFileName=coder.internal.Helper.createMATLABFile(mDir,master,mtree(code).tree2str());
                    cleanUpFcn=@()coder.internal.Helper.deleteFile(fullFileName);
                end



                function dvoCfg=buildConfig(dName,isPsuedoDesign)
                    [varIDMap,varIDMapkeyBldr,getNextIntegerID]=this.buildVarInfoTable();
                    dvoCfg=this.createDvoRangeAnalysisConfig(dName);



                    if isPsuedoDesign


                        fcns=this.DesignFunctionNames;
                        for mm=1:length(fcns)
                            fcn=fcns{mm};
                            vars=this.fxpCfg.getDesignSpecifiedVars(fcn);
                            for nn=1:length(vars)
                                var=vars{nn};



                                psuedoVarName=getPsuedoVarNames(fcn,var);
                                [dMin,dMax]=this.fxpCfg.getDesignRangeSpecification(fcn,var);
                                dvoCfg.addDesignRangeSpecification(dName...
                                ,psuedoVarName...
                                ,coder.InternalDesignRange(dMin,dMax));



                                k=varIDMapkeyBldr(dName,psuedoVarName);
                                assert(~varIDMap.isKey(k),'Pseudo design cannot have any multiple instances of variable instances');
                                varInID=getNextIntegerID();varIDMap(k)=varInID;
                                dvoCfg.setVarIntegerId(dName,psuedoVarName,varInID);
                            end
                        end
                    end
                end

                function res=getPsuedoVarNames(fcnName,varName)
                    res=[fcnName,'_',varName];
                end
            end

            try
                tCompileDvo=tic;
                emlcprivate('emlckernel','codegen','-args',cgInfo.exInputs,'-config',cgInfo.config,'-d',this.fxpCfg.OutputFilesDirectory);
                disp(sprintf('%s: %18.4f %s'...
                ,message('Coder:FxpConvDisp:FXPCONVDISP:elapsedStaticAnalysisCompileTime').getString...
                ,toc(tCompileDvo)...
                ,message('Coder:FxpConvDisp:FXPCONVDISP:sec').getString));

            catch me
                disp(me.message)
                return;
            end
            this.propagateDesignRangeSpecifications();




            curDir=pwd;
            cd(this.fxpCfg.CodegenWorkDirectory);
            cleanup=onCleanup(@()cd(curDir));
            bbaResult=this.analyzeDVO(cgInfo.config.DVOFileName);


            this.coerceIncorrectDerivedRangesToInfs();

            success=true;
        end

        function emitTypesTableFunction(this,typesTableName)
            if this.fxpCfg.DoubleToSingle&&this.fxpCfg.TransformF2FInIR()
                return;
            end
            if~this.fxpCfg.EmitTypesTable&&~this.fxpCfg.GenerateParametrizedCode
                return;
            end

            mExt=this.getMext();
            outputFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,[typesTableName,mExt]);

            fid=coder.internal.safefopen(outputFilePath,'w');
            closeFid=onCleanup(@()fclose(fid));

            fcnInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
            ii=1;
            while ii<=length(fcnInfos)
                fcnInfo=fcnInfos{ii};
                if~fcnInfo.emitted
                    fcnInfos(ii)=[];
                else
                    ii=ii+1;
                end
            end

            functionUniqueNames={};
            for ii=1:length(fcnInfos)
                fcnInfo=fcnInfos{ii};
                functionUniqueNames{end+1}=fcnInfo.specializationName;
            end

            fprintf(fid,'%s\n','%#codegen');
            fprintf(fid,'%s\n','');
            fprintf(fid,'function T = %s()\n',typesTableName);
            maxFunctionUniqueNameLength=max(cellfun(@(x)numel(x),functionUniqueNames));
            for ii=1:length(fcnInfos)
                functionUniqueName=functionUniqueNames{ii};
                spaces=repmat(' ',1,maxFunctionUniqueNameLength+1-length(functionUniqueName));
                fprintf(fid,'\t T.%s%s= %s_Types();\n',functionUniqueName,spaces,functionUniqueName);
            end
            fprintf(fid,'end\n\n');

            for ii=1:length(fcnInfos)
                fcnInfo=fcnInfos{ii};
                varNames=fcnInfo.getAllVarNames();
                entries=struct('Name',{},'NT',{},'PT',{},'Specialized',{},'Boolean',{},'FixedPoint',{});
                maxFieldNameLength=0;

                for jj=1:length(varNames)
                    varName=varNames{jj};
                    varInfo=fcnInfo.getVarInfo(varName);
                    if varInfo.isStruct()||varInfo.isVarInSrcCppSystemObj()
                        for kk=1:length(varInfo.loggedFields)


                            if isnumerictype(varInfo.annotated_Type{kk})
                                entries(end+1)=struct('Name',varInfo.loggedFields{kk},'NT',varInfo.annotated_Type{kk},...
                                'PT',varInfo.proposed_Type{kk},...
                                'Specialized',varInfo.isSpecialized,...
                                'Boolean',false,...
                                'FixedPoint',false);
                                maxFieldNameLength=max(maxFieldNameLength,length(entries(end).Name));
                            end
                        end
                    else
                        if~isempty(varInfo.annotated_Type)
                            entries(end+1)=struct('Name',varName,'NT',varInfo.annotated_Type,...
                            'PT',varInfo.proposed_Type,...
                            'Specialized',varInfo.isSpecialized,...
                            'Boolean',varInfo.isVarInSrcBoolean,...
                            'FixedPoint',varInfo.isVarInSrcFixedPoint);
                            maxFieldNameLength=max(maxFieldNameLength,length(entries(end).Name));
                        end
                    end
                end

                functionUniqueName=functionUniqueNames{ii};
                fprintf(fid,'function T = %s_Types()\n',functionUniqueName);
                fprintf(fid,'\tfm = %s;\n\n',this.fxpCfg.fimath);
                for jj=1:length(entries)
                    if entries(jj).Specialized
                        fprintf(fid,'\t%% Variable %s is specialized. Skipped.\n',entries(jj).Name);
                        continue;
                    end
                    fieldName=entries(jj).Name;
                    NT=entries(jj).NT;
                    PT=entries(jj).PT;
                    spaces=repmat(' ',1,maxFieldNameLength+1-length(fieldName));
                    proposedTypeStr='';
                    if~isempty(PT)
                        if~NT.isequivalent(PT)||entries(jj).Boolean
                            proposedTypeStr=sprintf('%% Autoscaled Type = fi([], %d, %d, %d)',PT.SignednessBool,PT.WordLength,PT.FractionLength);
                        end
                    end
                    if entries(jj).Boolean
                        fprintf(fid,'\tT.%s%s= logical([]);%s\n',fieldName,spaces,proposedTypeStr);
                    elseif entries(jj).FixedPoint
                        fprintf(fid,'\t%%T.%s%s= fi([], %d, %3d, %3d, fm);%s\n',fieldName,spaces,NT.SignednessBool,NT.WordLength,NT.FractionLength,proposedTypeStr);
                    else
                        fprintf(fid,'\tT.%s%s= fi([], %d, %3d, %3d, fm);%s\n',fieldName,spaces,NT.SignednessBool,NT.WordLength,NT.FractionLength,proposedTypeStr);
                    end
                end

                if this.fxpCfg.GenerateParametrizedCode&&~isempty(fcnInfo.expressionTypes)

                    fprintf(fid,'\n\t%% Expression types \n');
                    expressionTypes=fcnInfo.expressionTypes;
                    types=sort(expressionTypes.keys());
                    for jj=1:length(types)
                        type=types{jj};
                        entry=expressionTypes(type);
                        fprintf(fid,'\tT.%s = %s; %% Applied to: %s \n',entry.TypesTableField,type,strjoin(entry.AppliesTo.keys(),'  '));
                    end
                end
                fprintf(fid,'\tT.DefaultWordLength = fi([], 0, %d, 0); \n',this.fxpCfg.DefaultWordLength);
                fprintf(fid,'\tT.Fimath = fi([], fm);\n');

                if isempty(entries)&&isempty(fcnInfo.expressionTypes)
                    fprintf(fid,'\tT=[];\n');
                end
                fprintf(fid,'end\n\n');
            end









clear closeFid;
        end


        function[fcnVarInfo,exprTypeInfo,messages]=proposeTypes(this,generateExInputMatFile)

            if(nargin<=1)
                generateExInputMatFile=false;
            end

            disp(sprintf('\n============= %s ==============\n',this.message('Coder:FxpConvDisp:FXPCONVDISP:step2Header').getString));

            if~this.fxpCfg.ComputeSimulationRanges&&~this.fxpCfg.ComputeDerivedRanges
                disp(sprintf('No Range Information Available. Using single data type for doubles.;'));
            end

            this.propagateTypeSpecifications();
            this.typeProposalSettings=this.getTypeProposalSettings();

            messages=coder.internal.lib.Message.empty();
            generateNegFractionLenWarning=false;
            [fcnVarInfo,messages]=coder.internal.computeBestTypes(this.fcnInfoRegistry,this.typeProposalSettings,generateNegFractionLenWarning,messages);

            exprTypeInfo={};
            tbExprMaps=this.tbExpressionInfoMap.values;
            if~isempty(tbExprMaps)

                exprInfoMap=tbExprMaps{1};
                exprTypeInfo=coder.internal.computeBestTypeForExpressions(exprInfoMap,this.typeProposalSettings);
            end

            fcnRegistry=this.fcnInfoRegistry;%#ok<NASGU>
            if(generateExInputMatFile)
                exInputMatFileName=[this.DesignFunctionNames,'_fixpt_TypeInfo','.mat'];
                eval(sprintf('save(%s, %s)',exInputMatFileName,'fcnRegistry'));
            end

            if this.fxpCfg.DoubleToSingle

            else
                messages=[messages,this.fcnInfoRegistry.checkForUnAssignedGlobals()];
            end
            this.clearAnnotations();
        end


        function data=getHistogramData(this,functionName,varName)
            fcnInfo=this.fcnInfoRegistry.getFunctionTypeInfo(functionName);

            [baseVarName,~]=strtok(varName,'.');
            baseVarInfo=fcnInfo.getVarInfo(baseVarName);

            if isempty(baseVarInfo)
                varInfo=[];
            elseif baseVarInfo.isStruct()||baseVarInfo.isVarInSrcSystemObj()||baseVarInfo.isVarInSrcCppSystemObj
                varInfo=baseVarInfo.getStructPropVarInfo(varName);
            elseif baseVarInfo.isMCOSClass()
                varName=coder.internal.FcnInfoRegistryBuilder.normalizeVarName(varName);
                varInfo=fcnInfo.getVarInfo(varName);
            else
                varInfo=baseVarInfo;
            end

            assert(~isempty(varInfo));
            positiveVals=varInfo.HistogramOfPositiveValues;
            if all(Inf==positiveVals)
                positiveVals=[];
            end
            negativeVals=varInfo.HistogramOfNegativeValues;
            if all(Inf==negativeVals)
                negativeVals=[];
            end
            data.HistogramOfPositiveValues=positiveVals;
            data.HistogramOfNegativeValues=negativeVals;
        end







        function generatePlot(this,uniqueID,variableName,exprType)
            fcnInfo=this.fcnInfoRegistry.getFunctionTypeInfo(uniqueID);
            fcnSplName=fcnInfo.functionName;
            scriptPath=fcnInfo.scriptPath;
            fcnSplNumber=fcnInfo.specializationId;

            this.generatePlotWithSplName(scriptPath,fcnSplName,fcnSplNumber,variableName,exprType);
        end





        function generatePlotWithSplName(this,scriptPath,fcnName,fcnSplNum,variableName,exprType)
            uniqueFullName=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(scriptPath,fcnName,fcnSplNum);
            if isKey(this.plottedFigureHandles,uniqueFullName)

                fcnPlots=this.plottedFigureHandles(uniqueFullName);
                figHndl=fetchFcnHndl(exprType,variableName);
                if~isempty(figHndl)&&isvalid(figHndl)
                    figure(figHndl);
                else
                    this.generatePlotImpl(scriptPath,fcnName,fcnSplNum,variableName,exprType);
                end
            else
                this.generatePlotImpl(scriptPath,fcnName,fcnSplNum,variableName,exprType);
            end

            function figHndl=fetchFcnHndl(exprType,variableName)
                figHndl=[];
import coder.internal.lib.StructHelper;
                switch exprType
                case coder.internal.ComparisonPlotService.INPUT_EXPR
                    figHndl=StructHelper.getFieldVal(fcnPlots.inputs,variableName);
                case coder.internal.ComparisonPlotService.OUTPUT_EXPR
                    figHndl=StructHelper.getFieldVal(fcnPlots.outputs,variableName);
                end
            end
        end


        function info=getVariableInfo(this)
            info=coder.internal.Float2FixedConverter.getVariableInfoUsing(this.fcnInfoRegistry,this.getTypeProposalSettings());
        end


        function registry=testAPI_getCopyOfFunctionRegistryMap(this)
            registry=containers.Map(this.fcnInfoRegistry.registry.keys(),this.fcnInfoRegistry.registry.values());
        end


        function reportPath=printTypeReport(this,showreport,annotations)
            if nargin<3
                annotations=[];
            end
            fcnName=[this.DesignFunctionNames];
            pEP=fcnName{1};
            isFixPtReport=false;
            reportName=[pEP,'_report.html'];
            reportPath=this.printTypeReportBase(reportName,showreport,annotations,this.fcnInfoRegistry,fcnName,isFixPtReport);
        end


        function reportPath=printFixptTypeReport(this,reportName,showreport,registry,annotations)
            if nargin<5
                annotations=[];
            end
            fcnNames=cellfun(@(d)[d,this.fxpCfg.FixPtFileNameSuffix],this.DesignFunctionNames,'UniformOutput',false);
            isFixPtReport=true;
            reportPath=this.printTypeReportBase(reportName,showreport,annotations,registry,fcnNames,isFixPtReport);
        end

        function txtMsg=getMessageText(this,varargin)
            txtMsg=this.message(varargin{:}).getString;
        end





        function[coderReport,outputSummary,isVarLoggableInfo,msgs]=generateFixedPointCode(this)
            outputSummary.mcosFiles={};
            outputSummary.designFiles={};
            outputSummary.mexFiles={};
            outputSummary.reports={};
            outputSummary.otherFiles={};


            this.propagateTypeSpecifications();

            this.propagateDesignRangeSpecifications();




            typePropSettings=this.getTypeProposalSettings();
            if typePropSettings.proposeAggregateStructTypes
                funcs=this.fcnInfoRegistry.getAllFunctionTypeInfos();

                coder.internal.FcnInfoRegistryBuilder.AggregateStructProposedTypes(funcs,this.fcnInfoRegistry.mxInfos,typePropSettings);
            end

            disp(sprintf('\n============= %s ==============\n',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:step3Header')));

            setupInfo=doSetup(this.fxpCfg.CodegenWorkDirectory);
            function setupInfo=doSetup(workingDir)
                setupInfo.currDir=pwd;
                setupInfo.pathBak=path;
                setupInfo.projectDir=workingDir;
clear mex;
                [~,~,~]=rmdir(workingDir,'s');
                [~,~,~]=mkdir(workingDir);
                setupInfo.warnState=coder.internal.Helper.changeBacktraceWarning('off');
            end

            cleanup=onCleanup(@()this.runCleanup(setupInfo));

            dNames=this.DesignFunctionNames;

            typesTableName='FixedPointTypes';
            if(~this.fxpCfg.EmitTypesTable&&~this.fxpCfg.GenerateParametrizedCode)||this.fxpCfg.DoubleToSingle
                typesTableName=[];
            end
            outTypesTablePath=[];
            fixptWrapperNames=[];
            fixptDNames=[];

            this.globalUniqNameMap=this.fcnInfoRegistry.getUniqGlobalNameMapping();
            [fixptDNames,fixptWrapperNames]=getFixptFileNames(dNames);
            [this.fixedInVals,this.fxpCfg.ConvertedInputFiTypesInfo,translationMsgs]=generateCode(dNames);
            this.fxpCfg.ConvertedInputFiTypes=this.fixedInVals;

            function[dNameFixPt,dNameFixptWrapper]=getFixptFileNames(dNames)
                dNameFixPt=cellfun(@(d)this.getFixPtDesignName(d),dNames,'UniformOutput',false);
                dNameFixptWrapper=cellfun(@(d)this.getFixPtWrapperName(d),dNames,'UniformOutput',false);
            end

            function[fixedInVals,newTypesInfo,msgs]=generateCode(dNames)

                pEP=dNames{1};

                designActualFcnNames=pEP;
                if~isempty(this.actualFunctionName)
                    designActualFcnNames=this.actualFunctionName;
                end

                fxpConversionSettings.autoScaleLoopIndexVars=false;
                fxpConversionSettings.globalFimathStr=this.fxpCfg.fimath;
                fxpConversionSettings.fiMathVarName='fm';
                fxpConversionSettings.userFcnTemplatePath=this.fxpCfg.UserFunctionTemplatePath;
                fxpConversionSettings.userFcnMap=this.getUserFunctionReplacements();
                fxpConversionSettings.suppressErrorMessages=this.fxpCfg.SuppressErrorMessages;
                fxpConversionSettings.fiCastFiVars=this.fxpCfg.FiCastFiVars;
                fxpConversionSettings.fiCastIntegers=this.fxpCfg.FiCastIntegerVars;
                fxpConversionSettings.fiCastDoubleLiteralVars=this.fxpCfg.FiCastDoubleLiteralVars;
                fxpConversionSettings.detectFixptOverflows=this.fxpCfg.DetectFixptOverflows;
                fxpConversionSettings.debugEnabled=this.fxpCfg.DebugEnabled;
                fxpConversionSettings.autoReplaceCfgs=this.fxpCfg.getMathFcnConfigs;
                fxpConversionSettings.FixPtFileNameSuffix=this.fxpCfg.FixPtFileNameSuffix;
                fxpConversionSettings.GenerateParametrizedCode=this.fxpCfg.GenerateParametrizedCode;
                fxpConversionSettings.UseF2FPrimitives=this.fxpCfg.UseF2FPrimitives;
                if isempty(this.tbFcnInfoRegistryMap)
                    fxpConversionSettings.detectDeadCode=0;
                else
                    fxpConversionSettings.detectDeadCode=this.fxpCfg.ComputeCodeCoverage&&this.ComputedCodeCoverageInfo;
                end
                fxpConversionSettings.TransformF2FInIR=coder.FixPtConfig.TransformF2FInIR;
                fxpConversionSettings.DoubleToSingle=this.fxpCfg.DoubleToSingle||this.fxpCfg.DoubleToSingleInFxpApp();
                fxpConversionSettings.EmitSeperateFimathFunction=this.fxpCfg.EmitSeperateFimathFunction;
                fxpConversionSettings.MLFBApply=strcmp(this.fxpCfg.ProposeTypesMode,coder.FixPtConfig.MODE_MLFB);

                designSettings.designNames=dNames;
                designSettings.fixPtDesignNames=fixptDNames;
                designSettings.designActualFcnNames=designActualFcnNames;
                designSettings.outputPath=this.fxpCfg.CodegenWorkDirectory;
                designSettings.fcnInfoRegistry=this.fcnInfoRegistry;

                designSettings.globalUniqNameMap=this.globalUniqNameMap;
                exprMaps=this.tbExpressionInfoMap.values();


                if~isempty(exprMaps)
                    exprInfo=exprMaps{1};
                else
                    exprInfo=exprMaps;
                end
                designSettings.simExprInfo=exprInfo;
                designSettings.compiledExprInfo=this.designExprInfoMap;
                designSettings.testbenchName=this.fxpCfg.TestBenchName;
                designSettings.designIOWrapperName=fixptWrapperNames;

                fpc=coder.internal.DesignTransformer(designSettings,typePropSettings,fxpConversionSettings);

                try

                    [fixedInVals,newTypesInfo,msgs,~]=fpc.doIt(this.inputTypeSpecifications,containers.Map);
                    this.emitTypesTableFunction(typesTableName);
                catch ex
                    rethrow(ex);
                end

            end

            printLinksForWrappers(fixptDNames,fixptWrapperNames);

            this.functionCodeMaps=[];
            this.methodCodeMaps=[];
            if this.generateMATLAB
                copySummary=this.copyFixPtFilesFromCodegenToOutputDir(dNames,fixptDNames,fixptWrapperNames,typesTableName,outTypesTablePath);
                outputSummary.mcosFiles=copySummary.mcosFiles;
                outputSummary.designFiles=copySummary.designFiles;
                outputSummary.data.config=this.fxpCfg;





                pEPFixpt=fixptDNames{1};
                fixptDesignInfo=struct('inputArgs',this.fixedInVals,'designName',fixptDNames);

                valueMatFile=this.generateValueMatFile(pEPFixpt,fixptDesignInfo);
                outputSummary.otherFiles={valueMatFile};

                if coder.internal.gui.Features.FixedPointTraceability.Enabled
                    [this.functionCodeMaps,this.methodCodeMaps]=coder.internal.FunctionCodeMap.buildCodeMaps(...
                    this.fcnInfoRegistry,fixptDNames,this.fxpCfg,copySummary.mcosFiles);
                    outputSummary.data.traceability=coder.internal.FunctionCodeMap.toTraceabilityData(...
                    this.functionCodeMaps,this.methodCodeMaps);
                end
            end

            [msgs,logFile]=handleTranslationMessage(translationMsgs);

            if~isempty(outputSummary)&&~isempty(logFile)
                outputSummary.otherFiles{end+1}=logFile;
            end

            [coderReport,mexFileName]=this.buildFixedPointCode(false);

            isCompilationSuccess=coder.internal.Float2FixedConverter.isCodegenSuccess(coderReport);
            outputSummary=appendCoderReportInfo(coderReport,outputSummary);



            if 2==coder.internal.f2ffeature('MEXLOGGING')&&isCompilationSuccess
                this.InstrLoggedFixedVars=coder.internal.Helper.fevalInPath(@()custom_logger_lib('get_all_loggable_expr_info',mexFileName)...
                ,this.fxpCfg.OutputFilesDirectory);


                this.cleanupFixedPtGlobals();
            end



            if this.fxpCfg.DetectFixptOverflows&&isCompilationSuccess
                coderReport=coder.internal.Helper.fevalInPath(@()this.buildFixedPointCode(true),...
                this.fxpCfg.OutputFilesDirectory);
                outputSummary=appendCoderReportInfo(coderReport,outputSummary);
            end

            this.fxpCfg.setFixedGlobalTypes(this.fixedGlobalTypes);

            if 2==coder.internal.f2ffeature('MEXLOGGING')

                markLoggableVariablesNew();
            end

            isVarLoggableInfo=coder.internal.plotting.getVariableLoggableInfoFromRegistry(this.fcnInfoRegistry);



            function markLoggableVariablesNew()














                floatExprInfos=groupByFunctionNames(this.InstrLoggedFloatVars,false);


                fixedExprInfos=groupByFunctionNames(this.InstrLoggedFixedVars,true);

                floatFcns=floatExprInfos.keys;
                for mm=1:length(floatFcns)
                    fcn=floatFcns{mm};

                    [functionPath,functionName,specializationNumber]=internal.mtree.FunctionTypeInfo.SplitFullUniqueName(fcn);
                    fcnInfo=this.fcnInfoRegistry.getFunctionTypeInfoBySpecializationAndPath(functionPath,functionName,specializationNumber);
                    if isempty(fcnInfo)
                        continue;
                    end

                    cnvtFI=fcnInfo.convertedFunctionInterface;
                    if isempty(cnvtFI.convertedFilePath)||isempty(cnvtFI.convertedName)||isempty(cnvtFI.convertedSpecializationID)

                        continue;
                    end

                    [~,fn,fext]=fileparts(cnvtFI.convertedFilePath);
                    normalizedFcnPath=[fn,fext];
                    fixptUniqueFullName=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(normalizedFcnPath,cnvtFI.convertedName,cnvtFI.convertedSpecializationID);
                    if~isKey(fixedExprInfos,fixptUniqueFullName)


                        continue;
                    end


                    floatExprs=floatExprInfos(fcn);
                    fixedExprs=fixedExprInfos(fixptUniqueFullName);

                    markInputVariablesForLogging(fcnInfo,cnvtFI,floatExprs,fixedExprs);
                    markOutputVariablesForLogging(fcnInfo,cnvtFI,floatExprs,fixedExprs);
                end



                function markInputVariablesForLogging(fcnInfo,cnvtFI,floatExprs,fixedExprs)

                    floatExprs=floatExprs(strcmp({floatExprs.exprType},coder.internal.ComparisonPlotService.INPUT_EXPR));
                    fixedExprs=fixedExprs(strcmp({fixedExprs.exprType},coder.internal.ComparisonPlotService.INPUT_EXPR));

                    floatExprIds={floatExprs.ExprId};
                    fixedExprIds={fixedExprs.ExprId};

                    origInputVarNames=fcnInfo.inputVarNames;
                    for jj=1:length(origInputVarNames)
                        origName=origInputVarNames{jj};

                        flInfo=floatExprs(strcmp(floatExprIds,origName));
                        if isempty(flInfo)
                            continue;
                        end
                        assert(length(flInfo)==1);

                        cnvtName=cnvtFI.inputParams{jj};
                        fxpInfo=fixedExprs(strcmp(fixedExprIds,cnvtName));
                        if isempty(fxpInfo)
                            continue;
                        end
                        assert(length(fxpInfo)==1);



                        markVariableForLogging(fcnInfo,flInfo.ExprId,flInfo.exprType);
                    end
                end

                function markOutputVariablesForLogging(fcnInfo,cnvtFI,floatExprs,fixedExprs)

                    floatExprs=floatExprs(strcmp({floatExprs.exprType},coder.internal.ComparisonPlotService.OUTPUT_EXPR));
                    fixedExprs=fixedExprs(strcmp({fixedExprs.exprType},coder.internal.ComparisonPlotService.OUTPUT_EXPR));

                    floatExprIds={floatExprs.ExprId};
                    fixedExprIds={fixedExprs.ExprId};

                    origOutputVarNames=fcnInfo.outputVarNames;
                    for jj=1:length(origOutputVarNames)
                        origName=origOutputVarNames{jj};

                        flInfo=floatExprs(strcmp(floatExprIds,origName));
                        if isempty(flInfo)
                            continue;
                        end
                        assert(length(flInfo)==1);

                        cnvtName=cnvtFI.outputParams{jj};
                        fxpInfo=fixedExprs(strcmp(fixedExprIds,cnvtName));
                        if isempty(fxpInfo)
                            continue;
                        end
                        assert(length(fxpInfo)==1);



                        markVariableForLogging(fcnInfo,flInfo.ExprId,flInfo.exprType);
                    end
                end

                function markVariableForLogging(fcnInfo,varName,exprType)
                    varInfos=fcnInfo.getVarInfosByName(varName);
                    varInfos=[varInfos{:}];

                    switch exprType
                    case coder.internal.ComparisonPlotService.INPUT_EXPR

                        tmpVarInfos=varInfos([varInfos.isInputArg]);
                    case coder.internal.ComparisonPlotService.OUTPUT_EXPR

                        tmpVarInfos=varInfos([varInfos.isOutputArg]);
                    otherwise


                        return;
                    end

                    if length(tmpVarInfos)>1


                        varInfo=tmpVarInfos(min([tmpVarInfos.TextStart])==[tmpVarInfos.TextStart]);
                    else
                        varInfo=tmpVarInfos;
                    end
                    for var=varInfos
                        if var.SpecializationId==varInfo.SpecializationId
                            var.setIsInstrumentedForLogging(true);
                        end
                    end
                end

                function out=groupByFunctionNames(exprMappingInfo,normalizeFcnpath)
                    out=coder.internal.lib.Map();

                    for ii=1:length(exprMappingInfo)
                        exprInfo=exprMappingInfo(ii);
                        if normalizeFcnpath
                            [~,f,ext]=fileparts(exprInfo.FunctionPath);
                            exprFcnPath=[f,ext];
                        else
                            exprFcnPath=exprInfo.FunctionPath;
                        end
                        fullFcnID=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(exprFcnPath,exprInfo.FunctionName,num2str(exprInfo.SpecializationNumber));
                        if out.isKey(fullFcnID)
                            t=out(fullFcnID);
                            t=[t,exprInfo];
                        else

                            t=exprInfo;
                        end
                        out(fullFcnID)=t;
                    end
                end
            end




            function outputFiles=appendCoderReportInfo(report,outputFiles)
                if coder.internal.Float2FixedConverter.isCodegenSuccess(report)...
                    &&~isempty(outputFiles)
                    outputFiles.mexFiles{end+1}=fullfile(report.summary.outDirectory,[report.summary.fileName,'.',mexext()]);
                    outputFiles.reports{end+1}=report.summary.mainhtml;
                end
                if isfield(report,'inference')

                end
            end




            function[msgs,logFileName]=handleTranslationMessage(translationMsgs)
                [logFileName,isFail]=writeLogFile(translationMsgs);
                msgs=coder.internal.lib.Message.getNonLogMessages(translationMsgs);
                if isFail
                    warning('Coder:FXPCONV:INTERNALERROR',this.message('Coder:FxpConvDisp:FXPCONVDISP:WritingLogMessageFailed').getString());
                    logFileName='';
                elseif~isempty(logFileName)
                    [~,fName,ext]=fileparts(logFileName);
                    link=['<a href="matlab:edit(''',logFileName,''')">',[fName,ext],'</a>'];
                    disp(sprintf('### %s',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:Float2FixedConversionLog',link)));
                end

                function[logFileName,err]=writeLogFile(msgs)
                    logFileName='';
                    err=false;
                    try
                        textContent='';

                        infoContent='';
                        infoMsgs=coder.internal.lib.Message.getMessagesOfType(msgs,coder.internal.lib.Message.USRLOG);
                        if~isempty(infoMsgs)
                            infoContent=message('Coder:FxpConvDisp:FXPCONVDISP:InfoMessages').getString();
                            infoContent=[infoContent,getTextContentFor(infoMsgs)];
                        end

                        warningsContent='';
                        warnMsgs=coder.internal.lib.Message.getMessagesOfType(msgs,coder.internal.lib.Message.WARN);
                        if~isempty(warnMsgs)
                            warningsContent=message('Coder:FxpConvDisp:FXPCONVDISP:LogWarningMessages').getString();
                            warningsContent=[warningsContent,getTextContentFor(warnMsgs)];
                        end

                        errorsContent='';
                        errMsgs=coder.internal.lib.Message.getMessagesOfType(msgs,coder.internal.lib.Message.ERR);
                        if~isempty(errMsgs)
                            errorsContent=message('Coder:FxpConvDisp:FXPCONVDISP:LogErrorMessages').getString();
                            errorsContent=[errorsContent,getTextContentFor(errMsgs)];
                        end

                        if~isempty(infoContent)||~isempty(warningsContent)||~isempty(errorsContent)
                            textContent=strjoin({errorsContent,warningsContent,infoContent},newline);
                        end

                        if~isempty(textContent)
                            logFileName=fullfile(this.fxpCfg.OutputFilesDirectory,[fixptDNames{1},'_log.txt']);
                            coder.internal.Helper.writeFile(logFileName,textContent);
                        end
                    catch
                        err=true;
                    end

                    function textContent=getTextContentFor(msgs)
                        textContent='';
                        for ii=1:length(msgs)
                            msg=msgs(ii);
                            msgText=msg.text;
                            textWithFileInfo=message('Coder:FxpConvDisp:FXPCONVDISP:LogMessage',msg.file,msg.node.lineno,msg.node.charno,msgText).getString();
                            textContent=[textContent,newline,textWithFileInfo];
                        end
                    end
                end
            end

            function printLinksForWrappers(fixptDNames,fixptWrapperNames)
                for mm=1:length(fixptDNames)
                    dFixPt=fixptDNames{mm};
                    wrapperFixPt=fixptWrapperNames{mm};
                    printLinksForDesignWrapper(dFixPt,wrapperFixPt);
                end

                function printLinksForDesignWrapper(dNameFixPt,dNameFixptWrapper)
                    if~this.fxpCfg.TransformF2FInIR()
                        outDesignPath=fullfile(this.fxpCfg.OutputFilesDirectory,[dNameFixPt,'.m']);
                        link=['<a href="matlab:edit(''',outDesignPath,''')">',dNameFixPt,'</a>'];
                        disp(sprintf('### %s',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genFixPtMLCode',link)));%#ok<*DSPS>
                    end
                    hasWrapper=true;
                    if this.fxpCfg.TransformF2FInIR()&&this.fxpCfg.DoubleToSingle
                        hasWrapper=false;
                    end
                    if hasWrapper
                        outWrapperPath=fullfile(this.fxpCfg.OutputFilesDirectory,[dNameFixptWrapper,'.m']);
                        link=['<a href="matlab:edit(''',outWrapperPath,''')">',dNameFixptWrapper,'</a>'];
                        disp(sprintf('### %s',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genFixPtWrapper',link)));
                    end

                    if~isempty(typesTableName)
                        outTypesTablePath=fullfile(this.fxpCfg.OutputFilesDirectory,[typesTableName,'.m']);
                        link=['<a href="matlab:edit(''',outTypesTablePath,''')">',typesTableName,'</a>'];
                        disp(sprintf('### %s',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:genTypeProposalTable',link)));
                    end
                end
            end
        end




        function[coderReport,mexFileName]=buildFixedPointCode(this,buildForOverflowDetection)
            coderReport=[];
            fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',1);

            outPath=this.fxpCfg.OutputFilesDirectory;
            prjDir=this.fxpCfg.DesignDirectory;



            setupInfo=setup(prjDir,outPath,this.fxpCfg.CodegenWorkDirectory);
            c=onCleanup(@()cleanup(setupInfo));

            try
                exInputs=this.inputTypeSpecifications;
                dName=this.DesignFunctionNames;
                dNameFixPt=cellfun(@(d)this.getFixPtDesignName(d),dName,'UniformOutput',false);
                dNameFixptWrapper=cellfun(@(d)this.getFixPtWrapperName(d),dName,'UniformOutput',false);
                pEP=dName{1};
                pEPFixptWrapper=this.getFixPtWrapperName(pEP);

                fCtrl=coder.internal.FeatureControl;





                if this.UseCoderForCodegen
                else
                    fCtrl.DisableFiaccelFiIOCheck=true;
                end

                if buildForOverflowDetection
                    fCtrl.HighlightPotentialDataTypeIssues=false;
                    fCtrl.LogHighlightPotentialDataTypeIssues=false;
                    exInputs=coder.internal.makeFiTypesScaledDouble(exInputs);
                else
                    fCtrl.HighlightPotentialDataTypeIssues=this.fxpCfg.HighlightPotentialDataTypeIssues;
                    fCtrl.LogHighlightPotentialDataTypeIssues=this.fxpCfg.LogHighlightPotentialDataTypeIssues;
                end

                mexFilesOutputDir=fullfile(this.fxpCfg.CodegenWorkDirectory,pEPFixptWrapper);

                compileFixptAsEP=false;

                enableIOLoggingInstrumentation=(2==coder.internal.f2ffeature('MEXLOGGING'))&&~buildForOverflowDetection;

                if compileFixptAsEP&&enableIOLoggingInstrumentation&&...
                    ~this.fxpCfg.DoubleToSingle&&~this.fxpCfg.TransformF2FInIR()


                    numEP=2;
                else


                    numEP=1;
                end




                designsArgsList=cell(1,numEP*3*length(dNameFixptWrapper));
                for ll=1:length(dNameFixptWrapper)
                    if this.fxpCfg.DoubleToSingle&&this.fxpCfg.TransformF2FInIR()


                        designsArgsList{(ll-1)*3+1}=dName{ll};
                    else
                        designsArgsList{(ll-1)*3+1}=dNameFixptWrapper{ll};
                    end
                    designsArgsList{(ll-1)*3+2}='-args';
                    designsArgsList{(ll-1)*3+3}=exInputs{ll};


                    if compileFixptAsEP&&enableIOLoggingInstrumentation&&...
                        ~this.fxpCfg.DoubleToSingle&&~this.fxpCfg.TransformF2FInIR()

                        designsArgsList{(ll-1)*3+4}=dNameFixPt{ll};
                        designsArgsList{(ll-1)*3+5}='-args';
                        designsArgsList{(ll-1)*3+6}=this.fixedInVals{ll};
                    end
                end

                if enableIOLoggingInstrumentation

                    designsArgsList{end+1}=coder.internal.LoggerService.LOGSTMTS_ENTRY_POINT;
                    designsArgsList{end+1}='-args';
                    designsArgsList{end+1}=coder.internal.LoggerService.LOGSTMTS_ENTRY_POINT_EXAMPLE_INPUTS;


                    designsArgsList{end+1}=coder.internal.LoggerService.FETCH_CODER_LOGGER_ENTRY_POINT;
                    designsArgsList{end+1}='-args';
                    designsArgsList{end+1}=coder.internal.LoggerService.FETCH_CODER_LOGGER_ENTRY_POINT_EXAMPLE_INPUTS;
                end

                codegenArgs={'-feature',fCtrl,'-report','-d',mexFilesOutputDir};



                if this.UseCoderForCodegen&&false
                    codegenArgs{end+1}='-coder';


                    mexCfg=this.fxpCfg.F2FMexConfig;
                    mexCfg.ConstantInputs='Remove';
                else


                    mexCfg=coder.mexconfig;
                end
                codegenArgs=[codegenArgs,{'-config',mexCfg}];

                if this.fxpCfg.TransformF2FInIR()
                    cppcfg=this.createCppConfig();

                    if enableIOLoggingInstrumentation
                        cppcfg.LogFunctionExpressions=true;
                        cppcfg.LogFunctionInputsAndOutputs=false;
                    end
                    mexCfg.F2FConfig=cppcfg;
                else
                    if enableIOLoggingInstrumentation
                        cppcfg=internal.float2fixed.F2FConfig;
                        cppcfg.F2FEnabled=true;
                        cppcfg.ApplyTypeAnnotations=false;
                        cppcfg.TransformOperators=false;
                        cppcfg.LogFunctionExpressions=true;
                        cppcfg.LogFunctionInputsAndOutputs=false;
                        mexCfg.F2FConfig=cppcfg;
                    end
                end

                if~isempty(this.floatGlobalTypes)




                    glbVarNames=cellfun(@(t)t.Name,this.floatGlobalTypes,'UniformOutput',false);
                    [globalNumericTypes,fimathList]=this.fcnInfoRegistry.getGlobalVarNumerictypes(glbVarNames);

                    if this.fxpCfg.DoubleToSingle
                        this.fixedGlobalTypes=coder.internal.makeDoubleTypesSingle(this.floatGlobalTypes);
                    else
                        this.fixedGlobalTypes=coder.internal.DesignTransformer.convertTypesToFixPt(this.floatGlobalTypes,globalNumericTypes,fimathList);
                    end

                    assert(~isempty(this.fixedGlobalTypes));



                    fxpGlbTypCount=length(this.fixedGlobalTypes);
                    for pp=fxpGlbTypCount:-1:1
                        type=this.fixedGlobalTypes{pp};
                        if this.globalUniqNameMap.isKey(type.Name)
                            psuedoName=this.globalUniqNameMap(type.Name);
                            type.Name=psuedoName;
                            if buildForOverflowDetection
                                this.fixedGlobalTypes{pp}=coder.internal.makeFiTypesScaledDouble(type);
                            else
                                this.fixedGlobalTypes{pp}=type;
                            end





                        end
                    end







                    codegenArgs=[codegenArgs,{'-globals',coder.internal.Helper.getGlobalCodegenArgs([this.floatGlobalTypes,this.fixedGlobalTypes])}];
                end

                if buildForOverflowDetection
                    assert(this.fxpCfg.DetectFixptOverflows);

                    mexFileName=[pEPFixptWrapper,'_scaled_double_mex'];
                    mexOutputFile=fullfile(outPath,mexFileName);
                    codegenArgs=[codegenArgs,{'-o',mexOutputFile}];
                    disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:genScaledDoubleMEXfile',strjoin(dNameFixptWrapper,', ')).getString));

                    switch coder.FixPtConfig.FixptOverflowDetectionStrategy
                    case coder.FixPtConfig.FixptODS_ScaledDoubleInFixedPointCode

                        coderReport=coder.internal.cachedCodegen(@fixed.internal.buildInstrumentedMex,codegenArgs{:},designsArgsList{:});
                    case coder.FixPtConfig.FixptODS_DataTypeOverride
                        p=fipref;
                        dto=p.DataTypeOverride;
                        dtoa=p.DataTypeOverrideAppliesTo;
                        p.DataTypeOverride='ScaledDoubles';
                        p.DataTypeOverrideAppliesTo='Fixed-point';
                        restoreDTOA=onCleanup(@()fipref('DataTypeOverrideAppliesTo',dtoa));
                        restoreDTO=onCleanup(@()fipref('DataTypeOverride',dto));
                        coderReport=coder.internal.cachedCodegen(@fixed.internal.buildInstrumentedMex,codegenArgs{:},designsArgsList{:});
                    case coder.FixPtConfig.FixptODS_FiCastFunction
                        assert(false);
                    otherwise
                        assert(false);
                    end

                    if coder.internal.Float2FixedConverter.isCodegenSuccess(coderReport)
                        this.fixptSDFcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;
                        updateRegistryWithInference(this.fixptSDFcnInfoRegistry,dName,dNameFixPt,coderReport,this.fixedGlobalTypes);
                    end
                else
                    mexFileName=[pEPFixptWrapper,'_mex'];
                    mexOutputFile=fullfile(outPath,mexFileName);
                    disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:genMEXfile',strjoin(dNameFixptWrapper,', ')).getString));
                    codegenArgs=[codegenArgs,{'-o',mexOutputFile}];
                    coderReport=coder.internal.cachedCodegen(@fixed.internal.buildInstrumentedMex,codegenArgs{:},designsArgsList{:});

                    if coder.internal.Float2FixedConverter.isCodegenSuccess(coderReport)
                        this.fixptFcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;
                        updateRegistryWithInference(this.fixptFcnInfoRegistry,dName,dNameFixPt,coderReport,this.fixedGlobalTypes);
                    end
                end
            catch me
                disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:examineErrorReport').getString));
                rethrow(me);
            end







            function setupInfo=setup(prjDir,outputPath,~)
                setupInfo.OrigDir=pwd;

                setupInfo.OrigPath=path;




                addpath(prjDir);

                cd(outputPath);
            end

            function cleanup(setupInfo)

                cd(setupInfo.OrigDir);

                path(setupInfo.OrigPath);
            end



            function updateRegistryWithInference(registry,dNames,dNameFixPt,coderReport,fixedGlobalTypes)
                assert(length(dNames)==length(dNameFixPt));
                userWrittenFunctions=getUserWrittenFncs();
                coder.internal.FcnInfoRegistryBuilder.populateFcnInfoRegistryFromInferenceInfo(coderReport.inference...
                ,dNameFixPt...
                ,userWrittenFunctions...
                ,registry...
                ,fixedGlobalTypes...
                ,this.fxpCfg.DebugEnabled);



                function fcns=getUserWrittenFncs()
                    fcns=coder.internal.lib.Map();
                    fcnTypeInfos=this.fcnInfoRegistry.getAllFunctionTypeInfos();
                    for ii=1:length(fcnTypeInfos)
                        fcnTypeInfo=fcnTypeInfos{ii};
                        generatedFcnName=fcnTypeInfo.specializationName;



                        epIdx=strcmp(generatedFcnName,dNames);
                        if any(epIdx)
                            if coder.FixPtConfig.TransformF2FInIR()
                                generatedFcnName=dNames{epIdx};
                            else
                                generatedFcnName=dNameFixPt{epIdx};
                            end
                        end
                        fcns.add(generatedFcnName,true);
                    end
                end
            end
            fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0);
        end

        function r=DoubleToSingle(this)
            r=this.fxpCfg.DoubleToSingle;
        end

        function cfg=createCppConfig(this)
            cfg=internal.float2fixed.F2FConfig;
            if this.fxpCfg.DoubleToSingle()
                cfg.DoubleToSingle=true;
                return;
            end

            cfg.DataTypesFunctionName='FixedPointTypes';

            replacements=this.fxpCfg.getFunctionReplacementMap;
            fcns=replacements.keys();
            for ff=1:length(fcns)
                fcn=fcns{ff};
                rep=replacements(fcn);
                cfg.addFunctionReplacement(fcn,rep)
            end
            builtins={'eye','false','ones','permute','repmat','reshape','shiftdim','sort','sub2ind','true','zeros'};
            for ii=1:numel(builtins)
                fcn=builtins{ii};
                cfg.addFunctionReplacement(fcn,[fcn,'x']);
            end

            T=feval(@FixedPointTypes);
            fcns=fieldnames(T);
            fcnsToTransform=strjoin(fcns',' , ');

            cfg.FunctionsToTransform=fcnsToTransform;
        end


        function copySummary=copyFixPtFilesFromCodegenToOutputDir(this,dNames,dNamesFixPt,dNamesFixptWrapper,typesTableName,outTypesTablePath,~)


            copySummary.mcosFiles={};
            if coder.internal.Float2FixedConverter.supportMCOSClasses
                files=what(this.fxpCfg.CodegenWorkDirectory);
                for ff=1:length(files.m)
                    switch files.m{ff}
                    case strcat(dNamesFixPt,'.m'),continue;
                    case strcat(dNamesFixptWrapper,'.m'),continue;
                    case 'FixedPointTypes.m',continue;
                    end

                    workDirMCOSFile=fullfile(this.fxpCfg.CodegenWorkDirectory,files.m{ff});
                    this.insertHeaders({workDirMCOSFile});
                    outClassPath=fullfile(this.fxpCfg.OutputFilesDirectory,files.m{ff});
                    coder.internal.Helper.fileCopyIfDifferent(workDirMCOSFile,outClassPath);
                    copySummary.mcosFiles{end+1}=outClassPath;

                    link=['<a href="matlab:edit(''',outClassPath,''')">',files.m{ff},'</a>'];
                    disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:genFixPtMLCode',link).getString));
                end
            end

            if~coder.FixPtConfig.TransformF2FInIR()
                initialZeros=zeros(size(dNamesFixPt));
                copySummary.designFiles=struct(...
                'originalName',initialZeros,...
                'convertedName',initialZeros,...
                'convertedPath',initialZeros,...
                'wrapperPath',initialZeros);
            else
                copySummary.designFiles=[];
            end



            assert(length(dNamesFixPt)==length(dNamesFixptWrapper));
            for ii=1:length(dNamesFixPt)
                fixptDesign=dNamesFixPt{ii};
                fixptWrapper=dNamesFixptWrapper{ii};

                workDirDesignFile=fullfile(this.fxpCfg.CodegenWorkDirectory,[fixptDesign,'.m']);
                workDirWrapperFile=fullfile(this.fxpCfg.CodegenWorkDirectory,[fixptWrapper,'.m']);
                if coder.FixPtConfig.TransformF2FInIR()
                    if this.fxpCfg.DoubleToSingle

                        mlFilesList={};
                    else
                        mlFilesList={workDirWrapperFile};
                    end
                else
                    mlFilesList={workDirDesignFile,workDirWrapperFile};
                end
                if~isempty(mlFilesList)
                    this.insertHeaders(mlFilesList);
                end

                outDesignPath=fullfile(this.fxpCfg.OutputFilesDirectory,[fixptDesign,'.m']);
                outWrapperPath=fullfile(this.fxpCfg.OutputFilesDirectory,[fixptWrapper,'.m']);
                if~coder.FixPtConfig.TransformF2FInIR()

                    coder.internal.Helper.fileCopyIfDifferent(workDirDesignFile,outDesignPath);
                    if this.MLFB.isConvertingMLFB
                        sfId=sfprivate('block2chart',this.MLFB.fixptMlfbH);
                        chart=idToHandle(slroot,sfId);
                        if~isempty(chart)
                            code=[fileread(workDirWrapperFile),newline,fileread(workDirDesignFile)];
                            chart.Script=code;
                        end
                    end
                end

                if~isempty(mlFilesList)

                    coder.internal.Helper.fileCopyIfDifferent(workDirWrapperFile,outWrapperPath);


                    copySummary.designFiles(ii).originalName=dNames{ii};
                    copySummary.designFiles(ii).convertedName=fixptDesign;
                    copySummary.designFiles(ii).convertedPath=outDesignPath;
                    copySummary.designFiles(ii).wrapperPath=outWrapperPath;
                end

                if~isempty(outTypesTablePath)

                    coder.internal.Helper.fileCopyIfDifferent(fullfile(this.fxpCfg.CodegenWorkDirectory,[typesTableName,'.m']),outTypesTablePath);
                end
            end
        end


        function copyFilesFromCodegenToOutputDir(this,fileName)
            mExt='.m';
            codegenDirFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,[fileName,mExt]);
            outputDirFilePath=fullfile(this.fxpCfg.OutputFilesDirectory,[fileName,mExt]);
            coder.internal.Helper.fileCopyIfDifferent(codegenDirFilePath,outputDirFilePath);
        end


        function copyFilesFromOutputToCodegenDir(this,fileName)
            mExt='.m';
            codegenDirFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,[fileName,mExt]);
            outputDirFilePath=fullfile(this.fxpCfg.OutputFilesDirectory,[fileName,mExt]);
            coder.internal.Helper.fileCopyIfDifferent(outputDirFilePath,codegenDirFilePath);
        end



        function cpyDepTBFilesOpDirToCodegenDir(this,designName)
            mExt='.m';
            dcMap=this.getDependencyContainerForTB();
            depConts=dcMap.values('array');
            copyfiles([depConts.depFuncNames]);
            function copyfiles(depFuncNames)
                for ii=1:length(depFuncNames)
                    depFunName=depFuncNames{ii};

                    if~strcmp(depFunName,designName)
                        codegenDirFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,[depFunName,mExt]);


                        if 2~=exist(codegenDirFilePath,'file')

                            this.copyFilesFromOutputToCodegenDir(depFunName);
                        end
                    end
                end
            end
        end


        function[messages,reportFile]=verifyFixedPoint(this,tbNames)
            messages=coder.internal.lib.Message.empty();
            if nargin<2
                tbNames=this.fxpCfg.TestBenchName;
            end

            if ischar(tbNames)
                tbNames={tbNames};
            end

            disp(sprintf('\n============= %s ==============\n',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:step4Header')));

            origWarnState=coder.internal.Helper.changeBacktraceWarning('off');
            cleanUp=onCleanup(@()coder.internal.Helper.changeBacktraceWarning('reset',origWarnState));


            this.coderLoggedErrorData=coder.internal.Float2FixedConverter.getErrorStruct();
            tRunSim=tic;

            plotsManager=coder.internal.PlotsManager();


            if this.fxpCfg.DetectFixptOverflows
                messages=this.runFixedPointSimulation(tbNames,false,true,plotsManager);
                fprintf('\n\n\n\n')
            end

            dNames=this.DesignFunctionNames;

            if this.fxpCfg.LogIOForComparisonPlotting

                enableInstrumentation=false;
                bLogIOForComparisionPlotting=true;

                epHasIO=zeros(size(dNames));
                for ii=1:length(dNames)
                    dif=this.createDIF(dNames{ii});
                    epHasIO(ii)=~isempty(dif.inportNames)||~isempty(dif.outportNames);
                end
                isOldLogging=2~=coder.internal.f2ffeature('MEXLOGGING');

                if~any(epHasIO)&&...
                    (isOldLogging||~this.isGUIWorkflow)
                    bLogIOForComparisionPlotting=false;
                    warning(message('Coder:FXPCONV:NoIOForDesign',strjoin(dNames,',')));
                end
                if bLogIOForComparisionPlotting
                    this.runFloatingPointSimulation(tbNames,enableInstrumentation,bLogIOForComparisionPlotting,plotsManager);
                end
                this.runFixedPointSimulation(tbNames,bLogIOForComparisionPlotting,false,plotsManager);

                if bLogIOForComparisionPlotting
                    performOrigToConvNameMapping();
                    generatePlots(plotsManager,dNames);
                end
            else
                bLogIOForComparisionPlotting=false;
                this.runFixedPointSimulation(tbNames,bLogIOForComparisionPlotting,false,plotsManager);
            end

            launchReport=this.fxpCfg.LaunchNumericTypesReport;
            pEP=this.DesignFunctionNames{1};
            fcnName=[pEP,this.fxpCfg.FixPtFileNameSuffix];
            reportName=[fcnName,'_report.html'];
            reportFile=this.printFixptTypeReport(reportName,launchReport,this.fixptFcnInfoRegistry);



            if false&&this.fxpCfg.DetectFixptOverflows
                fcnName=[this.DesignFunctionNames,this.fxpCfg.FixPtFileNameSuffix];
                reportName=[fcnName,'_scaled_doubles_report.html'];
                this.printFixptTypeReport(reportName,launchReport,this.fixptSDFcnInfoRegistry);
            end

            disp(sprintf('### %s: %18.4f %s'...
            ,this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:elapsedTime')...
            ,toc(tRunSim)...
            ,this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:sec')));



            this.coderLoggedErrorData(1)=[];





            function performOrigToConvNameMapping()
                if 2~=coder.internal.f2ffeature('MEXLOGGING')
                    return;
                end

                if isempty(this.coderLoggedFixedPtData)


                    return;
                end



                fixedData=coder.internal.lib.Map();
                keys=this.coderLoggedFixedPtData.keys;
                for jj=1:length(keys)
                    key=keys{jj};
                    [tmpScriptPath,tmpFcn,tmpSplID]=internal.mtree.FunctionTypeInfo.SplitFullUniqueName(key);

                    [~,fileN,ext]=fileparts(tmpScriptPath);
                    normalizedKey=internal.mtree.FunctionTypeInfo.BuildUniqueFullName([fileN,ext],tmpFcn,tmpSplID);
                    fixedData(normalizedKey)=this.coderLoggedFixedPtData(key);
                end
                this.coderLoggedFixedPtData=fixedData;

                keys=this.coderLoggedFloatingPtData.keys;
                this.floatToFixedNameMap=coder.internal.lib.Map();
                for jj=1:length(keys)
                    key=keys{jj};
                    if this.coderLoggedDataVarInfo.isKey(key)

                        fcnInfo=this.coderLoggedDataVarInfo(key);
                        [~,convertedFcnName,ext]=fileparts(fcnInfo.convertedFcnScriptPath);
                        fixedKey=internal.mtree.FunctionTypeInfo.BuildUniqueFullName([convertedFcnName,ext],fcnInfo.convertedFcnName,fcnInfo.convertedSpecializationId);
                        this.floatToFixedNameMap(key)=fixedKey;
                    end
                end
            end

            function generatePlots(plotsManager,dNames)

                sdiRunSuffix=datestr(now);
                if 2==coder.internal.f2ffeature('MEXLOGGING')
                    this.coderLoggedFloatingPtData;



                    keys=this.coderLoggedFloatingPtData.keys;
                    for jj=1:length(keys)

                        fcnUniqueFullName=keys{jj};
                        [floatVals,fixedVals]=this.fetchFloatFixedLoggedValsNew(fcnUniqueFullName);
                        if~isempty(floatVals)&&~isempty(fixedVals)
                            fcnInfo=this.coderLoggedDataVarInfo(fcnUniqueFullName);
                            dName=fcnInfo.origFcnName;
                            this.handlePlot(fcnInfo.origFcnScriptPath,dName,fcnInfo.origSpecializationId,any(strcmp(dNames,dName)),floatVals,fixedVals,sdiRunSuffix,plotsManager);
                        end
                    end
                else
                    for jj=1:length(dNames)
                        dName=dNames{jj};
                        fcnInfo=this.fcnInfoRegistry.getFunctionTypeInfo(dNames{jj});

                        [floatVals,fixedVals]=fetchFloatFixedLoggedVals(dName);
                        this.handlePlot(fcnInfo.scriptPath,dName,fcnInfo.specializationId,any(strcmp(dNames,dName)),floatVals,fixedVals,sdiRunSuffix,plotsManager)
                    end
                end


                function[floatVals,fixedVals]=fetchFloatFixedLoggedVals(dName)
                    floatVals=this.loggedIOValuesFromFloatingPointSim(dName);
                    fixedVals=this.loggedIOValuesFromFixedPointSim(dName);
                    floatVals.exprs=[];
                    fixedVals.exprs=[];
                end
            end
        end

        function desc=getPlotTitleFixedPointDescription(this)
            if this.DoubleToSingle
                desc='single';
            else
                if this.fxpCfg.ProposeFractionLengthsForDefaultWordLength
                    desc=sprintf('%d-bit WL',this.fxpCfg.DefaultWordLength);
                else
                    desc=sprintf('%d-bit FL',this.fxpCfg.DefaultFractionLength);
                end
            end
        end

        function messages=runFixedPointSimulation(this,tbNames,bLogIOForComparisonPlotting,detectFixPtOverflows,plotsManager)
            if detectFixPtOverflows

                plotsManager.newGroup({'Testbench:','scaled doubles'});
            else

                plotsManager.newGroup({'Testbench:',this.getPlotTitleFixedPointDescription()});
            end
            messages=[];
            [setupInfo,postBuildSetup]=doSetup(this.fxpCfg.CodegenWorkDirectory,this.fxpCfg.OutputFilesDirectory);
            cleanup=onCleanup(@()this.runCleanup(setupInfo));

            dNames=this.DesignFunctionNames;
            pEP=dNames{1};
            pEPWrapperName=this.getFixPtWrapperName(pEP);

            if detectFixPtOverflows
                mexFileName=[pEPWrapperName,'_scaled_double_mex'];
            else
                mexFileName=[pEPWrapperName,'_mex'];
            end

            mexFilePath=fullfile(this.fxpCfg.OutputFilesDirectory,mexFileName);
            if detectFixPtOverflows&&(~exist([mexFilePath,'.',mexext],'file')||isempty(this.fixptSDFcnInfoRegistry))



                coder.internal.Helper.fevalInPath(@()this.buildFixedPointCode(true)...
                ,this.fxpCfg.OutputFilesDirectory);

            end

            postBuildSetup([mexFileName,'.',mexext]);

            inputArgNames=cellfun(@(d)this.createDIF(d).inportNames,dNames,'UniformOutput',false);

            tbExecCfg=buildTBExecConfig(dNames);

            if bLogIOForComparisonPlotting
                setupDataLogging(tbExecCfg,mexFileName,dNames,this.fxpCfg.CodegenWorkDirectory);
            end

            tRunSim=tic;
            for ii=1:length(tbNames)
                tb=tbNames{ii};

                if detectFixPtOverflows
                    disp(sprintf('### %s',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:beginFixPtScaledDoubleSim',tb)));
                else
                    disp(sprintf('### %s',this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:beginFixPtSim',tb)));
                end


                runSimFcn=@runSimulation;

                outDirForEvalTBSim=this.fxpCfg.DesignDirectory;
                runSimFcn=withScopeProtection(runSimFcn,outDirForEvalTBSim);

                runSimFcn(tbExecCfg,tb,dNames,mexFileName);
            end

            if bLogIOForComparisonPlotting
                collectLoggedData(mexFileName,dNames);
            end

            this.cleanupFixedPtGlobals();

            updateFixptFcnInfoRegistry();

            if detectFixPtOverflows
                messages=this.detectOverflowErrors(this.fixptSDFcnInfoRegistry,this.fixptSDExpressionInfo);
                elapsedTimeStr=this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:elapsedFixPtScaledDoubleSimTime');
            else
                elapsedTimeStr=this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:elapsedFixPtSimTime');
            end

            disp(sprintf('### %s in %8.4f %s'...
            ,elapsedTimeStr...
            ,toc(tRunSim)...
            ,this.getMessageText('Coder:FxpConvDisp:FXPCONVDISP:sec')));



            function[setupInfo,postBuildSetup]=doSetup(workingDir,outputDir)
                setupInfo.currDir=pwd;
                setupInfo.pathBak=path;
                setupInfo.projectDir=workingDir;
clear mex;
                [~,~,~]=rmdir(workingDir,'s');
                [~,~,~]=mkdir(workingDir);
                addpath(workingDir);
                setupInfo.warnState=coder.internal.Helper.changeBacktraceWarning('off');


                postBuildSetup=@copyMexToOutputDir;
                function copyMexToOutputDir(mexFileName)
                    src=fullfile(outputDir,mexFileName);
                    dst=fullfile(workingDir,mexFileName);
                    coder.internal.Helper.fileCopy(src,dst);
                end
            end


            function fcn=withScopeProtection(runSimFcn,outDirForEvalTBSim)
                fcn=@runSimWithTBEvalSimFcn;
                function runSimWithTBEvalSimFcn(tbExecCfg,tb,dNames,mexFileName)
                    simFile=tb;
                    try


                        [simFile,deleteSimFile]=coder.internal.Float2FixedConverter.createEvalTBSimFunction(tb,outDirForEvalTBSim);

                        simFilePath=fullfile(outDirForEvalTBSim,[simFile,'.m']);
                        c=onCleanup(@()deleteEvalSimFcn(deleteSimFile,simFilePath));

                        runSimFcn(tbExecCfg,simFile,dNames,mexFileName);
                    catch ex
                        simEx=MException(ex.identifier,strrep(ex.message,simFile,tb));
                        simEx.addCause(ex);
                        throw(simEx);
                    end
                    function deleteEvalSimFcn(doDelete,simFilePath)
                        if doDelete
                            coder.internal.Helper.deleteFile(simFilePath);
                        end
                    end
                end

            end

            function runSimulation(tbExecCfg,tb,dNames,mexFcn)
                try
                    if detectFixPtOverflows
                        switch coder.FixPtConfig.FixptOverflowDetectionStrategy
                        case coder.FixPtConfig.FixptODS_ScaledDoubleInFixedPointCode
                            coder.internal.runTest(tbExecCfg,tb,dNames,mexFcn);
                        case coder.FixPtConfig.FixptODS_DataTypeOverride
                            p=fipref;
                            dto=p.DataTypeOverride;
                            dtoa=p.DataTypeOverrideAppliesTo;
                            p.DataTypeOverride='ScaledDoubles';
                            p.DataTypeOverrideAppliesTo='Fixed-point';
                            restoreDTOA=onCleanup(@()fipref('DataTypeOverrideAppliesTo',dtoa));
                            restoreDTO=onCleanup(@()fipref('DataTypeOverride',dto));
                            coder.internal.runTest(tbExecCfg,tb,dNames,mexFcn);
                        case coder.FixPtConfig.FixptODS_FiCastFunction
                            assert(false);
                        otherwise
                            assert(false);
                        end
                    else
                        if this.fxpCfg.DoubleToSingle
                            if this.fxpCfg.TransformF2FInIR
                                tbExecCfg.setDoubleToSingle(true);
                            end
                            coder.internal.runTest(tbExecCfg,tb,dNames,mexFcn);
                        else
                            coder.internal.runTest(tbExecCfg,tb,dNames,mexFcn);
                        end
                    end
                catch evalEx



                    customexp=MException('Coder:FXPCONV:floatingPointSimulationException',strrep(evalEx.getReport('basic','hyperlinks','on'),'\','/'));
                    throw(customexp);
                end
            end

            function tbExecCfg=buildTBExecConfig(dNames)
                isMexInDesignPath=false;
                isEntryPointCompiled=true;
                tbExecCfg=coder.internal.TestBenchExecConfig(isMexInDesignPath,isEntryPointCompiled);




                m=containers.Map();
                for mm=1:length(dNames)
                    dn=dNames{mm};
                    if this.fxpCfg.DoubleToSingle&&this.fxpCfg.TransformF2FInIR
                        m(dn)=dn;
                    else
                        m(dn)=this.getFixPtWrapperName(dn);
                    end
                end
                tbExecCfg.setActualEntryPointNamesMap(m);
            end

            function updateFixptFcnInfoRegistry()
                addpath(this.fxpCfg.OutputFilesDirectory);
                try
                    if detectFixPtOverflows

                        [this.fixptSDFcnInfoRegistry,this.fixptSDExpressionInfo]=updateFcnInfoRegistryAndExprInfo(this.fixptSDFcnInfoRegistry);
                    else
                        [this.fixptFcnInfoRegistry,this.fixptExpressionInfo]=updateFcnInfoRegistryAndExprInfo(this.fixptFcnInfoRegistry);
                    end
                catch ex
                    rmpath(this.fxpCfg.OutputFilesDirectory);
                    throwAsCaller(ex);
                end
                rmpath(this.fxpCfg.OutputFilesDirectory);
            end

            function collectLoggedData(mexFileName,dNames)
                if 2==coder.internal.f2ffeature('MEXLOGGING')



                    primaryEP=dNames{1};
                    collectData(primaryEP,mexFileName);
                else
                    cellfun(@(dName)collectData(dName,mexFileName),dNames);
                end

                function collectData(dName,mexFileName)
                    dif=createLoggingDIF(dName);
                    [inputVarDimIndices,outputVarDimIndices]=this.getVarDimIncides(dName);



                    nonVarDimDif=dif;
                    nonVarDimDif.outportNames(outputVarDimIndices)=[];
                    nonVarDimDif.inportNames(inputVarDimIndices)=[];
                    this.loggedIOValuesFromFixedPointSim(dName)=collectLoggedValues(nonVarDimDif,dif);
                    if~this.isGUIWorkflow&&any(outputVarDimIndices)
                        outArgNames=dif.outportNames;
                        if~this.isGUIWorkflow
                            warning('Coder:FXPCONV:VarDimPlotWarning',message('Coder:FXPCONV:VarDimPlotWarning',strjoin(outArgNames(outputVarDimIndices),' ,')).getString());
                        end
                    end

                    if 2==coder.internal.f2ffeature('MEXLOGGING')
                        this.coderLoggedFixedPtData=collectCoderLogValues(mexFileName,dif);
                    end
                end

                function data=collectCoderLogValues(mexFileName,dif)

                    rawData=custom_logger_lib('get_logged_data',mexFileName);
                    data=coder.internal.LoggerService.convertToMapFormat(rawData,dif);
                end

                function loggedValues=collectLoggedValues(nonVarDimDif,dif)
                    loggedValues=coder.internal.LoggerService.packageLoggedValues(nonVarDimDif);
                    coder.internal.LoggerService.clearLogValues(dif);
                end
            end

            function setupDataLogging(tbExecCfg,mexFileName,dNames,workDir)
                initAllLogIOState(dNames);
                if 2~=coder.internal.f2ffeature('MEXLOGGING')
                    cellfun(@(dName,constIndices)logSetupAndUpdateTbExecConfig(dName,constIndices,tbExecCfg,workDir)...
                    ,dNames,this.coderConstIndices);
                end
                if 2==coder.internal.f2ffeature('MEXLOGGING')
                    fcnsToLog=this.coderLoggedDataVarInfo.keys;
                    fcnScriptPaths=cell(1,length(fcnsToLog));

                    fxpFcnNames=cell(1,length(fcnsToLog));
                    varsToLogStr='';
                    for jj=1:length(fcnsToLog)
                        fcnToLog=fcnsToLog{jj};

                        fcnInfo=this.coderLoggedDataVarInfo(fcnToLog);
                        fxpFcnNames{jj}=fcnInfo.convertedFcnName;
                        varsToLog=[fcnInfo.convertedInputsToLog,fcnInfo.convertedOutputsToLog];
                        fcnScriptPaths{jj}=fcnInfo.convertedFcnScriptPath;

                        t=strjoin(varsToLog,'<>');
                        if isempty(t)
                            t=' ';
                        end
                        if 1==jj
                            varsToLogStr=[varsToLogStr,t];
                        else
                            varsToLogStr=[varsToLogStr,',',t];
                        end
                    end
                    custom_logger_lib('enable_location_logging_for_functions'...
                    ,mexFileName...
                    ,strjoin(fxpFcnNames,',')...
                    ,strjoin(fcnScriptPaths,',')...
                    ,varsToLogStr);
                end

                function logSetupAndUpdateTbExecConfig(dName,constIndices,tbExecCfg,workDir)
                    dif=createLoggingDIF(dName);


                    dif.logFcnSuffix=['_',dName];


                    dif.logFcnVarSuffix=['_',dName];

                    [inputVarDimIndices,outputVarDimIndices]=this.getVarDimIncides(dName);
                    logDataFcnName=coder.internal.LoggerService.createLocalLogDataFunctionFile(dif,workDir,constIndices,inputVarDimIndices,outputVarDimIndices);


                    tbExecCfg.setLogFcnName(dName,logDataFcnName);
                    outArgNames=dif.outportNames;
                    inputParamCount=length(dif.inportNames);
                    outputParamCount=length(outArgNames);
                    tbExecCfg.setOutputParamCount(dName,outputParamCount);
                    inLogIndices=ones(1,inputParamCount);
                    inLogIndices(inputVarDimIndices)=0;
                    outLogIndices=ones(1,outputParamCount);
                    outLogIndices(outputVarDimIndices)=0;
                    tbExecCfg.setInputOutputLogIndices(dName,inLogIndices,outLogIndices);
                end

                function initAllLogIOState(dNames)
                    if 2~=coder.internal.f2ffeature('MEXLOGGING')
                        for nn=1:length(dNames)
                            dName=dNames{nn};
                            dif=createLoggingDIF(dName);
                            coder.internal.LoggerService.clearLogValues(dif);
                            coder.internal.LoggerService.defineSimLogValues(dif);
                        end
                        this.loggedIOValuesFromFixedPointSim=[];
                    end
                end
            end

            function dif=createLoggingDIF(dName)
                dif=this.createDIF(dName);


                dif.logFcnSuffix=['_',dName];


                dif.logFcnVarSuffix=['_',dName];
            end



            function[registry,exprInfo]=updateFcnInfoRegistryAndExprInfo(registry)


                assert(~isempty(registry.registry));

                [~,coderReport]=fixed.internal.getInstrumentedVariables(mexFileName);
                dNamesFixPt=cellfun(@(d)this.getFixPtDesignName(d),dNames,'UniformOutput',false);
                [registry,exprInfo]=coder.internal.FcnInfoRegistryBuilder.updateFunctionInfoRegistry(registry,coderReport,dNamesFixPt,tbNames{1},inputArgNames,this.coderConstIndices,this.fixedGlobalTypes,this.fxpCfg.DebugEnabled);
            end
        end

        function buildCoderLoggedErrorData(this,~,floatVals,fixedVals)

            floatingPtScriptPath=coder.internal.ASCIIConversion.unsanitize(floatVals.filePath);
            floatingPtFcnName=floatVals.functionName;
            floatintPtSpecializationNum=floatVals.specializationNumber;
            fcnTypeInfo=this.fcnInfoRegistry.getFunctionTypeInfoBySpecializationAndPath(floatingPtScriptPath,floatingPtFcnName,floatintPtSpecializationNum);

            assert(~isempty(fcnTypeInfo)&&length(fcnTypeInfo)==1);
            inputVarInfos=fcnTypeInfo.getInputVarInfos();
            outputVarInfos=fcnTypeInfo.getOutputVarInfos();

            Z=coder.internal.Float2FixedConverter.getErrorStruct(...
            fcnTypeInfo.functionName,...
            fcnTypeInfo.inferenceId,...
            fcnTypeInfo.specializationName,...
            fcnTypeInfo.specializationId,...
            fcnTypeInfo.scriptPath);


            if isempty(floatVals.inputs)
                flInVars={};
            else
                flInVars=fieldnames(floatVals.inputs);
            end
            if isempty(fixedVals.inputs)
                fxpInVars={};
            else
                fxpInVars=fieldnames(fixedVals.inputs);
            end
            commonVars=intersect(flInVars,fxpInVars);
            for ii=1:length(commonVars)
                v=commonVars{ii};
                varInfo=inputVarInfos(strcmp({inputVarInfos.SymbolName},v));
                if~isempty(varInfo)&&length(varInfo)==1
                    maxErr=this.ComputeLogDataError(floatVals.inputs.(v),fixedVals.inputs.(v));
                    Z.Inputs=[Z.Inputs,coder.internal.Float2FixedConverter.getNumericalErrorInfoForVar(v,varInfo,varInfo.MxInfoLocationId,maxErr)];
                end
            end

            if isempty(floatVals.outputs)
                flOutVars={};
            else
                flOutVars=fieldnames(floatVals.outputs);
            end
            if isempty(fixedVals.outputs)
                fxpOutVars={};
            else
                fxpOutVars=fieldnames(fixedVals.outputs);
            end
            commonVars=intersect(flOutVars,fxpOutVars);
            for ii=1:length(commonVars)
                v=commonVars{ii};
                varInfo=outputVarInfos(strcmp({outputVarInfos.SymbolName},v));
                if~isempty(varInfo)&&length(varInfo)==1
                    maxErr=this.ComputeLogDataError(floatVals.outputs.(v),fixedVals.outputs.(v));
                    Z.Outputs=[Z.Outputs,coder.internal.Float2FixedConverter.getNumericalErrorInfoForVar(v,varInfo,varInfo.MxInfoLocationId,maxErr)];
                end
            end

            this.coderLoggedErrorData(end+1)=Z;
        end


        function maxDifference=ComputeLogDataError(this,floatVarVal,fixedPtVarVal)

            if isstruct(floatVarVal)
                maxDifference=struct();
                fldNames=fieldnames(floatVarVal);
                for jj=1:length(fldNames)
                    fld=fldNames{jj};
                    maxDifference.(fld)=this.ComputeLogDataError(floatVarVal.(fld),fixedPtVarVal.(fld));
                end
            else
                flatFloat=floatVarVal(1:end);
                flatFixed=fixedPtVarVal(1:end);
                maxDifference=ComputeLogDataErrorImpl(flatFloat,flatFixed);
            end


            function errorVal=ComputeLogDataErrorImpl(floatVarVal,fixedPtVarVal)

import coder.internal.plotting.PlotHelper;




                fxError=double(floatVarVal)-double(fixedPtVarVal);

                maxFxError=max(fxError(1:end));
                maxPosFxError=(maxFxError>0)*maxFxError;
                minFxError=min(fxError(1:end));
                maxNegFxError=(minFxError<0)*minFxError;
                if PlotHelper.safeAbs(maxPosFxError)>PlotHelper.safeAbs(maxNegFxError)
                    topFxError=maxPosFxError;
                else
                    topFxError=maxNegFxError;
                end

                errorVal=topFxError;
            end
        end

        function messages=detectOverflowErrors(~,fcnRegistry,expressionInfos)
            messages=coder.internal.lib.Message.empty();
            fcnTypeInfos=fcnRegistry.getAllFunctionTypeInfos();
            for ii=1:length(fcnTypeInfos)
                fcnTypeInfo=fcnTypeInfos{ii};
                uniqueId=fcnTypeInfo.uniqueId;


                if~expressionInfos.isKey(uniqueId)
                    continue;
                end

                exprInfos=expressionInfos(uniqueId);
                instrumentedMxInfoLocations=exprInfos.values();
                scriptText=fileread(fcnTypeInfo.scriptPath);

                for jj=1:length(instrumentedMxInfoLocations)
                    mxInfoLoc=instrumentedMxInfoLocations{jj};

                    switch mxInfoLoc.NodeTypeName
                    case{'outputVar','var'}
                        continue;
                    end
                    if~isempty(mxInfoLoc.RatioOfRange)&&...
                        ~isempty(mxInfoLoc.RatioOfRange{1})&&...
                        mxInfoLoc.RatioOfRange{1}>1.0
                        addOverflowMessage();
                    end
                end
            end

            function addOverflowMessage()

                textStart=mxInfoLoc.TextStart;
                textEnd=textStart+mxInfoLoc.TextLength-1;
                exprText=scriptText(textStart:textEnd);
                percentageStr=sprintf('%d',ceil(mxInfoLoc.RatioOfRange{1}*100));
                params={exprText,percentageStr};
                overflowMsg=message('Coder:FXPCONV:F2FOverflow',params{:});

                i=length(messages)+1;
                msg=coder.internal.lib.Message();
                msg.functionName=fcnTypeInfo.functionName;%#ok<*AGROW>
                msg.specializationName=fcnTypeInfo.specializationName;
                msg.file=fcnTypeInfo.scriptPath;
                msg.type='Warning';
                msg.position=mxInfoLoc.TextStart-1;
                msg.length=mxInfoLoc.TextLength;
                msg.text=overflowMsg.getString();
                msg.id=overflowMsg.Identifier;
                msg.params=params;
                messages(i)=msg;
                disp(overflowMsg.getString);
            end
        end





        function constructCoderEnabledLogListForSelected(this,varsToLogMap)
            fcnUniqIDs=varsToLogMap.keys;
            for ii=1:length(fcnUniqIDs)
                uniqID=fcnUniqIDs{ii};
                fcnInfo=this.fcnInfoRegistry.getFunctionTypeInfo(uniqID);
                if isempty(fcnInfo)


                    continue;
                end

                fcnInVarNames=fcnInfo.inputVarNames;
                fcnOutVarNames=fcnInfo.outputVarNames;
                convertedIpNames=fcnInfo.convertedFunctionInterface.inputParams;
                convertedOpNames=fcnInfo.convertedFunctionInterface.outputParams;
                isFcnConverted=fcnInfo.convertedFunctionInterface.isConverted;

                origIpsToLog={};
                origOpsToLog={};
                convertedIpsToLog={};
                convertedOpsToLog={};

                inVarInfos=fcnInfo.getInputVarInfos();
                outVarInfos=fcnInfo.getOutputVarInfos();
                inVarInfoMap=buildVarInfoMap(inVarInfos);
                outVarInfoMap=buildVarInfoMap(outVarInfos);




                origGUIIpVarsToPlot={};
                origGUIOpVarsToPlot={};
                varsToLog=varsToLogMap(uniqID);
                for jj=1:length(varsToLog)
                    varN=varsToLog{jj};
                    baseVarName=getNonStructName(varN);


                    inIndices=strcmp(baseVarName,fcnInVarNames);
                    if any(inIndices)

                        vinfo=inVarInfoMap(baseVarName);
                        isloggable=vinfo.instrumentedForLogging()&&vinfo.isLoggableType();
                        if isloggable
                            origGUIIpVarsToPlot{end+1}=varN;

                            if~any(strcmp(origIpsToLog,baseVarName))
                                origIpsToLog{end+1}=baseVarName;
                                if isFcnConverted
                                    convertedIpsToLog{end+1}=convertedIpNames{inIndices};
                                end
                            end
                        end
                    end


                    opIndices=strcmp(baseVarName,fcnOutVarNames);
                    if any(opIndices)

                        vinfo=outVarInfoMap(baseVarName);
                        isloggable=vinfo.instrumentedForLogging()&&vinfo.isLoggableType();
                        if isloggable
                            origGUIOpVarsToPlot{end+1}=varN;

                            if~any(strcmp(origOpsToLog,baseVarName))
                                origOpsToLog{end+1}=baseVarName;
                                if isFcnConverted
                                    convertedOpsToLog{end+1}=convertedOpNames{opIndices};
                                end
                            end
                        end
                    end
                end

                s.originalInputsToLog=origIpsToLog;
                s.originalOutputsToLog=origOpsToLog;
                s.convertedInputsToLog=convertedIpsToLog;
                s.convertedOutputsToLog=convertedOpsToLog;
                s.origGUIVarsToPlot=[origGUIIpVarsToPlot,origGUIOpVarsToPlot];
                s.origFcnName=fcnInfo.functionName;
                s.origSpecializationId=fcnInfo.specializationId;
                s.convertedFcnName=fcnInfo.convertedFunctionInterface.convertedName;
                s.origFcnScriptPath=fcnInfo.scriptPath;
                s.convertedFcnScriptPath=fcnInfo.convertedFunctionInterface.convertedFilePath;
                s.convertedSpecializationId=fcnInfo.convertedFunctionInterface.convertedSpecializationID;

                this.coderLoggedDataVarInfo(fcnInfo.uniqueFullName())=s;
            end






            function varInfoMap=buildVarInfoMap(varInfos)
                varInfoMap=coder.internal.lib.Map();
                for nn=1:length(varInfos)
                    varInfoMap(varInfos(nn).SymbolName)=varInfos(nn);
                end
            end

            function n=getNonStructName(varN)
                if contains(varN,'.')
                    n=strtok(varN,'.');
                else
                    n=varN;
                end
            end
        end


        function valMatFileDest=generateValueMatFile(this,filePreFix,values)
            valMatFileName=coder.internal.Float2FixedConverter.getFiValMatFileName(filePreFix);
            valMatFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,valMatFileName);
            save(valMatFilePath,'values');
            valMatFileDest=fullfile(this.fxpCfg.OutputFilesDirectory,valMatFileName);
            coder.internal.Helper.fileCopy(valMatFilePath,valMatFileDest);
        end


        function[inVals,outVals]=runTestBenchToLogData(this,designDir,dName,tbNames,logInputTypesAndBailOut,dontMex,isFixptDone)
            if(nargin<7)
                isFixptDone=false;
            end

            if ischar(tbNames)
                tbNames={tbNames};
            end

            assert(~contains(dName,'.m'),'File extension supplied with design name.');
            cellfun(@(tb)assert(~contains(tb,'.m'),'File extension supplied with test bench name.'),tbNames);
            cellfun(@(tb)assert(~contains(tb,'.mlx'),'File extension supplied with test bench name.'),tbNames);

            if nargin<5
                logInputTypesAndBailOut=false;
                dontMex=0;
            end

            if nargin<6
                dontMex=0;
            end

            if~isempty(tbNames)
                msgs=this.validateTBs(tbNames);
                if coder.internal.lib.Message.containErrorMsgs(msgs)
                    for ii=1:length(msgs)
                        msg=msgs(ii);
                        if strcmp(msg.type,coder.internal.lib.Message.ERR)
                            error(msg.getMatlabMessage());
                        end
                    end
                end
            end


            verboseDisp=~logInputTypesAndBailOut;

            setupInfo=doSetup(this,designDir,this.fxpCfg.CodegenWorkDirectory);
            cleanup=onCleanup(@()this.runCleanup(setupInfo));





            fixPtDesignFilePath=fullfile(designDir,[dName,'.m']);
            if exist(fixPtDesignFilePath,'file')==0


                designDir=this.fxpCfg.DesignDirectory;
            end

            dNameWithPath=fullfile(designDir,[dName,'.m']);
            tbNamesWithPath=cell(1,length(tbNames));
            tbExts=cell(1,length(tbNames));
            for ii=1:length(tbNames)
                tb=tbNames{ii};
                if 2==exist(fullfile(designDir,[tb,'.m']),'file')
                    tbNamesWithPath{ii}=fullfile(designDir,[tb,'.m']);
                    tbExts{ii}='.m';
                elseif 2==exist(fullfile(designDir,[tb,'.mlx']),'file')
                    tbNamesWithPath{ii}=fullfile(designDir,[tb,'.mlx']);
                    tbExts{ii}='.mlx';
                else
                    error('cannot find testbench');
                end
            end

            coder.internal.Helper.fileCopy(dNameWithPath,fullfile(this.fxpCfg.CodegenWorkDirectory,[dName,'.m']))
            cellfun(@(tbPath,mExt)copyTestBench(tbPath,mExt),tbNamesWithPath,tbExts);


            function copyTestBench(tbPath,mExt)
                [~,tb,~]=fileparts(tbPath);
                coder.internal.Helper.fileCopy(tbPath,fullfile(this.fxpCfg.CodegenWorkDirectory,[tb,mExt]))
            end

            coder.internal.Helper.commentAllAsserts(fullfile(this.fxpCfg.CodegenWorkDirectory,[dName,'.m']));
            cellfun(@(tb,mExt)coder.internal.Helper.commentAllAsserts(fullfile(this.fxpCfg.CodegenWorkDirectory,[tb,mExt])),tbNames,tbExts);


            wrapperName=strrep(dName,this.fxpCfg.FixPtFileNameSuffix,['_wrapper',this.fxpCfg.FixPtFileNameSuffix]);
            wrapperNameWithPath=fullfile(designDir,[wrapperName,'.m']);
            wrapperExists=exist(wrapperNameWithPath,'file');
            if wrapperExists
                coder.internal.Helper.fileCopy(wrapperNameWithPath,fullfile(this.fxpCfg.CodegenWorkDirectory,[wrapperName,'.m']));
                clear(wrapperName);
            end

            arrayfun(@(depCont)this.copyDependentFilesForTBToWorkDir(depCont,'.m'),this.tbDepContsMap.values('array'));
            if isFixptDone
                this.cpyDepTBFilesOpDirToCodegenDir(dName);
            end
            this.checkForFileNameMismatch(fullfile(this.fxpCfg.CodegenWorkDirectory,[dName,'.m']));

            removeClearAlls(this,this.tbDepContsMap.values('array'),...
            tbNames);


            global fxpGlobalParams;
            fxpGlobalParams=struct('designMexed',false,'runWithInstrumentationFlag',false,'simulationTime',0,'isVerboseMexOp',true,'createInputMATFile',false,'inputMatFileName',[],'createOutputMATFile',false,'outputMatFileName',[],'showMexMessages',true,'hasCoderConstInputs',false,'screenedInps',[],'coderConstIndicies',[]);
            fxpGlobalParams.screnedInps={};
            fxpGlobalParams.coderConstIndicies={};

            inVals={};
            outVals={};
            gatewayFcnName='';

            dif=this.createDIF(dNameWithPath);
            if isempty(dif.inportNames)
                return;
            end

            valFileAlreadyExists=false;
            if logInputTypesAndBailOut
                runSimulation(tbNames{1});
            else
                cellfun(@(tb)runSimulation(tb),tbNames);
            end

            function runSimulation(tbName)
                bailoutEarly=logInputTypesAndBailOut||(this.fxpCfg.SimulationIterationLimit>0);
                if logInputTypesAndBailOut
                    if(this.fxpCfg.SimulationIterationLimit>0)
                        error('Internal error: Cannot set logInputTypesAndBailOut as true and SimulationIterationLimit other than Inf at the same time');
                    end
                    simulationLimit=2;

                    dontMex=true;

                    matFileName=coder.internal.Float2FixedConverter.getFiValMatFileName(dName);
                    valMatFilePath=fullfile(this.fxpCfg.OutputFilesDirectory,matFileName);
                    if false&&(isFixptDone&&2==exist(valMatFilePath,'file'))
                        fxpGlobalParams.createInputMATFile=false;
                        fxpGlobalParams.createOutputMATFile=false;
                        vals=load(valMatFilePath);
                        vals=vals.values;
                        inVals=vals.inputArgs;
                        outVals=vals.outputArgs;
                        valFileAlreadyExists=true;



                        if isempty(inVals)
                            valFileAlreadyExists=false;
                            valMatFilePath=[];%#ok<NASGU>
                            fxpGlobalParams.createInputMATFile=true;
                            fxpGlobalParams.createOutputMATFile=true;
                        else
                            return;
                        end
                    else
                        valFileAlreadyExists=false;
                        valMatFilePath=[];%#ok<NASGU>
                        fxpGlobalParams.createInputMATFile=true;
                        fxpGlobalParams.createOutputMATFile=true;
                    end
                else
                    inVals=this.inVals;
                    outVals=this.outVals;
                    fxpGlobalParams.createInputMATFile=false;
                    fxpGlobalParams.createOutputMATFile=false;
                    simulationLimit=this.fxpCfg.SimulationIterationLimit;
                end

                bailoutExceptionIdentifier='Coder:FXPCONV:MATLABSimBailOut';
                coder.internal.LoggerService.createLocalLogDataFunctionFile(dif,this.fxpCfg.CodegenWorkDirectory,this.coderConstIndices,[],[],bailoutEarly,bailoutExceptionIdentifier,inVals,outVals,simulationLimit);

                if verboseDisp
                    disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:collectTbStimulus').getString));
                end

                designFileWithLogging=fullfile(this.fxpCfg.CodegenWorkDirectory,[dName,'.m']);

                coder.internal.LoggerService.addLoggingCalls(designFileWithLogging,...
                logInputTypesAndBailOut,...
                bailoutExceptionIdentifier,...
                this.fxpCfg.CodegenWorkDirectory);

                fxpGlobalParams.showMexMessages=false;

                if logInputTypesAndBailOut




                    caller=tbName;
                    callee=dName;
                else

                    caller=tbName;
                    if(wrapperExists)
                        callee=wrapperName;
                    else
                        callee=dName;
                    end
                end
                [coderConstIndices,coderConstVals]=coder.internal.Helper.getCoderConstIndices(this.inputTypes);%#ok<PROPLC>
                [~,gatewayFcnName,~,~]=this.GatewayCreationHandler(caller,callee,true,this.fxpCfg.CodegenWorkDirectory,coderConstIndices,coderConstVals);%#ok<PROPLC>

                tbSimFile=tbName;

                fxpGlobalParams.isVerboseMexOp=false;
                if dontMex



                    fxpGlobalParams.designMexed=true;
                else
                    fxpGlobalParams.designMexed=false;
                end

clear mex;
                coder.internal.LoggerService.clearLogValues(dif);
                coder.internal.LoggerService.defineSimLogValues(dif);

                if verboseDisp
                    disp(sprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:beginSim4LoggingData').getString));
                end

                try
                    assert(strcmp(pwd,this.fxpCfg.CodegenWorkDirectory),message('Coder:FxpConvDisp:FXPCONVDISP:wrongCodeGenDirLocation').getString);
                    fileName=this.createEvalTBSimFunction(tbSimFile,this.fxpCfg.CodegenWorkDirectory);
                    clear(tbSimFile);
                    eval(fileName);
                catch ex



                    if strfind(ex.message,bailoutExceptionIdentifier)
                    elseif dontMex&&strcmp(ex.message,'Return early for input computation')

                    else
                        rethrow(ex);
                    end
                end

                if verboseDisp
                    disp(sprintf('### %s %8.4f %s'...
                    ,message('Coder:FxpConvDisp:FXPCONVDISP:elapsedSim4LoggingDataTime').getString...
                    ,fxpGlobalParams.simulationTime...
                    ,message('Coder:FxpConvDisp:FXPCONVDISP:sec').getString));
                end
            end





            if(~valFileAlreadyExists&&logInputTypesAndBailOut&&~isempty(fxpGlobalParams.inputMatFileName))
                matFileName=fxpGlobalParams.inputMatFileName;
                matFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,matFileName);

                tmpVals=load(matFilePath);
                inVals=tmpVals.exInput;

                matFileName=fxpGlobalParams.outputMatFileName;
                matFilePath=fullfile(this.fxpCfg.CodegenWorkDirectory,matFileName);

                tmpVals=load(matFilePath);
                outVals=tmpVals.exOutput;

                val.inputArgs=inVals;
                val.designName=dName;
                generateValueMatFile(this,dName,val);
            end

            if logInputTypesAndBailOut
                dif=this.createDIF(dNameWithPath);
                coder.internal.LoggerService.clearLogValues(dif);
            end

clear global fxpGlobalParams;
            simulationCleanup(tbNames,dName,gatewayFcnName);


            function simulationCleanup(tbNames,dName,gatewayFcnName)



                cellfun(@(tb)clear(tb),tbNames);
                clear(dName);
                clear(gatewayFcnName);
            end
        end
    end








    methods(Access='private')

        function removeClearAlls(~,tbDepConts,tbNames)
            depFcnNames=unique([tbDepConts.depFuncNames,tbNames{:}]);
            cellfun(@(file)coder.internal.Helper.removeClearAll(file),depFcnNames);
        end

        function setupInfo=doSetup(this,explicitDesignDir,projectDir)



            setupInfo.currDir=pwd;
            setupInfo.pathBak=path;
            setupInfo.projectDir=projectDir;



            addpath(this.fxpCfg.DesignDirectory);

clear mex;

            [~,~,~]=rmdir(projectDir,'s');
            [~,~,~]=mkdir(projectDir);
            cd(projectDir);





            if exist(explicitDesignDir,'dir')
                addpath(explicitDesignDir);
            end
            setupInfo.warnState=coder.internal.Helper.changeBacktraceWarning('off');
        end
    end


    methods

        function saveConverterState(this)
            State=struct(...
            'fxpCfg',[],...
            'fcnInfoRegistry',[],...
            'fixptSDFcnInfoRegistry',[],...
            'fixptFcnInfoRegistry',[],...
            'inputTypeSpecifications',[],...
            'inputTypes',[],...
            'floatGlobalTypes',[],...
            'tbFcnInfoRegistryMap',[],...
            'tbExpressionInfoMap',[],...
            'FlattenedReport',[],...
            'coderLoggedFloatingPtData',[],...
            'coderLoggedFixedPtData',[],...
            'coderLoggedDataVarInfo',[],...
            'floatToFixedNameMap',[]);

            props=fields(State);
            for ii=1:length(props)
                prop=props{ii};
                State.(prop)=this.(prop);
            end
            StateMatFile=fullfile(this.fxpCfg.OutputFilesDirectory,'IncrementalConversion.mat');
            save(StateMatFile,'State');
        end

        function res=loadConverterState(this)
            this.StateLoaded=false;
            try
                StateMatFile=fullfile(this.fxpCfg.OutputFilesDirectory,'IncrementalConversion.mat');
                if exist(StateMatFile,'file')


                    S=load(StateMatFile);
                    State=S.State;
                    props=fields(State);
                    for ii=1:length(props)
                        prop=props{ii};
                        switch prop
                        case{'inputTypes','floatGlobalTypes'}




                        otherwise
                            if isprop(this,prop)
                                this.(prop)=State.(prop);
                            end
                        end
                    end





                    if isequaln(this.inputTypes,State.inputTypes)&&...
                        isequaln(this.floatGlobalTypes,State.floatGlobalTypes)
                        this.StateLoaded=true;
                    else


                        this.StateLoaded=false;




                        this.inputTypeSpecifications=[];
                        this.updateInputTypeSpecificationsFromInputTypes();
                    end
                end
            catch

            end
            res=this.StateLoaded;
        end
    end


    methods(Access='public')

        function addInputTypes(this,design,inArgs)
            dIndex=strcmp(this.DesignFunctionNames,design);
            assert(any(dIndex),[design,' not part of ''DesignFunctionNames''.']);
            assert(iscell(inArgs),'value for codegen ''-args'' flag should be a cell array');
            this.inputTypes{dIndex}=inArgs;
        end

        function testingHelperAPIUseOldFxpCfgDefaults(this)
            this.fxpCfg.DefaultFractionLength=0;
            this.fxpCfg.fimath=sprintf('fimath(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)',...
            '''RoundMode''','''floor''',...
            '''OverflowMode''','''wrap''',...
            '''ProductMode''','''FullPrecision''',...
            '''MaxProductWordLength''','128',...
            '''SumMode''','''FullPrecision''',...
            '''MaxSumWordLength''','128');
        end
    end

    methods(Static)
        function b=supportMCOSClasses(~)
            b=true;
        end
    end

    methods(Static)

        function S=getErrorStruct(fcnName,inferenceId,specializationName,specializationNumber,scriptPath)
            if nargin==0
                fcnName='';
                inferenceId=0;
                specializationName='';
                specializationNumber=-1;
                scriptPath='';
            end

            S.FunctionName=fcnName;
            S.FunctionId=inferenceId;
            S.SpecializationName=specializationName;
            S.SpecializationNumber=specializationNumber;
            S.ScriptPath=scriptPath;
            S.Inputs=struct('name',{},'mxLocationID',{},'errorPercentage',{});
            S.Outputs=struct('name',{},'mxLocationID',{},'errorPercentage',{});
        end




        function[numericalErrorInfo]=getNumericalErrorInfoForVar(varName,varInfo,varMxInfoLocId,errorPercentage)
            if varInfo.isStruct()

                numericalErrorInfo=struct('name','','mxLocationID',[],'errorPercentage',[]);



                nonStructFields=varInfo.getNonNestedLoggedFields;
                for loggedFieldN=nonStructFields

                    fVarInfo=varInfo.getStructPropVarInfo(loggedFieldN{1});
                    fullName=fVarInfo.SymbolName;
                    fieldN=regexprep(fullName,[varInfo.SymbolName,'.'],'','Once');



                    if isfield(errorPercentage,fieldN)
                        ep=errorPercentage.(fieldN);
                        numericalErrorInfo(end+1)=struct('name',fullName,'mxLocationID',varMxInfoLocId,'errorPercentage',ep);
                    end
                end

                nestedVarInfos=varInfo.getNestedStructVarInfos;
                for svInfo=nestedVarInfos
                    fullName=svInfo.SymbolName;
                    fieldN=regexprep(fullName,[varInfo.SymbolName,'.'],'','Once');



                    if isfield(errorPercentage,fieldN)
                        ep=errorPercentage.(fieldN);
                        numericalErrorInfo=[numericalErrorInfo,coder.internal.Float2FixedConverter.getNumericalErrorInfoForVar(fullName,svInfo,varMxInfoLocId,ep)];
                    end
                end

                numericalErrorInfo(1)=[];
            else
                numericalErrorInfo=struct('name',varName,'mxLocationID',varMxInfoLocId,'errorPercentage',errorPercentage);
            end

        end


        function info=getVariableInfoUsing(fcnInfoRegistry,typeProposalSettings)
            info=coder.internal.convertFcnInfoRegistryToJavaArray(fcnInfoRegistry,typeProposalSettings);
        end





        function callerCalleeList=BuildCallerCalleeTripes(fcnInfoRegistry)
            funcs=fcnInfoRegistry.getAllFunctionTypeInfos();
            callerCalleeList={};
            for mm=1:length(funcs)
                caller=funcs{mm};
                callSiteFcnInfos=caller.callSites;
                for nn=1:length(callSiteFcnInfos)
                    calleeInfo=callSiteFcnInfos{nn};
                    callee=calleeInfo{2};
                    calleeMtree=calleeInfo{1};
                    callerCalleeList=[callerCalleeList,{caller.functionName,caller.specializationName,caller.scriptPath,callee.functionName,callee.specializationName,callee.scriptPath,calleeMtree.position}];
                end
            end
        end

        function loadFunctionReplacementsFromProject(xmlReader,cfg)
            if isempty(xmlReader)
                return;
            end
            cfg.clearFunctionReplacements();
            functionReader=xmlReader.getChild('Function');
            while functionReader.isPresent()
                functionName=functionReader.readAttribute('name').toCharArray';
                functionReplacement=functionReader.readAttribute('replacement').toCharArray';
                cfg.addFunctionReplacement(functionName,functionReplacement);
                functionReader=functionReader.next();
            end
        end

        function proposedTypesCustomizations=loadAnnotationsFromProjectUserData(xmlReader,cfg)
            if isempty(xmlReader)
                return;
            end

            f2fFimath=eval(cfg.fimath);

            cfg.clearDesignRangeSpecifications();
            cfg.clearTypeSpecifications();
            proposedTypesCustomizations=containers.Map;

            functionReader=xmlReader.getChild('Function');
            while functionReader.isPresent()
                functionName=functionReader.readAttribute('name').toCharArray';
                specializationName=functionReader.readAttribute('specialization');
                if~isempty(specializationName)
                    specializationName=specializationName.toCharArray';
                else
                    specializationName=functionName;
                end
                functionContents=containers.Map;
                proposedTypesCustomizations(specializationName)=functionContents;
                variableReader=functionReader.getChild('Variable');

                while(variableReader.isPresent)
                    variableName=extractVariableName(variableReader);


                    variableContents=containers.Map;
                    functionContents(variableName)=variableContents;

                    designMin=[];
                    designMax=[];
                    typeSpec=coder.FixPtTypeSpec;
                    varFimath=f2fFimath;

                    fieldReader=variableReader.getChild('Column');
                    while fieldReader.isPresent
                        index=fieldReader.readAttribute('index');
                        if~isempty(index)
                            columnIndex=str2num(index);
                            switch columnIndex
                            case 1
                                fieldName='DesignMin';
                            case 2
                                fieldName='DesignMax';
                            case 3
                                fieldName='IsInteger';
                            case 4
                                fieldName='ProposedType';
                            case 5
                                fieldName='RoundMode';
                            case 6
                                fieldName='OverflowMode';
                            end
                        else
                            fieldName=fieldReader.readAttribute('property').toCharArray';
                        end
                        fieldValue=fieldReader.readAttribute('value').toCharArray';

                        variableContents(fieldName)=fieldValue;
                        fieldReader=fieldReader.next();

                        switch fieldName
                        case 'DesignMin',designMin=str2num(fieldValue);%#ok<*ST2NM>
                        case 'DesignMax',designMax=str2num(fieldValue);
                        case 'IsInteger',typeSpec.IsInteger=str2num(fieldValue);
                        case 'ProposedType'
                            try

                                [~,fieldValue]=evalc(fieldValue);
                            catch

                            end
                            typeSpec.ProposedType=fieldValue;
                        case 'RoundMode'
                            varFimath.RoundingMethod=fieldValue;
                            typeSpec.fimath=varFimath;
                        case 'OverflowMode'
                            varFimath.OverflowAction=fieldValue;
                            typeSpec.fimath=varFimath;
                        case{'ProductMode','SumMode'}
                            varFimath.(fieldName)=fieldValue;
                            typeSpec.fimath=varFimath;
                        case{'ProductWordLength','ProductFractionLength'...
                            ,'SumWordLength','SumFractionLength'}
                            varFimath.(fieldName)=str2num(fieldValue);
                            typeSpec.fimath=varFimath;
                        case{'CastBeforeSum'}
                            varFimath.(fieldName)=logical(str2num(fieldValue));
                            typeSpec.fimath=varFimath;
                        end
                    end

                    if~isempty(designMin)&&~isempty(designMax)
                        try
                            cfg.addDesignRangeSpecification(specializationName,variableName,designMin,designMax);
                        catch ex
                            disp(ex.message);
                        end
                    end
                    if typeSpec.IsIntegerSet||typeSpec.ProposedTypeSet||typeSpec.RoundingMethodSet||typeSpec.OverflowActionSet||typeSpec.FimathSet
                        cfg.addTypeSpecification(specializationName,variableName,typeSpec);
                    end

                    variableReader=variableReader.next();
                end
                functionReader=functionReader.next();
            end
        end
    end
end

function variableName=extractVariableName(variableReader)
    variableNameText=variableReader.readAttribute('name').toCharArray';
    variableNameParts=strsplit(variableNameText,',');
    variableName=variableNameParts{1};
end














