classdef MultiPass
    properties(Access=public)
functionMTree
functionTypeInfo
functionCompiledExprInfo
functionSimulationExprInfo
functionTypeInfoRegistry
typeProposalSettings
loopIndexVars
autoScaleLoopIndexVars
globalFimathStr
globalFimath
emitFiMathVar
fiMathVarName
fiOperatorMapper
fxpConversionSettings
outputPath
uniqueNamesService
autoReplaceHndlr
globalUniqNameMap
structCopyHandler
fimathFcnName
    end
    methods(Access=public)

        function this=MultiPass(fMTree,fTypeInfo,fcnCompiledExprInfo,fcnSimExprInfo,fTypeInfoRegistry,tpSettings,fxpConversionSettings,fiOperatorMapper,autoReplaceHndlr,structCopyHandler,outputPath,uniqueNamesService,globalUniqNameMap,fimathFcnName)
            this.functionMTree=fMTree;
            this.functionTypeInfo=fTypeInfo;
            this.functionCompiledExprInfo=fcnCompiledExprInfo;
            this.functionSimulationExprInfo=fcnSimExprInfo;
            this.functionTypeInfoRegistry=fTypeInfoRegistry;
            this.typeProposalSettings=tpSettings;
            this.loopIndexVars=containers.Map();
            this.autoScaleLoopIndexVars=fxpConversionSettings.autoScaleLoopIndexVars;
            this.globalFimathStr=fxpConversionSettings.globalFimathStr;
            this.globalFimath=eval(this.globalFimathStr);
            this.emitFiMathVar=false;
            this.fiMathVarName=fxpConversionSettings.fiMathVarName;
            this.fiOperatorMapper=fiOperatorMapper;
            this.autoReplaceHndlr=autoReplaceHndlr;
            this.structCopyHandler=structCopyHandler;
            this.fxpConversionSettings=fxpConversionSettings;
            this.outputPath=outputPath;
            this.uniqueNamesService=uniqueNamesService;
            this.globalUniqNameMap=globalUniqNameMap;
            this.fimathFcnName=fimathFcnName;
        end

        function[functionCode,errMsgs,uniqueNamesService,needsFiMathFcn]=translate(this,indentLevel)
            functionCode='';%#ok<NASGU>
            tree=this.functionMTree;

            needsFiMathFcn=false;
            replacements={};



            if this.fxpConversionSettings.detectDeadCode&&this.functionTypeInfo.isDead...
                &&~this.functionTypeInfo.isDesign
                specializationName=this.functionTypeInfo.specializationName;


                errMsgs=coder.internal.lib.Message.buildMessage(this.functionTypeInfo,...
                tree,'Warning','Coder:FXPCONV:DeadFUNCTION',specializationName);



                callNodes=this.functionTypeInfo.callSites;
                for i=1:length(callNodes)
                    callNodeInfo=callNodes{i};
                    callNode=callNodeInfo{1};
                    calledFunction=callNodeInfo{2};
                    if calledFunction.isDead
                        specName=calledFunction.specializationName;
                        replacements{end+1}=callNode.Left;
                        replacements{end+1}=coder.internal.Helper.newFunctionName(specName,...
                        coder.internal.translator.Phase.DEAD);
                    end
                end

                replacements=addNewFunction(specializationName,tree,...
                coder.internal.translator.Phase.DEAD,replacements);


                uniqueNamesService=this.uniqueNamesService;
            elseif this.fxpConversionSettings.detectDeadCode&&this.functionTypeInfo.isConstantFolded...
                &&~this.functionTypeInfo.isDesign&&~this.functionTypeInfo.isDefinedInAClass
                specializationName=this.functionTypeInfo.specializationName;


                errMsgs=coder.internal.lib.Message.buildMessage(this.functionTypeInfo,...
                tree,'Warning','Coder:FXPCONV:ConstantFolded',specializationName);




                callNodes=this.functionTypeInfo.callSites;
                for i=1:length(callNodes)
                    callNodeInfo=callNodes{i};
                    callNode=callNodeInfo{1};
                    calledFunction=callNodeInfo{2};
                    if calledFunction.isConstantFolded
                        specName=calledFunction.specializationName;
                        replacements{end+1}=callNode.Left;
                        replacements{end+1}=coder.internal.Helper.newFunctionName(specName,...
                        coder.internal.translator.Phase.CFOLD);
                    end
                end

                replacements=addNewFunction(specializationName,tree,...
                coder.internal.translator.Phase.CFOLD,replacements);


                uniqueNamesService=this.uniqueNamesService;
            else
                mtreeAttributes=this.functionTypeInfo.treeAttributes;

                this.functionTypeInfo.expressionTypes=containers.Map();
                expressionTypes=this.functionTypeInfo.expressionTypes;

                possibleTypeTableNames={'T','TT','Types','TypesTable','TableOfTypesInThisFunction'};
                for ii=1:length(possibleTypeTableNames)
                    if~this.functionTypeInfo.symbolTable.isKey(possibleTypeTableNames{ii})
                        break;
                    end
                end
                this.functionTypeInfo.typesTableName=possibleTypeTableNames{ii};

                translatorData=coder.internal.translator.TranslatorData(...
                tree,...
                mtreeAttributes,...
                replacements,...
                this.functionTypeInfo,...
                this.functionSimulationExprInfo,...
                this.functionTypeInfoRegistry,...
                this.typeProposalSettings,...
                this.fxpConversionSettings,...
                this.fiOperatorMapper,...
                this.autoReplaceHndlr,...
                this.structCopyHandler,...
                this.uniqueNamesService,...
                expressionTypes,...
                this.globalUniqNameMap,...
                this.fimathFcnName);

                coder.internal.translator.Phase0(translatorData).run(indentLevel);

                uniqueNamesService=this.uniqueNamesService;

                [unsupportedFcnMessages,p1needsFimathVar]=...
                coder.internal.translator.Phase1(translatorData).run(indentLevel);

                [p2needsFiMathFcn,p2needsFimathVar]=...
                coder.internal.translator.Phase2(translatorData).run(indentLevel);

                p3=coder.internal.translator.Phase3(translatorData);

                if p1needsFimathVar||p2needsFimathVar
                    p3.emittedFiCast=true;
                end
                [msgs,p3needsFiMathFcn]=p3.run(indentLevel);

                errMsgs=[unsupportedFcnMessages,msgs];
                if p3needsFiMathFcn||p2needsFiMathFcn
                    needsFiMathFcn=true;
                end

                replacements=translatorData.Replacements;
            end



            indentLevel=0;
            functionCode=coder.internal.MTREEUtils.getFcnCode(tree,indentLevel,replacements,true);



            function replacements=addNewFunction(name,functionNode,suffix,replacements)
                replacements{end+1}=functionNode.Fname;
                replacements{end+1}=name;


                [indentStr,~]=functionNode.getOriginalIndentString();
                newCode=generateNewFunction(name,this.functionTypeInfo,indentStr,suffix);



                oldFunctionStr=functionNode.tree2str(0,1,replacements);
                code=[newCode,newline,indentStr,oldFunctionStr];
                replacements={functionNode,code};
            end

            function code=generateNewFunction(functionName,functionTypeInfo,indentStr,type)
                rootFcnMT=functionTypeInfo.tree;


                inputArgNames={};
                inputTypes={};
                insR=rootFcnMT.Ins;
                containsStruct=false;

                while~insR.isempty
                    if strcmp(insR.kind,'NOT')
                        varName='NOT_USED';
                        inputTypes{end+1}='';
                    else
                        varName=insR.string;

                        if strcmp(type,coder.internal.translator.Phase.CFOLD)
                            vars=functionTypeInfo.symbolTable(varName);
                            pos=insR.rightposition;
                            var=vars{1};
                            for j=1:length(vars)
                                if vars{j}.TextStart==pos
                                    var=vars{j};
                                    break;
                                end
                            end

                            varType=var.getOriginalTypeClassName();

                            switch varType
                            case 'struct'
                                structTypes={'struct'};
                                fields=var.loggedFields;
                                fieldTypes=var.loggedFieldsInferred_Types;

                                for j=1:length(fields)
                                    structTypes{end+1}={fields{j},fieldTypes{j}.Class};
                                end

                                inputTypes{end+1}=structTypes;

                                containsStruct=true;
                            otherwise
                                inputTypes{end+1}=varType;
                            end
                        end
                    end

                    inputArgNames{end+1}=varName;%#ok<*AGROW>
                    insR=insR.Next;
                end


                outputArgNames={};
                outsR=rootFcnMT.Outs;

                while~outsR.isempty
                    outputArgNames{end+1}=outsR.string;
                    outsR=outsR.Next;
                end

                nameService=coder.internal.lib.DistinctNameService();


                for j=1:length(inputArgNames)
                    inpArg=inputArgNames{j};
                    nameService.distinguishName(inpArg);
                end

                for j=1:length(outputArgNames)
                    outArg=outputArgNames{j};
                    nameService.distinguishName(outArg);
                end





                if strcmp(type,coder.internal.translator.Phase.CFOLD)

                    if containsStruct
                        structStrs='';

                        for j=1:length(inputTypes)
                            if length(inputTypes{j})>1
                                inArgsWithTypes={};
                                switch inputTypes{j}{1}
                                case 'struct'
                                    structStr='';

                                    for k=2:length(inputTypes{j})
                                        fieldName=inputTypes{j}{k}{1};
                                        fieldType=inputTypes{j}{k}{2};
                                        len=length(inputArgNames{j});
                                        newFieldName=[fieldName(1:len),'_orig',fieldName(len+1:end)];
                                        structStr=[structStr,newFieldName,' = ',fieldType,'(',fieldName,');',newline,indentStr];
                                    end

                                    structStrs=[structStrs,structStr,newline,indentStr];
                                    inArgsWithTypes{end+1}=[inputArgNames{j},'_orig'];
                                otherwise
                                    error('NOT A VALID INPUT TYPE');
                                end
                            else
                                inArgsWithTypes{end+1}=strcat(inputTypes{j},'(',inputArgNames{j},')');
                            end
                        end
                    else
                        structStrs='';
                        inArgsWithTypes=strcat(inputTypes,'(',inputArgNames,')');
                    end

                    outSig=strjoin(outputArgNames,', ');
                    inSig=strjoin(inArgsWithTypes,', ');
                    if isempty(outSig)
                        callStmt=sprintf('coder.const(%s(%s))',functionName,inSig);
                    elseif containsStruct
                        callStmt=sprintf('[%s] = %s(%s);\n',outSig,functionName,inSig);
                    else
                        callStmt=sprintf('[%s] = coder.const(%s(%s));\n',outSig,functionName,inSig);
                    end

                    callStmt=[structStrs,callStmt];
                else
                    callStmt=coder.internal.Helper.getFcnInterfaceSignature(functionName...
                    ,inputArgNames...
                    ,outputArgNames);
                    callStmt=sprintf('%s;\n',callStmt);
                end


                fcnSig=['function ',coder.internal.Helper.getFcnInterfaceSignature(coder.internal.Helper.newFunctionName(functionName,type),...
                inputArgNames,outputArgNames)];
                code=['%#codegen',newline,indentStr,fcnSig,newline,indentStr,callStmt,indentStr,'end',newline];
            end
        end
    end
end