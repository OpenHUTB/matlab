

















classdef FcnInfoRegistryBuilder
    methods(Static=true)

        function[inferenceMsgs,exprMap]=populateFcnInfoRegistryFromInferenceInfo(...
            inferenceReport,...
            designNames,...
            userWrittenFunctions,...
            chartData,...
            fcnInfoRegistry,...
            globalTypes,...
            debugEnabled,...
            varargin)

            if nargin<7
                debugEnabled=false;
            end

            inferenceMsgs=coder.internal.lib.Message.empty();
            exprMap=coder.internal.lib.Map();

            specializationIds=coder.internal.FcnInfoRegistryBuilder.constructSpecializationIds(inferenceReport);

            logs=[];
            if~isempty(varargin)&&~isempty(varargin{1})
                logs=varargin{1};
                loggedFcnIds=[logs.Functions(:).FunctionID];



                REASON_CPPSYSOBJ=10;
            end

            inferenceReportFunctions=inferenceReport.Functions;
            inferenceReportScripts=inferenceReport.Scripts;
            inferenceReportMxInfos=inferenceReport.MxInfos;
            inferenceReportMxArrays=inferenceReport.MxArrays;

            inferInfoMap=containers.Map();
            for ii=1:length(inferenceReportFunctions)
                fcnInferenceInfo=inferenceReportFunctions(ii);
                scriptID=fcnInferenceInfo.ScriptID;

                if(scriptID<1)||...
                    (scriptID>length(inferenceReportScripts))
                    continue;
                end

                scriptInferenceInfo=inferenceReportScripts(scriptID);
                fcnName=fcnInferenceInfo.FunctionName;

                if~scriptInferenceInfo.IsUserVisible&&...
                    ~internal.mtree.isTranslatableInternalFunction(scriptInferenceInfo.ScriptPath)


                    continue;
                end


                if~isKey(userWrittenFunctions,fcnName)


                    continue;
                end

                if~isempty(fcnInferenceInfo.FunctionName)&&'@'==fcnInferenceInfo.FunctionName(1)

                    continue;
                end

                className=fcnInferenceInfo.ClassName;

                functionId=ii;

                [uniqueId,specializationName,isDesign]=...
                coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(...
                fcnName,functionId,designNames,specializationIds);

                if isDesign
                    dInfo=fcnInfoRegistry.getFunctionTypeInfo(uniqueId);
                    if~isempty(dInfo)

                        msg=dInfo.getMessage(coder.internal.lib.Message.ERR...
                        ,'Coder:FXPCONV:EntryPointSpecialized'...
                        ,{fcnName});
                        inferenceMsgs=[inferenceMsgs,msg];
                    end
                end

                loggedMxInfoIds=[];
                loggedFields={};

                if~isempty(logs)
                    loggedLocations=[logs.Functions(loggedFcnIds==ii).loggedLocations];
                    loggedTextStarts=[];
                    loggedTextLength=[];
                    loggedReasons=[];
                    for j=1:length(loggedLocations)
                        if loggedLocations(j).Locations(1).Reason==REASON_CPPSYSOBJ
                            loggedMxInfoIds=[loggedMxInfoIds,loggedLocations(j).Locations(1).MxInfoID];
                            loggedTextStarts=[loggedTextStarts,loggedLocations(j).Locations(1).TextStart];
                            loggedTextLength=[loggedTextLength,loggedLocations(j).Locations(1).TextLength];

                            loggedReasons=[loggedReasons,loggedLocations(j).Locations(1).Reason];
                            tmpFields=loggedLocations(j).Fields;
                            for jj=length(tmpFields):-1:1
                                if strcmp(tmpFields{jj}(1),'_')
                                    tmpFields(jj)=[];
                                end
                            end
                            loggedFields={loggedFields{:},tmpFields};%#ok<CCAT>
                        end
                    end
                end

                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    if~isempty(className)
                        if matlab.system.internal.isMATLABAuthoredSystemObjectName(className)

                            switch fcnName
                            case{'setupImpl','stepImpl'}
                                specializationName=fcnName;
                            otherwise

                            end
                        else

                        end
                    end
                end

                fcnInfoRegistry.mxInfos=inferenceReportMxInfos;
                fcnInfoRegistry.mxArrays=inferenceReportMxArrays;


                scriptText=scriptInferenceInfo.ScriptText;
                [unicodemap,~]=coder.internal.FcnInfoRegistryBuilder.getUnicodedScriptText(scriptText);
                scriptPath=scriptInferenceInfo.ScriptPath;

                fcnInfo=internal.mtree.FunctionTypeInfo(...
                fcnName,...
                specializationName,...
                uniqueId,...
                fcnInferenceInfo.MxInfoLocations,...
                scriptText,...
                scriptPath,...
                unicodemap,...
                chartData);

                fcnInfo.setDebug(debugEnabled);
                fcnInfo.isDesign=isDesign;
                fcnInfo.specializationId=specializationIds(functionId);
                fcnInfo.className=className;
                fcnInfo.classdefUID=fcnInferenceInfo.ClassdefUID;
                fcnInfo.isPCoded=scriptInferenceInfo.IsPFile;

                if fcnInfo.classdefUID==-1
                    fcnInfo.classdefUID=0;
                    fcnInfo.isStaticMethod=true;
                    if~isempty(className)

                        try
                            node=fcnInfo.tree;
                            iters=1;
                            while~isempty(node)&&iters<1000
                                if strcmp(node.kind,'METHODS')
                                    attributes=node.Attr;
                                    fcnInfo.isStaticMethod=false;
                                    if~isempty(attributes)
                                        attr=attributes.Arg;
                                        while~isempty(attr)
                                            if strcmp(string(attr.Left),'Static')
                                                fcnInfo.isStaticMethod=true;
                                                break;
                                            end
                                            attr=attr.Next;
                                        end
                                    end
                                    break;
                                end
                                node=node.Parent;
                                iters=iters+1;
                            end
                        catch ex %#ok<NASGU>
                        end
                    end
                end

                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    if isempty(fcnInfo.tree)&&~fcnInfo.isPCoded


                        tmp=strsplit(className,'.');
                        nonPkgClassName=tmp{end};
                        if strcmp(nonPkgClassName,fcnName)||contains(fcnName,'set.')


                            continue;
                        else
                            assert(false);
                        end
                    end
                end

                fcnInfo.inferenceId=functionId;
                mxInfoLocations=fcnInferenceInfo.MxInfoLocations;
                for kk=1:length(mxInfoLocations)
                    mxLocInfo=mxInfoLocations(kk);

                    nodeTypeName=mxLocInfo.NodeTypeName;
                    if coder.internal.Float2FixedConverter.supportMCOSClasses
                        switch nodeTypeName
                        case{'inputVar','outputVar','persistentVar','globalVar','var','(type cast)','.'}
                        otherwise
                            continue;
                        end
                    else
                        switch nodeTypeName
                        case{'inputVar','outputVar','persistentVar','globalVar','var','(type cast)'}
                        otherwise
                            continue;
                        end
                    end

                    mxInferredTypeInfo=inferenceReportMxInfos{mxLocInfo.MxInfoID};
                    switch class(mxInferredTypeInfo)
                    case 'eml.MxFimathInfo'
                        continue;
                    case 'eml.MxNumericTypeInfo'
                        continue;
                    end

                    textStart=mxLocInfo.TextStart;
                    textLength=mxLocInfo.TextLength;
                    if textStart==-1&&textLength==-1
                        switch nodeTypeName
                        case 'var'



                            continue;
                        end
                    end

                    start=textStart+1;
                    [start,textLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(unicodemap,start,textLength);
                    stop=start+textLength-1;
                    SymbolName=scriptText(start:stop);

                    [skipSymbol,SymbolName]=coder.internal.FcnInfoRegistryBuilder.processSymbol(nodeTypeName,SymbolName,fcnInfo);
                    if skipSymbol
                        continue;
                    end

                    mxInferredTypeInfo=inferenceReportMxInfos{mxLocInfo.MxInfoID};
                    inferredInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxInferredTypeInfo,inferenceReportMxArrays);
                    inferredInfo.CppSystemObj=any(loggedMxInfoIds==mxLocInfo.MxInfoID);

                    varLogInfo=internal.mtree.FcnInfoRegistryBuilder.buildVarLogInfo(...
                    SymbolName,...
                    nodeTypeName,...
                    mxLocInfo.MxInfoID,...
                    inferredInfo,...
                    inferenceReportMxInfos,...
                    inferenceReportMxArrays,...
                    loggedMxInfoIds,...
                    loggedFields);

                    isCoderConst=false;
                    varTypeInfo=coder.internal.VarTypeInfo(varLogInfo,inferredInfo,isCoderConst);
                    varTypeInfo.TextStart=start;
                    varTypeInfo.TextLength=textLength;
                    varTypeInfo.MxInfoLocationId=kk;
                    fcnInfo.addVarInfo(SymbolName,varTypeInfo);
                end

                coder.internal.FcnInfoRegistryBuilder.assignVariableSpecializationNames(fcnInfo);
                fcnInfoRegistry.addFunctionTypeInfo(fcnInfo);
                inferInfoMap(uniqueId)=fcnInferenceInfo;

                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    classMemberBuilder=coder.internal.ClassMemberVarTypeInfoBuilder();
                    classMemberBuilder.run([],mxInfoLocations,inferenceReportMxInfos,fcnInfo,[],inferenceReportMxArrays);
                end
            end

            coder.internal.FcnInfoRegistryBuilder.populateCallSiteInfo(designNames,inferenceReport,fcnInfoRegistry,inferInfoMap);
            populateSysObjCallSiteInfo(inferenceReport,fcnInfoRegistry,inferInfoMap);
            if coder.internal.Float2FixedConverter.supportMCOSClasses
                coder.internal.FcnInfoRegistryBuilder.assignClassSpecializationNames(fcnInfoRegistry);
            end

            fcnInfoRegistry.buildGlobalVarMap();


            constGlbIdx=cellfun(@(typ)isa(typ.InitialValue,'coder.Constant'),globalTypes,'UniformOutput',true);
            if any(constGlbIdx)
                for glbIdx=1:length(constGlbIdx)


                    isConst=constGlbIdx(glbIdx);
                    if isConst
                        glbTyp=globalTypes{glbIdx};
                        glbName=glbTyp.Name;
                        glbFcnIds=fcnInfoRegistry.getFcnsContainingGlobals(glbName);
                        for fcnId=glbFcnIds


                            fcnInfo=fcnInfoRegistry.getFunctionTypeInfo(fcnId{1});
                            varInfos=fcnInfo.getVarInfosByName(glbName);
                            cellfun(@(v)v.setIsCoderConst(true),varInfos);
                        end
                    end
                end
            end

            try
                propertyDependencies=containers.Map();
                coder.internal.FcnInfoRegistryBuilder.updateRangesForClassMembers(fcnInfoRegistry,propertyDependencies);
            catch
            end

            totalScripts=length(inferenceReportScripts);
            for ii=1:length(inferenceReportFunctions)
                fcnInferenceInfo=inferenceReportFunctions(ii);
                scriptID=fcnInferenceInfo.ScriptID;

                if(scriptID<1)||(scriptID>totalScripts)

                    continue;
                end

                scriptInferenceInfo=inferenceReportScripts(scriptID);

                if~scriptInferenceInfo.IsUserVisible

                    continue;
                end

                fcnID=ii;
                fcnName=fcnInferenceInfo.FunctionName;
                [uniqueId,~]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,fcnID,designNames,specializationIds);
                fcnInfo=fcnInfoRegistry.getFunctionTypeInfo(uniqueId);
                hasFcnInfoInRegistry=~isempty(fcnInfo);

                if~hasFcnInfoInRegistry


                    continue;
                end

                scriptText=scriptInferenceInfo.ScriptText;
                [unicodemap,~]=coder.internal.FcnInfoRegistryBuilder.getUnicodedScriptText(scriptText);


                fcnExprMap=coder.internal.lib.Map();
                mxInfoLocations=fcnInferenceInfo.MxInfoLocations;
                for kk=1:length(mxInfoLocations)
                    mxLocInfo=mxInfoLocations(kk);


                    start=mxLocInfo.TextStart;
                    textLength=mxLocInfo.TextLength;
                    [start,textLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(unicodemap,start,textLength);

                    if mxLocInfo.TextStart<1&&mxLocInfo.TextLength==-1


                        switch mxLocInfo.NodeTypeName
                        case 'var'



                            continue;
                        end
                    end


                    if start<5
                        continue;
                    end

                    stop=start+textLength;
                    start=start+1;

                    fcnExprMap.add([num2str(start),':',num2str(stop)],mxLocInfo);
                end

                [uniqueId,~]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,fcnID,designNames,specializationIds);
                exprMap.add(uniqueId,fcnExprMap);
            end
        end
    end

    methods(Static=true,Access=public)
        function varLogInfo=buildVarLogInfo(...
            SymbolName,...
            nodeTypeName,...
            mxInfoID,...
            inferredInfo,...
            inferenceReportMxInfos,...
            inferenceReportMxArrays,...
            loggedMxInfoIds,...
            loggedFields)
            varLogInfo.SymbolName=SymbolName;
            varLogInfo.SimMin=[];
            varLogInfo.SimMax=[];
            varLogInfo.IsAlwaysInteger=coder.internal.VarTypeInfo.DEFAULT_IS_INTEGER;
            varLogInfo.IsArgin=strcmp(nodeTypeName,'inputVar');
            varLogInfo.IsOutputArg=strcmp(nodeTypeName,'outputVar');
            varLogInfo.MxInfoID=mxInfoID;
            if(strcmp(inferredInfo.Class,'struct'))
                varLogInfo.IsAlwaysInteger=[];
                varLogInfo.LoggedFieldNames={};
                varLogInfo.LoggedFieldMxInfoIDs={};
                varLogInfo.LoggedFieldsInferredTypes={};
                varLogInfo.nestedStructuresInferredTypes=coder.internal.lib.Map();
                varLogInfo.nestedStructuresMxInfoIDs=coder.internal.lib.Map();

                varLogInfo=coder.internal.FcnInfoRegistryBuilder.addStructField(varLogInfo,...
                varLogInfo.SymbolName,mxInfoID,...
                inferenceReportMxInfos,...
                inferenceReportMxArrays);
            elseif inferredInfo.CppSystemObj

                matchMxInfoIdsIdx=(loggedMxInfoIds==mxInfoID);
                matchMxInfoIdsIdx=find(matchMxInfoIdsIdx,1);

                varLogInfo.IsAlwaysInteger=[];
                varLogInfo.LoggedFieldNames={};
                varLogInfo.LoggedFieldMxInfoIDs={};
                varLogInfo.LoggedFieldsInferredTypes={};
                varLogInfo.nestedStructuresInferredTypes=coder.internal.lib.Map();
                varLogInfo.nestedStructuresMxInfoIDs=coder.internal.lib.Map();
                varLogInfo.cppSystemObjectLoggedPropertiesInfo={};
                varLogInfo=coder.internal.FcnInfoRegistryBuilder.addSystemObjectField(varLogInfo,...
                varLogInfo.SymbolName,mxInfoID,...
                inferenceReportMxInfos,...
                inferenceReportMxArrays,...
                loggedFields{matchMxInfoIdsIdx});
            end
        end
    end
