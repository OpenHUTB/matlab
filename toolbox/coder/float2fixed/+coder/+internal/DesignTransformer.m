




classdef DesignTransformer<handle

    properties
        fcnRegistry;
        compiledExprInfo;
        simExprInfo;
        designFileNames;
        designActualFcnNames;
        designNames;
        fixPtDesignNames;
        testbenchName;
        designWrapperName;
        outputPath;

        fiTemplateMtree;
        typeProposalSettings;

        fxpConversionSettings;
        fiOperatorMapper;
        autoReplaceHndlr;
        userFcnTemplatePath;
userFcnMap
globalUniqNameMap



fimathFcnName
    end

    methods

        function this=DesignTransformer(designSettings,tpSettings,fxpConversionSettings)

            this.designFileNames=designSettings.designNames;
            this.designActualFcnNames=designSettings.designActualFcnNames;
            this.fixPtDesignNames=designSettings.fixPtDesignNames;
            this.outputPath=designSettings.outputPath;
            this.testbenchName=designSettings.testbenchName;
            this.fcnRegistry=designSettings.fcnInfoRegistry;
            this.compiledExprInfo=designSettings.compiledExprInfo;
            this.simExprInfo=designSettings.simExprInfo;
            this.userFcnTemplatePath=fxpConversionSettings.userFcnTemplatePath;
            this.userFcnMap=fxpConversionSettings.userFcnMap;
            this.designWrapperName=designSettings.designIOWrapperName;


            this.typeProposalSettings=tpSettings;

            this.fxpConversionSettings=fxpConversionSettings;

            [~,fn,~]=cellfun(@(d)fileparts(d),this.designFileNames,'UniformOutput',false);
            this.designNames=fn;

            cdrPath=fullfile(matlabroot,'toolbox','coder','float2fixed','emlfiauthoring');
            userRepPath=this.userFcnTemplatePath;
            userRepMap=this.userFcnMap;
            this.fiOperatorMapper=coder.internal.FiOperatorMapper(cdrPath,userRepPath,userRepMap,this.typeProposalSettings.DoubleToSingle);
            this.autoReplaceHndlr=coder.internal.F2FMathFcnGenHandler();
            this.globalUniqNameMap=designSettings.globalUniqNameMap;

            this.fimathFcnName=coder.internal.translator.Phase.FIMATHFCNNAME;
        end










        function[inVals,newTypesInfo,allErrorMsgs,translatedFiles]=doIt(this,inVals,prevTranslatedFiles)
            newTypesInfo=[];

            if this.DoubleToSingle
                dtsLibPath=[matlabroot,'/toolbox/coder/float2fixed/dtslib/'];

                addpath(dtsLibPath);
                cleanupDtsLibPath=onCleanup(@()rmpath(dtsLibPath));
            end


            fcnTypeInfos=this.fcnRegistry.getAllFunctionTypeInfos();
            for ii=1:length(fcnTypeInfos)
                fcnTypeInfos{ii}.emitted=false;
            end



            functionIds=this.fcnRegistry.registry.keys();
            [specializationMap,classFiles]=groupFcnsPerClasses(functionIds);
            onC=onCleanup(@()restoreSpecializationNames(this.fcnRegistry,specializationMap));




            functionIds=this.getFunctionsToEmit();




            dutTypeInfos=internal.mtree.FunctionTypeInfo.empty(0,length(this.designNames));
            entryPtFcnIds=getEntryPointFcnIds(this);
            for ii=1:length(entryPtFcnIds)
                fcnId=functionIds{ii};
                entryPointInfo=this.fcnRegistry.getFunctionTypeInfo(fcnId);
                entryPointInfo.specializationName=this.fixPtDesignNames{ii};
                dutTypeInfos(ii)=entryPointInfo;
            end
            function restoreDesignSpecializationName(dutTypeInfos,that)
                for mm=1:length(dutTypeInfos)
                    epInfo=dutTypeInfos(mm);
                    setSpecializationName(epInfo,that.designNames{mm});
                end
            end
            c=onCleanup(@()restoreDesignSpecializationName(dutTypeInfos,this));

            import coder.internal.lib.ListHelper;
            allErrorMsgs=coder.internal.lib.Message.empty();


            tmpMsgList=ListHelper.flatten(arrayfun(@(fcnInfo)checkForEntryPointReplacements(fcnInfo),dutTypeInfos,'UniformOutput',false));
            if~isempty(tmpMsgList)
                allErrorMsgs=[allErrorMsgs,tmpMsgList{:}];
            end


            [fcnsToEmitEPMap,sharedMemoryFcnInfos]=buildFunctionsToEmitMap();
            if~isempty(sharedMemoryFcnInfos)
                msgs=warnSharedMemory(sharedMemoryFcnInfos);
                allErrorMsgs=[allErrorMsgs,msgs];
            end

            if this.fxpConversionSettings.MLFBApply
                [msgs,translatedFiles]=checkForSharedFiles(prevTranslatedFiles,fcnsToEmitEPMap);
                allErrorMsgs=[allErrorMsgs,msgs];
            else
                translatedFiles=[];
            end



            this.fiOperatorMapper.beginSession();





            genCodeUniqueNamesService=coder.internal.lib.DistinctNameService();


            if coder.FixPtConfig.TransformF2FInIR()
                errMsgs=coder.internal.lib.Message.empty();
            else
                errMsgs=coder.internal.lib.Message.empty();


                for zz=1:length(this.designNames)
                    entryPoint=this.designNames{zz};
                    functionIds=fcnsToEmitEPMap(entryPoint);

                    entryPointFixptName=this.fixPtDesignNames{zz};

                    [errMsgsForEp]=this.generateFixPtCode(entryPointFixptName,functionIds,genCodeUniqueNamesService,this.globalUniqNameMap);
                    errMsgs=[errMsgs,errMsgsForEp];
                end
            end

            if coder.internal.Float2FixedConverter.supportMCOSClasses
                generateClasses(classFiles,genCodeUniqueNamesService);
            end
            allErrorMsgs=[allErrorMsgs,errMsgs];

            emitDutInterface=true;
            if this.fxpConversionSettings.MLFBApply
                emitDutInterface=false;
            end

            if emitDutInterface
                for kk=1:length(dutTypeInfos)
                    dutInfo=dutTypeInfos(kk);
                    wrapperName=this.designWrapperName{kk};
                    fixPtDesignName=this.fixPtDesignNames{kk};

                    [~,inVals{kk},newTypesInfo{kk}]=this.generateDutInterface(wrapperName,dutInfo,fixPtDesignName,inVals{kk},this.globalUniqNameMap);
                end
            end














            function[fcnsToEmitMap,sharedMemFcnInfos]=buildFunctionsToEmitMap()
                fcnsToEmitMap=coder.internal.lib.Map();

                fcnsSoFarList={};
                sharedMemFcnInfos=internal.mtree.FunctionTypeInfo.empty();
                for mm=1:length(this.designNames)
                    entryPoint=this.designNames{mm};
                    functionIds=this.getFunctionsToEmit(entryPoint);
                    commonFcns=intersect(fcnsSoFarList,functionIds);
                    fcnsSoFarList=[fcnsSoFarList,functionIds{:}];


                    for nn=1:length(commonFcns)
                        cmnFcnId=commonFcns{nn};
                        fcnInfo=this.fcnRegistry.getFunctionTypeInfo(cmnFcnId);
                        isSharedMemFcn=~isempty(fcnInfo)&&fcnInfo.hasPersistents();
                        if isSharedMemFcn
                            sharedMemFcnInfos(end+1)=fcnInfo;
                        end
                    end

                    fcnsToEmitMap(entryPoint)=functionIds;
                end





            end

            function msgs=warnSharedMemory(sharedFcnInfos)
                msgs=coder.internal.lib.Message.empty();
                for fcnInfo=sharedFcnInfos
                    if this.DoubleToSingle
                        msgs(end+1)=fcnInfo.getMessage(coder.internal.lib.Message.ERR...
                        ,'Coder:FXPCONV:MEPSharedMemory_DTS'...
                        ,{fcnInfo.functionName});
                    else
                        msgs(end+1)=fcnInfo.getMessage(coder.internal.lib.Message.ERR...
                        ,'Coder:FXPCONV:MEPSharedMemory'...
                        ,{fcnInfo.functionName});
                    end
                end
            end

            function[msgs,statefulFiles]=checkForSharedFiles(prevStatefulFiles,fcnsToEmitMap)




                fcnsToEmitNestedCells=fcnsToEmitMap.values;
                fcnsToEmitIDs=unique([fcnsToEmitNestedCells{:}]);
                newStatefulFiles=containers.Map;
                msgs=coder.internal.lib.Message.empty;

                for i=1:numel(fcnsToEmitIDs)
                    fcnInfo=this.fcnRegistry.getFunctionTypeInfo(fcnsToEmitIDs{i});


                    if~isempty(fcnInfo)&&fcnInfo.hasPersistents
                        scriptPath=fcnInfo.scriptPath;

                        if prevStatefulFiles.isKey(scriptPath)


                            if this.DoubleToSingle
                                errorID='Coder:FXPCONV:MEPSharedMemory_MLFB_DTS';
                            else
                                errorID='Coder:FXPCONV:MEPSharedMemory_MLFB';
                            end

                            msgs(end+1)=fcnInfo.getMessage(coder.internal.lib.Message.ERR,...
                            errorID,{fcnInfo.functionName});
                        else



                            newStatefulFiles(scriptPath)='';
                        end
                    end
                end


                statefulFilenames=[prevStatefulFiles.keys,newStatefulFiles.keys];
                if~isempty(statefulFilenames)

                    vals=repmat({''},size(statefulFilenames));
                    statefulFiles=containers.Map(statefulFilenames,vals);
                else


                    statefulFiles=containers.Map;
                end
            end

            function generateClasses(classFiles,genCodeUniqueNamesService)
                classSpecializationNames=classFiles.keys();
                for mm=1:length(classSpecializationNames)
                    classSpecializationName=classSpecializationNames{mm};
                    classFilePath=classFiles(classSpecializationName);

                    fileEmitter=coder.internal.FixPtFileEmitter(...
                    classFilePath,...
                    this.fcnRegistry,...
                    this.compiledExprInfo,...
                    this.simExprInfo,...
                    this.typeProposalSettings,...
                    this.fxpConversionSettings,...
                    this.fiOperatorMapper,...
                    [],...
                    this.autoReplaceHndlr,...
                    classSpecializationName,...
                    genCodeUniqueNamesService,...
                    this.globalUniqNameMap,...
                    this.fimathFcnName);

                    [code,errMsgsForClass]=fileEmitter.emit();
                    errMsgs=[errMsgs,errMsgsForClass];
                    fid=coder.internal.safefopen([this.outputPath,'/',classSpecializationName,'.m'],'w');
                    fprintf(fid,'%s',code);
                    fclose(fid);
                    coder.internal.Helper.which(classSpecializationName);
                end
            end


            function[specializationMap,classFiles]=groupFcnsPerClasses(functionIds)
                specializationMap=containers.Map();
                classFiles=containers.Map();
                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    i=1;
                    while i<=length(functionIds)
                        functionId=functionIds{i};
                        fcnTypeInfo=this.fcnRegistry.getFunctionTypeInfo(functionId);
                        if fcnTypeInfo.isDefinedInAClass()
                            fcnTypeInfo.emitted=true;
                            newClassSpecializationName=[fcnTypeInfo.classSpecializationName,this.fxpConversionSettings.FixPtFileNameSuffix];
                            specializationMap(newClassSpecializationName)=fcnTypeInfo.classSpecializationName;
                            fcnTypeInfo.classSpecializationName=newClassSpecializationName;
                            if strcmp(fcnTypeInfo.functionName,fcnTypeInfo.className)

                                fcnTypeInfo.specializationName=fcnTypeInfo.classSpecializationName;
                            end
                            classFiles(fcnTypeInfo.classSpecializationName)=fcnTypeInfo.scriptPath;
                            functionIds(i)=[];
                        else
                            i=i+1;
                        end
                    end
                end
            end



            function msg=checkForEntryPointReplacements(dutTypeInfo)
                msg=coder.internal.lib.Message.empty();

                fNode=dutTypeInfo.tree;




                if~isempty(this.fiOperatorMapper.getMapping(dutTypeInfo.functionName,true))...
                    ||this.fxpConversionSettings.autoReplaceCfgs.isKey(dutTypeInfo.functionName)


                    this.fiOperatorMapper.removeUserFcnMapping(dutTypeInfo.functionName);
                    msg=coder.internal.lib.Message.buildMessage(dutTypeInfo...
                    ,fNode...
                    ,coder.internal.lib.Message.WARN...
                    ,'Coder:FXPCONV:NoDesignReplacement'...
                    ,dutTypeInfo.functionName);
                end
            end

            function setSpecializationName(fcnTypeInfo,specializationName)
                fcnTypeInfo.specializationName=specializationName;
            end

            function restoreSpecializationNames(fcnInfoRegistry,specializationMap)
                funcs=fcnInfoRegistry.getAllFunctionTypeInfos();
                for jj=1:length(funcs)
                    func=funcs{jj};
                    if func.isDefinedInAClass()
                        origSpecializationName=specializationMap(func.classSpecializationName);
                        func.classSpecializationName=origSpecializationName;
                        if strcmp(func.functionName,func.className)

                            func.specializationName=origSpecializationName;
                        end
                    end
                end
            end
        end

    end

    methods(Access='private')
        function entryPtFcnIds=getEntryPointFcnIds(this)
            dutTypeInfos=cellfun(@(ep)this.fcnRegistry.getFunctionTypeInfosByName(ep),this.designNames,'UniformOutput',false);
            dutTypeInfos=cellfun(@(infos)infos{1},dutTypeInfos,'UniformOutput',false);
            entryPtFcnIds=cellfun(@(typeInfo)typeInfo.uniqueId,dutTypeInfos,'UniformOutput',false);
        end




        function[functionsToEmit]=getFunctionsToEmit(this,entryPoint)
            if nargin<=1
                entryPoint=this.designNames;
            end
            if~iscell(entryPoint)
                entryPoint={entryPoint};
            end
            dutTypeInfos=cellfun(@(ep)this.fcnRegistry.getFunctionTypeInfosByName(ep),entryPoint,'UniformOutput',false);


            dutTypeInfos=cellfun(@(infos)infos{1},dutTypeInfos,'UniformOutput',false);

            ii=1;
            while ii<=numel(dutTypeInfos)
                if~dutTypeInfos{ii}.isDesign



                    dutTypeInfos(ii)=[];
                else
                    ii=ii+1;
                end
            end


            functionsToEmit={};

            this.fiOperatorMapper.beginSession();

            workList=dutTypeInfos;
            visited=containers.Map();
            while~isempty(workList)
                fcn=workList{1};
                fcn.emitted=true;
                workList(1)=[];
                if~visited.isKey(fcn.uniqueId)
                    if~fcn.isDefinedInAClass()

                        functionsToEmit{end+1}=fcn.uniqueId;
                    end
                    tree=fcn.tree.wholetree;
                    attribs=fcn.treeAttributes;
                    N=tree.count;
                    for ii=1:N
                        node=tree.select(ii);
                        callee=attribs(node).CalledFunction;
                        if~isempty(callee)

                            replacement=this.fiOperatorMapper.getMapping(callee.specializationName,false);
                            if isempty(replacement)
                                workList{end+1}=callee;
                            end
                        end
                    end
                    visited(fcn.uniqueId)=true;
                end
            end
        end

        function[compiledExprInfo,simExprInfo]=getExprInfo(this,functionId)
            simExprInfo=coder.internal.lib.Map.empty();
            if~isempty(this.simExprInfo)&&isKey(this.simExprInfo,functionId)
                simExprInfo=this.simExprInfo(functionId);
            end

            compiledExprInfo=coder.internal.lib.Map.empty();
            if~isempty(this.compiledExprInfo)&&isKey(this.compiledExprInfo,functionId)
                compiledExprInfo=this.compiledExprInfo(functionId);
            end
        end


        function[allErrorMsgs]=generateFixPtCode(this,entryPointFixptName,functionsInFile,uniqueNamesService,globalUniqNameMap)
            allErrorMsgs={};

            structCopyHandler=coder.internal.StructCopyHandler();
            mExt=coder.internal.Float2FixedConverter.getMext();

            outputFileName=fullfile(this.outputPath,[entryPointFixptName,mExt]);

            fid=coder.internal.safefopen(outputFileName,'w');

            fcnNeedsFiMathFcn=zeros(1,length(functionsInFile));
            for i=1:length(functionsInFile)
                functionId=functionsInFile{i};

                fcnTypeInfo=this.fcnRegistry.getFunctionTypeInfo(functionId);
                fcnTypeInfo.setConvertedFilePath(outputFileName);

                [compiledFcnExprInfo,simFcnExprInfo]=this.getExprInfo(functionId);

                if isempty(fcnTypeInfo.scriptPath)
                    disp(message('Coder:FxpConvDisp:FXPCONVDISP:unresolvedFcn',fcnTypeInfo.specializationName).getString);
                    continue;
                end

                fcnNode=fcnTypeInfo.tree;

                translator=coder.internal.translator.MultiPass(...
                fcnNode,fcnTypeInfo,compiledFcnExprInfo,...
                simFcnExprInfo,this.fcnRegistry,...
                this.typeProposalSettings,...
                this.fxpConversionSettings,this.fiOperatorMapper,...
                this.autoReplaceHndlr,structCopyHandler,...
                this.outputPath,uniqueNamesService,...
                globalUniqNameMap,this.fimathFcnName);

                try
                    [functionCode,errMsgs,uniqueNamesService,fcnNeedsFiMathFcn(i)]=translator.translate(0);
                catch me
                    fclose(fid);
                    link=['<a href="matlab:edit(''',fcnTypeInfo.scriptPath,''')">',fcnTypeInfo.functionName,'</a>'];
                    if this.typeProposalSettings.DoubleToSingle
                        disp(message('Coder:FxpConvDisp:FXPCONVDISP:errConv_DTS',link).getString);
                    else
                        disp(message('Coder:FxpConvDisp:FXPCONVDISP:errConv',link).getString);
                    end
                    rethrow(me);
                end

                if(1==i)
                    if(~contains(functionCode,'%#codegen'))
                        fprintf(fid,'%%#codegen\n');
                    end
                end
                allErrorMsgs=[allErrorMsgs,errMsgs];
                fprintf(fid,'%s\n\n',functionCode);
            end


            code=getCodeForFunctionReplacements();

            mathFcnGenCode=this.autoReplaceHndlr.getCode();
            if~isempty(mathFcnGenCode)
                code=[code,newline,mathFcnGenCode];
            end

            structCopyFcnCode=structCopyHandler.getCode();
            if~isempty(structCopyFcnCode)
                code=[code,newline,mtree(structCopyFcnCode).tree2str];
            end

            if this.fxpConversionSettings.EmitSeperateFimathFunction&&~this.DoubleToSingle&&any(fcnNeedsFiMathFcn)
                fimathFcnCode=coder.internal.DesignTransformer.getFiMathFunctionCode(this.fimathFcnName,this.fxpConversionSettings.globalFimathStr);
                code=[code,newline,fimathFcnCode,newline];
            end

            if~isempty(code)
                fprintf(fid,'%s',code);
            end


            if this.fxpConversionSettings.GenerateParametrizedCode
                fprintf(fid,'\n\n');
                fprintf(fid,'function T = GetTypesTable(functionName)\n');
                fprintf(fid,'\tFixT = FixedPointTypes();\n');
                fprintf(fid,'\tT = FixT.(functionName);\n');
                fprintf(fid,'end\n\n');
            end

            fclose(fid);

            code=fileread(outputFileName);
            fid=coder.internal.safefopen(outputFileName,'w');
            fprintf(fid,'%s',code);
            fclose(fid);

            function code=getCodeForFunctionReplacements()
                code=this.fiOperatorMapper.getLibraryCode();
            end
        end

        function r=DoubleToSingle(this)
            r=this.fxpConversionSettings.DoubleToSingle;
        end






        function[code,fixptInVals,newTypesInfo]=generateDutInterface(this,ioWrapperName,functionTypeInfo,fixPtDesignName,inVals,glbUniqNameMap)

            fixptInVals=cell(1,length(inVals));

            newTypesInfo.varNumericTypeInfoMap=[];
            newTypesInfo.varList={};

            rootFcnMT=functionTypeInfo.tree;

            inputArgNames={};
            insR=rootFcnMT.Ins;
            unused=1;
            while~insR.isempty
                if strcmp(insR.kind,'NOT')
                    inputArgNames{end+1}=sprintf('unused_%d',unused);
                    unused=unused+1;
                else
                    inputArgNames{end+1}=insR.string;%#ok<*AGROW>
                end
                insR=insR.Next;
            end

            outputArgNames={};
            outsR=rootFcnMT.Outs;
            while~outsR.isempty
                if strcmp(outsR.kind,'NOT')
                    outputArgNames{end+1}=sprintf('unused_%d',unused);
                    unused=unused+1;
                else
                    outputArgNames{end+1}=outsR.string;
                end
                outsR=outsR.Next;
            end

            defaultFimath=eval(this.fxpConversionSettings.globalFimathStr);

            if this.fxpConversionSettings.DoubleToSingle
                fiMathExp='';
            else
                if this.fxpConversionSettings.EmitSeperateFimathFunction
                    fiMathExp=sprintf('%s = %s();\n',this.fxpConversionSettings.fiMathVarName,this.fimathFcnName);
                else

                    fiMathExp=sprintf('%s = %s;\n',this.fxpConversionSettings.fiMathVarName,this.fxpConversionSettings.globalFimathStr);
                end
            end
            nameService=coder.internal.lib.DistinctNameService();

            for ii=1:length(inputArgNames)
                inpArg=inputArgNames{ii};
                nameService.distinguishName(inpArg);
            end

            for ii=1:length(outputArgNames)
                outArg=outputArgNames{ii};
                nameService.distinguishName(outArg);
            end

            localInArgNames={};
            for ii=1:length(inputArgNames)
                inpArg=inputArgNames{ii};
                localInArgNames{end+1}=nameService.distinguishName([inpArg,'_in']);
            end

            localOutArgNames={};
            for ii=1:length(outputArgNames)
                outArg=outputArgNames{ii};
                localOutArgNames{end+1}=nameService.distinguishName([outArg,'_out']);
            end

            structCopyHandler=coder.internal.StructCopyHandler();

            argLocalAssignments='';
            inNumericTypes=[];
            for ii=1:length(inputArgNames)

                formalArgName=inputArgNames{ii};
                argLocal=localInArgNames{ii};
                varInfo=functionTypeInfo.getVarInfo(formalArgName);




                if~isempty(varInfo)&&isempty(varInfo.annotated_Type)&&~varInfo.isEnum()

                    varInfo=[];
                end
                inNumericTypes.(formalArgName)=[];

                if~isempty(varInfo)&&varInfo.isStruct()
                    [structLocalAssignments,fixptInVals{ii}]=emitFixptCopyStructVar(argLocal,varInfo,inVals{ii},defaultFimath,false,nameService,structCopyHandler);
                    argLocalAssignments=[argLocalAssignments,structLocalAssignments];
                    continue;
                end

                if isempty(varInfo)||~varInfo.needsFiCast()
                    if isempty(varInfo)&&~contains(formalArgName,'unused_')
                        warning(message('Coder:FXPCONV:BADType',formalArgName));
                    end

                    argLocalAssignment=sprintf('%s = %s;',argLocal,formalArgName);
                    fixptInVals{ii}=inVals{ii};
                    argLocalAssignments=[argLocalAssignments,argLocalAssignment];
                    continue;
                end



                [argLocalAssignment,fixptInVals{ii}]=emitFixptCopyVar(argLocal,formalArgName,varInfo,inVals{ii},defaultFimath);


                argLocalAssignments=[argLocalAssignments,argLocalAssignment];
                if isnumerictype(varInfo.annotated_Type)
                    inNumericTypes.(formalArgName)=numerictype(varInfo.annotated_Type.Signed...
                    ,varInfo.annotated_Type.WordLength...
                    ,varInfo.annotated_Type.FractionLength);
                else
                    inNumericTypes.(formalArgName)=varInfo.annotated_Type;
                end
            end


            returnReassignments='';
            for ii=1:length(outputArgNames)

                formalRetParamName=outputArgNames{ii};



                varInfo=functionTypeInfo.getVarInfo(formalRetParamName);





                if~isempty(varInfo)&&isempty(varInfo.annotated_Type)&&~varInfo.isEnum()

                    varInfo=[];
                end

                retLocal=localOutArgNames{ii};
                formalRetName=outputArgNames{ii};

                retLocalAssignment=emitReturnAssignStmts(formalRetName,retLocal,varInfo,structCopyHandler);

                returnReassignments=[returnReassignments,retLocalAssignment];
            end

            [globalCopyAssigs,returnGlobalCopyAssgns]=getGlobalCopyAssignments(glbUniqNameMap,nameService,structCopyHandler,defaultFimath);

            if coder.FixPtConfig.TransformF2FInIR
                fxpDesignName=functionTypeInfo.functionName;
            else
                fxpDesignName=fixPtDesignName;
            end

            callStmt=coder.internal.Helper.getFcnInterfaceSignature(fxpDesignName...
            ,localInArgNames...
            ,localOutArgNames);
            callStmt=sprintf('%s;\n',callStmt);


            code=[fiMathExp,argLocalAssignments,globalCopyAssigs,callStmt,returnGlobalCopyAssgns,returnReassignments];

            fcnSig=['function ',coder.internal.Helper.getFcnInterfaceSignature(ioWrapperName,inputArgNames,outputArgNames)];

            code=['%#codegen',newline,fcnSig,newline,code,'end'];


            structCopyFcnCode=structCopyHandler.getCode();
            if~isempty(structCopyFcnCode)
                code=[code,newline,structCopyFcnCode];
            end

            wrapperCodeTree=mtree(code);
            code=wrapperCodeTree.tree2str;

            if this.fxpConversionSettings.EmitSeperateFimathFunction&&~this.DoubleToSingle
                fimathFcnCode=coder.internal.DesignTransformer.getFiMathFunctionCode(this.fimathFcnName,this.fxpConversionSettings.globalFimathStr);
                code=[code,newline,fimathFcnCode,newline];
            end

            emitWrappers=true;
            if this.fxpConversionSettings.DoubleToSingle&&coder.FixPtConfig.TransformF2FInIR
                emitWrappers=false;
            end
            if emitWrappers
                wrapperFullFilName=fullfile(this.outputPath,[ioWrapperName,'.m']);
                coder.internal.Helper.writeFile(wrapperFullFilName,code);
            end

            newTypesInfo.varList=inputArgNames;
            newTypesInfo.varNumericTypeInfoMap=inNumericTypes;




            function[globalCopyAssigs,returnGlobalCopyAssgns]=getGlobalCopyAssignments(glbUniqNameMap,nameService,structCopyHandler,defaultFimath)
                globalCopyAssigs='';
                returnGlobalCopyAssgns='';


                if~this.fcnRegistry.hasGlobals
                    return;
                end

                isGlobal=true;
                globalVars=this.fcnRegistry.getGlobalVars();
                globalCopyAssigsStmts={};
                globalReturnAssigsStmts={};
                globalCopyNames={};
                for hh=1:length(globalVars)
                    origName=globalVars{hh};
                    if~glbUniqNameMap.isKey(origName)




                        continue;
                    end
                    copyName=glbUniqNameMap(origName);

                    fcnUniqIDs=this.fcnRegistry.getFcnsContainingGlobals(origName);
                    fcnInfo=this.fcnRegistry.getFunctionTypeInfo(fcnUniqIDs{1});
                    glbVarInfo=fcnInfo.getVarInfo(origName);

                    globalCopyNames{end+1}=copyName;

                    if glbVarInfo.isStruct()
                        globalCopyAssigsStmts{end+1}=emitFixptCopyStructVar(copyName,glbVarInfo,[],defaultFimath,isGlobal,nameService,structCopyHandler);
                        globalReturnAssigsStmts{end+1}=emitReturnAssignStmts(origName,copyName,glbVarInfo,structCopyHandler);
                    else
                        if~isempty(glbVarInfo.annotated_Type)
                            globalReturnAssigsStmts{end+1}=emitReturnAssignStmts(origName,copyName,glbVarInfo,structCopyHandler);
                            globalCopyAssigsStmts{end+1}=emitFixptCopyVar(copyName,origName,glbVarInfo,[],defaultFimath);
                        end
                    end
                end
                globalDeclStmt=sprintf('global %s',strjoin([globalVars,globalCopyNames],' '));
                globalCopyAssigs=[globalDeclStmt,newline,strjoin(globalCopyAssigsStmts,newline)];
                returnGlobalCopyAssgns=strjoin(globalReturnAssigsStmts,newline);
            end






            function[argLocalAssignment,fixptInVal]=emitFixptCopyVar(argLocal,formalArgName,varInfo,inVal,defaultFimath)
                argLocalAssignment='';%#ok<NASGU>
                fixptInVal=[];

                if this.fxpConversionSettings.DoubleToSingle
                    if~isempty(varInfo)&&varInfo.isVarInSrcDouble()&&~varInfo.isCoderConst
                        argLocalAssignment=sprintf('%s = single(%s);',argLocal,formalArgName);
                        fixptInVal=coder.internal.makeDoubleTypesSingle(inVal);
                    else
                        argLocalAssignment=sprintf('%s = %s;',argLocal,formalArgName);
                        fixptInVal=inVal;
                    end
                    return;
                end

                if~isempty(varInfo)&&varInfo.needsFiCast()&&~varInfo.isCoderConst



                    if~varInfo.isFimathSet()||isequal(varInfo.getFimath(),defaultFimath)
                        numType=numerictype(varInfo.annotated_Type.Signed...
                        ,varInfo.annotated_Type.WordLength...
                        ,varInfo.annotated_Type.FractionLength);
                        fiwrappedExpr=@(var,fiMathVarName)sprintf('fi(%s, %d, %d, %d, %s)',...
                        var,...
                        numType.Signed,...
                        numType.WordLength,...
                        numType.FractionLength,...
                        fiMathVarName);
                        if(~varInfo.isCoderConst&&~isempty(inVal))



                            if isa(inVal,'coder.Type')
                                fixptInVal=emlcprivate('convertTypesToFixPt',{inVal},{numType},eval(this.fxpConversionSettings.globalFimathStr));
                                fixptInVal=fixptInVal{1};
                            else

                                fixptInVal=eval(fiwrappedExpr('inVals{ii}',this.fxpConversionSettings.globalFimathStr));
                            end
                        end
                        argLocalAssignment=sprintf(['%s = ',fiwrappedExpr(formalArgName,this.fxpConversionSettings.fiMathVarName),';\n'],argLocal);

                    else
                        numType=numerictype(varInfo.annotated_Type.Signed,...
                        varInfo.annotated_Type.WordLength,...
                        varInfo.annotated_Type.FractionLength);
                        fiwrappedExpr=@(var,fiMathVarName)sprintf('fi(%s, %d, %d, %d, %s, %s)'...
                        ,var...
                        ,numType.Signed...
                        ,numType.WordLength...
                        ,numType.FractionLength...
                        ,fiMathVarName...
                        ,coder.internal.Helper.diffFimathString(varInfo.getFimath(),defaultFimath));
                        argLocalAssignment=sprintf(['%s = ',fiwrappedExpr(formalArgName,this.fxpConversionSettings.fiMathVarName),';\n'],argLocal);

                        if(~varInfo.isCoderConst&&~isempty(inVal))
                            if isa(inVal,'coder.Type')
                                fixptInVal=emlcprivate('convertTypesToFixPt',{inVal},{numType},varInfo.getFimath());
                                fixptInVal=fixptInVal{1};
                            else
                                fixptInVal=eval(fiwrappedExpr('inVal',this.fxpConversionSettings.globalFimathStr));
                            end
                        end
                    end
                else
                    argLocalAssignment=sprintf('%s = %s;',argLocal,formalArgName);
                    fixptInVal=inVal;
                end
            end

            function[localAssignments,fixptInVal]=...
                emitFixptCopyStructVar(argLocal,varInfo,inVal,...
                defaultFimath,~,nameService,structCopyHandler)
                localAssignments='';
                fixptInVal=[];

                if~varInfo.isCoderConst
                    lhsVarInfo=varInfo.clone();
                    lhsVarInfo.setSymbolName(argLocal);
                    rhsVarInfo=varInfo;





                    dummyPhase.structCopyHandler=structCopyHandler;
                    dummyPhase.emittedFiCast=true;
                    if this.fxpConversionSettings.EmitSeperateFimathFunction
                        dummyPhase.emitFiMathStr=@()sprintf('%s = %s();',this.fxpConversionSettings.fiMathVarName,this.fimathFcnName);
                    else

                        dummyPhase.emitFiMathStr=@()sprintf('%s = %s;',this.fxpConversionSettings.fiMathVarName,tostring(defaultFimath));
                    end
                    if~this.fxpConversionSettings.DoubleToSingle
                        dummyPhase.wrapCodeWithType=...
                        @(rhsFullPropName,annotated_Type,fmDecl,propVarInfo)...
                        sprintf('fi(%s, %d, %d, %d, %s)',...
                        rhsFullPropName,...
                        annotated_Type.Signed,...
                        annotated_Type.WordLength,...
                        annotated_Type.FractionLength,...
                        fmDecl);
                    else
                        dummyPhase.wrapCodeWithType=...
                        @(rhsFullPropName,annotated_Type,fmDecl,propVarInfo)sprintf('single(%s)',rhsFullPropName);
                    end

                    disableStructAssgnOptim=true;

                    [~,fcnStr,fcnName,structNumTypes,structFimaths]=...
                    coder.internal.translator.Helper.CreateCopyStructFunction(...
                    this.fxpConversionSettings,...
                    lhsVarInfo,...
                    rhsVarInfo,...
                    dummyPhase,...
                    nameService,...
                    disableStructAssgnOptim);

                    if~isempty(fcnStr)&&~isempty(fcnName)
                        structCopyHandler.addCopyStruct(fcnName,fcnStr);
                        structFieldAssignment=sprintf('%s = %s(%s);',argLocal,fcnName,varInfo.SymbolName);
                    else
                        structFieldAssignment=sprintf('%s = %s;',argLocal,varInfo.SymbolName);
                    end
                    localAssignments=[localAssignments,structFieldAssignment];

                    if~isempty(inVal)
                        if this.DoubleToSingle
                            fixptInVal=coder.internal.makeDoubleTypesSingle(inVal);
                        else


                            if isa(inVal,'coder.Type')
                                tmp=coder.internal.DesignTransformer.convertTypesToFixPt({inVal},{structNumTypes.(lhsVarInfo.SymbolName)},{structFimaths.(lhsVarInfo.SymbolName)});
                                fixptInVal=tmp{1};
                            else
                                fixptInVal=coder.internal.DesignTransformer.castStructTo(inVal,structNumTypes.(lhsVarInfo.SymbolName),structFimaths.(lhsVarInfo.SymbolName));
                            end
                        end
                    end
                else
                    structFieldAssignment=sprintf('%s = %s;',argLocal,varInfo.SymbolName);
                    localAssignments=[localAssignments,structFieldAssignment];

                    if this.DoubleToSingle
                        fixptInVal=coder.internal.makeDoubleTypesSingle(inVal);
                    else
                        fixptInVal=inVal;
                    end
                end
            end



            function returnReassignments=emitReturnAssignStmts(formalRetName,retLocal,varInfo,structCopyHandler)
                returnReassignments='';

                if~isempty(varInfo)
                    if varInfo.isStruct()
                        disableStructAssgnOptim=true;
                        castToOriginalTypes=true;
                        psuedoRhsVarInfo=varInfo.clone();
                        psuedoRhsVarInfo.setSymbolName(retLocal);
                        psuedoLhsVarInfo=varInfo.clone;
                        psuedoLhsVarInfo.setSymbolName(formalRetName);
                        dummyPhase.structCopyHandler=structCopyHandler;
                        dummyPhase.emittedFiCast=true;
                        if this.fxpConversionSettings.EmitSeperateFimathFunction
                            dummyPhase.emitFiMathStr=@()sprintf('%s = %s();',this.fxpConversionSettings.fiMathVarName,this.fimathFcnName);
                        else

                            dummyPhase.emitFiMathStr=@()sprintf('%s = %s;',this.fxpConversionSettings.fiMathVarName,this.fxpConversionSettings.globalFimathStr);
                        end

                        [~,fcnStr,fcnName,~,~]=...
                        coder.internal.translator.Helper.CreateCopyStructFunction(...
                        this.fxpConversionSettings,...
                        psuedoLhsVarInfo,...
                        psuedoRhsVarInfo,...
                        dummyPhase,...
                        nameService,...
                        disableStructAssgnOptim,...
                        castToOriginalTypes);

                        if~isempty(fcnName)&&~isempty(fcnStr)
                            structCopyHandler.addCopyStruct(fcnName,fcnStr);
                            retLocalAssignment=sprintf('%s = %s(%s);\n',formalRetName,fcnName,retLocal);
                        else
                            retLocalAssignment=sprintf('%s = %s;\n',formalRetName,retLocal);
                        end
                        returnReassignments=[returnReassignments,retLocalAssignment];
                    else
                        origTypeName=varInfo.getOriginalTypeClassName();

                        if varInfo.needsFiCast
                            retLocalAssignment=sprintf('%s = %s( %s );\n',formalRetName,origTypeName,retLocal);
                        else
                            retLocalAssignment=sprintf('%s = %s;\n',formalRetName,retLocal);
                        end
                        returnReassignments=[returnReassignments,retLocalAssignment];
                    end
                else
                    retLocalAssignment=sprintf('%s = %s;\n',formalRetName,retLocal);
                    if isempty(varInfo)
                        warning(message('Coder:FXPCONV:BADType',formalRetName));
                    end
                    returnReassignments=[returnReassignments,retLocalAssignment];
                end
            end
        end
    end

    methods(Static)












        function newItys=convertTypesToFixPt(origItys,numerictypeList,fimathStrs)
            assert(length(numerictypeList)==length(fimathStrs));
            assert(length(origItys)==length(numerictypeList));

            for ii=1:length(origItys)
                oITy=origItys{ii};
                iTyName=oITy.Name;
                iTyClass=oITy.ClassName;

                fimathStr=fimathStrs{ii};
                numType=numerictypeList{ii};

                if strcmpi(iTyClass,'logical')||strcmpi(iTyClass,'embedded.fi')
                    nITy=oITy;
                else
                    if isa(oITy,'coder.Constant')
                        nITy=oITy;
                    elseif isa(oITy,'coder.EnumType')
                        nITy=oITy;
                    elseif isa(oITy,'coder.StructType')

                        assert(isa(numType,'struct'));
                        assert(isa(fimathStr,'struct'));
                        assert(length(fieldnames(oITy.Fields))==length(fieldnames(numType)));
                        assert(length(fieldnames(oITy.Fields))==length(fieldnames(fimathStr)));

                        nITy=oITy;


                        if~isa(oITy.InitialValue,'coder.Constant')

                            nInitVal=[];
                            fldNames=fieldnames(numType);
                            if numel(fldNames)==0
                                iTyFieldsStruct=struct();
                            else

                                for jj=1:numel(oITy.InitialValue)
                                    for fieldCount=1:numel(fldNames)
                                        field=fldNames{fieldCount};

                                        tmpType=oITy.Fields.(field);
                                        hasInitVal=~isempty(oITy.InitialValue(jj))&&~isempty(oITy.InitialValue(jj).(field));
                                        if hasInitVal
                                            tmpType.InitialValue=oITy.InitialValue(jj).(field);
                                        end

                                        tempStruct=coder.internal.DesignTransformer.convertTypesToFixPt({tmpType},{numType.(field)},{fimathStr.(field)});


                                        if length(tempStruct)>=1&&hasInitVal
                                            nInitVal(jj).(field)=tempStruct{1}.InitialValue;
                                        end
                                    end
                                end


                                for fieldCount=1:numel(fldNames)
                                    field=fldNames{fieldCount};
                                    tmpType=oITy.Fields.(field);

                                    tempStruct=coder.internal.DesignTransformer.convertTypesToFixPt({tmpType},{numType.(field)},{fimathStr.(field)});

                                    iTyFieldsStruct.(field)=tempStruct{:};
                                end
                            end
                            nITy.Fields=iTyFieldsStruct;
                            if~isempty(nInitVal)
                                nITy.InitialValue=nInitVal;
                            end
                        end
                    else
                        if ischar(fimathStr)
                            fimathObj=eval(fimathStr);
                        else
                            fimathObj=fimathStr;
                        end

                        if~isempty(fimathObj)&&~isempty(numType)
                            assert(isfimath(fimathObj));
                            nITy=coder.newtype('embedded.fi',numType,oITy.SizeVector,oITy.VariableDims,'complex',oITy.Complex,'fimath',fimathObj);
                            nITy.Name=iTyName;
                            if~isempty(oITy.InitialValue)
                                nITy.InitialValue=fi(oITy.InitialValue,numType,fimathObj);
                            end
                        else


                            nITy=oITy;
                        end
                    end
                end

                newItys{ii}=nITy;
            end
        end












        function newItys=convertTypesToFixPtOldStableWithChanges(origItys,numerictypeList,fimathStrs)
            assert(length(numerictypeList)==length(fimathStrs));
            assert(length(origItys)==length(numerictypeList));

            for ii=1:length(origItys)
                oITy=origItys{ii};
                iTyName=oITy.Name;
                iTyClass=oITy.ClassName;

                fimathStr=fimathStrs{ii};
                numType=numerictypeList{ii};

                if strcmpi(iTyClass,'logical')||strcmpi(iTyClass,'embedded.fi')
                    nITy=oITy;
                else
                    if isa(oITy,'coder.Constant')
                        nITy=oITy;
                    elseif isa(oITy,'coder.EnumType')
                        nITy=oITy;
                    elseif isa(oITy,'coder.StructType')

                        assert(isa(numType,'struct'));
                        assert(isa(fimathStr,'struct'));
                        assert(length(fieldnames(oITy.Fields))==length(fieldnames(numType)));
                        assert(length(fieldnames(oITy.Fields))==length(fieldnames(fimathStr)));

                        nITy=oITy;
                        nInitVal=[];
                        fldNames=fieldnames(numType);
                        if numel(fldNames)==0
                            iTyFieldsStruct=struct();
                        else
                            for count=1:numel(fldNames)
                                field=fldNames{count};

                                tempStruct=coder.internal.DesignTransformer.convertTypesToFixPt({oITy.Fields.(field)},{numType.(field)},{fimathStr.(field)});

                                if~isa(oITy.InitialValue,'coder.Constant')
                                    hasInitVal=~isempty(oITy.InitialValue)&&~isempty(oITy.InitialValue.(field));
                                    hasFieldType=~isempty(numType.(field));
                                    if length(tempStruct)>=1&&hasInitVal&&hasFieldType
                                        if ischar(fimathStr.(field))
                                            fimathObj=eval(fimathStr.(field));
                                        else
                                            fimathObj=fimathStr.(field);
                                        end
                                        tempStruct{1}.InitialValue=fi(oITy.InitialValue.(field),numType.(field),fimathObj);
                                        nInitVal.(field)=tempStruct{1}.InitialValue;
                                    end
                                end
                                iTyFieldsStruct.(field)=tempStruct{:};
                            end
                        end
                        nITy.Fields=iTyFieldsStruct;
                        if~isempty(nInitVal)
                            nITy.InitialValue=nInitVal;
                        end
                    else
                        if ischar(fimathStr)
                            fimathObj=eval(fimathStr);
                        else
                            fimathObj=fimathStr;
                        end

                        if~isempty(fimathObj)&&~isempty(numType)
                            assert(isfimath(fimathObj));
                            nITy=coder.newtype('embedded.fi',numType,oITy.SizeVector,oITy.VariableDims,'complex',oITy.Complex,'fimath',fimathObj);
                            nITy.Name=iTyName;
                            if~isempty(oITy.InitialValue)
                                nITy.InitialValue=fi(oITy.InitialValue,numType,fimathObj);
                            end
                        else


                            nITy=oITy;
                        end
                    end
                end

                newItys{ii}=nITy;
            end
        end


        function outStruct=castStructTo(inStruct,structNumTypes,structFimaths)
            outStruct=inStruct;

            for jj=1:numel(inStruct)
                fields=fieldnames(inStruct);
                for ii=1:length(fields)
                    field=fields{ii};
                    if isa(inStruct(jj).(field),'struct')
                        outStruct(jj).(field)=coder.internal.DesignTransformer.castStructTo(inStruct(jj).(field),structNumTypes.(field),structFimaths.(field));
                    elseif isenum(inStruct(jj).(field))||ischar(inStruct(jj).(field))||islogical(inStruct(jj).(field))||isempty(structNumTypes.(field))||isempty(structFimaths.(field))
                        outStruct(jj).(field)=inStruct(jj).(field);
                    else
                        outStruct(jj).(field)=fi(inStruct(jj).(field),structNumTypes.(field),structFimaths.(field));
                    end
                end
            end
        end



        function code=getFiMathFunctionCode(fimathFcnName,fimathStr)
            fimathObj=eval(fimathStr);
            c=fimathObj.tostring();

            tmpStr='fm = ';
            tc=strjoin(strsplit(c,newline),[newline,'\t',repmat(' ',1,length(tmpStr))]);
            code=[sprintf('function fm = %s()',fimathFcnName),newline...
            ,sprintf('\tfm = %s;',tc),newline...
            ,'end'];
        end
    end
end



