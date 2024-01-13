classdef Coder<pslink.verifier.Coder

    properties(Constant,GetAccess=public)
        CODER_NAME='Custom-Code';
        CODER_ID='slcc';
        CODER_VERIF_NAME='CUSTOMCODE';
        CODER_IDE_NAME='CUSTOMCODE';
    end

    properties(Access=private)
WrappersFile
Dialect
TargetInfo
    end


    methods(Static=true)

        function str=getCoderName()
            str=pslink.verifier.slcc.Coder.CODER_NAME;
        end
    end


    methods

        function self=Coder(blockPath,pslinkOptions)
            if nargin<2
                pslinkOptions=pslink.Options(blockPath);
            end
            self@pslink.verifier.Coder(blockPath);
            resultDir=pslinkOptions.ResultDir;
            self.sysDirInfo=pslink.util.Helper.getConfigDirInfo(self.slSystemName,pslink.verifier.slcc.Coder.CODER_ID);
            self.cgName=fullfile(resultDir,'pslink');
            self.cgDirStatus=exist(self.sysDirInfo.SystemCodeGenDir,'dir');
            self.inputFullRange=true;

            self.Dialect='';
            self.WrappersFile='';
        end


        function extractAllInfo(self,opts)
            blockPath=self.slSystemName;

            tmpDir=self.cgName;

            [~,~,~]=mkdir(tmpDir);

            [sourceFiles,wrapperInfo,feOptions]=...
            self.generateFilesAndExtractDrs(tmpDir,opts,blockPath);
            compilerInfo=sldv.code.internal.getCompilerInfo(feOptions);
            self.Dialect=compilerInfo.dialect;
            self.TargetInfo=self.computeTargetInfo(feOptions);
            self.fcnInfo.codeLanguage=wrapperInfo.Language;
            self.fileInfo.source=sourceFiles;
            self.fileInfo.include=[feOptions.Preprocessor.SystemIncludeDirs(:);...
            feOptions.Preprocessor.IncludeDirs(:)];
            self.fileInfo.define=feOptions.Preprocessor.Defines;
            if~isempty(feOptions.Preprocessor.UnDefines)
                self.fileInfo.undefine=feOptions.Preprocessor.UnDefines;
            end
            self.fcnInfo.step=pslink.verifier.Coder.createFcnInfoStruct();
            self.fcnInfo.step.fcn=wrapperInfo.StepFcns;
            self.fcnInfo.step.var=wrapperInfo.StepVars;

            if~isempty(wrapperInfo.InitFcns)
                self.fcnInfo.init=pslink.verifier.Coder.createFcnInfoStruct();
                self.fcnInfo.init.fcn=wrapperInfo.InitFcns;
            end

            if~isempty(wrapperInfo.TermFcns)
                self.fcnInfo.term=pslink.verifier.Coder.createFcnInfoStruct();
                self.fcnInfo.term.fcn=wrapperInfo.TermFcns;
            end
        end


        function checkSum=getCheckSum(self)%#ok;
            checkSum=[];
        end


        function language=getLanguage(self)
            language=self.fcnInfo.codeLanguage;
        end


        function dialect=getDialect(self)
            dialect=self.Dialect;
        end


        function targetInfo=getTargetInfo(self)
            targetInfo=self.TargetInfo;
        end


        function wrappersFile=getWrappersFile(self)
            wrappersFile=self.WrappersFile;
        end
    end


    methods(Access=private)

        function name=getLinkName(~,blockH)
            sid=Simulink.ID.getSID(blockH);
            fullName=Simulink.ID.getFullName(sid);
            slashIndexes=strfind(fullName,'/');
            if~isempty(slashIndexes)
                startIndex=slashIndexes(1);
                name=['<Root>',fullName(startIndex:end)];
            else
                name='<Root>';
            end
        end


        function targetInfo=computeTargetInfo(~,feOpts)
            if strcmp(feOpts.Target.Endianness,'little')
                endianess='LittleEndian';
            else
                endianess='BigEndian';
            end
            targetInfo=struct('CharNumBits',feOpts.Target.CharNumBits,...
            'IsCharSigned',feOpts.Language.PlainCharsAreSigned,...
            'ShortNumBits',feOpts.Target.ShortNumBits,...
            'IntNumBits',feOpts.Target.IntNumBits,...
            'LongNumBits',feOpts.Target.LongNumBits,...
            'LongLongNumBits',feOpts.Target.LongLongNumBits,...
            'FloatNumBits',feOpts.Target.FloatNumBits,...
            'DoubleNumBits',feOpts.Target.DoubleNumBits,...
            'LongDoubleNumBits',feOpts.Target.LongDoubleNumBits,...
            'PointerNumBits',feOpts.Target.PointerNumBits,...
            'WordNumBits',feOpts.Target.IntNumBits,...
            'Endianess',endianess,...
            'ShiftRightIntArith',1,...
            'HWDeviceType','Generic->MATLAB Host Computer');
        end


        function parseData=parseCustomCode(~,feOptions,customCodeInfo)
            options=internal.cxxfe.il2ast.Options();
            options.ConvertMacros=true;
            e=internal.cxxfe.il2ast.Env(feOptions);
            if~e.parseText(customCodeInfo.customCode,options)
                error('pslink:errorParsingCustomCode',...
                message('polyspace:gui:pslink:errorParsingCustomCode').getString());
            end
            parseData=e.Ast;
        end


        function[sourceFiles,wrapperInfo,feOptions]=generateFilesAndExtractDrs(self,...
            tmpDir,...
            pslinkOptions,...
            blockH)



            function cleanupCompile(cleanupStruct)
                if isfield(cleanupStruct,'TerminateStr')
                    evalc(cleanupStruct.TerminateStr);
                end
                if isfield(cleanupStruct,'SimulationMode')
                    set_param(cleanupStruct.Model,'SimulationMode',cleanupStruct.SimulationMode);
                end

                warning(cleanupStruct.WarnStruct);

            end

            modelName=bdroot(blockH);

            initFcns={};
            termFcns={};

            cleanupStruct.Model=modelName;
            cleanupStruct.WarnStruct=warning;
            warning('off');

            simulationMode=get_param(modelName,'SimulationMode');
            if simulationMode=="accelerator"

                set_param(modelName,'SimulationMode','normal');
                cleanupStruct.SimulationMode=simulationMode;
            end

            if~strcmpi(get_param(modelName,'SimulationStatus'),'initializing')

                evalc('feval(modelName, [],[], [], ''compile'')');

                cleanupStruct.TerminateStr=sprintf('feval(''%s'', [], [], [], ''term'')',modelName);
            end

            restore=onCleanup(@()cleanupCompile(cleanupStruct));

            [customCodeInfo,userIncludes,userSources]=sldv.code.slcc.internal.getMergedCustomCodeInfo(modelName);

            if customCodeInfo.isCpp
                language='C++';
            else
                language='C';
            end
            slccTempDir=slcc('getSLCCTempHeaderDir');
            userIncludes{end+1}=slccTempDir;
            feOptions=CGXE.CustomCode.getFrontEndOptions(language,...
            userIncludes,...
            customCodeInfo.customUserDefines);

            [~,hasCustomSource]=customCodeInfo.hasCustomCode();
            if hasCustomSource
                [customCodeFile,initFcns,termFcns]=self.generateCustomCodeFile(tmpDir,modelName,customCodeInfo);
            end

            parseInfo=self.parseCustomCode(feOptions,customCodeInfo);

            writeParamValues=~strcmp(pslinkOptions.ParamRangeMode,'DesignMinMax');
            [self.WrappersFile,wrappersHeader]=self.createWrappersFiles(tmpDir,customCodeInfo);

            [modelInfo,ccVars]=self.getCustomCodeModelInfo(modelName);

            if isempty(modelInfo)
                modelHandle=get_param(modelName,'Handle');
                customCodeInfo=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelHandle);

                if~customCodeInfo.hasCustomCode()
                    throw(MSLException(modelHandle,...
                    message('polyspace:gui:pslink:noCustomCode',modelName)));
                elseif~customCodeInfo.parseCC
                    throw(MSLException(modelHandle,...
                    message('polyspace:gui:pslink:noSimParseCustomCode',modelName)));
                else
                    hasInitTerm=~isempty(strtrim(customCodeInfo.customTerminator))||...
                    ~isempty(strtrim(customCodeInfo.customInitializer));
                    if~hasInitTerm
                        throw(MSLException(modelHandle,...
                        message('polyspace:gui:pslink:noCustomCodeCalled')));
                    end
                end
            end

            stepVars=ccVars;
            stepFcns={};

            blocks=modelInfo.keys;

            self.dlinkInfo.name=self.slModelName;
            self.dlinkInfo.source='traceInfo';
            self.dlinkInfo.model=self.slModelFileName;
            self.dlinkInfo.version=self.slModelVersion;
            self.dlinkInfo.info(1:numel(blocks))=pslink.verifier.Coder.createLinkDataInfoStruct();

            for bb=1:numel(blocks)
                currentBlockH=blocks{bb};
                callInfo=modelInfo(currentBlockH);
                isCScript=get_param(currentBlockH,'BlockType')=="CFunction";

                [blockInfo,callInfo]=self.getBlockInfo(currentBlockH,callInfo);


                if~isCScript
                    [blockInfo,callInfo]=pslink.verifier.slcc.Coder.simplifyBlockInfo(callInfo,blockInfo);
                end
                if~isempty(blockInfo.Inputs)
                    inputVars={blockInfo.Inputs.VarName};
                    stepVars=[stepVars;inputVars(:)];%#ok<AGROW>
                end

                if~isempty(blockInfo.Others)
                    otherVars={blockInfo.Others.VarName};
                    stepVars=[stepVars;otherVars(:)];%#ok <AGROW>
                end

                if~isempty(blockInfo.Outputs)
                    outputVars={blockInfo.Outputs.VarName};
                    stepVars=[stepVars;outputVars(:)];%#ok <AGROW>
                end

                stepFcns=[stepFcns;blockInfo.StepFcns(:)];%#ok <AGROW>

                self.generateWrappersDeclarations(wrappersHeader,currentBlockH,blockInfo,writeParamValues);

                if isCScript
                    [cscriptInits,cscriptTerms]=self.generateCScriptWrappers(feOptions,customCodeInfo,self.WrappersFile,currentBlockH,blockInfo,callInfo,writeParamValues);
                    if~isempty(cscriptInits)
                        initFcns=[initFcns(:);cscriptInits(:)];
                    end
                    if~isempty(cscriptTerms)
                        termFcns=[termFcns(:);cscriptTerms(:)];
                    end
                else
                    self.generateCallWrappers(self.WrappersFile,currentBlockH,blockInfo,parseInfo,callInfo,writeParamValues);
                end
                self.getDesignMinMax(pslinkOptions,modelName,currentBlockH,blockInfo);


                sid=Simulink.ID.getSID(currentBlockH);
                fullName=Simulink.ID.getFullName(sid);

                self.dlinkInfo.info(bb).name=fullName;
                self.dlinkInfo.info(bb).codename=self.getLinkName(currentBlockH);
                self.dlinkInfo.info(bb).path=Simulink.ID.getFullName(sid);
                self.dlinkInfo.info(bb).sid=sid;
            end

            self.endWrappersHeader(wrappersHeader);

            if hasCustomSource
                generatedFiles={self.WrappersFile,customCodeFile};
            else
                generatedFiles={self.WrappersFile};
            end

            sourceFiles=[generatedFiles(:);userSources(:)];

            wrapperInfo=struct();
            wrapperInfo.Language=language;
            wrapperInfo.TermFcns=termFcns;
            wrapperInfo.InitFcns=initFcns;
            wrapperInfo.StepFcns=stepFcns;
            wrapperInfo.StepVars=stepVars;
        end


        function[modelInfo,customCodeVars]=getCustomCodeModelInfo(self,mainModelName)
            modelInfo=containers.Map('KeyType','double','ValueType','any');
            customCodeVars={};
            modelRefs=find_mdlrefs(mainModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for modelIndex=1:numel(modelRefs)
                modelName=modelRefs{modelIndex};

                modelObj=get_param(modelName,'Object');
                sfcharts=find(modelObj,'-isa','Stateflow.Chart');
                for ii=1:numel(sfcharts)
                    currentChart=sfcharts(ii);
                    if~pslink.verifier.slcc.Coder.isCommented(currentChart.Path)&&...
                        currentChart.ActionLanguage=="C"
                        sfInfo=sldv.code.slcc.internal.getStateflowCallInfo(currentChart.Path);
                        if~isempty(sfInfo)&&isstruct(sfInfo)
                            chartHandle=get_param(currentChart.Path,'Handle');
                            modelInfo(chartHandle)=sfInfo.Functions;
                            customCodeVars=[customCodeVars;sfInfo.Variables(:)];%#ok<AGROW>
                        end
                    end
                end
                ccallers=find(modelObj,'-isa','Simulink.CCaller');
                for ii=1:numel(ccallers)
                    callerHandle=ccallers(ii).Handle;
                    if~pslink.verifier.slcc.Coder.isCommented(callerHandle)
                        callInfo=self.getCallInfoFromCCaller(callerHandle);
                        modelInfo(callerHandle)=callInfo;
                    end
                end
                cscripts=find(modelObj,'-isa','Simulink.CFunction');
                for ii=1:numel(cscripts)
                    cscriptHandle=cscripts(ii).Handle;
                    if~pslink.verifier.slcc.Coder.isCommented(cscriptHandle)
                        callInfo=self.getCallInfoFromCScript(cscriptHandle);
                        modelInfo(cscriptHandle)=callInfo;
                    end
                end
            end
        end


        function[wrappersFile,wrappersHeader]=createWrappersFiles(self,tmpDir,customCodeInfo)
            if customCodeInfo.isCpp
                ext='cpp';
            else
                ext='c';
            end

            fileHeader=sprintf(['/* Copyright %s The MathWorks, Inc.\n',...
            ' *\n',...
            ' * THIS FILE IS AUTOMATICALLY GENERATED AND USED BY POLYSPACE.\n',...
            ' * DO NOT MODIFY IT.\n',...
            ' */\n'],datestr(now,'yyyy'));

            wrappersHeader=fullfile(tmpDir,sprintf('customcode_wrappers.h'));
            fid=fopen(wrappersHeader,'w','n',self.SourceEncoding);
            fprintf(fid,'%s\n',fileHeader);
            fprintf(fid,'#ifndef CUSTOMCODE_WRAPPERS_H\n');
            fprintf(fid,'#define CUSTOMCODE_WRAPPERS_H\n');

            fprintf(fid,'#include <tmwtypes.h>\n\n');
            fprintf(fid,'/* custom-code panel headers */\n');
            fprintf(fid,'%s\n\n',customCodeInfo.customCode);
            fclose(fid);

            wrappersFile=fullfile(tmpDir,sprintf('customcode_wrappers.%s',ext));
            fid=fopen(wrappersFile,'w','n',self.SourceEncoding);

            fprintf(fid,'%s\n',fileHeader);
            fprintf(fid,'#include "customcode_wrappers.h"\n\n');
            fclose(fid);
        end


        function endWrappersHeader(self,wrappersHeader)
            fid=fopen(wrappersHeader,'at','n',self.SourceEncoding);
            fprintf(fid,'\n#endif /* CUSTOMCODE_WRAPPERS_H */\n');
            fclose(fid);
        end


        function[customCodeFile,initFcns,termFcns]=generateCustomCodeFile(self,...
            tmpDir,...
            modelName,...
            customCodeInfo)
            if customCodeInfo.isCpp
                ext='cpp';
            else
                ext='c';
            end
            customCodeFile=fullfile(tmpDir,sprintf('customcode.%s',ext));

            fid=fopen(customCodeFile,'w','n',self.SourceEncoding);
            mainFileHeader=sprintf(['/* Copyright %s The MathWorks, Inc.\n',...
            ' *\n',...
            ' * THIS FILE IS AUTOMATICALLY GENERATED AND USED BY POLYSPACE.\n',...
            ' * DO NOT MODIFY IT.\n',...
            ' */\n'],datestr(now,'yyyy'));

            fprintf(fid,'%s\n',mainFileHeader);
            fprintf(fid,'#include <tmwtypes.h>\n\n');


            fprintf(fid,'/* Content of the custom-code panel */\n');
            fprintf(fid,'%s\n',customCodeInfo.getCustomCodeFromSettings());


            if~isempty(strtrim(customCodeInfo.customInitializer))
                [~,initFcn]=pslink.verifier.slcc.Coder.getVarPrefix(modelName,'init');
                fprintf(fid,'/* Initializer */\n');
                fprintf(fid,'void %s(void) {\n',initFcn);
                fprintf(fid,'    %s\n',customCodeInfo.customInitializer);
                fprintf(fid,'}\n\n');

                initFcns={initFcn};
            else
                initFcns={};
            end

            if~isempty(strtrim(customCodeInfo.customTerminator))
                [~,termFcn]=pslink.verifier.slcc.Coder.getVarPrefix(modelName,'term');
                fprintf(fid,'/* Terminator */\n');
                fprintf(fid,'void %s(void) {\n',termFcn);
                fprintf(fid,'    %s\n',customCodeInfo.customTerminator);
                fprintf(fid,'}\n\n');

                termFcns={termFcn};
            else
                termFcns={};
            end

            fclose(fid);
        end

        function callInfo=getCallInfoFromCScript(self,block)
            portSpec=get_param(block,'PortSpecStructParam');

            if(~isempty(portSpec))
                portSpec=portSpec.PortSpecification;
            end
            callInfo=getCallInfoFromStructData(self,block,'',portSpec);
        end

        function callInfo=getCallInfoFromCCaller(self,block)
            blockHandle=get_param(block,'Handle');
            calledFunction=get_param(block,'FunctionName');


            portSpec=get_param(blockHandle,'FunctionPortSpecification');
            callInfo.FunctionName=calledFunction;
            callInfo.SID=Simulink.ID.getSID(blockHandle);
            callInfo.NumOutputs=0;

            allArguments=[portSpec.ReturnArgument(:);portSpec.InputArguments(:)];
            numParams=numel(allArguments);

            paramStruct=struct('Kind','',...
            'Type','',...
            'PortIndex','',...
            'Dims','',...
            'ParameterString','',...
            'ArgName','');
            parameters(1:numParams)=paramStruct;
            for ii=1:numParams
                parameters(ii).PortIndex=allArguments(ii).PortNumber;
                parameters(ii).ArgName=allArguments(ii).Name;

                switch allArguments(ii).Scope
                case 'Output'
                    parameters(ii).Kind='OutputPort';
                case{'Input','InputOutput'}
                    parameters(ii).Kind='InputPort';
                case{'Parameter','Constant'}


                    parameters(ii).Kind='BlockParameter';
                case 'Persistent'
                    parameters(ii).Kind='Persistent';
                    [parameters(ii).Type,parameters(ii).Dims]=self.resolveTypeAndDims(blockHandle,...
                    allArguments(ii).Type,allArguments(ii).Size);
                otherwise
                    error('pslink:unsupportedCustomCodeArgument',...
                    message('polyspace:gui:pslink:unsupportedCustomCodeArgument',calledFunction).getString());
                end
            end
            callInfo.Parameters=parameters;
        end

        function[cType,dims]=resolveTypeAndDims(self,blockHandle,slType,slSize)
            dims=slResolve(slSize,blockHandle);
            cType=pslink.verifier.slcc.Coder.structTypeToCType(slType);

            if isempty(cType)
                sid=Simulink.ID.getSID(blockHandle);
                blockPath=Simulink.ID.getFullName(sid);
                modelHandle=get_param(self.slModelName,'Handle');

                throw(MSLException(modelHandle,...
                message('polyspace:gui:pslink:unsupportedCustomCodeType',...
                blockPath,...
                slType)));
            end
        end

        function callInfo=getCallInfoFromStructData(self,blockHandle,calledFunction,structData)

            callInfo.FunctionName=calledFunction;
            callInfo.SID=Simulink.ID.getSID(blockHandle);
            callInfo.NumOutputs=0;

            numParams=numel(structData);
            paramStruct=struct('Kind','',...
            'Type','',...
            'PortIndex','',...
            'Dims','',...
            'ParameterString','',...
            'ArgName','');
            parameters(1:numParams)=paramStruct;
            for ii=1:numParams
                parameters(ii).PortIndex=structData(ii).Port+1;
                parameters(ii).ArgName=structData(ii).Name;

                switch structData(ii).Scope
                case 'Output'
                    parameters(ii).Kind='OutputPort';
                case{'Input','InputOutput'}
                    parameters(ii).Kind='InputPort';
                case{'Parameter','Constant'}


                    parameters(ii).Kind='BlockParameter';
                case 'Persistent'
                    parameters(ii).Kind='Persistent';
                    [parameters(ii).Type,parameters(ii).Dims]=self.resolveTypeAndDims(blockHandle,...
                    structData(ii).Type,structData(ii).Size);
                otherwise
                    error('pslink:unsupportedCustomCodeArgument',...
                    message('polyspace:gui:pslink:unsupportedCustomCodeArgument',calledFunction).getString());
                end
            end
            callInfo.Parameters=parameters;
        end


        function generateWrapperVariablesDeclarations(self,fid,block,blockInfo,writeParamValues)
            blockName=get_param(block,'Name');
            blockLinkName=self.getLinkName(block);
            blockComment=message('polyspace:gui:pslink:customCodeWrapperDeclarationComment',blockName).getString();
            fprintf(fid,'/* %s */\n',blockComment);
            blockLinkComment=message('polyspace:gui:pslink:customCodeWrapperBlockComment',blockLinkName).getString();
            fprintf(fid,'/* %s */\n',blockLinkComment);
            for ii=1:numel(blockInfo.Inputs)
                self.writeVarDecl(fid,blockInfo.Inputs(ii),'extern');
            end

            for ii=1:numel(blockInfo.Outputs)
                self.writeVarDecl(fid,blockInfo.Outputs(ii),'extern');
            end



            if writeParamValues
                for ii=1:numel(blockInfo.Parameters)
                    initValue=getInitValue(blockInfo.Parameters(ii).Value);
                    if~isempty(initValue)
                        self.writeVarDecl(fid,blockInfo.Parameters(ii),'extern');
                    end
                end
            end

            for ii=1:numel(blockInfo.Others)
                self.writeVarDecl(fid,blockInfo.Others(ii),'extern');
            end
        end


        function generateWrapperVariables(self,fid,block,blockInfo,writeParamValues)
            blockName=get_param(block,'Name');
            blockLinkName=self.getLinkName(block);
            blockComment=message('polyspace:gui:pslink:customCodeWrapperBlockComment',blockLinkName).getString();
            fprintf(fid,'/* %s */\n',blockComment);
            if~isempty(blockInfo.Inputs)
                inputComment=message('polyspace:gui:pslink:customCodeWrapperInputComment',blockName).getString();
                fprintf(fid,'/* %s */\n',inputComment);
                for ii=1:numel(blockInfo.Inputs)
                    self.writeVarDecl(fid,blockInfo.Inputs(ii),'');
                end
            end

            if~isempty(blockInfo.Outputs)
                outputComment=message('polyspace:gui:pslink:customCodeWrapperOutputComment',blockName).getString();
                fprintf(fid,'/* %s */\n',outputComment);
                for ii=1:numel(blockInfo.Outputs)
                    self.writeVarDecl(fid,blockInfo.Outputs(ii),'');
                end
            end

            if~isempty(blockInfo.Parameters)
                parameterComment=message('polyspace:gui:pslink:customCodeWrapperParameterComment',blockName).getString();
                fprintf(fid,'/* %s */\n',parameterComment);
                for ii=1:numel(blockInfo.Parameters)
                    if writeParamValues
                        initValue=getInitValue(blockInfo.Parameters(ii).Value);
                        if isempty(initValue)
                            qualifiers='extern';
                        else
                            qualifiers='';
                        end
                    else
                        qualifiers='extern';
                        initValue='';
                    end
                    self.writeVarDecl(fid,blockInfo.Parameters(ii),qualifiers,initValue);
                end
            end

            if~isempty(blockInfo.Others)
                otherComment=message('polyspace:gui:pslink:customCodeWrapperOtherComment',blockName).getString();
                fprintf(fid,'/* %s */\n',otherComment);
                for ii=1:numel(blockInfo.Others)
                    self.writeVarDecl(fid,blockInfo.Others(ii),'');
                end
            end

            if~isempty(blockInfo.PersistentVars)
                persistentComment=message('polyspace:gui:pslink:customCodeWrapperPersistentComment',blockName).getString();
                fprintf(fid,'/* %s */\n',persistentComment);
                for ii=1:numel(blockInfo.PersistentVars)
                    self.writeVarDecl(fid,blockInfo.PersistentVars(ii),'static');
                end
            end
        end


        function initializeScriptReplacer(self,cscriptVarReplacer,blockInfo,callInfo)
            numParams=numel(callInfo.Parameters);

            params=cell(1,numParams);

            for ii=1:numel(callInfo.Parameters)
                param=callInfo.Parameters(ii);

                portIndex=param.PortIndex;
                portField='';
                switch param.Kind
                case 'OutputPort'
                    portField='Outputs';
                case 'InputPort'
                    portField='Inputs';
                case 'BlockParameter'
                    portField='Parameters';
                case 'OtherVar'
                    portField='Others';
                case 'Persistent'
                    portField='PersistentVars';
                otherwise
                    assert(false,'Unsupported C-caller mapping: %s',...
                    parm.Kind);
                end

                varName=blockInfo.(portField)(portIndex).VarName;
                varDims=blockInfo.(portField)(portIndex).Dims;
                varType=blockInfo.(portField)(portIndex).Type;

                params{ii}=self.getVarDecl(param.ArgName,varType,varDims);

                cscriptVarReplacer.addReplacementVariable(param.ArgName,varName);
            end

            cscriptVarReplacer.setScriptParams(params);
        end


        function generateWrappersDeclarations(self,wrapperFile,block,blockInfo,writeParamValues)
            fid=fopen(wrapperFile,'at','n',self.SourceEncoding);
            closeFile=onCleanup(@()fclose(fid));

            self.generateWrapperVariablesDeclarations(fid,block,blockInfo,writeParamValues);

            fprintf(fid,'\n');
            for ii=1:numel(blockInfo.StepFcns)
                fprintf(fid,'\nvoid %s(void);',blockInfo.StepFcns{ii});
            end
            fprintf(fid,'\n\n');
        end



        function[initFcns,termFcns]=generateCScriptWrappers(self,feOptions,customCodeSettings,wrapperFile,block,blockInfo,callInfo,writeParamValues)
            initFcns={};
            termFcns={};

            fid=fopen(wrapperFile,'at','n',self.SourceEncoding);
            closeFile=onCleanup(@()fclose(fid));

            blockName=get_param(block,'Name');

            self.generateWrapperVariables(fid,block,blockInfo,writeParamValues);


            functionComment=message('polyspace:gui:pslink:customCodeWrapperFunctionComment',blockName).getString();
            fprintf(fid,'/* %s */\n',functionComment);

            scriptVarReplacer=sldv.code.slcc.internal.CScriptVarReplacer(feOptions,customCodeSettings);

            self.initializeScriptReplacer(scriptVarReplacer,blockInfo,callInfo);


            stepFcn=blockInfo.StepFcns{1};
            mainScript=get_param(block,'CFunctionScript');
            stepBody=scriptVarReplacer.getBody(mainScript);

            polyspaceStartComment=get_param(block,'PolyspaceStartComment');
            polyspaceEndComment=get_param(block,'PolyspaceEndComment');
            if~isempty(polyspaceStartComment)
                polyspaceStartComment=sprintf('    /* %s */\n',polyspaceStartComment);
            end

            if~isempty(polyspaceEndComment)
                polyspaceEndComment=sprintf('    /* %s */\n',polyspaceEndComment);
            end

            fprintf(fid,'void %s(void) {\n%s',stepFcn,polyspaceStartComment);
            fprintf(fid,'    %s\n',stepBody);
            fprintf(fid,'%s}\n\n',polyspaceEndComment);


            blockLinkName=self.getLinkName(block);
            blockComment=message('polyspace:gui:pslink:customCodeWrapperBlockComment',blockLinkName).getString();
            startScript=get_param(block,'CFunctionStartScript');
            if~isempty(startScript)
                [~,startFunction]=pslink.verifier.slcc.Coder.getVarPrefix(block,'start');
                startBody=scriptVarReplacer.getBody(startScript);

                fprintf(fid,'/* %s */\n',blockComment);
                fprintf(fid,'/* Start function for C-Function block %s */\n',blockName);
                fprintf(fid,'void %s(void) {\n%s%s\n%s}\n\n',startFunction,polyspaceStartComment,startBody,polyspaceEndComment);

                initFcns{end+1}=startFunction;
            end

            initScript=get_param(block,'InitializeConditionsCode');
            if~isempty(initScript)
                [~,initFunction]=pslink.verifier.slcc.Coder.getVarPrefix(block,'script_init');
                initBody=scriptVarReplacer.getBody(initScript);

                fprintf(fid,'/* %s */\n',blockComment);
                fprintf(fid,'/* Init function for C-Function block %s */\n',blockName);
                fprintf(fid,'void %s(void) {\n%s%s\n%s}\n\n',initFunction,polyspaceStartComment,initBody,polyspaceEndComment);

                initFcns{end+1}=initFunction;
            end

            termScript=get_param(block,'CFunctionTermScript');
            if~isempty(termScript)
                [~,termFunction]=pslink.verifier.slcc.Coder.getVarPrefix(block,'script_terminate');
                termBody=scriptVarReplacer.getBody(termScript);

                fprintf(fid,'/* %s */\n',blockComment);
                fprintf(fid,'/* Terminate function for C-Function block %s */\n',blockName);
                fprintf(fid,'void %s(void) {\n%s%s\n%s}\n\n',termFunction,polyspaceStartComment,termBody,polyspaceEndComment);

                termFcns={termFunction};
            end

        end




        function generateCallWrappers(self,wrapperFile,block,blockInfo,parseData,callInfo,writeParamValues)
            fid=fopen(wrapperFile,'at','n',self.SourceEncoding);
            closeFile=onCleanup(@()fclose(fid));

            blockName=get_param(block,'Name');


            self.generateWrapperVariables(fid,block,blockInfo,writeParamValues);


            functionComment=message('polyspace:gui:pslink:customCodeWrapperFunctionComment',blockName).getString();
            fprintf(fid,'/* %s */\n',functionComment);
            for ci=1:numel(callInfo)
                fprintf(fid,'void %s(void) {\n',blockInfo.StepFcns{ci});
                tooltipComment=message('polyspace:gui:pslink:customCodeWrapperTooltipComment').getString();
                fprintf(fid,'    /* %s */\n',tooltipComment);

                fprintf(fid,'    ');

                currentInfo=callInfo(ci);

                calledFunction=currentInfo.FunctionName;
                paramInfo=currentInfo.Parameters;

                functionInfo=pslink.verifier.slcc.Coder.getFunction(parseData,calledFunction);
                if isempty(functionInfo)
                    error('pslink:ccallerFunctionNotFound',...
                    message('polyspace:gui:pslink:ccallerFunctionNotFound',calledFunction).getString());
                end

                paramStart=1;
                isVoidFunction=functionInfo.Type.RetType.isVoidType();

                if~isVoidFunction
                    numFcnParams=functionInfo.Params.Size;


                    if numFcnParams<numel(paramInfo)
                        portIndex=paramInfo(1).PortIndex;
                        switch paramInfo(1).Kind
                        case 'OutputPort'
                            paramStart=2;
                            fprintf(fid,'%s = ',blockInfo.Outputs(portIndex).VarName);
                        case 'OtherVar'
                            paramStart=2;
                            fprintf(fid,'%s = ',blockInfo.Others(portIndex).VarName);
                        end
                    end
                end

                fprintf(fid,'%s(',calledFunction);

                paramEnd=numel(paramInfo);
                if paramStart<=paramEnd
                    sigIndex=1;
                    for ii=paramStart:paramEnd
                        if sigIndex>1
                            fprintf(fid,', ');
                        end

                        isVariableArg=true;
                        portIndex=paramInfo(ii).PortIndex;
                        switch paramInfo(ii).Kind
                        case 'OutputPort'
                            portField='Outputs';
                        case 'InputPort'
                            portField='Inputs';
                        case 'BlockParameter'
                            portField='Parameters';
                        case 'CustomCodeExpr'


                            argContent=paramInfo(ii).ParameterString;
                            varDims=1;
                            isVariableArg=false;
                        case 'OtherVar'
                            portField='Others';
                        otherwise
                            assert(false,'Unsupported C-caller mapping: %s',...
                            paramInfo(ii).Kind);
                        end

                        if isVariableArg
                            argContent=blockInfo.(portField)(portIndex).VarName;
                            varDims=blockInfo.(portField)(portIndex).Dims;
                        end

                        prefix='';
                        if isVariableArg
                            paramType=functionInfo.Params(sigIndex).Type;
                            paramType=internal.cxxfe.ast.types.Type.skipQualifiers(paramType);
                            if prod(varDims)==1&&paramType.isPointerType()

                                prefix='&';
                            end
                        end

                        fprintf(fid,'%s%s',prefix,argContent);
                        sigIndex=sigIndex+1;
                    end
                end
                fprintf(fid,');\n');
                fprintf(fid,'}\n\n');
            end
        end


        function varType=getVarType(~,t)

            if ischar(t)
                varType=t;
            elseif isa(t,'embedded.numerictype')
                if t.isfloat
                    varType=sprintf('real%d_T',t.WordLength);
                elseif t.isboolean
                    varType='boolean_T';
                elseif t.isfixed
                    signednessPrefix='';
                    if~t.SignednessBool
                        signednessPrefix='u';
                    end
                    varType=sprintf('%sint%d_T',signednessPrefix,t.WordLength);
                end
            end
        end


        function varDecl=getVarDecl(self,varName,varType,varDims)
            numElements=prod(varDims);
            typeStr=self.getVarType(varType);

            if numElements>1
                varDecl=sprintf('%s %s[%d]',typeStr,varName,numElements);
            else
                varDecl=sprintf('%s %s',typeStr,varName);
            end
        end


        function writeVarDecl(self,fid,portInfo,qualifiers,initValue)
            if nargin<4
                qualifiers='';
            end

            if nargin<5
                initValue='';
            end

            declStr=self.getVarDecl(portInfo.VarName,portInfo.Type,portInfo.Dims);
            fprintf(fid,'%s %s',qualifiers,declStr);

            if~isempty(initValue)
                fprintf(fid,' = %s',initValue);
            end

            fprintf(fid,';\n');
        end


        function[blockInfo,callInfo]=getBlockInfo(self,blockH,callInfo)
            [varPrefix,stepPrefix]=pslink.verifier.slcc.Coder.getVarPrefix(blockH);

            numSteps=numel(callInfo);

            if numSteps==1
                stepFunctions={stepPrefix};
            else
                stepFunctions=cell(1,numSteps);
                for ii=1:numSteps
                    stepFunctions{ii}=sprintf('%s_%d',stepPrefix,ii);
                end
            end

            rtObj=get_param(blockH,'RuntimeObject');
            if isempty(rtObj)
                sid=Simulink.ID.getSID(blockH);
                blockPath=Simulink.ID.getFullName(sid);
                modelHandle=get_param(self.slModelName,'Handle');

                throw(MSLException(modelHandle,...
                message('polyspace:gui:pslink:noInformationForBlock',blockPath)));
            end

            numInputs=rtObj.NumInputPorts;
            if numInputs<=0
                inputInfo={};
            else
                inputInfo(numInputs)=struct('VarName','',...
                'Type','',...
                'Dims',[]);
                for ii=1:numInputs
                    inputInfo(ii).VarName=pslink.verifier.slcc.Coder.getVarName(varPrefix,sprintf('In%d',ii));
                    [inputInfo(ii).Type,inputInfo(ii).Dims]=self.getTypeInfo(rtObj,rtObj.InputPort(ii));
                end
            end

            numOutputs=rtObj.NumOutputPorts;
            if numOutputs<=0
                outputInfo={};
            else
                outputInfo(numOutputs)=struct('VarName','',...
                'Type','',...
                'Dims',[]);
                for ii=1:numOutputs
                    outputInfo(ii).VarName=pslink.verifier.slcc.Coder.getVarName(varPrefix,sprintf('Out%d',ii));
                    [outputInfo(ii).Type,outputInfo(ii).Dims]=self.getTypeInfo(rtObj,rtObj.OutputPort(ii));
                end
            end
            numParameters=rtObj.NumRuntimePrms;
            if numParameters<=0
                parameterInfo={};
            else
                parameterInfo(numParameters)=struct('VarName','',...
                'Type','',...
                'Dims',[],...
                'Value',[]);
                for ii=1:numParameters
                    parameterInfo(ii).VarName=pslink.verifier.slcc.Coder.getVarName(varPrefix,sprintf('Param%d',ii));
                    paramObj=rtObj.RuntimePrm(ii);
                    [parameterInfo(ii).Type,parameterInfo(ii).Dims]=self.getTypeInfo(rtObj,paramObj,false);
                    parameterInfo(ii).Value=paramObj.Data;
                end
            end


            othersCount=0;
            for ii=1:numel(callInfo)
                params=callInfo(ii).Parameters;
                otherParams=params(strcmp({params.Kind},'OtherVar'));
                othersCount=othersCount+numel(otherParams);
            end

            if othersCount>0

                otherIndex=1;
                othersInfo(othersCount)=struct('VarName','',...
                'Type','',...
                'Dims',[]);

                for ii=1:numel(callInfo)
                    params=callInfo(ii).Parameters;

                    for oo=1:numel(params)
                        if params(oo).Kind=="OtherVar"
                            callInfo(ii).Parameters(oo).PortIndex=otherIndex;

                            p=callInfo(ii).Parameters(oo);
                            othersInfo(otherIndex).VarName=pslink.verifier.slcc.Coder.getVarName(varPrefix,sprintf('Other%d',otherIndex));
                            othersInfo(otherIndex).Dims=p.Dims;
                            othersInfo(otherIndex).Type=p.Type;

                            otherIndex=otherIndex+1;
                        end
                    end
                end
            else
                othersInfo={};
            end



            persistentCount=0;
            for ii=1:numel(callInfo)
                params=callInfo(ii).Parameters;
                otherParams=params(strcmp({params.Kind},'Persistent'));
                persistentCount=persistentCount+numel(otherParams);
            end

            if persistentCount>0

                persistentIndex=1;
                persistentInfo(persistentCount)=struct('VarName','',...
                'Type','',...
                'Dims',[]);

                for ii=1:numel(callInfo)
                    params=callInfo(ii).Parameters;

                    for oo=1:numel(params)
                        if params(oo).Kind=="Persistent"
                            callInfo(ii).Parameters(oo).PortIndex=persistentIndex;

                            p=callInfo(ii).Parameters(oo);
                            persistentInfo(persistentIndex).VarName=pslink.verifier.slcc.Coder.getVarName(varPrefix,p.ArgName);
                            persistentInfo(persistentIndex).Dims=p.Dims;
                            persistentInfo(persistentIndex).Type=p.Type;

                            persistentIndex=persistentIndex+1;
                        end
                    end
                end
            else
                persistentInfo={};
            end

            blockInfo=struct('StepFcns','');
            blockInfo.StepFcns=stepFunctions;
            blockInfo.Inputs=inputInfo;
            blockInfo.Outputs=outputInfo;
            blockInfo.Parameters=parameterInfo;
            blockInfo.Others=othersInfo;
            blockInfo.PersistentVars=persistentInfo;
        end


        function[type,dims]=getTypeInfo(~,rtObj,portInfo,hasBus)
            if nargin<4
                hasBus=true;
            end

            dims=portInfo.Dimensions;

            id=portInfo.DatatypeID;
            name=rtObj.DatatypeName(id);
            if hasBus&&portInfo.IsBus

                type=name;
            elseif rtObj.DataTypeIsFixedPoint(id)
                type=rtObj.FixedPointNumericType(id);
            else
                if any(strcmp(name,{'double','single','boolean'}))
                    type=numerictype(name);
                else

                    type=name;
                end
            end
        end


        function getDesignMinMax(self,pslinkOptions,modelName,blockH,portInfo)
            inputFullRange=self.inputFullRange;
            if strcmpi(pslinkOptions.InputRangeMode,'DesignMinMax')
                inputFullRange=false;
            end
            drsHelper=pslink.util.DrsInfoHelper(modelName,inputFullRange,self.drsInfo);
            rethrowEx=[];
            try
                blockObj=get_param(blockH,'Object');
                sid=Simulink.ID.getSID(blockH);

                ports=blockObj.PortHandles;


                if strcmp(pslinkOptions.ParamRangeMode,'DesignMinMax')
                    portSpec=get_param(blockH,'PortSpecification');

                    structData=portSpec.getPortStruct();
                    for ii=1:numel(structData)
                        if strcmp(structData(ii).Scope,'Parameter')
                            paramIdx=structData(ii).Index+1;
                            paramName=structData(ii).PortName;
                            varName=portInfo.Parameters(paramIdx).VarName;
                            varType=portInfo.Parameters(paramIdx).Type;

                            [slObj,~]=slResolve(paramName,sid,'variable','startUnderMask');
                            drsHelper.extractDrs('param',varName,varType,slObj,sid);
                        end
                    end
                end


                numInputs=numel(ports.Inport);
                assert(numel(portInfo.Inputs)==numInputs);

                for inp=1:numInputs
                    drsHelper.addDrsInput(ports.Inport(inp),...
                    portInfo.Inputs(inp).VarName,...
                    portInfo.Inputs(inp).Type);
                end

                if strcmpi(pslinkOptions.OutputRangeMode,'DesignMinMax')
                    numOutputs=numel(portInfo.Outputs);
                    assert(numel(portInfo.Outputs)==numOutputs);

                    for outp=1:numOutputs
                        drsHelper.addDrsOutput(ports.Outport(outp),...
                        portInfo.Outputs(outp).VarName,...
                        portInfo.Outputs(outp).Type);
                    end
                end
            catch Me
                rethrowEx=Me;
            end

            self.drsInfo=drsHelper.getDrsInfo();

            if~isempty(rethrowEx)
                warning('pslink:unexpectedErrorForRangeGeneration',message('polyspace:gui:pslink:unexpectedErrorForRangeGeneration',rethrowEx.message).getString());
            end
        end
    end

    methods(Static=true)



        function[blockInfo,callInfo]=simplifyBlockInfo(callInfo,blockInfo)
            usedInputs=false(size(blockInfo.Inputs));
            usedOutputs=false(size(blockInfo.Outputs));
            usedParameters=false(size(blockInfo.Parameters));

            for ii=1:numel(callInfo)
                for pp=1:numel(callInfo(ii).Parameters)
                    param=callInfo(ii).Parameters(pp);
                    switch param.Kind
                    case 'InputPort'
                        usedInputs(param.PortIndex)=true;
                    case 'OutputPort'
                        usedOutputs(param.PortIndex)=true;
                    case 'BlockParameter'
                        usedParameters(param.PortIndex)=true;
                    end
                end
            end

            if any(~usedInputs)||any(~usedOutputs)

                blockInfo.Inputs=blockInfo.Inputs(usedInputs);
                blockInfo.Outputs=blockInfo.Outputs(usedOutputs);
                blockInfo.Parameters=blockInfo.Parameters(usedParameters);

                inputIndexes=pslink.verifier.slcc.Coder.getRemappedIndexes(usedInputs);
                outputIndexes=pslink.verifier.slcc.Coder.getRemappedIndexes(usedOutputs);
                parameterIndexes=pslink.verifier.slcc.Coder.getRemappedIndexes(usedParameters);

                for ii=1:numel(callInfo)
                    for pp=1:numel(callInfo(ii).Parameters)
                        param=callInfo(ii).Parameters(pp);
                        origIndex=param.PortIndex;
                        switch param.Kind
                        case 'InputPort'
                            callInfo(ii).Parameters(pp).PortIndex=inputIndexes(origIndex);
                        case 'OutputPort'
                            callInfo(ii).Parameters(pp).PortIndex=outputIndexes(origIndex);
                        case 'BlockParameter'
                            callInfo(ii).Parameters(pp).PortIndex=parameterIndexes(origIndex);
                        end
                    end
                end
            end
        end





        function newIndexes=getRemappedIndexes(usedIndexes)
            newIndexes=zeros(size(usedIndexes));
            currentIndex=1;
            for ii=1:numel(usedIndexes)
                if usedIndexes(ii)
                    newIndexes(ii)=currentIndex;
                    currentIndex=currentIndex+1;
                end
            end
        end


        function res=getFunction(parseData,functionName)
            comp=parseData.Project.Compilations(1);
            functions=comp.Funs.toArray();
            res=[];

            for ii=1:numel(functions)
                f=functions(ii);

                if strcmp(f.Name,functionName)
                    res=f;
                    return
                end
            end


            macros=comp.Macros.toArray();
            for ii=1:numel(macros)
                m=macros(ii);

                if strcmp(m.Name,functionName)
                    aliasedFunction=sldv.code.slcc.internal.getMacroAlias(m.Text);
                    if~isempty(aliasedFunction)
                        res=pslink.verifier.slcc.Coder.getFunction(parseData,aliasedFunction);
                    end
                    return
                end
            end
        end



        function cIdent=getCIdent(str)


            invalidChars='[^A-Za-z_0-9]';
            cIdent=regexprep(str,invalidChars,'_');
        end

        function varName=getVarName(varPrefix,name)


            varName=[name,'_',varPrefix];
        end

        function[varPrefix,stepPrefix]=getVarPrefix(blockH,fcnName)
            if nargin<2
                fcnName='step';
            end



            sid=Simulink.ID.getSID(blockH);
            sidStr=pslink.verifier.slcc.Coder.getCIdent(sid);

            blockName=get_param(blockH,'Name');
            cBlockName=pslink.verifier.slcc.Coder.getCIdent(blockName);

            varPrefix=sprintf('%s_%s',sidStr,cBlockName);
            stepPrefix=sprintf('%s_%s_%s',fcnName,sidStr,cBlockName);

        end





        function varType=structTypeToCType(structType)
            infoStruct=SLCC.blocks.PortSpecification.parseTypeString(structType);
            switch infoStruct.mode
            case 'built-in'
                varType=pslink.verifier.slcc.Coder.getBuiltinType(infoStruct.type);
            case 'fixed point'
                if infoStruct.isSigned
                    prefix='';
                else
                    prefix='u';
                end
                varType=sprintf('%sint%d_T',prefix,infoStruct.wordLength);
            case{'bus','enum'}
                varType=infoStruct.type;
            otherwise
                varType='';
            end
        end


        function varType=getBuiltinType(builtinType)
            switch builtinType
            case{'boolean','int8','int16','int32','int64',...
                'uint8','uint16','uint32','uint64'}
                varType=[builtinType,'_T'];
            case 'single'
                varType='real32_T';
            case 'double'
                varType='real_T';
            otherwise
                varType='';
            end
        end


        function commented=isCommented(block)
            commented=false;
            try
                while~commented&&get_param(block,'Type')~="block_diagram"
                    commented=get_param(block,'Commented')~="off";
                    block=get_param(block,'Parent');
                end
            catch
                commented=false;
            end
        end
    end
end



function valueStr=getInitValue(value)
    canWrite=~isempty(value)&&isnumeric(value)&&isreal(value)...
    &&(isfloat(value)||isinteger(value));

    if~canWrite
        valueStr='';
    else
        if isfloat(value)
            strformat='%f';
        else
            strformat='%d';
        end
        if numel(value)>1
            isFirst=true;
            valueStr='{ ';

            for ii=1:numel(value)
                v=value(ii);
                if isFirst
                    currentFormat=['%s',strformat];
                    isFirst=false;
                else
                    currentFormat=['%s, ',strformat];

                end
                valueStr=sprintf(currentFormat,valueStr,v);
            end
            valueStr=sprintf('%s }',valueStr);
        else
            valueStr=sprintf(strformat,value);
        end
    end
end





