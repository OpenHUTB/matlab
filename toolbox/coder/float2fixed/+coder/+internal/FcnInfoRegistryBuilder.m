




classdef FcnInfoRegistryBuilder
    methods(Static=true)

        function ti=getDefaultInferredTypeInfo()
            ti.Class='';
            ti.Size=int32([]);
            ti.SizeDynamic=false;
            ti.Complex=false;
            ti.SystemObj=false;
            ti.Sparse=false;
            ti.CppSystemObj=false;
            ti.MCOSClass=false;
            ti.Enum=false;
            ti.FiMath=[];
            ti.NumericType=[];
            ti.FiMathLocal=[];
        end
        function ti=getInferredTypeInfo(mxTypeInfo,MxArrays)

            ti=coder.internal.FcnInfoRegistryBuilder.getDefaultInferredTypeInfo();
            ti.Class=mxTypeInfo.Class;
            ti.Size=mxTypeInfo.Size;
            ti.SizeDynamic=mxTypeInfo.SizeDynamic;

            if strcmp(ti.Class,'embedded.fi')
                fiMathID=coder.internal.FcnInfoRegistryBuilder.getMappedMxArrayID(mxTypeInfo.FiMathID);
                ti.FiMath=MxArrays{fiMathID};
                ti.FiMathLocal=mxTypeInfo.FiMathLocal;
                numericTypeID=coder.internal.FcnInfoRegistryBuilder.getMappedMxArrayID(mxTypeInfo.NumericTypeID);
                ti.NumericType=MxArrays{numericTypeID};
            end

            if strcmp(ti.Class,'embedded.numerictype')
                numericTypeID=coder.internal.FcnInfoRegistryBuilder.getMappedMxArrayID(mxTypeInfo.NumericTypeID);
                ti.NumericType=MxArrays{numericTypeID};
            end



            ti.SystemObj=matlab.system.isSystemObjectName(ti.Class);
            switch class(mxTypeInfo)
            case 'eml.MxFiInfo'
                ti.Complex=mxTypeInfo.Complex;
            case 'eml.MxEnumInfo'
                ti.Enum=true;
            case 'eml.MxFimathInfo'
            case 'eml.MxNumericInfo'
                ti.Complex=mxTypeInfo.Complex;
            case 'eml.MxNumericTypeInfo'
            case{'eml.MxInfo','eml.MxStructInfo'}
            case{'eml.MxClassInfo'}
                ti.MCOSClass=true;
                ti.ClassProperties=mxTypeInfo.ClassProperties;
            case{'eml.MxSparseClassInfo'}
                ti.Sparse=true;
                ti.MCOSClass=true;
                ti.ClassProperties=mxTypeInfo.ClassProperties;
            otherwise
            end
        end

        function[textStart,textLength]=getUnicodedStartLenght(unicodemap,textStart,textLength)
            [textStart,textLength]=emlcprivate('uniposition',unicodemap,textStart,textLength);
        end

        function[unicodemap,scriptText]=getUnicodedScriptText(scriptText)


            [unicodemap,scriptText]=emlcprivate('makeunicodemap'...
            ,scriptText);
        end

        function[uniqueId,specializationName,isDesign]=getFunctionIdentifiers(functionName,fcnIdx,designNames,specializationIds)
            uniqueId=['f',int2str(fcnIdx),'_',functionName];
            isDesign=false;
            if any(strcmp(functionName,designNames))


                uniqueId=functionName;
                isDesign=true;
            end

            if specializationIds(fcnIdx)~=-1
                if contains(functionName,'set.')

                    if specializationIds(fcnIdx)==1
                        specializationName=functionName;
                    else
                        specializationName=sprintf('%s_s%d',strrep(functionName,'.','_'),specializationIds(fcnIdx));
                    end
                else
                    specializationName=sprintf('%s_s%d',functionName,specializationIds(fcnIdx));
                end
            else

                specializationName=functionName;
            end
        end

        function varName=normalizeVarName(varName)
            if contains(varName,'.')
                varName=strrep(varName,' ','');
                varName=strrep(varName,'(''','');
                varName=strrep(varName,''')','');
            end
        end








        function[fcnInfoRegistry,exprMap,globalTypes,inferenceReportMisMatch]=updateFunctionInfoRegistry(...
            fcnInfoRegistry,coderReport,designNames,~,inputArgNames,...
            coderConstIndicies,globalTypes,debugEnabled)
            inferenceReport=coderReport.inference;
            specializationIds=coder.internal.FcnInfoRegistryBuilder.constructSpecializationIds(inferenceReport);

            assert(~isempty(fcnInfoRegistry),'Empty Function Info registry. buildDesign is supposed to do this.');

            inferenceReportMisMatch=false;
            assert(length(designNames)==length(inputArgNames));
            assert(length(designNames)==length(coderConstIndicies));



            coderConstInMap=coder.internal.lib.Map();
            for ii=1:length(designNames)
                dn=designNames{ii};
                inargs=inputArgNames{ii};
                coderConstInMap.add(dn,inargs(coderConstIndicies{ii}));
            end

            coderReportInstrumentedDataInstrumentedFunctions=coderReport.InstrumentedData.InstrumentedFunctions;

            masterInferenceManager=coder.internal.MasterInferenceManager.getInstance;
            if~masterInferenceManager.isMapEmpty()






                masterInference=masterInferenceManager.MasterInferenceReport;
                inferenceReportFunctions=masterInference.Functions;
                inferenceReportScripts=masterInference.Scripts;
                inferenceReportMxInfos=masterInference.MxInfos;
                inferenceReportMxArrays=masterInference.MxArrays;
            else
                inferenceReportFunctions=inferenceReport.Functions;
                inferenceReportScripts=inferenceReport.Scripts;
                inferenceReportMxInfos=inferenceReport.MxInfos;
                inferenceReportMxArrays=inferenceReport.MxArrays;
            end

            exprMap=coder.internal.lib.Map();
            instrumentedFunctions=coderReportInstrumentedDataInstrumentedFunctions;
            for ii=1:length(instrumentedFunctions)
                instrumentedFcn=instrumentedFunctions(ii);
                fcnID=instrumentedFcn.FunctionID;
                fcnID=coder.internal.FcnInfoRegistryBuilder.getMappedFunctionID(fcnID);
                fcnInferenceInfo=inferenceReportFunctions(fcnID);

                fcnName=fcnInferenceInfo.FunctionName;
                [uniqueId,~]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,fcnID,designNames,specializationIds);
                hasFcnInfoInRegistry=~isempty(fcnInfoRegistry.getFunctionTypeInfo(uniqueId));
                if~hasFcnInfoInRegistry


                    continue;
                end

                scriptID=coder.internal.FcnInfoRegistryBuilder.getMappedScriptID(fcnInferenceInfo.ScriptID);
                scriptText=inferenceReportScripts(scriptID).ScriptText;
                [unicodemap,~]=coder.internal.FcnInfoRegistryBuilder.getUnicodedScriptText(scriptText);


                fcnExprMap=coder.internal.lib.Map();
                mxInfoLocations=getMexInfoLocationsFor(fcnID,coderReport);
                for kk=1:length(mxInfoLocations)
                    mxLocInfo=mxInfoLocations(kk);


                    start=mxLocInfo.TextStart;
                    textLength=mxLocInfo.TextLength;
                    [start,textLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(unicodemap,start,textLength);
                    stop=start+textLength-1;

                    if mxLocInfo.TextStart<1&&mxLocInfo.TextLength==-1


                        switch mxLocInfo.NodeTypeName
                        case 'var'



                            continue;
                        end
                    end


                    if start<5
                        continue;
                    end
                    exprT=mtree(scriptText(start:stop));
                    if 1==count(exprT)&&strcmp(exprT.kind,'ERR')


                        mTreeBasedPosition=start;
                    else



                        mTreeBasedPosition=start-1+exprT.root.position;
                    end

                    fcnExprMap.add(num2str(mTreeBasedPosition),mxLocInfo);
                end

                [uniqueId,~]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,fcnID,designNames,specializationIds);
                exprMap.add(uniqueId,fcnExprMap);
            end


            function mxInfoLocs=getMexInfoLocationsFor(fcnID,~)
                mxInfoLocs=[];
                instrFcns=coderReportInstrumentedDataInstrumentedFunctions;
                for ss=1:length(instrFcns)
                    instrFcn=instrFcns(ss);
                    if fcnID==instrFcn.FunctionID
                        mxInfoLocs=instrFcn.InstrumentedMxInfoLocations;
                    end
                end
            end

            propertyDependencies=containers.Map();

            debugFunctionInfos=coder.internal.lib.Map(fcnInfoRegistry.registry.keys(),fcnInfoRegistry.registry.values());
            instrumentedFunctions=coderReportInstrumentedDataInstrumentedFunctions;
            for ii=1:length(instrumentedFunctions)
                instrumentedFcn=instrumentedFunctions(ii);
                functionId=instrumentedFcn.FunctionID;
                functionId=coder.internal.FcnInfoRegistryBuilder.getMappedFunctionID(functionId);
                fcnInferenceInfo=inferenceReportFunctions(functionId);

                fcnName=fcnInferenceInfo.FunctionName;

                [uniqueId,~]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,functionId,designNames,specializationIds);
                fcnInfo=fcnInfoRegistry.getFunctionTypeInfo(uniqueId);
                if isempty(fcnInfo)

                    continue;
                end

                scriptID=coder.internal.FcnInfoRegistryBuilder.getMappedScriptID(fcnInferenceInfo.ScriptID);
                [unicodemap,scriptText]=coder.internal.FcnInfoRegistryBuilder.getUnicodedScriptText(inferenceReportScripts(scriptID).ScriptText);

                debugFunctionInfos.remove(uniqueId);

                instrumentedMxInfoLocations=instrumentedFcn.InstrumentedMxInfoLocations;
                for jj=1:length(instrumentedMxInfoLocations)
                    instrumentedMxInfoLoc=instrumentedMxInfoLocations(jj);

                    if coder.internal.Float2FixedConverter.supportMCOSClasses
                        switch instrumentedMxInfoLoc.NodeTypeName
                        case{'inputVar','outputVar','persistentVar','globalVar','var','.'}
                        otherwise,continue;
                        end
                    else
                        switch instrumentedMxInfoLoc.NodeTypeName
                        case{'inputVar','outputVar','persistentVar','globalVar','var'}
                        otherwise,continue;
                        end
                    end

                    if~instrumentedMxInfoLoc.IsInstrumented
                        continue;
                    end









                    if coder.internal.Float2FixedConverter.supportMCOSClasses
                        if instrumentedMxInfoLoc.NodeTypeName=='.'
                            TextStart=instrumentedMxInfoLoc.TextStart;
                            TextLength=instrumentedMxInfoLoc.TextLength;
                            [TextStart,TextLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(unicodemap,TextStart,TextLength);
                            varName=scriptText(TextStart:TextStart+TextLength-1);
                        else
                            varName=instrumentedMxInfoLoc.SymbolName;
                        end

                        if coder.internal.FcnInfoRegistryBuilder.isStructFieldAccess(varName,fcnInfo)
                            continue;
                        end

                    else
                        varName=instrumentedMxInfoLoc.SymbolName;
                    end

                    if isempty(varName)
                        continue;
                    end

                    TextStart=instrumentedMxInfoLoc.TextStart;
                    TextLength=instrumentedMxInfoLoc.TextLength;
                    [TextStart,TextLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(unicodemap,TextStart,TextLength);


                    nodeTypeName=instrumentedMxInfoLoc.NodeTypeName;
                    [skipSymbol,varName]=coder.internal.FcnInfoRegistryBuilder.processSymbol(nodeTypeName,varName,fcnInfo);
                    if skipSymbol
                        continue;
                    end

                    MxInfoLocationId=jj;
                    varTypeInfo=fcnInfo.getVarInfoByLocationId(varName,TextStart,TextLength,MxInfoLocationId);
                    if isempty(varTypeInfo)||~strcmp(varTypeInfo.SymbolName,varName)


                        inferenceReportMisMatch=true;
                        return;
                    end

                    if coderConstInMap.isKey(fcnName)
                        isCoderConst=~isempty(intersect(coderConstInMap(fcnName),varName));
                    else
                        isCoderConst=false;
                    end

                    REASON_CPPSYSOBJ=10;
                    if(instrumentedMxInfoLoc.Reason==REASON_CPPSYSOBJ)&&~varTypeInfo.isVarInSrcCppSystemObj()




                        nLoggedFields=length(instrumentedMxInfoLoc.LoggedFieldNames);
                        varTypeInfo.inferred_Type.CppSystemObj=true;
                        varTypeInfo.setFimath(cell(1,nLoggedFields));

                        mxInfoID=coder.internal.FcnInfoRegistryBuilder.getMappedMxInfoID(varTypeInfo.MxInfoID);
                        mxInfo=inferenceReportMxInfos{mxInfoID};
                        mxInfoPropIdx=strcmpi({mxInfo.ClassProperties.PropertyName},'cSFunObject');
                        sysObjMxInfoID=mxInfo.ClassProperties(mxInfoPropIdx).MxInfoID;




                        sysObjInstanceID=inferenceReportMxInfos{sysObjMxInfoID}.SEACompID;
                        sysObjInstance=inferenceReportMxArrays{sysObjInstanceID};
                        try


                            sysObjCompiledDataTypeInfo=getCompiledFixedPointInfo(sysObjInstance);
                        catch

                            sysObjCompiledDataTypeInfo=[];
                        end
                        for kk=1:nLoggedFields
                            varTypeInfo.loggedFields{kk}=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                            [loggedFldInferredType,loggedFldMxInfoID]=coder.internal.FcnInfoRegistryBuilder.getSystemObjectLoggedFieldInferredType(...
                            instrumentedMxInfoLoc.LoggedFieldNames{kk},sysObjCompiledDataTypeInfo,mxInfo);
                            varTypeInfo.loggedFieldsInferred_Types{kk}=loggedFldInferredType;
                            varTypeInfo.loggedFieldsMxInfoIDs{kk}=loggedFldMxInfoID;
                        end
                    end

                    if varTypeInfo.isStruct||varTypeInfo.isVarInSrcCppSystemObj()
                        if~isempty(instrumentedMxInfoLoc.LoggedFieldNames)
                            assert(length(instrumentedMxInfoLoc.LoggedFieldNames)==length(instrumentedMxInfoLoc.SimMin));
                        end
                        if length(instrumentedMxInfoLoc.LoggedFieldNames)~=length(varTypeInfo.loggedFields)




                            varTypeInfo.SimMin=Inf(1,length(varTypeInfo.loggedFields));
                            for kk=1:length(instrumentedMxInfoLoc.LoggedFieldNames)
                                fullLoggedFieldName=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                                loggedFieldIndices=strcmp(varTypeInfo.loggedFields,fullLoggedFieldName);
                                if any(loggedFieldIndices)&&instrumentedMxInfoLoc.SimMin(kk)<=varTypeInfo.SimMin(loggedFieldIndices)
                                    varTypeInfo.SimMin(loggedFieldIndices)=instrumentedMxInfoLoc.SimMin(kk);
                                end
                            end
                        else
                            varTypeInfo.SimMin=instrumentedMxInfoLoc.SimMin;
                        end
                        if~isempty(instrumentedMxInfoLoc.LoggedFieldNames)
                            assert(length(instrumentedMxInfoLoc.LoggedFieldNames)==length(instrumentedMxInfoLoc.SimMax));
                        end
                        if length(instrumentedMxInfoLoc.LoggedFieldNames)~=length(varTypeInfo.loggedFields)




                            varTypeInfo.SimMax=-Inf(1,length(varTypeInfo.loggedFields));
                            for kk=1:length(instrumentedMxInfoLoc.LoggedFieldNames)
                                fullLoggedFieldName=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                                loggedFieldIndices=strcmp(varTypeInfo.loggedFields,fullLoggedFieldName);
                                if any(loggedFieldIndices)&&instrumentedMxInfoLoc.SimMax(kk)>=varTypeInfo.SimMax(loggedFieldIndices)
                                    varTypeInfo.SimMax(loggedFieldIndices)=instrumentedMxInfoLoc.SimMax(kk);
                                end
                            end
                        else
                            varTypeInfo.SimMax=instrumentedMxInfoLoc.SimMax;
                        end

                        if length(instrumentedMxInfoLoc.IsAlwaysInteger)~=length(varTypeInfo.loggedFields)
                            varTypeInfo.IsAlwaysInteger=Inf(1,length(varTypeInfo.loggedFields));
                            for kk=1:length(instrumentedMxInfoLoc.LoggedFieldNames)
                                fullLoggedFieldName=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                                loggedFieldIndices=strcmp(varTypeInfo.loggedFields,fullLoggedFieldName);
                                if any(loggedFieldIndices)&&length(instrumentedMxInfoLoc.IsAlwaysInteger)>=kk
                                    varTypeInfo.IsAlwaysInteger(loggedFieldIndices)=instrumentedMxInfoLoc.IsAlwaysInteger(kk);
                                end
                            end
                        else
                            varTypeInfo.IsAlwaysInteger=instrumentedMxInfoLoc.IsAlwaysInteger;
                        end

                        if size(instrumentedMxInfoLoc.HistogramOfNegativeValues,1)~=length(varTypeInfo.loggedFields)
                            varTypeInfo.HistogramOfNegativeValues=Inf(length(varTypeInfo.loggedFields),size(instrumentedMxInfoLoc.HistogramOfNegativeValues,2));
                            for kk=1:length(instrumentedMxInfoLoc.LoggedFieldNames)
                                fullLoggedFieldName=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                                loggedFieldIndices=strcmp(varTypeInfo.loggedFields,fullLoggedFieldName);
                                if any(loggedFieldIndices)&&length(instrumentedMxInfoLoc.HistogramOfNegativeValues)>=kk
                                    varTypeInfo.HistogramOfNegativeValues(loggedFieldIndices,:)=instrumentedMxInfoLoc.HistogramOfNegativeValues(kk);
                                end
                            end
                        else
                            varTypeInfo.HistogramOfNegativeValues=instrumentedMxInfoLoc.HistogramOfNegativeValues;
                        end

                        if size(instrumentedMxInfoLoc.HistogramOfPositiveValues,1)~=length(varTypeInfo.loggedFields)
                            varTypeInfo.HistogramOfPositiveValues=Inf(length(varTypeInfo.loggedFields),size(instrumentedMxInfoLoc.HistogramOfPositiveValues,2));
                            for kk=1:length(instrumentedMxInfoLoc.LoggedFieldNames)
                                fullLoggedFieldName=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                                loggedFieldIndices=strcmp(varTypeInfo.loggedFields,fullLoggedFieldName);
                                if any(loggedFieldIndices)&&length(instrumentedMxInfoLoc.HistogramOfPositiveValues)>=kk
                                    varTypeInfo.HistogramOfPositiveValues(loggedFieldIndices,:)=instrumentedMxInfoLoc.HistogramOfPositiveValues(kk);
                                end
                            end
                        else
                            varTypeInfo.HistogramOfPositiveValues=instrumentedMxInfoLoc.HistogramOfPositiveValues;
                        end

                        if length(instrumentedMxInfoLoc.RatioOfRange)~=length(varTypeInfo.loggedFields)
                            varTypeInfo.RatioOfRange=cell(1,length(varTypeInfo.loggedFields));
                            for kk=1:length(instrumentedMxInfoLoc.LoggedFieldNames)
                                fullLoggedFieldName=[instrumentedMxInfoLoc.SymbolName,'.',instrumentedMxInfoLoc.LoggedFieldNames{kk}];
                                loggedFieldIndices=strcmp(varTypeInfo.loggedFields,fullLoggedFieldName);
                                if any(loggedFieldIndices)&&length(instrumentedMxInfoLoc.RatioOfRange)>=kk
                                    varTypeInfo.RatioOfRange(loggedFieldIndices)=instrumentedMxInfoLoc.RatioOfRange(kk);
                                end
                            end
                        else
                            varTypeInfo.RatioOfRange=instrumentedMxInfoLoc.RatioOfRange;
                        end
                    else
                        if varTypeInfo.isMCOSClass
                            continue;
                        end
                        if isempty(varTypeInfo.SimMin)||...
                            (~isempty(instrumentedMxInfoLoc.SimMin)&&instrumentedMxInfoLoc.SimMin<=varTypeInfo.SimMin)
                            varTypeInfo.SimMin=instrumentedMxInfoLoc.SimMin;
                        end
                        if isempty(varTypeInfo.SimMax)||...
                            (~isempty(instrumentedMxInfoLoc.SimMax)&&instrumentedMxInfoLoc.SimMax>=varTypeInfo.SimMax)
                            varTypeInfo.SimMax=instrumentedMxInfoLoc.SimMax;
                        end
                        varTypeInfo.IsAlwaysInteger=instrumentedMxInfoLoc.IsAlwaysInteger;

                        varTypeInfo.HistogramOfNegativeValues=instrumentedMxInfoLoc.HistogramOfNegativeValues;
                        varTypeInfo.HistogramOfPositiveValues=instrumentedMxInfoLoc.HistogramOfPositiveValues;
                        varTypeInfo.RatioOfRange=instrumentedMxInfoLoc.RatioOfRange;
                    end

                    varTypeInfo.isInputArg=instrumentedMxInfoLoc.IsArgin;



                    varTypeInfo.isCoderConst=varTypeInfo.isCoderConst||isCoderConst;

                    if coder.internal.Float2FixedConverter.supportMCOSClasses
                        if isempty(varTypeInfo.RatioOfRange)
                            varTypeInfo.RatioOfRange={[]};
                        end
                    end
                end

                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    classMemberBuilder=coder.internal.ClassMemberVarTypeInfoBuilder();
                    classMemberBuilder.run([],instrumentedMxInfoLocations,inferenceReportMxInfos,fcnInfo,propertyDependencies,inferenceReportMxArrays);
                end
            end
            if debugEnabled









            end
            if coder.internal.Float2FixedConverter.supportMCOSClasses
                coder.internal.FcnInfoRegistryBuilder.updateRangesForClassMembers(fcnInfoRegistry,propertyDependencies);
            end

            globalTypes=coder.internal.FcnInfoRegistryBuilder.updateGlobalRangesAcrossFcns(fcnInfoRegistry,globalTypes);
        end







        function AggregateStructProposedTypes(fcnInfos,mxInfos,typeProposalSettings)
            propseTargetContainerTypes=typeProposalSettings.proposeTargetContainerTypes;



            structVarInfoMap=coder.internal.lib.Map();
            for ii=1:length(fcnInfos)
                fcn=fcnInfos{ii};
                allVarInfos=fcn.getAllVarInfos();
                for jj=1:length(allVarInfos)
                    varInfo=allVarInfos{jj};
                    if~varInfo.isStruct()||varInfo.isCoderConst
                        continue;
                    end

                    allNestedVarInfos=varInfo.getAllNestedStructVarInfos();
                    for mm=1:length(allNestedVarInfos)
                        structVarInfo=allNestedVarInfos(mm);
                        mxIDKey=num2str(structVarInfo.MxInfoID);
                        if structVarInfoMap.isKey(mxIDKey)
                            structVarInfoMap(mxIDKey)=[structVarInfoMap(mxIDKey),structVarInfo];
                        else
                            structVarInfoMap(mxIDKey)=structVarInfo;
                        end
                    end
                end
            end

            mergedStructVarInfoMap=coder.internal.lib.Map();
            mxIDKeys=structVarInfoMap.keys;
            for ii=1:length(mxIDKeys)
                mxIDStr=mxIDKeys{ii};
                structMxInfo=mxInfos{str2double(mxIDStr)};
                sign=coder.internal.FcnInfoRegistryBuilder.calculateSignature(structMxInfo,mxInfos);
                if mergedStructVarInfoMap.isKey(sign)
                    mergedStructVarInfoMap(sign)=[mergedStructVarInfoMap(sign),structVarInfoMap(mxIDStr)];
                else
                    mergedStructVarInfoMap(sign)=structVarInfoMap(mxIDStr);
                end
            end

            mxIDKeys=mergedStructVarInfoMap.keys;
            for ii=1:length(mxIDKeys)
                mxIdkey=mxIDKeys{ii};
                structVarInfos=mergedStructVarInfoMap(mxIdkey);


                aggrFieldProposedTypes=structVarInfos(1).proposed_Type;





                for jj=1:length(structVarInfos)
                    varInfo=structVarInfos(jj);
                    fieldAnnotaions=varInfo.proposed_Type;



                    for aa=1:length(aggrFieldProposedTypes)
                        if isempty(aggrFieldProposedTypes{aa})&&isnumerictype(fieldAnnotaions{aa})



                            aggrFieldProposedTypes{aa}=fieldAnnotaions{aa};
                        elseif isnumerictype(aggrFieldProposedTypes{aa})&&isnumerictype(fieldAnnotaions{aa})
                            aggrFieldProposedTypes{aa}=fixed.aggregateType(aggrFieldProposedTypes{aa},fieldAnnotaions{aa});
                        end
                    end
                end

                if~isempty(aggrFieldProposedTypes)


                    for jj=1:length(structVarInfos)
                        varInfo=structVarInfos(jj);
                        if propseTargetContainerTypes
                            aggrFieldProposedTypes=cellfun(@(T)coder.internal.Helper.getTargetType(T.SignednessBool,T.WordLength,T.FractionLength,propseTargetContainerTypes)...
                            ,aggrFieldProposedTypes,'UniformOutput',false);
                        end
                        varInfo.proposed_Type=aggrFieldProposedTypes;
                    end
                end





                indices=arrayfun(@(v)v.hasUserSpecifiedAnnotation(),structVarInfos);
                if any(indices)

                    tmpStructVars=structVarInfos(indices);
                    userSpecifiedAnnotation=tmpStructVars(1).userSpecifiedAnnotation;
                    for mm=1:length(userSpecifiedAnnotation)



                        if isempty(userSpecifiedAnnotation{mm})
                            for nn=2:length(tmpStructVars)
                                annotaions=tmpStructVars(nn).userSpecifiedAnnotation;
                                if~isempty(annotaions{mm})

                                    userSpecifiedAnnotation{mm}=annotaions{mm};
                                    break;
                                end
                            end
                        end
                    end


                    for jj=1:length(structVarInfos)
                        varInfo=structVarInfos(jj);
                        varInfo.userSpecifiedAnnotation=userSpecifiedAnnotation;
                    end
                end
            end
        end








        function globalTypes=updateGlobalRangesAcrossFcns(fcnInfoRegistry,globalTypes)




            for ii=1:length(globalTypes)
                glbName=globalTypes{ii}.Name;







                glbFcnIds=fcnInfoRegistry.globalVarMap(glbName);
                glbFcnInfos=cellfun(@(uniqID)fcnInfoRegistry.getFunctionTypeInfo(uniqID),glbFcnIds,'UniformOutput',false);
                glbVarInfos=cellfun(@(fcnInfo)fcnInfo.getVarInfosByName(glbName),glbFcnInfos,'UniformOutput',false);


                glbVarInfos=[glbVarInfos{:}];

                glbVarInfos=glbVarInfos(~cellfun(@(x)isempty(x),glbVarInfos));

                glbVarInfosArr=[glbVarInfos{:}];


                fcnNames=arrayfun(@(varInfo)varInfo.functionInfo.uniqueId,glbVarInfosArr,'UniformOutput',false);
                if length(unique(fcnNames))<=1
                    continue;
                end
                if length(glbVarInfos)>1
                    [minSimMin,maxSimMax,cummIsAlwaysInteger]=coder.internal.FcnInfoRegistryBuilder.findSimMinMax(glbVarInfos,[],[],[]);

                    for jj=1:length(glbVarInfosArr)
                        var=glbVarInfosArr(jj);
                        var.SimMin=minSimMin;
                        var.SimMax=maxSimMax;
                        var.IsAlwaysInteger=cummIsAlwaysInteger;
                    end

                    [minDesignMin,maxDesignMax,cummDesignIsAlwaysInteger]=coder.internal.FcnInfoRegistryBuilder.findDesignMinMax(glbVarInfos,[],[],[]);
                    if~isempty(minDesignMin)||~isempty(maxDesignMax)||~isempty(cummDesignIsAlwaysInteger)
                        for jj=1:length(glbVarInfosArr)
                            var=glbVarInfosArr(jj);
                            if~isempty(minDesignMin)
                                var.DesignMin=minDesignMin;
                            end
                            if~isempty(maxDesignMax)
                                var.DesignMax=maxDesignMax;
                            end
                            if~isempty(cummDesignIsAlwaysInteger)
                                var.DesignIsInteger=cummDesignIsAlwaysInteger;
                            end
                            var.DesignRangeSpecified=true;
                        end
                    end
                end
            end



        end

        function populateCallSiteInfo(~,inferenceReport,fcnInfoRegistry,inferInfoMap)




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
                    calledFcn=fcnInfoRegistry.getFunctionTypeInfo(calleeUniqueId);

                    if~isempty(calledFcn)
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
                            if coderRightCallPos(node,nodesInTree)==callEnd
                                if~isempty(callNode)
                                    if strcmp(callNode.kind,'CALL')||strcmp(callNode.kind,'DCALL')











                                        assert(~strcmp(node.kind,'CALL')&&~strcmp(node.kind,'DCALL'));


                                        continue;
                                    else

                                    end
                                end

                                if strcmp(node.kind,'EQUALS')
                                    if strcmp(node.Left.kind,'DOT')||strcmp(node.Left.kind,'DOTLP')

                                        assert(~isempty(strfind(calledFcn.functionName,'set.')));
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
                            fcnInfo.addCallSite(callNode,calledFcn);
                        else
                            error(message('Coder:FXPCONV:missingcallinfo',...
                            callee));
                        end
                    end
                end
            end
        end

        function r=isBuiltinScript(scriptPath)

            scriptPath=strrep(scriptPath,'/',filesep);
            toolboxPath=fullfile(matlabroot,'toolbox');
            r=strncmp(scriptPath,toolboxPath,length(toolboxPath));
        end

        function specializationIds=constructSpecializationIds(inferenceReport)
            inferenceReportFunctions=inferenceReport.Functions;
            inferenceReportScripts=inferenceReport.Scripts;

            specializationIds=repmat(-1,size(inferenceReportFunctions));
            functionsByClass=containers.Map('KeyType','double','ValueType','any');

            totalScripts=length(inferenceReportScripts);
            for ii=1:length(inferenceReportFunctions)
                scriptId=inferenceReportFunctions(ii).ScriptID;

                if(scriptId<1)||(scriptId>totalScripts)
                    continue;
                end

                if~inferenceReportScripts(scriptId).IsUserVisible

                    continue;
                end

                classId=inferenceReportFunctions(ii).ClassdefUID;
                if functionsByClass.isKey(classId)
                    fcns=functionsByClass(classId);
                else
                    fcns=[];
                end
                fcns(end+1)=ii;
                functionsByClass(classId)=fcns;
            end

            functionsByClass=functionsByClass.values();
            for ii=1:length(functionsByClass)
                fcnsInScript=functionsByClass{ii};
                specialized=containers.Map();
                for jj=1:length(fcnsInScript)
                    fcnIdx=fcnsInScript(jj);
                    fcnInferenceInfo=inferenceReportFunctions(fcnIdx);
                    fcnName=fcnInferenceInfo.FunctionName;

                    if specialized.isKey(fcnName)
                        specialized(fcnName)=true;
                    else

                        specialized(fcnName)=false;
                    end
                end

                counts=containers.Map();
                for jj=1:length(fcnsInScript)
                    fcnIdx=fcnsInScript(jj);
                    fcnInferenceInfo=inferenceReportFunctions(fcnIdx);
                    fcnName=fcnInferenceInfo.FunctionName;

                    if specialized(fcnName)
                        if~counts.isKey(fcnName)
                            c=0;
                        else
                            c=counts(fcnName);
                        end
                        c=c+1;
                        specializationIds(fcnIdx)=c;
                        counts(fcnName)=c;
                    else

                        specializationIds(fcnIdx)=-1;
                    end
                end
            end
        end

        function assignVariableSpecializationNames(functionTypeInfo)
            varNames=functionTypeInfo.getAllVarNames();
            for ii=1:length(varNames)
                varInfos=functionTypeInfo.getVarInfosByName(varNames{ii});
                specialized=false;
                for jj=1:length(varInfos)
                    varInfo=varInfos{jj};
                    if varInfo.MxInfoID~=varInfos{1}.MxInfoID
                        specialized=true;
                        break;
                    end
                end

                if specialized





                    mxIds=containers.Map('KeyType','double','ValueType','logical');
                    for jj=length(varInfos):-1:1
                        varInfo=varInfos{jj};
                        mxIds(varInfo.MxInfoID)=true;
                    end


                    mxIds=sort(cell2mat(mxIds.keys));


                    specializationIdTable=[];
                    for specId=1:numel(mxIds)
                        mxId=mxIds(specId);
                        specializationIdTable(mxId)=specId;
                    end

                    for jj=1:length(varInfos)
                        varInfo=varInfos{jj};
                        varInfo.SpecializationId=specializationIdTable(varInfo.MxInfoID);
                        spName=sprintf('%s_s%d',varInfo.SymbolName,varInfo.SpecializationId);
                        if~isempty(functionTypeInfo.getVarInfo(spName))

                            spName=sprintf('%s__s%d',varInfo.SymbolName,varInfo.SpecializationId);
                        end
                        varInfo.SpecializationName=spName;
                    end

                end

            end
        end

        function[skipSymbol,SymbolName]=processSymbol(nodeTypeName,SymbolName,fcnInfo)
            skipSymbol=false;
            if strcmp(nodeTypeName,'(type cast)')
                try
                    t=mtree(SymbolName);
                    idNode=t.select(3);
                    if strcmp(kind(idNode),'ID')
                        SymbolName=string(idNode);
                    else
                        skipSymbol=true;
                        return;
                    end
                catch
                    skipSymbol=true;
                    return;
                end

                res=coder.internal.Helper.which(SymbolName);
                if~isempty(res)&&coder.internal.Helper.isToolboxPath(res)
                    skipSymbol=true;
                    return;
                end
            else
                try

                    SymbolName=coder.internal.FcnInfoRegistryBuilder.normalizeVarName(SymbolName);

                    switch SymbolName
                    case{'~'}
                        skipSymbol=true;
                        return;
                    end

                    t=mtree(SymbolName);
                    if coder.internal.Float2FixedConverter.supportMCOSClasses
                        if coder.internal.FcnInfoRegistryBuilder.isStructFieldAccess(SymbolName,fcnInfo)
                            skipSymbol=true;
                            return;
                        end

                        indicesCount=length(t.indices);
                        if indicesCount~=3
                            if indicesCount<3
                                skipSymbol=true;
                                return;
                            end
                            ignore=false;
                            for kkk=4:indicesCount
                                node=t.select(kkk);
                                if~strcmp(node.kind,'FIELD')
                                    ignore=true;
                                    break;
                                end
                            end
                            if ignore
                                skipSymbol=true;
                                return;
                            end
                        end
                    else
                        idNode=t.select(3);
                        if length(t.indices)==3&&strcmp(kind(idNode),'ID')
                            SymbolName=string(idNode);
                        else
                            skipSymbol=true;
                            return;
                        end
                    end
                catch ex %#ok<NASGU>
                    skipSymbol=true;
                    return;
                end
            end
        end

        function[inferenceMsgs,exprMap]=populateFcnInfoRegistryFromInferenceInfo(inferenceReport,designNames,userWrittenFunctions,fcnInfoRegistry,globalTypes,debugEnabled,varargin)

            if nargin<6
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

                if~inferenceReportScripts(scriptID).IsUserVisible


                    continue;
                end

                fcnName=fcnInferenceInfo.FunctionName;
                if~isKey(userWrittenFunctions,fcnName)


                    continue;
                end

                if~isempty(fcnInferenceInfo.FunctionName)&&'@'==fcnInferenceInfo.FunctionName(1)

                    continue;
                end

                className=fcnInferenceInfo.ClassName;

                functionId=ii;
                [uniqueId,specializationName,isDesign]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,functionId,designNames,specializationIds);
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
                if~isempty(logs)
                    loggedLocations=[logs.Functions(loggedFcnIds==ii).loggedLocations];
                    loggedTextStarts=[];
                    loggedTextLength=[];
                    loggedReasons=[];
                    loggedFields={};
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


                scriptText=inferenceReportScripts(fcnInferenceInfo.ScriptID).ScriptText;
                [unicodemap,~]=coder.internal.FcnInfoRegistryBuilder.getUnicodedScriptText(scriptText);
                scriptPath=inferenceReportScripts(fcnInferenceInfo.ScriptID).ScriptPath;

                fcnInfo=internal.mtree.FunctionTypeInfo(fcnName,specializationName,uniqueId,fcnInferenceInfo.MxInfoLocations,scriptText,scriptPath,unicodemap);
                fcnInfo.setDebug(debugEnabled);
                fcnInfo.isDesign=isDesign;
                fcnInfo.specializationId=specializationIds(functionId);
                fcnInfo.className=className;
                fcnInfo.classdefUID=fcnInferenceInfo.ClassdefUID;
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

                if~isempty(className)&&strcmp(fcnName,className)
                    className=fcnName;
                end

                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    if isempty(fcnInfo.tree)


                        tmp=strsplit(className,'.');
                        nonPkgClassName=tmp{end};
                        if strcmp(nonPkgClassName,fcnName)||contains(fcnName,'set.')||contains(fcnName,'validate.')



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
                        otherwise,continue;
                        end
                    else
                        switch nodeTypeName
                        case{'inputVar','outputVar','persistentVar','globalVar','var','(type cast)'}
                        otherwise,continue;
                        end
                    end

                    mxInferredTypeInfo=inferenceReportMxInfos{mxLocInfo.MxInfoID};
                    switch class(mxInferredTypeInfo)
                    case 'eml.MxFimathInfo',continue;
                    case 'eml.MxNumericTypeInfo',continue;
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

                    varLogInfo.SymbolName=SymbolName;
                    varLogInfo.SimMin=[];
                    varLogInfo.SimMax=[];
                    varLogInfo.IsAlwaysInteger=coder.internal.VarTypeInfo.DEFAULT_IS_INTEGER;
                    varLogInfo.IsArgin=strcmp(nodeTypeName,'inputVar');
                    varLogInfo.IsOutputArg=strcmp(nodeTypeName,'outputVar');
                    varLogInfo.MxInfoID=mxLocInfo.MxInfoID;
                    isCoderConst=false;
                    mxInferredTypeInfo=inferenceReportMxInfos{mxLocInfo.MxInfoID};
                    inferredInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxInferredTypeInfo,inferenceReportMxArrays);
                    inferredInfo.CppSystemObj=any(loggedMxInfoIds==mxLocInfo.MxInfoID);
                    if(strcmp(inferredInfo.Class,'struct'))
                        varLogInfo.IsAlwaysInteger=[];
                        varLogInfo.LoggedFieldNames={};
                        varLogInfo.LoggedFieldMxInfoIDs={};
                        varLogInfo.LoggedFieldsInferredTypes={};
                        varLogInfo.nestedStructuresInferredTypes=coder.internal.lib.Map();
                        varLogInfo.nestedStructuresMxInfoIDs=coder.internal.lib.Map();

                        varLogInfo=coder.internal.FcnInfoRegistryBuilder.addStructField(varLogInfo,...
                        varLogInfo.SymbolName,mxLocInfo.MxInfoID,...
                        inferenceReportMxInfos,...
                        inferenceReportMxArrays);
                    elseif inferredInfo.CppSystemObj

                        matchMxInfoIdsIdx=(loggedMxInfoIds==mxLocInfo.MxInfoID);
                        matchMxInfoIdsIdx=find(matchMxInfoIdsIdx,1);

                        varLogInfo.IsAlwaysInteger=[];
                        varLogInfo.LoggedFieldNames={};
                        varLogInfo.LoggedFieldMxInfoIDs={};
                        varLogInfo.LoggedFieldsInferredTypes={};
                        varLogInfo.nestedStructuresInferredTypes=coder.internal.lib.Map();
                        varLogInfo.nestedStructuresMxInfoIDs=coder.internal.lib.Map();
                        varLogInfo.cppSystemObjectLoggedPropertiesInfo={};
                        varLogInfo=coder.internal.FcnInfoRegistryBuilder.addSystemObjectField(varLogInfo,...
                        varLogInfo.SymbolName,mxLocInfo.MxInfoID,...
                        inferenceReportMxInfos,...
                        inferenceReportMxArrays,...
                        loggedFields{matchMxInfoIdsIdx});

                    end
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

                if~inferenceReportScripts(fcnInferenceInfo.ScriptID).IsUserVisible

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

                scriptText=inferenceReportScripts(fcnInferenceInfo.ScriptID).ScriptText;
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
                    exprT=mtree(scriptText(start+1:stop));
                    if 1==count(exprT)&&strcmp(exprT.kind,'ERR')




                        mTreeBasedPosition=start+1;
                    else



                        mTreeBasedPosition=start+exprT.root.position;
                    end

                    fcnExprMap.add(num2str(mTreeBasedPosition),mxLocInfo);
                end

                [uniqueId,~]=coder.internal.FcnInfoRegistryBuilder.getFunctionIdentifiers(fcnName,fcnID,designNames,specializationIds);
                exprMap.add(uniqueId,fcnExprMap);
            end
        end

        function varLogInfo=addStructField(varLogInfo,fieldName,MxInfoID,MxInfos,MxArrays)
            mxInfo=MxInfos{MxInfoID};
            if iscell(mxInfo)
                mxInfo=mxInfo{end};
            end
            if isa(mxInfo,'eml.MxStructInfo')
                varLogInfo.nestedStructuresInferredTypes(fieldName)=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxInfo,MxArrays);
                varLogInfo.nestedStructuresMxInfoIDs(fieldName)=MxInfoID;
                StructFields=mxInfo.StructFields;
                for f=1:length(StructFields)
                    nestedFieldName=[fieldName,'.',StructFields(f).FieldName];
                    nestedFieldMxInfoID=StructFields(f).MxInfoID;
                    varLogInfo=coder.internal.FcnInfoRegistryBuilder.addStructField(varLogInfo,nestedFieldName,nestedFieldMxInfoID,MxInfos,MxArrays);
                end
            else
                varLogInfo.IsAlwaysInteger(end+1)=0;
                varLogInfo.LoggedFieldNames{end+1}=fieldName;
                varLogInfo.LoggedFieldMxInfoIDs{end+1}=MxInfoID;
                varLogInfo.LoggedFieldsInferredTypes{end+1}=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxInfo,MxArrays);
            end
        end

        function varLogInfo=addSystemObjectField(varLogInfo,fieldName,MxInfoID,...
            MxInfos,MxArrays,loggedProperties)
            mxInfo=MxInfos{MxInfoID};
            if iscell(mxInfo)
                mxInfo=mxInfo{end};
            end
            mxInfoPropIdx=strcmpi({mxInfo.ClassProperties.PropertyName},'cSFunObject');
            sysObjMxInfoID=mxInfo.ClassProperties(mxInfoPropIdx).MxInfoID;
            sysObjInstanceID=MxInfos{sysObjMxInfoID}.SEACompID;
            sysObjInstance=MxArrays{sysObjInstanceID};
            inputDataTypeID=getInputDataTypeID(sysObjInstance);









            doApplyProposedType=any(inputDataTypeID<14);




            sysObjStruct=get(sysObjInstance);
            try


                sysObjCompiledDataTypeInfo=getCompiledFixedPointInfo(sysObjInstance);
            catch

                sysObjCompiledDataTypeInfo=[];
            end
            if matlab.system.isSystemObjectName(mxInfo.Class)
                sysObjConstraints=coder.internal.getSystemObjectConstraints();
                constraintStruct=struct();
                if isKey(sysObjConstraints,class(sysObjInstance))
                    constraintStruct=sysObjConstraints(class(sysObjInstance));
                end
                varLogInfo.nestedStructuresInferredTypes(fieldName)=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxInfo,MxArrays);
                varLogInfo.nestedStructuresMxInfoIDs(fieldName)=MxInfoID;
                for f=1:length(loggedProperties)
                    nestedFieldName=[fieldName,'.',loggedProperties{f}];
                    varLogInfo=coder.internal.FcnInfoRegistryBuilder.addSystemObjectPropertyField(...
                    varLogInfo,nestedFieldName,sysObjCompiledDataTypeInfo,mxInfo);
                    parentPropertyName=regexprep(loggedProperties{f},'Custom','');
                    propInfo.ParentPropertyValue=sysObjStruct.(parentPropertyName);





                    propInfo.doProposeType=~isInactiveProperty(sysObjInstance,loggedProperties{f});
                    propValue=sysObjStruct.(loggedProperties{f});
                    propInfo.Signedness=get(propValue,'Signedness');
                    propInfo.WordLength=get(propValue,'WordLength');
                    propInfo.FractionLength=get(propValue,'FractionLength');





                    propInfo.doApplyProposedType=doApplyProposedType&&propInfo.doProposeType;
                    if isfield(constraintStruct,loggedProperties{f})
                        propInfo.ConstraintStruct=constraintStruct.(loggedProperties{f});
                    else
                        propInfo.ConstraintStruct=struct();
                    end
                    varLogInfo.cppSystemObjectLoggedPropertiesInfo{f}=propInfo;
                end
            else
                varLogInfo.IsAlwaysInteger(end+1)=0;
                varLogInfo.LoggedFieldNames{end+1}=fieldName;
                varLogInfo.LoggedFieldMxInfoIDs{end+1}=[];
                varLogInfo.LoggedFieldsInferredTypes{end+1}=coder.internal.FcnInfoRegistryBuilder.getDefaultInferredTypeInfo();
            end
        end

        function varLogInfo=addSystemObjectPropertyField(varLogInfo,fieldName,sysObjCompiledDataTypeInfo,sysObjMxInfo)
            varLogInfo.IsAlwaysInteger(end+1)=0;
            varLogInfo.LoggedFieldNames{end+1}=fieldName;
            tmp=regexp(fieldName,'\.','split');
            propName=tmp{end};
            [propInferredType,propMxInfoID]=coder.internal.FcnInfoRegistryBuilder.getSystemObjectLoggedFieldInferredType(propName,sysObjCompiledDataTypeInfo,sysObjMxInfo);
            varLogInfo.LoggedFieldsInferredTypes{end+1}=propInferredType;
            varLogInfo.LoggedFieldMxInfoIDs{end+1}=propMxInfoID;
        end
        function[inferredType,mxInfoID]=getSystemObjectLoggedFieldInferredType(sysObjPropName,sysObjCompiledDataTypeInfo,sysObjMxInfo)
            inferredType=coder.internal.FcnInfoRegistryBuilder.getDefaultInferredTypeInfo();
            inferredType.CppSystemObj=true;
            propName=regexprep(sysObjPropName,'Custom','');
            if~isempty(sysObjCompiledDataTypeInfo)&&isfield(sysObjCompiledDataTypeInfo,propName)
                ntVal=sysObjCompiledDataTypeInfo.(propName);
                if isfloat(ntVal)
                    inferredType.Class=ntVal.DataType;
                else
                    inferredType.Class='embedded.fi';
                    inferredType.FiMath=fimath;
                    inferredType.FiMathLocal=false;
                    inferredType.NumericType=ntVal;
                end
            end

            propIdx=strcmp({sysObjMxInfo.ClassProperties.PropertyName},sysObjPropName);
            mxInfoID=sysObjMxInfo.ClassProperties(propIdx).MxInfoID;
        end
        function newRegistry=merge(fcnInfoRegistries,typeProposalSettings)
            newRegistry=coder.internal.FunctionTypeInfoRegistry;
            cellfun(@(registry)newRegistry.update(registry,typeProposalSettings),...
            fcnInfoRegistries);
        end


        function[minValue,maxValue]=getMinMax(value)
            value=value(:);
            if isreal(value)
                minValue=double(min(value));
                maxValue=double(max(value));
            else


                realParts=real(value);
                imagParts=imag(value);
                minValue=double(min([min(realParts),min(imagParts)]));
                maxValue=double(max([max(realParts),max(imagParts)]));
            end
        end

        function updateAnnotationsForClassMembers(classMap)
            classNames=classMap.keys();
            for ii=1:length(classNames)
                className=classNames{ii};
                properties=classMap(className);
                propInfos=properties.values();
                for jj=1:length(propInfos)
                    propInfo=propInfos{jj};

                    if~isfield(propInfo,'vars')

                        continue;
                    end

                    vars=propInfo.vars;
                    userSpecifiedAnnotation=[];
                    for kk=1:length(vars)
                        if~isempty(vars{kk}.userSpecifiedAnnotation)
                            userSpecifiedAnnotation=vars{kk}.userSpecifiedAnnotation;
                        end
                    end

                    if~isempty(userSpecifiedAnnotation)
                        for kk=1:length(vars)
                            vars{kk}.userSpecifiedAnnotation=userSpecifiedAnnotation;
                        end
                    end
                end
            end
        end

        function updateRangesForClassMembers(fcnInfoRegistry,propertyDependencies)
            fcnTypeInfos=fcnInfoRegistry.getAllFunctionTypeInfos();

            classMap=containers.Map();
            for ii=1:length(fcnTypeInfos)
                fcn=fcnTypeInfos{ii};
                if isempty(fcn.className)
                    classMap(fcn.className)=containers.Map();
                    continue;
                end
                if~classMap.isKey(fcn.className)
                    classdefNode=fcn.tree.root;
                    while~isempty(classdefNode)&&~strcmp(classdefNode.kind,'CLASSDEF')
                        classdefNode=classdefNode.Next;
                    end
                    if isempty(classdefNode)


                        continue;
                    end
                    properties=coder.internal.FcnInfoRegistryBuilder.parsePropertiesSections(classdefNode,fcn.className);
                    classMap(fcn.className)=properties;
                end
            end

            for ii=1:length(fcnTypeInfos)
                fcn=fcnTypeInfos{ii};
                varInfos=fcn.getAllVarInfos();
                for kk=1:length(varInfos)
                    var=varInfos{kk};



                    if contains(var.SymbolName,'.')
                        fieldAccess=strsplit(var.SymbolName,'.');
                        if length(fieldAccess)>1
                            baseVarName=strjoin(fieldAccess(1:end-1),'.');
                            fieldName=fieldAccess{end};

                            baseVarInfo=fcn.getVarInfosByFullVarName(baseVarName);
                            assert(~isempty(baseVarInfo)&&baseVarInfo{1}.isMCOSClass());

                            className=baseVarInfo{1}.inferred_Type.Class;
                            if baseVarInfo{1}.isVarInSrcCppSystemObj()
                                continue;
                            end

                            if~classMap.isKey(className)



                                continue;
                            end
                            properties=classMap(className);

                            assert(properties.isKey(fieldName));
                            propInfo=properties(fieldName);
                            if isfield(propInfo,'vars')
                                propInfo.vars{end+1}=var;
                            else
                                propInfo.vars={var};
                            end
                            properties(fieldName)=propInfo;%#ok<NASGU>
                        end
                    end
                end
            end

            classNames=classMap.keys();
            for ii=1:length(classNames)
                className=classNames{ii};
                properties=classMap(className);
                propInfos=properties.values();
                for jj=1:length(propInfos)
                    propInfo=propInfos{jj};

                    if~isfield(propInfo,'vars')

                        continue;
                    end

                    vars=propInfo.vars;
                    if vars{1}.isMCOSClass
                        continue;
                    end
                    [SimMin,SimMax,IsAlwaysInteger]=coder.internal.FcnInfoRegistryBuilder.findSimMinMax(vars,[],[],true);

                    if isfield(propInfo,'initialValue')
                        assert(~isempty(propInfo.initialValue));
                        if isnumeric(propInfo.initialValue)
                            [minInitialValue,maxInitialValue]=coder.internal.FcnInfoRegistryBuilder.getMinMax(propInfo.initialValue);
                            SimMin=min(SimMin,minInitialValue);
                            SimMax=max(SimMax,maxInitialValue);
                        end
                    end

                    for kk=1:length(vars)
                        vars{kk}.SimMin=SimMin;
                        vars{kk}.SimMax=SimMax;
                        vars{kk}.IsAlwaysInteger=IsAlwaysInteger;
                    end
                end
            end

            fcnInfoRegistry.classMap=classMap;

            propertyPaths=propertyDependencies.keys();

            for ii=1:10000
                changed=false;
                skipped={};
                for jj=1:length(propertyPaths)
                    propertyPath=propertyPaths{jj};
                    vars=coder.internal.FcnInfoRegistryBuilder.getVarInfos(classMap,propertyPath);
                    [SimMin,SimMax,IsAlwaysInteger]=coder.internal.FcnInfoRegistryBuilder.findSimMinMax(vars,[],[],true);

                    if isempty(SimMin)||isinf(SimMin)
                        skipped{end+1}=propertyPath;
                        continue;
                    end

                    if isempty(SimMax)||isinf(SimMax)
                        skipped{end+1}=propertyPath;
                        continue;
                    end

                    dependentProperties=propertyDependencies(propertyPath);
                    for kk=1:length(dependentProperties)
                        dependentProperty=dependentProperties{kk};
                        dependentVars=coder.internal.FcnInfoRegistryBuilder.getVarInfos(classMap,dependentProperty);
                        [depSimMin,depSimMax,depIsAlwaysInteger]=coder.internal.FcnInfoRegistryBuilder.findSimMinMax(dependentVars,SimMin,SimMax,IsAlwaysInteger);

                        for ll=1:length(dependentVars)
                            if dependentVars{ll}.SimMin~=depSimMin
                                dependentVars{ll}.SimMin=depSimMin;
                                changed=true;
                            end
                            if dependentVars{ll}.SimMax~=depSimMax
                                dependentVars{ll}.SimMax=depSimMax;
                                changed=true;
                            end
                            dependentVars{ll}.IsAlwaysInteger=depIsAlwaysInteger;
                        end
                    end
                end

                if~changed
                    break;
                end
            end
        end

        function[designMin,designMax,designIsAlwaysInteger]=findDesignMinMax(vars,designMin,designMax,designIsAlwaysInteger)
            if isempty(vars)
                return;
            end
            arrVars=[vars{:}];

            if vars{1}.isStruct()
                assert(~isempty(vars)&&all(strcmp(vars{1}.SymbolName,{arrVars.SymbolName})));
            end
            for kk=1:length(vars)
                var=arrVars(kk);
                if any([arrVars.DesignRangeSpecified])
                    if~isempty(var.DesignMin)
                        if~isempty(designMin)
                            designMin=min(designMin,var.DesignMin);
                        else
                            designMin=var.DesignMin;
                        end
                    end

                    if~isempty(var.DesignMax)
                        if~isempty(designMax)
                            designMax=max(designMax,var.DesignMax);
                        else
                            designMax=var.DesignMax;
                        end
                    end

                    if~isempty(var.DesignIsInteger)
                        if~isempty(designIsAlwaysInteger)
                            designIsAlwaysInteger=designIsAlwaysInteger&var.IsAlwaysInteger;
                        else
                            designIsAlwaysInteger=var.DesignIsInteger;
                        end
                    end
                end
            end
        end

        function[SimMin,SimMax,IsAlwaysInteger]=findSimMinMax(vars,SimMin,SimMax,IsAlwaysInteger)
            if isempty(vars)
                return;
            end
            arrVars=[vars{:}];

            if vars{1}.isStruct()
                assert(~isempty(vars)&&all(strcmp(vars{1}.SymbolName,{arrVars.SymbolName})));
            end
            for kk=1:length(vars)
                var=arrVars(kk);
                if~isempty(var.SimMin)
                    if~isempty(SimMin)
                        SimMin=min(SimMin,var.SimMin);
                    else
                        SimMin=var.SimMin;
                    end
                end

                if~isempty(var.SimMax)
                    if~isempty(SimMax)
                        SimMax=max(SimMax,var.SimMax);
                    else
                        SimMax=var.SimMax;
                    end
                end

                if~isempty(var.IsAlwaysInteger)
                    if~isempty(IsAlwaysInteger)
                        IsAlwaysInteger=IsAlwaysInteger&var.IsAlwaysInteger;
                    else
                        IsAlwaysInteger=var.IsAlwaysInteger;
                    end
                end
            end
        end

        function vars=getVarInfos(classMap,propertyPath)
            propertyPathExpr=strsplit(propertyPath,'.');
            className=propertyPathExpr{1};
            fieldName=propertyPathExpr{2};

            assert(classMap.isKey(className));
            properties=classMap(className);

            assert(properties.isKey(fieldName));
            info=properties(fieldName);
            if isfield(info,'vars')
                vars=info.vars;
            else
                vars=[];
            end
        end


        function properties=parsePropertiesSections(classdefNode,currentClassName)
            properties=containers.Map();
            sectionNode=classdefNode.Body;

            defaultValMap=containers.Map();
            currClassMeta=meta.class.fromName(currentClassName);
            for ii=1:length(currClassMeta.PropertyList)
                p=currClassMeta.PropertyList(ii);
                if p.HasDefault
                    defaultValMap(p.Name)=p.DefaultValue;
                end
            end

            while~isempty(sectionNode)
                if strcmp(sectionNode.kind,'PROPERTIES')
                    isConstant=false;
                    attributes=sectionNode.Attr;
                    if~isempty(attributes)
                        attr=attributes.Arg;
                        while~isempty(attr)&&~isConstant
                            isConstant=strcmp(string(attr.Left),'Constant');
                            attr=attr.Next;
                        end
                    end

                    propDecl=sectionNode.Body;
                    while~isempty(propDecl)
                        if strcmp(propDecl.kind,'EQUALS')
                            if strcmp(propDecl.Left.kind,'PROPTYPEDECL')
                                t=propDecl.Left;
                                propName=t.VarName.tree2str(0,1);
                                if~isempty(t.VarType)
                                    info.propType=string(t.VarType);
                                end
                                if isempty(t.VarDimensions)
                                    info.propDimensions=[];
                                else
                                    info.propDimensions=t.VarDimensions;
                                end
                                if~isempty(t.VarValidators)
                                    info.propValidators=string(t.VarValidators);
                                end
                            else
                                propName=propDecl.Left.tree2str(0,1);
                                info=[];
                                info.isConstant=isConstant;
                                if~isempty(propDecl.Right)
                                    if defaultValMap.isKey(propName)
                                        info.initialValue=defaultValMap(propName);
                                    end
                                end
                            end
                            info.node=propDecl;
                            properties(propName)=info;
                        end
                        propDecl=propDecl.Next;
                    end
                end
                sectionNode=sectionNode.Next;
            end
        end

        function r=isStructFieldAccess(SymbolName,fcnInfo)
            r=false;



            if contains(SymbolName,'.')
                fieldAccess=strsplit(SymbolName,'.');
                if length(fieldAccess)>1
                    baseVarName=fieldAccess{1};
                    baseVarInfo=fcnInfo.getVarInfosByName(baseVarName);
                    if~isempty(baseVarInfo)&&baseVarInfo{1}.isMCOSClass()&&~baseVarInfo{1}.isVarInSrcCppSystemObj()
                        r=false;
                    else
                        r=true;
                    end
                end
            end
        end



        function assignClassSpecializationNames(fcnInfoRegistry)
            fcnTypeInfos=fcnInfoRegistry.getAllFunctionTypeInfos();
            classNameMap=containers.Map();
            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                className=fcnInfo.className;
                if isempty(className)
                    continue;
                end
                if classNameMap.isKey(className)
                    classdefUIDs=classNameMap(className);
                    classdefUIDs(end+1)=fcnInfo.classdefUID;
                else
                    classdefUIDs=fcnInfo.classdefUID;
                end
                classNameMap(className)=unique(classdefUIDs);
            end

            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                className=fcnInfo.className;
                if isempty(className)
                    continue;
                end
                classdefUIDs=classNameMap(className);
                if length(classdefUIDs)==1

                    fcnInfo.classSpecializationName=className;
                else
                    idx=find(classdefUIDs==fcnInfo.classdefUID);
                    fcnInfo.classSpecializationName=sprintf('%s%d',className,idx);
                end

                if strcmp(fcnInfo.functionName,fcnInfo.className)

                    fcnInfo.specializationName=fcnInfo.classSpecializationName;
                end
            end
        end

        function sign=calculateSignature(structMxInfo,mxInfos)
            assert(isa(structMxInfo,'eml.MxStructInfo'));
            structFields=structMxInfo.StructFields;
            signList=cell(1,length(structFields));
            for ii=1:length(structFields)
                mxFieldInfo=structFields(ii);
                fieldMxInfo=mxInfos{mxFieldInfo.MxInfoID};
                if isa(fieldMxInfo,'eml.MxStructInfo')
                    signList{ii}=[mxFieldInfo.FieldName,'.',num2str(mxFieldInfo.MxInfoID),'( ',coder.internal.FcnInfoRegistryBuilder.calculateSignature(fieldMxInfo,mxInfos),' )'];
                else
                    signList{ii}=[mxFieldInfo.FieldName,'.',num2str(mxFieldInfo.MxInfoID)];
                end
            end
            sign=strjoin(signList,', ');
        end




        function mxInfoID=getMappedMxInfoID(mxInfoID_orig)
            masterInferenceManager=coder.internal.MasterInferenceManager.getInstance;
            if~isMapEmpty(masterInferenceManager)
                mxInfoID=masterInferenceManager.CurrentMap.MxInfos(mxInfoID_orig);
            else
                mxInfoID=mxInfoID_orig;
            end
        end
        function mxArrayID=getMappedMxArrayID(mxArrayID_orig)
            masterInferenceManager=coder.internal.MasterInferenceManager.getInstance;
            if~isMapEmpty(masterInferenceManager)
                mxArrayID=masterInferenceManager.CurrentMap.MxArrays(mxArrayID_orig);
            else
                mxArrayID=mxArrayID_orig;
            end
        end
        function functionID=getMappedFunctionID(functionID_orig)
            masterInferenceManager=coder.internal.MasterInferenceManager.getInstance;
            if~isMapEmpty(masterInferenceManager)
                functionID=masterInferenceManager.CurrentMap.Functions(functionID_orig);
            else
                functionID=functionID_orig;
            end
        end
        function scriptID=getMappedScriptID(scriptID_orig)
            masterInferenceManager=coder.internal.MasterInferenceManager.getInstance;
            if~isMapEmpty(masterInferenceManager)
                scriptID=masterInferenceManager.CurrentMap.Scripts(scriptID_orig);
            else
                scriptID=scriptID_orig;
            end
        end
        function ti=getMappedInferredTypeInfo(mxInfoID,MxInfos,MxArrays)




            mxInfoID=coder.internal.FcnInfoRegistryBuilder.getMappedMxInfoID(mxInfoID);
            rhsMxInferredTypeInfo=MxInfos{mxInfoID};
            ti=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(...
            rhsMxInferredTypeInfo,MxArrays);
        end
    end
end

function endpos=coderRightCallPos(node,nodesInTree)
    if strcmp(node.kind,'DCALL')





        node=nodesInTree.select(node.righttreeindex);
    end
    endpos=node.righttreepos;
end




