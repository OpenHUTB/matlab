
classdef HDLTBDataLogger<handle




    properties(Access=private)
        hHDLDriver;
        hTopFunctionName;
        hTopScriptName;
        hCgInfo;
    end
    methods(Static)










        function loggedVals=runTestBenchToLogData(workDirectory,outputFilesDirectory,fcnToMex,exInputs,fcnToIntercept,~,fcnToLog,tbNames,simLimit,coderConstIndices,coderConstVals,hdlMexCfg)
            if(nargin<12)
                hdlMexCfg=coder.config('mex');
            end

            loggedVals=[];
            [setupInfo]=doSetup(outputFilesDirectory,workDirectory);
            cleanup=onCleanup(@()runCleanup(setupInfo,workDirectory,outputFilesDirectory));

            assert(~isempty(fcnToIntercept));
            [mexFileName,logEPName]=buildDesign(fcnToMex,exInputs,fcnToLog,workDirectory,coderConstIndices,coderConstVals,simLimit,hdlMexCfg);
            for idx=1:length(tbNames)
                tb=tbNames{idx};

                isMexInDesignPath=false;
                isEntryPointCompiled=true;
                tbExecCfg=coder.internal.TestBenchExecConfig(isMexInDesignPath,isEntryPointCompiled);


                runSimFcn=@runSimulation;
                fcnToLogdif=coder.internal.Float2FixedConverter.getDIF(fcnToLog);
                runSimFcn=withLogging(runSimFcn,fcnToLogdif,workDirectory,coderConstIndices,fcnToLog,logEPName);


                outDirForEvalTBSim=pwd;
                runSimFcn=withScopeProtection(runSimFcn,outDirForEvalTBSim);

                if~strcmp(fcnToMex,fcnToIntercept)
                    designRedirectMap=coder.internal.lib.Map();
                    designRedirectMap(fcnToIntercept)=fcnToMex;





                    tbExecCfg.setActualEntryPointNamesMap(designRedirectMap);
                end
                runSimFcn(tbExecCfg,tb,fcnToIntercept,mexFileName);
            end


            function runCleanup(setupInfo,workDirectory,outputFilesDirectory)



                path(setupInfo.pathBak);
                cd(setupInfo.currDir);
                makeGeneratedFilesReadOnly(workDirectory,outputFilesDirectory);

                clear mex;%#ok<CLMEX> 
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
                clear mex;%#ok<CLMEX> 
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




            function fcn=withLogging(runSimFcn,fcnToLogdif,~,~,~,logEPName)
                fcn=@runSimWithLogged;
                function runSimWithLogged(tbExecCfg,tb,dName,mexFileName)


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

                    data=feval(mexFileName,logEPName);
                    loggedVals.inputNames=fcnToLogdif.inportNames;
                    loggedVals.outputNames=fcnToLogdif.outportNames;
                    loggedVals.inputs=cellfun(@(x)data.inputs.(x),fcnToLogdif.inportNames,'UniformOutput',false);
                    loggedVals.outputs=cellfun(@(x)data.outputs.(x),fcnToLogdif.outportNames,'UniformOutput',false);
                    loggedVals.iter=data.iterCount;
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





            function[mexFileName,logEPName]=buildDesign(dName,exInputs,fcnToLog,outPath,coderConstIndices,coderConstVals,simLimit,hdlMexCfg)
                mexFileName=[dName,'_hdl_mex'];

                try
                    if strlength(mexFileName)>namelengthmax
                        error(message('Coder:FXPCONV:F2F_LongFilename',mexFileName,namelengthmax));
                    end

                    exInputs=injectCoderConstants(exInputs,coderConstIndices,coderConstVals);
                    mexOutputFile=fullfile(outPath,mexFileName);
                    mexFilesOutputDir=fullfile(outPath,dName);

                    mexCfg=hdlMexCfg;


                    mexCfg.ConstantInputs='IgnoreValues';
                    logDif=coder.internal.Float2FixedConverter.getDIF(fcnToLog);

                    irLogCfg=internal.float2fixed.F2FConfig;
                    irLogCfg.F2FEnabled=true;
                    irLogCfg.ApplyTypeAnnotations=false;
                    irLogCfg.LogFunctionInputsAndOutputs=1;
                    irLogCfg.addFunctionsToLog({fcnToLog});
                    mexCfg.F2FConfig=irLogCfg;

                    mexLoggerTemplate=coder.internal.LoggerService.MEX_LOGGER_TEMPLATE_PATH;
                    logEPName=[fcnToLog,'_logger'];
                    outputLoggerPath=fullfile(outPath,[logEPName,'.m']);


                    inputsToLog=logDif.inportNames;%#ok<NASGU>
                    outputsToLog=logDif.outportNames;%#ok<NASGU>
                    if simLimit==-1

                        simLimit=Inf;
                    end
                    simIterLimit=simLimit;%#ok<NASGU>
                    coder.internal.tools.TML.render_to_file(mexLoggerTemplate,outputLoggerPath,true);

                    if isempty(exInputs)&&~iscell(exInputs)&&isempty(logDif.inportNames)





                        exInputs={};
                    end






                    designArgList={dName,'-args',exInputs,logEPName};
                    emlcprivate('emlckernel','codegen','-config',mexCfg,'-o',mexOutputFile,'-d',mexFilesOutputDir,designArgList{:});
                catch me
                    fprintf('### %s',message('Coder:FxpConvDisp:FXPCONVDISP:examineErrorReport').getString);
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






        function[flatDataNames,flatDataList]=flattenStructLoggedData(data)
            flatDataNames={};
            flatDataList={};

            fields=fieldnames(data);
            for kk=1:length(fields)
                field=fields{kk};
                if~isempty(data)&&isstruct(data(1).(field))
                    fieldData=vertcat(data.(field));


                    [tmpDataNames,tmpFlatDataList]=emlhdlcoder.HDLTBDataLogger.flattenStructLoggedData(fieldData);



                    flatDataNames=[flatDataNames,cellfun(@(s)[field,'_',s],tmpDataNames,'UniformOutput',false)];%#ok<AGROW>
                    flatDataList=[flatDataList,tmpFlatDataList];%#ok<AGROW>
                else
                    if iscolumn(data(1).(field))
                        fieldData=vertcat(data.(field));
                    else
                        fieldData=horzcat(data.(field));
                    end
                    flatDataNames{end+1}=field;%#ok<AGROW>
                    flatDataList{end+1}=fieldData;%#ok<AGROW>
                end
            end
        end
    end

    methods
        function this=HDLTBDataLogger(hdlDriver,dutName,tbName,cgInfo)
            this.hHDLDriver=hdlDriver;
            this.hTopFunctionName=dutName;
            this.hTopScriptName=tbName;
            this.hCgInfo=cgInfo;
        end




        function loggedData=computeData(this,emlDutInterface,streamInfo)
            cginfo=this.getHDLDriver.cgInfo;

            hdlCfg=cginfo.HDLConfig;
            fixPtDone=hdlCfg.IsFixPtConversionDone;
            if isfield(cginfo,'fxpCfg')
                fxpCfg=cginfo.fxpCfg;
            end

            customerDesignFolderName=this.hTopFunctionName;
            if fixPtDone
                assert(~isempty(fxpCfg.DesignFunctionName),'''DesignFunctionName'' property for Fixed Point Config Object cannot be empty');
                [~,customerDesignFolderName,~]=fileparts(fxpCfg.DesignFunctionName);
            end

            if fixPtDone&&~isempty(fxpCfg.CodegenDirectory)
                [fpcRootDir,codeGenFolderName,~]=fileparts(fxpCfg.CodegenDirectory);
                [workDir,outputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(fpcRootDir,codeGenFolderName,customerDesignFolderName);
            elseif(isfield(cginfo,'codegenDir'))
                [fpcRootDir,codeGenFolderName,~]=fileparts(cginfo.codegenDir);
                [workDir,outputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir(fpcRootDir,codeGenFolderName,customerDesignFolderName);
            else
                [workDir,outputFilesDir]=coder.internal.Float2FixedConverter.getWorkingAndOutputDir([],[],customerDesignFolderName);
            end

            simLimit=hdlCfg.SimulationIterationLimit;
            if simLimit==0
                simLimit=Inf;
            end

            assert(isfield(cginfo,'inVals'),'input values expected');

            fxpDirExistsToBeginWith=true;
            d=dir(outputFilesDir);
            if isempty(d)
                fxpDirExistsToBeginWith=false;
            end

            tbName=this.hTopScriptName;
            if ischar(tbName)
                tbNames={tbName};
            end

            if fixPtDone


                [~,fcnToIntercept,~]=fileparts(fxpCfg.DesignFunctionName);
                fcnToLog=this.hTopFunctionName;

                wrapperName=coder.internal.Float2FixedConverter.buildFixPtWrapperName(fcnToIntercept,fxpCfg.FixPtFileNameSuffix);
                wrapperFullFileName=fullfile(outputFilesDir,[wrapperName,'.m']);
                assert(2==exist(wrapperFullFileName,'file'));

                fcnToMexAndInvoke=wrapperName;

                inArgs=cginfo.origItcs;
            else
                fcnToLog=this.hTopFunctionName;

                fcnToMexAndInvoke=this.hTopFunctionName;



                fcnToIntercept=fcnToMexAndInvoke;
                inArgs=cginfo.inVals;
            end

            try
                loggedData=emlhdlcoder.HDLTBDataLogger.runTestBenchToLogData(workDir...
                ,outputFilesDir...
                ,fcnToMexAndInvoke...
                ,inArgs...
                ,fcnToIntercept...
                ,cginfo.inputITCs...
                ,fcnToLog...
                ,tbNames...
                ,simLimit...
                ,cginfo.coderConstIndices...
                ,cginfo.coderConstVals...
                ,cginfo.HDLConfig.HDLTBMexConfig);
            catch me
                coder.internal.LoggerService.clearLogValues(emlDutInterface);
                rethrow(me);
            end
            loggedData=this.removeConstantInputData(loggedData,cginfo.coderConstIndices);

            loggedData=this.processLoggedData(emlDutInterface,loggedData);
            loggedData=this.reshapeLoggedData(emlDutInterface,loggedData,streamInfo);

            if~fxpDirExistsToBeginWith
                coder.internal.Helper.deleteDir(outputFilesDir);
            end
        end



        function loggedData=removeConstantInputData(~,loggedData,coderConstIndices)
            loggedData.inputs(coderConstIndices)=[];
            loggedData.inputNames(coderConstIndices)=[];
        end












        function loggedData=processLoggedData(~,emlDutInterface,loggedData)
            iterationCount=loggedData.iter;




            loggedInputs=loggedData.inputs;

            loggedData.inputs={};


            for ii=1:length(loggedInputs)
                ipData=loggedInputs{ii};
                if~isempty(ipData)&&isstruct(ipData(1))
                    [flattenedNames,flattenedData]=emlhdlcoder.HDLTBDataLogger.flattenStructLoggedData(ipData(1:iterationCount));


                    for kk=1:length(flattenedNames)

                        loggedData.inputs{end+1}=flattenedData{kk};
                    end
                else

                    if length(ipData)>=iterationCount
                        loggedData.inputs{end+1}=ipData;
                    end
                end
            end
            loggedData.inputs=loggedData.inputs';


            loggedOutputs=loggedData.outputs;

            loggedData.outputs={};


            for ii=1:length(loggedOutputs)
                ipData=loggedOutputs{ii};
                if~isempty(ipData)&&isstruct(ipData(1))
                    [flattenedNames,flattenedData]=emlhdlcoder.HDLTBDataLogger.flattenStructLoggedData(ipData(1:iterationCount));
                    for kk=1:length(flattenedNames)
                        loggedData.outputs{end+1}=flattenedData{kk};
                    end
                else

                    if length(ipData)>=iterationCount
                        loggedData.outputs{end+1}=ipData;
                    end
                end
            end
            loggedData.outputs=loggedData.outputs';




            numInPorts=length(emlDutInterface.inputTypesInfo);
            for ii=1:numInPorts
                tp=emlDutInterface.inputTypesInfo{ii};
                if strcmp(tp.sltype,'boolean')&&isa(loggedData.inputs{ii},'double')
                    loggedData.inputs{ii}=logical(loggedData.inputs{ii});
                elseif 1==(strfind(tp.sltype,'Enum:'))
                    enumName=strtrim(strrep(tp.sltype,'Enum:',''));
                    loggedData.inputs{ii}=eval([enumName,'( loggedData.inputs{ii} )']);
                end
            end

            numOutPorts=length(emlDutInterface.outputTypesInfo);
            for ii=1:numOutPorts
                tp=emlDutInterface.outputTypesInfo{ii};
                if strcmp(tp.sltype,'boolean')&&isa(loggedData.outputs{ii},'double')
                    loggedData.outputs{ii}=logical(loggedData.outputs{ii});
                elseif 1==(strfind(tp.sltype,'Enum:'))
                    enumName=strtrim(strrep(tp.sltype,'Enum:',''));
                    loggedData.outputs{ii}=eval([enumName,'( loggedData.outputs{ii} )']);
                end
            end




            loggedData=rmfield(loggedData,'inputNames');
            loggedData=rmfield(loggedData,'outputNames');
        end









        function loggedData=reshapeLoggedData(this,emlDutInterface,loggedData,streamInfo)
            numIn=numel(loggedData.inputs);
            numOut=numel(loggedData.outputs);

            if isempty(streamInfo.streamedInPortsRelative)
                inputsStreamed=false(1,numIn);
            else
                inputsStreamed=ismember(1:numIn,[streamInfo.streamedInPortsRelative.data]);
            end

            if isempty(streamInfo.streamedOutPortsRelative)
                outputsStreamed=false(1,numOut);
            else
                outputsStreamed=ismember(1:numOut,[streamInfo.streamedOutPortsRelative.data]);
            end

            for ii=1:numIn
                typeInfo=emlDutInterface.inputTypesInfo{ii};
                dim=this.getDimFromTypeInfo(typeInfo);

                loggedData.inputs{ii}=this.reshapeData(loggedData.inputs{ii},...
                typeInfo,dim,loggedData.iter,inputsStreamed(ii));
            end

            for ii=1:numOut
                typeInfo=emlDutInterface.outputTypesInfo{ii};
                dim=this.getDimFromTypeInfo(typeInfo);

                loggedData.outputs{ii}=this.reshapeData(loggedData.outputs{ii},...
                typeInfo,dim,loggedData.iter,outputsStreamed(ii));
            end

            iterationCount=loggedData.iter;
            for ii=1:numIn
                dataLen=size(loggedData.inputs{ii},1);
                if 0~=dataLen
                    assert(dataLen==iterationCount||inputsStreamed(ii));
                end
            end

            for ii=1:numOut
                dataLen=size(loggedData.outputs{ii},1);
                if 0~=dataLen
                    assert(dataLen==iterationCount||outputsStreamed(ii));
                end
            end
        end


        function hdlDrv=getHDLDriver(this)
            hdlDrv=this.hHDLDriver;
        end


        function dim=getDimFromTypeInfo(~,typeInfo)
            assert(typeInfo.numdims<=2);
            if typeInfo.isscalar
                dim=[1,1];
            elseif typeInfo.isvector
                if typeInfo.iscolvec
                    dim=[typeInfo.dims,1];
                else
                    dim=[1,typeInfo.dims];
                end
            else

                assert(typeInfo.ismatrix);
                dim=typeInfo.vector;
            end
        end
    end

    methods(Access=private)
        function dat=reshapeData(this,dat,typeInfo,dim,iterCount,isStreamed)

            if~isStreamed&&(typeInfo.iscolvec||typeInfo.isscalar)
                y=reshape(dat,dim(1),dim(2)*iterCount);


                dat=transpose(y);
            elseif~isStreamed
                assert(typeInfo.isrowvec&&~typeInfo.ismatrix);
                y=reshape(dat,dim(2),dim(1)*iterCount);


                dat=transpose(y);
            else


                samplesPerCycle=this.hHDLDriver.getParameter('SamplesPerCycle');



                allRows=size(dat,1);

                if allRows==1&&iterCount>1



                    dat=transpose(reshape(dat,[],iterCount));
                    allRows=size(dat,1);
                end

                assert(mod(allRows,iterCount)==0);



                assert(mod(size(dat,2),samplesPerCycle)==0);

                frameRows=allRows/iterCount;
                frameNumel=numel(dat)/iterCount;
                samplesPerFrame=frameNumel/samplesPerCycle;
                datOut=zeros(numel(dat)/samplesPerCycle,samplesPerCycle,'like',dat);

                for i=1:iterCount

                    frame=dat(((i-1)*frameRows+1):(i*frameRows),:);


                    datOut(((i-1)*samplesPerFrame+1):(i*samplesPerFrame),:)=...
                    transpose(reshape(transpose(frame),samplesPerCycle,samplesPerFrame));
                end

                dat=datOut;
            end
        end
    end

end


