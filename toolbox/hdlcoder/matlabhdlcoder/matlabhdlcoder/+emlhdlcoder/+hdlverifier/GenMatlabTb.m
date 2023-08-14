


classdef GenMatlabTb<handle

    properties(Abstract,Constant)
        FeatureName;
        FeatureAbbrev;
        FeatureFullName;
    end

    properties
        codeInfo;
        projDir;
        cosimFuncName;
        cosimLaunchFuncName;
        cosimRunScriptName;
        cosimSysObjFuncName;
        cosimTbName;
        localClearFuncName;
        localRunTestFuncName;
        localRecompileFuncName;
        fcnToMex;
        mexFileName;
        dutInPortNames;
        dutOutPortNames;
        cosimSetup='CosimBlockAndDut';
        splitVector=true;
        isOutputDataLogged=false;
    end

    properties(Access=protected)
        outputDataPortIndx;
        inputDataPortIndx;
        clkenPortIndx;
        clockPortIndx;
        resetPortIndx;
    end

    properties(Access=private)
        logVar;
    end

    methods(Abstract)

        generateFeatureSpecificFiles(this);
        generateRunScript(this);

        generateSysObjInst(this,generator,sysobjVar);
    end

    methods

        function this=GenMatlabTb(codeInfo)
            this.codeInfo=codeInfo;

            [codegenRootDir,~,~]=fileparts(this.codeInfo.targetDir);
            this.projDir=fullfile(codegenRootDir,this.FeatureAbbrev);






            if~emlhdlcoder.hdlverifier.isHDLVerifierAvailable
                error(message('hdlcoder:hdlverifier:HDLVerifierNotAvailable',this.FeatureFullName));
            end


            for m=1:length(this.codeInfo.hdlDutPortInfo)
                portInfo=this.codeInfo.hdlDutPortInfo(m);
                if strcmpi(portInfo.Kind,'data')
                    if strcmpi(portInfo.Direction,'input')
                        this.inputDataPortIndx(end+1)=m;
                    else
                        this.outputDataPortIndx(end+1)=m;
                    end
                elseif strcmpi(portInfo.Kind,'clock')
                    this.clockPortIndx=m;
                elseif strcmpi(portInfo.Kind,'reset')
                    this.resetPortIndx=m;
                elseif strcmpi(portInfo.Kind,'clock_enable')&&strcmpi(portInfo.Direction,'input')
                    this.clkenPortIndx=m;
                end
            end

            initialize(this);
        end

        function checkCompatibility(this)
            hdldisp(message('hdlcoder:hdlverifier:DispCheckCompatibility',this.FeatureName));


            errmsg=getCompatibilityCheckErrMsg(this);

            if~isempty(errmsg)
                error('hdlcoder:hdlverifier:incompatible',errmsg);
            end
        end

        function compErr=getCompatibilityCheckErrMsg(this)
            compErr='';

            inPortNames=this.codeInfo.emlDutInterface.inportNames;
            outPortNames=this.codeInfo.emlDutInterface.outportNames;
            inPortTypes=this.codeInfo.emlDutInterface.inputTypesInfo;
            assert(length(inPortNames)==length(inPortTypes));
            outPortTypes=this.codeInfo.emlDutInterface.outputTypesInfo;
            assert(length(outPortNames)==length(outPortTypes));


            for m=1:length(inPortNames)
                portType=inPortTypes{m};
                if portType.isdouble
                    compErr=[compErr,char(10),getString(message('hdlcoder:hdlverifier:DoublePortNotSupported',inPortNames{m}))];%#ok<AGROW>
                end
            end
            for m=1:length(outPortNames)
                portType=outPortTypes{m};
                if portType.isdouble
                    compErr=[compErr,char(10),getString(message('hdlcoder:hdlverifier:DoublePortNotSupported',outPortNames{m}))];%#ok<AGROW>
                end
            end


            if strcmpi(this.codeInfo.codegenSettings.ScalarizePorts,'off')&&...
                ~strcmpi(this.codeInfo.codegenSettings.TargetLanguage,'Verilog')
                for m=1:length(inPortNames)
                    portType=inPortTypes{m};
                    if portType.isvector
                        compErr=[compErr,char(10),getString(message('hdlcoder:hdlverifier:VectorPortNotSupported',inPortNames{m}))];%#ok<AGROW>
                    end
                end

                for m=1:length(outPortNames)
                    portType=outPortTypes{m};
                    if portType.isvector
                        compErr=[compErr,char(10),getString(message('hdlcoder:hdlverifier:VectorPortNotSupported',outPortNames{m}))];%#ok<AGROW>
                    end
                end
            end
        end

        function initialize(this)

            emlhdlcoder.hdlverifier.getUniqueVarName('',1);

            this.cosimFuncName=getUniqueFunctionName(this,[this.codeInfo.topName,'_',this.FeatureAbbrev]);
            this.cosimSysObjFuncName=getUniqueFunctionName(this,[this.codeInfo.topName,'_sysobj_',this.FeatureAbbrev]);
            this.cosimLaunchFuncName=getUniqueFunctionName(this,['launch_',this.codeInfo.topName,'_',this.FeatureAbbrev]);
            this.cosimRunScriptName=getUniqueFunctionName(this,['run_',this.codeInfo.topName,'_',this.FeatureAbbrev]);
            this.cosimTbName=getUniqueFunctionName(this,[this.codeInfo.codegenSettings.TestBenchName,'_',this.FeatureAbbrev]);
            this.localClearFuncName=getUniqueFunctionName(this,'l_clearPersistentVariable',false);
            this.localRunTestFuncName=getUniqueFunctionName(this,['localRunTest_',this.codeInfo.topName]);
        end

        function doIt(this)
            hdldisp(message('hdlcoder:hdlverifier:DispBegin',this.FeatureFullName));

            savedpath=path;
            onCleanupObj=onCleanup(@()path(savedpath));


            checkCompatibility(this);


            createProjectDir(this);



            addpath(this.projDir);


            emlhdlcoder.hdlverifier.getUniqueVarName('',1);
            generateCosimFcn(this);
            emlhdlcoder.hdlverifier.getUniqueVarName('',1);




            generateFeatureSpecificFiles(this);


            if isempty(this.codeInfo.TopScriptName)
                hdldisp(message('hdlcoder:hdlverifier:DispSkipTB'));
            else

                copyTestBench(this);


                buildMexFile(this);


                generateRunTestFcn(this);


                generateRunScript(this);

                hdldisp(message('hdlcoder:hdlverifier:DispManualRunTB'));
                hdldisp(sprintf('      >> addpath(''%s'')',this.projDir));
                hdldisp(sprintf('      >> %s',this.cosimRunScriptName));

            end
            hdldisp(message('hdlcoder:hdlverifier:DispFinished',this.FeatureFullName));

        end

        function buildMexFile(this)
            exInputs=this.fcnToMex.InputArgs;


            exInputs=l_injectCoderConstants(exInputs,this.codeInfo.coderConstIndices,this.codeInfo.coderConstVals);%#ok<NASGU>

            this.mexFileName=[this.fcnToMex.Name,'_mex'];
            mexOutputFile=fullfile(this.projDir,this.mexFileName);

            hdldisp(message('hdlcoder:hdlverifier:DispGenerateMex',[this.mexFileName,'.',mexext],this.fcnToMex.Name));

            this.localRecompileFuncName=getUniqueFunctionName(this,['localRecompile_',this.fcnToMex.Name]);
            localRecompileFuncPath=fullfile(this.projDir,[this.localRecompileFuncName,'.m']);
            localArgFileName=getUniqueFunctionName(this,['localCodegenArgs_',this.fcnToMex.Name]);
            localArgFilePath=fullfile(this.projDir,localArgFileName);
            save(localArgFilePath,'exInputs');
            generator=emlhdlcoder.hdlverifier.GenMCode(localRecompileFuncPath);


            comment=sprintf('Function %s recreates a MEX-function %s from MATLAB function %s',...
            this.localRecompileFuncName,this.mexFileName,this.fcnToMex.Name);
            generator.addComment(comment);
            generator.addGeneratedHeader;

            generator.addFuncDecl(this.localRecompileFuncName);
            generator.addNewLine;

            loadCmd=sprintf('load(''%s'');',localArgFilePath);
            generator.appendCode(loadCmd);
            generator.addNewLine;


            addpathcmd=getAddRmFxptCmd(this);
            compileCmd=[addpathcmd,'codegen -args exInputs -o ''',mexOutputFile,''' ',this.fcnToMex.Name,';',char(10)];

            generator.appendCode(compileCmd);

            try
                eval(compileCmd);
            catch me
                disp('### Please look into the errors by following the error report link.');
                rethrow(me);
            end
        end

        function addpathcmd=getAddRmFxptCmd(this)
            if this.codeInfo.IsFixPtConversionDone
                addpathcmd=['fxptPath = ''',this.codeInfo.fxpBldDir,''';',char(10)];
                addpathcmd=[addpathcmd,'addpath(fxptPath);',char(10)];
                addpathcmd=[addpathcmd,'cleanupObj = onCleanup(@() rmpath(fxptPath));',char(10)];
            else
                addpathcmd='';
            end
        end


        function copyTestBench(this)

            if this.codeInfo.IsFixPtConversionDone
                designName=this.codeInfo.TopFunctionName;
                if iscell(this.codeInfo.TopScriptName)
                    tbName=this.codeInfo.TopScriptName{1};
                else
                    tbName=this.codeInfo.TopScriptName;
                end


                actualDesignName=getUserDUTName(this);

                if(isfield(this.codeInfo,'codegenDir'))
                    [fpcRootDir,codeGenFolderName,~]=fileparts(this.codeInfo.codegenDir);
                    [~,fxpOutputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(fpcRootDir,codeGenFolderName,actualDesignName);
                else
                    [~,fxpOutputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir([],[],actualDesignName);
                end

                fixptSuffix=this.codeInfo.fxpCfg.FixPtFileNameSuffix;


                fixptWrapperName=coder.internal.Float2FixedConverter.buildFixPtWrapperName(actualDesignName,fixptSuffix);
                fixptDesignName=coder.internal.Float2FixedConverter.buildFixPtDesignName(actualDesignName,fixptSuffix);
                cosimWrapperName=getUniqueFunctionName(this,[fixptWrapperName,'_',this.FeatureAbbrev]);


                savedpath=addpath(fxpOutputFilesDir);
                onCleanupObj=onCleanup(@()path(savedpath));

                fixptWrapperPath=which(fixptWrapperName);
                [~,~,ext]=fileparts(fixptWrapperPath);
                copiedWrapperPath=fullfile(this.projDir,[cosimWrapperName,ext]);

                coder.internal.Helper.fileCopy(fixptWrapperPath,copiedWrapperPath);
                coder.internal.Helper.changeIdInFile(copiedWrapperPath,fixptDesignName,this.cosimFuncName);
                coder.internal.Helper.changeIdInFile(copiedWrapperPath,fixptWrapperName,cosimWrapperName);


                fixptDesignPath=which(designName);
                [~,~,ext]=fileparts(fixptDesignPath);
                copiedDeisgnPath=fullfile(this.projDir,[fixptDesignName,ext]);
                coder.internal.Helper.fileCopy(fixptDesignPath,copiedDeisgnPath);




                [~,~,ext]=fileparts(which(tbName));
                outTBPath=fullfile(this.projDir,[this.cosimTbName,ext]);

                coder.internal.Helper.fileCopy(which(tbName)...
                ,fullfile(outTBPath));

                coder.internal.Helper.changeIdInFile(outTBPath...
                ,tbName...
                ,this.cosimTbName);

                coder.internal.Helper.changeIdInFile(outTBPath...
                ,actualDesignName...
                ,cosimWrapperName);


                if isempty(this.codeInfo.origItcs)



                    this.fcnToMex.InputArgs=this.codeInfo.inVals;
                    this.fcnToMex.Name=this.cosimFuncName;
                else
                    this.fcnToMex.InputArgs=this.codeInfo.origItcs;
                    this.fcnToMex.Name=cosimWrapperName;
                end
            else
                tbFilePath=which(this.codeInfo.TopScriptName);
                if isempty(tbFilePath)

                else
                    copiedTbPathPath=fullfile(this.projDir,[this.cosimTbName,'.m']);
                    hdldisp(message('hdlcoder:hdlverifier:DispGenerateTB',this.FeatureName,hdlgetfilelink(copiedTbPathPath)));
                    coder.internal.Helper.fileCopy(tbFilePath,copiedTbPathPath);

                    coder.internal.Helper.changeIdInFile(copiedTbPathPath,this.codeInfo.TopFunctionName,this.cosimFuncName);
                end
                this.fcnToMex.InputArgs=this.codeInfo.inVals;
                this.fcnToMex.Name=this.cosimFuncName;
            end
        end

        function createProjectDir(this)
            hdldisp(message('hdlcoder:hdlverifier:DispOutputDir',this.projDir));
            [success,errmsg,messageid]=mkdir(this.projDir);
            if~success
                error(messageid,errmsg);
            end
        end

        function userDutName=getUserDUTName(this)
            if this.codeInfo.IsFixPtConversionDone
                [~,userDutName,~]=fileparts(this.codeInfo.fxpCfg.DesignFunctionName);
            else
                [~,userDutName,~]=fileparts(this.codeInfo.TopFunctionName);
            end
        end

        function generateSysObjFcn(this,inputVarList,outputVarList)
            fileName=fullfile(this.projDir,[this.cosimSysObjFuncName,'.m']);
            hdldisp(message('hdlcoder:hdlverifier:DispGenerateSysobj',this.FeatureName,hdlgetfilelink(fileName)));
            generator=emlhdlcoder.hdlverifier.GenMCode(fileName);

            comment=['Auto generated wrapper function for ',this.FeatureName,' System object'];
            generator.addComment(comment);
            generator.addNewLine;
            generator.addGeneratedHeader;
            generator.addNewLine;

            generator.addFuncDecl(this.cosimSysObjFuncName,inputVarList,outputVarList);
            generator.addNewLine;

            sysobjVar=emlhdlcoder.hdlverifier.getUniqueVarName([this.FeatureAbbrev,'_sys_obj']);

            generator.addComment('Declare persistent variables');
            generator.addPersistentVar(sysobjVar);
            generator.addNewLine;

            condition=['isempty(',sysobjVar,')'];
            generator.addIfStatement(condition);
            generator.addComment(['Instantiate ',this.FeatureName,' System object']);
            generateSysObjInst(this,generator,sysobjVar);

            generator.addEndStatement;
            generator.addNewLine;

            inputVarList=[{sysobjVar},inputVarList];
            generator.addExecFunction('step',inputVarList,outputVarList);

            generator.addNewLine;
        end


        function generateCosimFcn(this)
            fileName=fullfile(this.projDir,[this.cosimFuncName,'.m']);
            hdldisp(message('hdlcoder:hdlverifier:DispGenerateFcn',this.FeatureName,hdlgetfilelink(fileName)));


            hdlOutPortNames=this.codeInfo.emlDutInterface.outportNames;


            hdlInPortTypes=this.codeInfo.emlDutInterface.inputTypesInfo;
            hdlOutPortTypes=this.codeInfo.emlDutInterface.outputTypesInfo;
            assert(length(hdlOutPortNames)==length(hdlOutPortTypes));

            origDutOutportInfos=cell2mat(this.codeInfo.emlDutInterface.origOutportPsuedoRecordTypes);




            userDutName=getUserDUTName(this);
            [this.dutInPortNames,this.dutOutPortNames]=coder.internal.Float2FixedConverter.getFcnInterface(userDutName);

            generator=emlhdlcoder.hdlverifier.GenMCode(fileName);


            comment=['Auto generated function to simulate the generated HDL code using ',this.FeatureName];
            generator.addComment(comment);
            generator.addComment('');
            generator.addGeneratedHeader;
            generator.addNewLine;



            emlhdlcoder.hdlverifier.getUniqueVarName('step');
            emlhdlcoder.hdlverifier.getUniqueVarName('dsp');
            emlhdlcoder.hdlverifier.getUniqueVarName('hdlverifier');


            [~]=emlhdlcoder.hdlverifier.getUniqueVarName(unique([this.dutInPortNames,this.dutOutPortNames]));

            cosimFuncInputNames=this.dutInPortNames;
            cosimFuncOutputNames=this.dutOutPortNames;












            generator.flushBuffer();
            [refOutNames,execDutOutNames]=this.buildRefSignalAndExecDutOutNameList(generator,cosimFuncOutputNames,origDutOutportInfos);





            generator.addFuncDecl(this.cosimFuncName,cosimFuncInputNames,execDutOutNames);
            generator.addNewLine;


            generator.addExecFunction('coder.extrinsic',l_AddQuote(this.cosimSysObjFuncName));
            generator.addExecFunction('coder.extrinsic',l_AddQuote('hdlverifier.assert'));
            generator.addExecFunction('coder.extrinsic',l_AddQuote('hdlverifier.Delay'));
            generator.addExecFunction('coder.extrinsic',l_AddQuote('step'));
            generator.addNewLine;


            initVar=emlhdlcoder.hdlverifier.getUniqueVarName('initialized');







            if this.codeInfo.outputPortLatency>0
                lenTxt=num2str(this.codeInfo.outputPortLatency);
                delayObjNames=cellfun(@(x)['delayobj_',x],hdlOutPortNames,'UniformOutput',false);
                delayVarNames=cellfun(@(x)[x,'_d',lenTxt],hdlOutPortNames,'UniformOutput',false);
                delayObjNames=emlhdlcoder.hdlverifier.getUniqueVarName(delayObjNames);
                delayVarNames=emlhdlcoder.hdlverifier.getUniqueVarName(delayVarNames);
            end


            generator.addComment('Declare persistent variables');
            generator.addPersistentVar(initVar);

            if this.codeInfo.outputPortLatency>0
                for m=1:numel(delayObjNames)
                    generator.addPersistentVar(delayObjNames{m});
                end
            end
            generator.addNewLine;


            generator.addComment('Initialize persistent variables');
            condition=['isempty(',initVar,')'];
            generator.addIfStatement(condition);

            generator.addAssignVar(initVar,true);


            if this.codeInfo.outputPortLatency>0
                generator.addComment('Instantiate delay System object(s)');
                lenTxt=num2str(this.codeInfo.outputPortLatency);
                for m=1:numel(delayObjNames)
                    generator.appendCode([delayObjNames{m},' = hdlverifier.Delay(''Length'',',lenTxt,');']);
                end
                generator.addNewLine;
            end

            generator.addEndStatement;
            generator.addNewLine;


            generator.addComment('Call the original MATLAB function to get reference signal');
            generator.addExecFunction(this.codeInfo.TopFunctionName,cosimFuncInputNames,execDutOutNames);





            generator.flushBuffer();
            generator.addNewLine;



            origDutInportInfos=this.codeInfo.emlDutInterface.origInportPsuedoRecordTypes;
            isAnyRecordType=any([cellfun(@(inportInfo)inportInfo.isRecordType,origDutInportInfos,'UniformOutput',true)]);




            nonConstCosimFuncInputNames=cosimFuncInputNames;
            nonConstCosimFuncInputNames(this.codeInfo.coderConstIndices)=[];
            assert(length(nonConstCosimFuncInputNames)==length(origDutInportInfos));
            if~isempty(origDutInportInfos)&&isAnyRecordType
                nonConstCosimFuncInputNames=this.emitExplodeInStructToCosimFlatInVars(generator,nonConstCosimFuncInputNames,origDutInportInfos);
            end





            assert(length(nonConstCosimFuncInputNames)==length(hdlInPortTypes));
            [inputVarList,inputConvTxt]=l_convertInput(nonConstCosimFuncInputNames,hdlInPortTypes);
            [outputVarList,outputConvTxt]=l_convertOutput(hdlOutPortNames,hdlOutPortTypes);


            if~isempty(inputConvTxt)
                generator.addComment('Convert input signals');
                generator.appendCode(inputConvTxt);
                generator.addNewLine;
            end


            generator.addComment(['Run ',this.FeatureName]);
            generator.addExecFunction(this.cosimSysObjFuncName,inputVarList,outputVarList);
            generator.addNewLine;


            if~isempty(outputConvTxt)
                generator.addComment('Convert output signals');
                generator.appendCode(outputConvTxt);
                generator.addNewLine;
            end




            origDutOutportInfos=cell2mat(this.codeInfo.emlDutInterface.origOutportPsuedoRecordTypes);
            assert(length(cosimFuncOutputNames)==length(origDutOutportInfos));
            assert(length(execDutOutNames)==length(cosimFuncOutputNames));







            goldSignalNames=cell(1,numel(hdlOutPortNames));
            if this.codeInfo.outputPortLatency>0
                generator.addComment('Delay reference signal');
                for m=1:numel(hdlOutPortNames)
                    generator.addExecFunction('step',{delayObjNames{m},refOutNames{m}},delayVarNames{m});
                    goldSignalNames{m}=delayVarNames{m};
                end
                generator.addNewLine;
            else
                for m=1:numel(hdlOutPortNames)
                    goldSignalNames{m}=refOutNames{m};
                end
            end


            generator.addComment(['Verify the ',this.FeatureName,' output']);
            for m=1:numel(hdlOutPortNames)
                tmp={hdlOutPortNames{m},goldSignalNames{m},['''',hdlOutPortNames{m},'''']};
                generator.addExecFunction('hdlverifier.assert',tmp);
            end
            generator.addNewLine;


            if this.isOutputDataLogged
                dif.outportNames=[hdlOutPortNames,goldSignalNames];
                dif.inportNames={};
                dif.NumOut=length(dif.outportNames);
                dif.NumIn=0;

                bailoutEarly=false;
                bailoutExceptionIdentifier='Coder:FXPCONV:MATLABSimBailOut';
                loggingMode=coder.internal.LoggerService.USE_NON_CELLARRAY_LOGGING;
                inVals={};outVals={};
                simulationLimit=Inf;

                logDataFcnName=coder.internal.LoggerService.createLocalLogDataFunctionFile(...
                dif,this.projDir,[],[],...
                [],bailoutEarly,bailoutExceptionIdentifier,inVals,outVals,simulationLimit,loggingMode);

                generator.addExecFunction('coder.extrinsic',l_AddQuote(logDataFcnName));
                generator.addExecFunction(logDataFcnName,dif.outportNames);


                this.logVar=arrayfun(@(x)[coder.internal.LoggerService.outputLogValuePrefix,x{:}],dif.outportNames,'UniformOutput',false);
            end

            delete(generator);


            generateSysObjFcn(this,inputVarList,outputVarList);

        end

        function runSimulation(this)
            if isempty(this.codeInfo.TopScriptName)
                hdldisp(message('hdlcoder:hdlverifier:DispSkipSim',this.FeatureName));
            else
                hdldisp(message('hdlcoder:hdlverifier:DispBeginSim'));


                oldWarningState=warning('error','hdlverifier:assert:mismatch');%#ok<CTPCT>
                onCleanupObj=onCleanup(@()warning(oldWarningState));

                tic;
                savedPath=addpath(pwd);
                addpath(this.projDir);
                currentPath=pwd;

                onCleanupObj1=onCleanup(@()path(savedPath));
                onCleanupObj2=onCleanup(@()cd(currentPath));
                onCleanupObj3=onCleanup(@()clear(this.cosimFuncName));
                onCleanupObj3=onCleanup(@()clear(this.cosimTbName));

                feval(this.cosimRunScriptName);

                tspan=toc;
                hdldisp(message('hdlcoder:hdlverifier:DispFinishSim',num2str(tspan)));
            end
        end

        function getCommonRunScriptText(this,generator)
            generator.addComment('Clear persistent variables before simulation');
            generator.addExecFunction(this.localClearFuncName);
            generator.addNewLine;

            generator.addComment('Clear persistent variables after simulation');
            onCleanupVar=emlhdlcoder.hdlverifier.getUniqueVarName('onCleanupObj');
            generator.appendCode([onCleanupVar,' = onCleanup(@() ',this.localClearFuncName,');']);
            generator.addNewLine;

            generator.addComment('Add current working directory to search path');
            savedPathVar=emlhdlcoder.hdlverifier.getUniqueVarName('savedPathVar');
            generator.appendCode([savedPathVar,' = addpath(pwd);']);
            restorePathObj=emlhdlcoder.hdlverifier.getUniqueVarName('restorePathObj');
            generator.appendCode([restorePathObj,' = onCleanup(@() path(',savedPathVar,'));']);
            generator.addNewLine;

            generator.addComment('Run generated test bench');
            generator.addExecFunction('disp','''### Simulating generated test bench ''');
            comment=sprintf('Exercise the compiled version of %s in the generated test bench.',this.fcnToMex.Name);
            generator.addComment(comment);

            comment=sprintf('To debug the test bench with the original function "%s",',this.fcnToMex.Name);
            generator.addComment(comment);
            comment=sprintf('replace the next line with "%s"',this.cosimTbName);
            generator.addComment(comment);

            generator.addExecFunction('coder.runTest',...
            {l_AddQuote(this.localRunTestFuncName),...
            l_AddQuote(this.fcnToMex.Name)});

            comment=sprintf('To recompile MATLAB function "%s",',this.fcnToMex.Name);
            generator.addComment(comment);

            comment=sprintf('run the re-compilation function "%s".',this.localRecompileFuncName);
            generator.addComment(comment);

            generator.addExecFunction('disp','''### Finished Simulation''');
            generator.addNewLine;

            if this.isOutputDataLogged
                generator.addComment('Plot logged output values');
                generator.appendCode('global gEMLSimLogRunIdx;');
                numOut=length(this.logVar)/2;
                for m=1:numOut
                    portType=this.codeInfo.emlDutInterface.outputTypesInfo{m};
                    portName=this.codeInfo.emlDutInterface.outportNames{m};
                    if portType.isvector||portType.iscomplex
                        str=sprintf('disp(''Warning: output %s is matrix or complex - it will not be plotted'')',...
                        this.logVar{m});
                        generator.appendCode(str);
                    else
                        generator.appendCode(sprintf('global %s;',this.logVar{m}));
                        generator.appendCode(sprintf('global %s;',this.logVar{m+numOut}));

                        generator.appendCode('figure;');
                        generator.appendCode('hold on;');
                        generator.appendCode('subplot(3,1,1);');
                        generator.appendCode(sprintf('plot(%s(1:gEMLSimLogRunIdx-1,:),''b'');',this.logVar{m}));
                        generator.appendCode(sprintf('title(''%s:%s'',''Interpreter'',''none'')',portName,this.FeatureAbbrev));

                        generator.appendCode('subplot(3,1,2);');
                        generator.appendCode(sprintf('plot(%s(1:gEMLSimLogRunIdx-1,:),''r'');',this.logVar{m+numOut}));
                        generator.appendCode(sprintf('title(''%s:%s'',''Interpreter'',''none'')',portName,'Reference'));

                        generator.appendCode('subplot(3,1,3);');
                        generator.appendCode(sprintf('plot(double(%s(1:gEMLSimLogRunIdx-1,:)) - double(%s(1:gEMLSimLogRunIdx-1,:)),''m'');',...
                        this.logVar{m},this.logVar{m+numOut}));
                        generator.appendCode(sprintf('title(''%s:%s'',''Interpreter'',''none'')',portName,'Difference'));

                        generator.appendCode('hold off;');
                    end
                end
                generator.addNewLine;
            end
            generator.addEndStatement;
            generator.addNewLine;

            generateClearFcn(this,generator);
            generator.addNewLine;
        end

        function generateRunTestFcn(this)
            fileName=fullfile(this.projDir,[this.localRunTestFuncName,'.m']);
            generator=emlhdlcoder.hdlverifier.GenMCode(fileName);

            generator.addFuncDecl(this.localRunTestFuncName)
            generator.addIndent;

            addpathcmd=getAddRmFxptCmd(this);
            generator.appendCode(addpathcmd);

            generator.addExecFunction(this.cosimTbName);
            generator.reduceIndent;
            generator.addEndStatement;
            generator.addNewLine;
        end

        function generateClearFcn(this,generator)
            generator.addFuncDecl(this.localClearFuncName)
            generator.addIndent;






            generator.addComment('Clear reference DUT function');
            generator.appendCode(['clear ',this.codeInfo.TopFunctionName,';']);
            generator.addNewLine;

            generator.addComment(['Clear ',this.FeatureName,' System object wrapper function']);
            generator.appendCode(['clear ',this.cosimSysObjFuncName,';']);
            generator.addNewLine;

            generator.addComment(['Clear ',this.FeatureName,' function']);
            generator.appendCode(['clear ',this.cosimFuncName,';']);
            generator.addNewLine;

            generator.addComment(['Clear generated MEX function']);
            generator.appendCode(['clear ',this.mexFileName]);
            generator.addNewLine;

            if this.isOutputDataLogged
                generator.addComment('Clear logged values');
                generator.appendCode('clear global gEMLSimLogRunIdx;');
                for m=1:length(this.logVar)
                    generator.appendCode(sprintf('clear global %s;',this.logVar{m}));
                end
                generator.addNewLine;
            end




            generator.addEndStatement;
        end

        function r=isClkEnableAtInputDataRate(this)
            r=~strcmpi(this.codeInfo.codegenSettings.EnableRate,'DutBaseRate')...
            &&this.codeInfo.baseRateScaling>1;
        end

    end

    methods(Access=private)
        function uniqueName=getUniqueFunctionName(this,name,deleteExistingFile)
            if nargin<=2
                deleteExistingFile=true;
            end

            [uniqueName,existedFilePath]=searchForExistingFile(name);

            while(~isempty(existedFilePath))
                [uniqueName,existedFilePath]=searchForExistingFile(name);
            end

            function[uniqueName,existedFilePath]=searchForExistingFile(name)
                uniqueName=emlhdlcoder.hdlverifier.getUniqueVarName(name);
                if deleteExistingFile
                    ext='.m';
                    fcnFilePath=fullfile(this.projDir,[uniqueName,ext]);
                    if exist(fcnFilePath,'file')

                        delete(fcnFilePath);
                    end
                end
                existedFilePath=which(uniqueName);
            end
        end











        function emitCosimOutStructVars(~,generator,cosimFuncOutputNames,hdlOutPortNames,execDutOutNames,origDutOutportInfos)
            cosimOutVarCount=0;
            for ii=1:length(cosimFuncOutputNames)
                if origDutOutportInfos(ii).isRecordType
                    origDutOutportInfo=origDutOutportInfos(ii);
                    varN=cosimFuncOutputNames{ii};





                    generator.appendCode([varN,' = coder.nullcopy(',execDutOutNames{ii},');']);
                    for jj=1:length(origDutOutportInfo.MemberNamesFlattened)
                        cosimOutVarCount=cosimOutVarCount+1;

                        flatFieldN=origDutOutportInfo.MemberNamesFlattened{jj};
                        generator.appendCode([varN,'.',flatFieldN,' = ',hdlOutPortNames{cosimOutVarCount},';']);
                    end
                else
                    cosimOutVarCount=cosimOutVarCount+1;
                end
            end
            generator.addNewLine;
        end















        function[refOutNames,execDutOutNames]=buildRefSignalAndExecDutOutNameList(~,generator,cosimFuncOutputNames,origDutOutportInfos)
            refOutNames={};
            assert(length(cosimFuncOutputNames)==length(origDutOutportInfos));
            execDutOutNames=cell(size(cosimFuncOutputNames));

            for ii=1:length(origDutOutportInfos)
                varN=cosimFuncOutputNames{ii};
                if origDutOutportInfos(ii).isRecordType
                    origDutOutportInfo=origDutOutportInfos(ii);
                    execDutOutNames{ii}=emlhdlcoder.hdlverifier.getUniqueVarName(['tmp_',varN]);
                    for jj=1:length(origDutOutportInfo.MemberNamesFlattened)
                        flatFieldN=origDutOutportInfo.MemberNamesFlattened{jj};
                        refN=['ref_',origDutOutportInfo.getFullName(flatFieldN)];
                        refOutNames{end+1}=refN;%#ok<AGROW>
                        generator.appendToBufferStore([refN,' = ',execDutOutNames{ii},'.',flatFieldN,';']);
                    end
                else
                    refN=emlhdlcoder.hdlverifier.getUniqueVarName(['ref_',varN]);
                    refOutNames{end+1}=refN;%#ok<AGROW>
                    execDutOutNames{ii}=refN;
                end
            end

        end








        function explodedNames=emitExplodeInStructToCosimFlatInVars(~,generator,nonConstCosimFuncInputNames,origDutInportInfos)
            explodedNames={};
            for ii=1:length(origDutInportInfos)
                origDutInportInfo=origDutInportInfos{ii};
                varN=nonConstCosimFuncInputNames{ii};
                if origDutInportInfo.isRecordType
                    for jj=1:length(origDutInportInfo.MemberNamesFlattened)
                        flatFieldN=origDutInportInfo.MemberNamesFlattened{jj};
                        explodedN=origDutInportInfo.getFullName(flatFieldN);
                        generator.appendCode([explodedN,' = ',varN,'.',flatFieldN,';']);
                        explodedNames{end+1}=explodedN;%#ok<AGROW>
                    end
                else
                    explodedNames{end+1}=varN;%#ok<AGROW>
                end
            end
            generator.addNewLine;
        end
    end

end


function[varList,convText]=l_convertInput(inPortNames,inPortTypes)
    generator=emlhdlcoder.hdlverifier.GenMCode;

    varList={};
    for m=1:numel(inPortNames)
        portName=inPortNames{m};
        portType=inPortTypes{m};
        isBitVec=portType.isvector&&(portType.wordsize==1);
        isComplex=portType.iscomplex;
        isVector=portType.isvector;


        if isComplex
            realVarName={[portName,'_re'],[portName,'_im']};
            realVarName=emlhdlcoder.hdlverifier.getUniqueVarName(realVarName);
            generator.appendCode(sprintf('%s = real(%s);\n',realVarName{1},portName));
            generator.appendCode(sprintf('%s = imag(%s);\n',realVarName{2},portName));
        else
            realVarName={portName};
        end

        if isVector||isBitVec
            for n=1:numel(realVarName)
                for k=1:portType.dims
                    scalarName=[realVarName{n},'_',num2str(k)];
                    scalarName=emlhdlcoder.hdlverifier.getUniqueVarName(scalarName);
                    generator.appendCode(sprintf('%s = %s(%d);\n',scalarName,realVarName{n},k));
                    varList{end+1}=scalarName;
                end
            end
        else
            varList=[varList,realVarName];
        end

    end

    convText=generator.mText;
end


function[varList,convText]=l_convertOutput(outPortNames,outPortTypes)
    generator=emlhdlcoder.hdlverifier.GenMCode;

    varList={};
    for m=1:numel(outPortNames)
        portName=outPortNames{m};
        portType=outPortTypes{m};
        isBitVec=portType.isvector&&(portType.wordsize==1);
        isComplex=portType.iscomplex;
        isVector=portType.isvector;


        if isComplex
            realVarName={[portName,'_re'],[portName,'_im']};
            realVarName=emlhdlcoder.hdlverifier.getUniqueVarName(realVarName);
            generator.prependCode(sprintf('%s = complex(%s,%s);\n',portName,realVarName{1},realVarName{2}));
        else
            realVarName={portName};
        end


        if isVector||isBitVec
            if portType.isrowvec
                seperator=',';
            else
                seperator=';';
            end
            for n=1:numel(realVarName)
                newTxt=[realVarName{n},' = ['];
                for k=1:portType.dims
                    scalarName=[realVarName{n},'_',num2str(k)];
                    scalarName=emlhdlcoder.hdlverifier.getUniqueVarName(scalarName);
                    newTxt=[newTxt,scalarName,seperator];
                    varList{end+1}=scalarName;
                end
                newTxt(end)=']';
                newTxt=[newTxt,';',char(10)];
                generator.prependCode(newTxt);
            end
        else
            varList=[varList,realVarName];
        end

        if strcmpi(portType.sltype,'boolean')
            generator.appendCode(sprintf('%s = logical(%s);',portName,portName));
        end

    end
    convText=generator.mText;
end

function exInputs=l_injectCoderConstants(exInputs,coderConstIndices,coderConstVals)
    assert(length(coderConstIndices)==length(coderConstVals));
    for ii=1:length(coderConstIndices)
        exInputs{coderConstIndices(ii)}=coder.Constant(coderConstVals{ii});
    end
end










function r=l_AddQuote(str)
    r=['''',str,''''];
end