end

function populateSysObjCallSiteInfo(inferenceReport,fcnInfoRegistry,inferInfoMap)




    inferenceReportFunctions=inferenceReport.Functions;
    fcns=fcnInfoRegistry.getAllFunctionTypeInfos();
    for ii=1:length(fcns)
        fcnInfo=fcns{ii};
        uniqueId=fcnInfo.uniqueId;

        nodesInTree=fcnInfo.tree.subtree;
        nodeStarts=nodesInTree.lefttreepos;
        nodeIndices=nodesInTree.indices();

        pos2NodeMap=containers.Map('KeyType','double','ValueType','any');
        for kk=1:length(nodeStarts)
            nodeStart=nodeStarts(kk);
            if~pos2NodeMap.isKey(nodeStart)
                values={};
            else
                values=pos2NodeMap(nodeStart);
            end
            values{end+1}=nodeIndices(kk);%#ok<*AGROW>
            pos2NodeMap(nodeStart)=values;
        end

        calls=inferInfoMap(uniqueId).CallSites;
        for jj=1:length(calls)
            call=calls(jj);
            callee=inferenceReportFunctions(call.CalledFunctionID).FunctionName;

            if any(call.CalledFunctionID==inferenceReport.RootFunctionIDs)
                calleeUniqueId=callee;
            else
                calleeUniqueId=['f',int2str(call.CalledFunctionID),'_',callee];
            end
            calledStepFcn=fcnInfoRegistry.getFunctionTypeInfo(calleeUniqueId);

            className=inferenceReportFunctions(call.CalledFunctionID).ClassName;
            isSystemObjectMethod=false;
            if strcmp(callee,'step')&&strcmp(className,'matlab.system.coder.SystemCore')
                isSystemObjectMethod=true;
                [stepImplFcn,setupImplFcn,resetImplFcn]=findStepImpl(inferenceReportFunctions,...
                inferenceReportFunctions(call.CalledFunctionID));
                if~isempty(stepImplFcn)
                    if lowersysobj.isPIRSupportedObject(stepImplFcn.ClassName)


                        continue;
                    end
                    calleeUniqueId=['f',int2str(stepImplFcn.FunctionID),'_',stepImplFcn.FunctionName];
                    calledStepFcn=fcnInfoRegistry.getFunctionTypeInfo(calleeUniqueId);
                end
                if~isempty(setupImplFcn)
                    calleeUniqueId=['f',int2str(setupImplFcn.FunctionID),'_',setupImplFcn.FunctionName];
                    calledSetupFcn=fcnInfoRegistry.getFunctionTypeInfo(calleeUniqueId);
                end
                if~isempty(resetImplFcn)
                    calleeUniqueId=['f',int2str(resetImplFcn.FunctionID),'_',resetImplFcn.FunctionName];
                    calledResetFcn=fcnInfoRegistry.getFunctionTypeInfo(calleeUniqueId);
                end
            end

            if~isempty(calledStepFcn)
                callStart=call.TextStart+1;
                callTextLength=call.TextLength;
                [callStart,callTextLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(fcnInfo.unicodeMap,callStart,callTextLength);
                callEnd=callStart+callTextLength-1;

                assert(pos2NodeMap.isKey(callStart));
                values=pos2NodeMap(callStart);
                callNode=[];
                for kk=1:length(values)
                    nodeIdx=values{kk};
                    node=nodesInTree.select(nodeIdx);
                    if node.righttreepos==callEnd
                        if~isempty(callNode)
                            if strcmp(callNode.kind,'CALL')||strcmp(callNode.kind,'DCALL')











                                assert(~strcmp(node.kind,'CALL')&&~strcmp(node.kind,'DCALL'));


                                continue;
                            else

                            end
                        end

                        if strcmp(node.kind,'EQUALS')
                            if strcmp(node.Left.kind,'DOT')||strcmp(node.Left.kind,'DOTLP')

                                assert(~isempty(strfind(calledStepFcn.functionName,'set.')));
                                callNode=node;
                            else

                                callNode=node.Right;
                                assert(strcmp(callNode.kind,'CALL')||strcmp(callNode.kind,'SUBSCR')||strcmp(callNode.kind,'DOT'));
                            end
                        else
                            callNode=node;
                        end
                    end
                end

                if~isempty(callNode)
                    fcnInfo.addCallSite(callNode,calledStepFcn);
                    if isSystemObjectMethod


                        if~isempty(setupImplFcn)
                            fcnInfo.addCallSite(callNode.Left,calledSetupFcn);
                        end
                        if~isempty(resetImplFcn)
                            fcnInfo.addCallSite(callNode.Right,calledResetFcn);
                        end
                    end
                else
                    error(message('Coder:FXPCONV:missingcallinfo',...
                    callee));
                end
            end
        end
    end
end

function[stepImplFcn,setupImplFcn,resetImplFcn]=findStepImpl(inferenceReportFunctions,calledFcn)

    callSites=calledFcn.CallSites;

    searchDepth=2;
    stepImplFcn=findMethod(inferenceReportFunctions,callSites,'stepImpl',searchDepth);
    searchDepth=3;
    setupImplFcn=findMethod(inferenceReportFunctions,callSites,'setupImpl',searchDepth);
    searchDepth=3;
    resetImplFcn=findMethod(inferenceReportFunctions,callSites,'resetImpl',searchDepth);
end

function[method,searchDepth]=findMethod(inferenceReportFunctions,callSites,methodName,searchDepth)
    searchDepth=searchDepth-1;
    method=[];
    if searchDepth<0
        return;
    end
    nextCallSites=[];
    for ii=1:numel(callSites)
        calledFcnInfo=inferenceReportFunctions(callSites(ii).CalledFunctionID);

        if strcmp(calledFcnInfo.FunctionName,methodName)&&...
            ~strcmp(calledFcnInfo.ClassName,'matlab.system.coder.SystemCore')
            method=calledFcnInfo;
            return;
        end

        if~isempty(calledFcnInfo.ClassName)
            nextCallSites=[nextCallSites,calledFcnInfo.CallSites];
        end
    end
    [method,searchDepth]=findMethod(inferenceReportFunctions,nextCallSites,methodName,searchDepth);
end




