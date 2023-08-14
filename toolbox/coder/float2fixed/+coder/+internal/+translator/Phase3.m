


classdef Phase3<coder.internal.translator.Phase
    properties(Access=private)
namingService
reassignVars
autoScaleLoopIndexVars
    end

    methods(Access=public)
        function phase3=Phase3(translatorData)
            phase3=phase3@coder.internal.translator.Phase(translatorData);
            phase3.TranslatorData=translatorData;
            phase3.namingService=coder.internal.lib.DistinctNameService();
            phase3.namingService.distinguishName('fmo_');

            phase3.reassignVars={};
            phase3.autoScaleLoopIndexVars=translatorData.FxpConversionSettings.autoScaleLoopIndexVars;
            phase3.emittedFiCast=false;

            annotater=coder.internal.translator.RedundantCastAnnotator(phase3.mtreeAttributes,phase3.fxpConversionSettings.DoubleToSingle);
            annotater.run(translatorData.Tree,translatorData.FunctionTypeInfo);
        end
    end


    methods(Access=public)

        function[messages,needsFiMathFcn]=run(this,indentLevel)
            if nargin>=2
                this.indentLevel=indentLevel;
            end
            this.visit(this.functionMTree,[]);
            replacements=this.replacements;
            messages=this.messages;
            needsFiMathFcn=this.emittedFiCast||this.emitFiMathFcn;

            this.TranslatorData.Replacements=replacements;
        end

        function output=visitFUNCTION(this,functionNode,~)

            [~,~,inputNodes,~]=coder.internal.MTREEUtils.fcnInputOutputParamNames(functionNode);

            inOutParams=intersect(this.inputParamNames,this.outputParamNames);
            if~isempty(inOutParams)
                this.reassignVars=inOutParams;
            end



            specializationName=this.functionTypeInfo.specializationName;
            this.replace(functionNode.Fname,specializationName);
            this.functionTypeInfo.convertedFunctionInterface.isConverted=true;
            this.functionTypeInfo.convertedFunctionInterface.convertedName=specializationName;
            this.functionTypeInfo.convertedFunctionInterface.inputParams=this.inputParamNames;
            this.functionTypeInfo.convertedFunctionInterface.outputParams=this.outputParamNames;


            output=this.visitBody(functionNode.Body,[]);

            prologue={};
            firstExecutableStmt=functionNode.Body;
            while~isempty(firstExecutableStmt)&&strcmp(firstExecutableStmt.kind,'COMMENT')

                firstExecutableStmt=firstExecutableStmt.Next;
            end
            [indentStr,sameLine]=firstExecutableStmt.getOriginalIndentString();



            if~isempty(firstExecutableStmt)
                isMLFBEntryPoint=this.fxpConversionSettings.MLFBApply&&this.functionTypeInfo.isDesign;
                if isMLFBEntryPoint


                    this.reassignVars=this.functionTypeInfo.inputVarNames;
                    mlfbReassignInputLValueVars(inputNodes);
                else


                    reassignInputLValueVars(functionNode,inputNodes);
                end
            end

            if this.fxpConversionSettings.GenerateParametrizedCode




                emitTypesTableVar();
                if~isempty(firstExecutableStmt)&&this.emittedFiCast
                    fmStr=this.emitFiMathStr();
                    prologue={fmStr,prologue{1:end}};
                end
            else




                if this.DoubleToSingle()
                else
                    if~isempty(firstExecutableStmt)&&this.emittedFiCast
                        fmStr=this.emitFiMathStr();
                        prologue={fmStr,prologue{1:end}};
                    end
                end
            end

            if~isempty(prologue)&&~isempty(firstExecutableStmt)
                firstLineStr=firstExecutableStmt.tree2str(0,1,this.replacements);



                if~sameLine
                    prologueStmts=strjoin(prologue,[newline,indentStr]);

                    firstLineStr=[prologueStmts,newline,newline,indentStr,firstLineStr];
                else

                    prologueStmts=strjoin(prologue,' ');
                    firstLineStr=[prologueStmts,' ',firstLineStr];
                end

                this.replace(firstExecutableStmt,firstLineStr);
            end

            function emitTypesTableVar()
                if~isempty(firstExecutableStmt)
                    if this.functionTypeInfo.specializationId==-1


                        typeTableName=this.functionTypeInfo.functionName;
                    else
                        typeTableName=this.functionTypeInfo.specializationName;
                    end
                    stmt=sprintf('%s = GetTypesTable(''%s'');',...
                    this.functionTypeInfo.typesTableName,typeTableName);
                    prologue={stmt,prologue{1:end}};
                end
            end

            function reassignInputLValueVars(functionNode,inputNodes)
                if this.DoubleToSingle






                    return;
                end
                this.reassignVars=unique(this.reassignVars);
                if~isempty(this.reassignVars)
                    fiCastFiVars=this.fxpConversionSettings.fiCastFiVars;
                    fiCastIntVars=this.fxpConversionSettings.fiCastIntegers;


                    for ii=1:length(this.reassignVars)
                        varName=this.reassignVars{ii};
                        inN=inputNodes{strcmp(this.inputParamNames,varName)};
                        varInfo=this.functionTypeInfo.getVarInfo(inN);
                        if isempty(varInfo)
                            continue;
                        end
                        if varInfo.isStruct()||varInfo.needsFiCast(fiCastFiVars,fiCastIntVars)
                            if varInfo.isStruct()

                                [fcnStr,fcnName,newName]=this.givenSingularStructVarInfoCreateCopyFcn(varInfo);
                                if~isempty(fcnStr)&&~isempty(fcnName)
                                    if~this.emitFiMathFcn

                                        this.emitFiMathFcn=true;
                                    end
                                    this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                                    ficastVar=[fcnName,'(',newName,')'];
                                end
                            elseif varInfo.needsFiCast(fiCastFiVars,fiCastIntVars)
                                newName=this.namingService.distinguishName([varName,'_1']);
                                ficastVar=this.encloseCodeWithFiCast(newName,varInfo,[]);
                            end
                            if~isempty(newName)&&~isempty(ficastVar)
                                replaceInput(functionNode,varName,newName);
                                reassignStr=sprintf('%s = %s;',...
                                varName,...
                                ficastVar);
                                prologue{end+1}=reassignStr;%#ok<AGROW>
                            end
                        end
                    end
                end

                function replaceInput(fNode,inputName,newName)
                    inNode=fNode.Ins;

                    while(~isempty(inNode))
                        if~strcmp(inNode.kind,'NOT')&&strcmp(inputName,inNode.string)
                            this.replace(inNode,newName);


                            idx=strcmp(this.inputParamNames,inputName);
                            this.functionTypeInfo.convertedFunctionInterface.inputParams{idx}=newName;
                        end
                        inNode=inNode.Next;
                    end
                end
            end







            function mlfbReassignInputLValueVars(inputNodes)
                assert(this.fxpConversionSettings.MLFBApply);

                this.reassignVars=unique(this.reassignVars);
                if~isempty(this.reassignVars)
                    fiCastFiVars=this.fxpConversionSettings.fiCastFiVars;
                    fiCastIntVars=this.fxpConversionSettings.fiCastIntegers;


                    for ii=1:length(this.reassignVars)
                        varName=this.reassignVars{ii};
                        inN=inputNodes{strcmp(this.inputParamNames,varName)};
                        varInfo=this.functionTypeInfo.getVarInfo(inN);
                        if isempty(varInfo)
                            continue;
                        end
                        if varInfo.isStruct()||varInfo.needsFiCast(fiCastFiVars,fiCastIntVars)
                            if varInfo.isStruct()
                                [fcnStr,fcnName,~]=this.givenSingularStructVarInfoCreateCopyFcn(varInfo);
                                if~isempty(fcnStr)&&~isempty(fcnName)


                                    newName=varName;
                                    this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                                    ficastVar=[fcnName,'(',newName,')'];
                                end
                            elseif varInfo.needsFiCast(fiCastFiVars,fiCastIntVars)


                                newName=varName;
                                ficastVar=this.encloseCodeWithFiCast(newName,varInfo,[]);
                            end



                            if~this.DoubleToSingle&&~isempty(varName)&&~isempty(ficastVar)
                                reassignStr=sprintf('%s = %s;',...
                                varName,...
                                ficastVar);
                                prologue{end+1}=reassignStr;%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end


        function output=visitEXPR(this,node,input)
            this.visit(node.Arg,input);


            if this.fxpConversionSettings.detectDeadCode&&~this.treeAttributes(node).isExecutedInSimulation
                string=this.treeAttributes(node).ScriptString;
                if isempty(string)
                    string=node.tree2str;
                end
                msg=coder.internal.lib.Message.buildMessage(this.functionTypeInfo,...
                node,'Warning','Coder:FXPCONV:DeadEXPR',string);
                this.addMessage(msg);
            end


            if this.fxpConversionSettings.detectDeadCode...
                &&(this.treeAttributes(node).isDeadCodeStart...
                ||this.treeAttributes(node).isDeadCodeEnd)
                insertDeadCodeComment();
            end

            output.tag=node.UNDEF;
            assertTag(this);




            function insertDeadCodeComment()
                nodeStr=node.tree2str(0,1,this.replacements);
                [indentStr,sameLine]=node.getOriginalIndentString();

                if this.treeAttributes(node).isDeadCodeStart
                    startComment=['%F2F: No information found for converting the following block of code',newline,indentStr,'%F2F: Start block'];
                    if sameLine
                        nodeStr=[newline,indentStr,startComment,newline,indentStr,nodeStr];
                    else
                        nodeStr=[startComment,newline,indentStr,nodeStr];
                    end
                end

                if this.treeAttributes(node).isDeadCodeEnd
                    endComment='%F2F: End block';
                    if sameLine
                        nodeStr=[nodeStr,newline,indentStr,endComment,newline];
                    else
                        nodeStr=[nodeStr,newline,indentStr,endComment];
                    end
                end

                this.replace(node,nodeStr);
            end
        end


        function output=visitID(this,idNode,~)
            output=[];
            varName=idNode.string;

            this.namingService.distinguishName(varName);
        end


        function output=visitEQUALS(this,assignNode,~)
            lValNodes=coder.internal.translator.Phase.getLValNodes(assignNode);

            lhs=assignNode.Left;
            this.visit(lhs,[]);

            rhs=assignNode.Right;
            output=this.visit(rhs,[]);

            if isNullCopy(rhs)
                this.handleNullCopy(rhs,lValNodes);
            elseif length(lValNodes)==1

                this.handleSingleAssigment(assignNode,lValNodes);
            else
                this.handleMultipleAssignemnt(assignNode,lValNodes);
            end

            output.tag=assignNode.UNDEF;

            function ret=isNullCopy(rhs)
                nullCopyNode=[];
                if(strcmp(rhs.kind,'SUBSCR'))
                    subScrNode=rhs;
                    nullCopyNode=subScrNode.Left.mtfind('Kind','DOT','Left.Kind','ID','Left.String','coder','Right.Kind','FIELD','Right.String','nullcopy');
                    if(isempty(nullCopyNode))
                        nullCopyNode=subScrNode.Left.mtfind('Kind','DOT','Left.Kind','ID','Left.String','eml','Right.Kind','FIELD','Right.String','nullcopy');
                    end
                end
                if isempty(nullCopyNode)
                    ret=false;
                else
                    ret=true;
                end
            end
        end




        function output=visitFOR(this,forNode,~)




            body=forNode.Body;

            output=this.visitBody(body,[]);

            indexNode=forNode.Index;
            this.autoScaleLoopIndexVars=shouldTransformLoopIndex(this,indexNode);
            if this.autoScaleLoopIndexVars
                if this.DoubleToSingle

                else
                    this.transformForLoopIndex(forNode);
                end
            end
        end




        function output=visitCALL(this,callNode,~)
            output=[];

            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
            if isempty(calleeFcnInfo)
                return
            end

            inputVarNames=calleeFcnInfo.inputVarNames;
            arg=callNode.Right;
            argNum=1;
            while~isempty(arg)
                if arg.iskind('CELL')

                    break
                end
                if arg.iskind('NAMEVALUE')
                    argNum=argNum+1;
                    param=arg.Right;
                else
                    param=arg;
                end
                inputName=inputVarNames{argNum};
                if strcmp(inputName,'varargin')

                    break
                end
                baseVarInfo=calleeFcnInfo.getVarInfo(inputName);
                encloseWithFiCastIfNeeded(this,baseVarInfo,param);
                arg=arg.Next;
                argNum=argNum+1;
            end

        end
    end

    methods(Access=private)






        function handleMultipleAssignemnt(this,assignNode,lValNodes)


            ret=assignNode.Left.first;
            if strcmp(ret.kind,'LB')
                ret=ret.Arg.first;
            end

            returnReassignment='';
            varNum=0;
            while~isempty(ret)
                varNum=varNum+1;

                lhsVarNode=lValNodes{varNum};
                if~isempty(lhsVarNode)&&~strcmp(lhsVarNode.kind,'NOT')
                    lhsVarName=lhsVarNode.tree2str(0,1,{});
                    if any(strcmp(lhsVarName,this.inputParamNames))
                        this.reassignVars=[this.reassignVars,lhsVarName];
                    end
                else
                    lhsVarName='~';
                end


                if strcmp(lhsVarName,'~')

                elseif this.mtreeAttributes(lhsVarNode).IsCastRedundant
                    if this.mtreeAttributes(lhsVarNode).UseColonSyntax
                        lhsStr=lhsVarNode.tree2str(0,1,this.replacements);
                        annotatedLhsStr=[lhsStr,'(:)'];
                        this.replace(lhsVarNode,annotatedLhsStr);
                    end
                else
                    varInfo=getIDType(this,lhsVarNode);

                    if isempty(varInfo)
                        return;
                    end


                    retStr=this.tree2str(ret);

                    if this.DoubleToSingle
                        if strcmp(lhsVarNode.kind,'ID')
                            retLocal=this.namingService.distinguishName([lhsVarName,'_tmp']);
                        else
                            retLocal=this.namingService.distinguishName('fmo_');
                        end
                    else
                        retLocal=this.namingService.distinguishName('fmo_');
                    end

                    this.replace(ret,retLocal);

                    if varInfo.isStruct()
                        convertedFlag=false;
                        if strcmp(assignNode.Right.kind,'CALL')
                            callNode=assignNode.Right;
                            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
                            if~isempty(calleeFcnInfo)
                                newLHSVarName=retLocal;
                                lhsVarInfo=varInfo;
                                if varNum>length(calleeFcnInfo.outputVarNames)&&...
                                    strcmp(calleeFcnInfo.outputVarNames{end},'varargout')






                                    [fcnStr,fcnName,~]=this.givenSingularStructVarInfoCreateCopyFcn(lhsVarInfo);
                                    if~isempty(fcnStr)&&~isempty(fcnName)
                                        this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                                        returnReassignment{end+1}=[retStr,' = ',fcnName,'(',newLHSVarName,');'];%#ok<AGROW>
                                    end
                                else
                                    fcnOutVarName=calleeFcnInfo.outputVarNames{varNum};
                                    fcnOutVarInfo=calleeFcnInfo.getVarInfo(fcnOutVarName);

                                    if~isempty(fcnOutVarInfo)
                                        rhsCallVarInfo=fcnOutVarInfo.clone;
                                        rhsCallVarInfo.setSymbolName(newLHSVarName);

                                        [isCopyFcnNeeded,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,lhsVarInfo,rhsCallVarInfo,this,this.uniqueNamesService);
                                        if isCopyFcnNeeded
                                            returnReassignment{end+1}=[retStr,' = ',fcnName,'(',newLHSVarName,');'];%#ok<AGROW>
                                            this.structCopyHandler.addCopyStruct(fcnName,fcnStr);

                                        else
                                            returnReassignment{end+1}=[retStr,' = ',newLHSVarName,';'];%#ok<AGROW>
                                        end
                                        convertedFlag=true;
                                    end
                                end
                            end
                        end





                        if~convertedFlag




                            lhsVarInfo=varInfo;

                            psuedoRhsVarInfo=lhsVarInfo.clone;
                            psuedoRhsVarInfo.setSymbolName(retLocal);

                            isCopyFcnNeeded=true;
                            [~,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,lhsVarInfo,psuedoRhsVarInfo,this,this.uniqueNamesService,isCopyFcnNeeded);
                            returnReassignment{end+1}=[retStr,' = ',fcnName,'(',retLocal,');'];%#ok<AGROW>
                            this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                        end
                    else
                        if~isempty(varInfo)&&varInfo.needsFiCast()
                            annotatedRhsStr=this.encloseCodeWithFiCast(retLocal,varInfo,ret);
                        else
                            annotatedRhsStr=retLocal;
                        end

                        retLocalAssignment=[retStr,' = ',annotatedRhsStr,';'];
                        returnReassignment{end+1}=retLocalAssignment;%#ok<AGROW> 
                    end
                end

                ret=ret.Next;
            end

            if~isempty(returnReassignment)
                assignStr=assignNode.tree2str(0,1,this.replacements);
                [indentStr,sameLine]=assignNode.getOriginalIndentString();
                if~sameLine
                    returnReassignmentStr=strjoin(returnReassignment,[newline,indentStr]);
                    assignStr=[assignStr,';',newline,indentStr,returnReassignmentStr];
                else
                    returnReassignmentStr=strjoin(returnReassignment,' ');
                    assignStr=[assignStr,'; ',returnReassignmentStr];
                end

                parent=assignNode.Parent;
                this.replacements{end+1}=parent;
                this.replacements{end+1}=assignStr;
            else

            end

        end

        function handleSingleAssigment(this,assignNode,lValNodes)
            rhs=assignNode.Right;
            lhs=assignNode.Left;
            lhsVarNode=lValNodes{1};
            [varInfo,baseVarInfo]=getIDType(this,lhsVarNode);

            if isMatrixDeletion(assignNode)


                return;
            end

            if strcmp(lhsVarNode.kind,'ID')||(~isempty(baseVarInfo)&&baseVarInfo.isStruct())
                if(~isempty(baseVarInfo)&&baseVarInfo.isStruct())


                    lhsRootVarName=baseVarInfo.SymbolName;
                else
                    lhsRootVarName=lhsVarNode.string;
                end
                if any(strcmp(lhsRootVarName,this.inputParamNames))
                    this.reassignVars=[this.reassignVars,lhsRootVarName];
                end
            end

            if strcmp(rhs.kind,'SUBSCR')&&coder.internal.translator.Phase.isCoderLoad(rhs)
                handleCoderLoad(lhs,rhs,assignNode,varInfo);
            else
                defaultSingleAssignmentHandler(rhs,varInfo);
            end


            function defaultSingleAssignmentHandler(rhs,lVarInfo)

                if isempty(lVarInfo)

                    return;
                end

                if lVarInfo.isStruct()

                    return;
                end

                fiCastFiVars=this.fxpConversionSettings.fiCastFiVars;
                fiCastIntVars=this.fxpConversionSettings.fiCastIntegers;
                fiCastDoubleLiteralVars=this.fxpConversionSettings.fiCastDoubleLiteralVars;

                emitFiCast=lVarInfo.needsFiCast(fiCastFiVars,fiCastIntVars,fiCastDoubleLiteralVars);
                requiresCoderConst=false;
                if this.mtreeAttributes(lhs).IsCastRedundant
                    emitFiCast=false;
                    if this.mtreeAttributes(lhs).UseColonSyntax
                        lhsStr=lhs.tree2str(0,1,this.replacements);
                        annotatedLhsStr=[lhsStr,'(:)'];
                        this.replace(lhs,annotatedLhsStr);
                    end
                else
                    if coder.internal.f2ffeature('AnalyzeConstants')


                        if~emitFiCast



                            if lVarInfo.isLiteralDoubleConstant
                                requiresCoderConst=true;
                            end
                        end
                    end
                end

                if emitFiCast
                    rhsStr=rhs.tree2str(0,1,this.replacements);
                    annotatedRhsStr=this.encloseCodeWithFiCast(rhsStr,lVarInfo,rhs);
                    this.replace(rhs,annotatedRhsStr);
                else
                    if coder.internal.f2ffeature('AnalyzeConstants')
                        if requiresCoderConst
                            rhsStr=rhs.tree2str(0,1,this.replacements);
                            annotatedRhsStr=sprintf('coder.const(%s)',rhsStr);
                            this.replace(rhs,annotatedRhsStr);
                        end
                    end
                end
            end

            function handleCoderLoad(lhs,~,assignNode,lVarInfo)




                tempName=this.namingService.distinguishName(lhs.string);
                actualName=lhs.tree2str(0,1,this.replacements);

                [indentStr,sameLine]=lhs.getOriginalIndentString();
                origLhsStr=this.tree2str(lhs);
                this.replace(lhs,tempName);
                modStmt=this.tree2str(assignNode);

                if lVarInfo.isStruct()
                    rhsVarInfo=lVarInfo.clone();
                    rhsVarInfo.setSymbolName(tempName);

                    disableCastOptimization=true;
                    [~,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,lVarInfo,rhsVarInfo,this,this.uniqueNamesService,disableCastOptimization);

                    reassignStmt=[indentStr,origLhsStr,' = ',fcnName,'(',tempName,')'];
                    this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                else
                    fiCastTempStr=this.encloseCodeWithFiCast(tempName,lVarInfo,[]);
                    reassignStmt=[indentStr,actualName,' = ',fiCastTempStr];
                end
                if~sameLine
                    this.replace(assignNode,[modStmt,';',newline,reassignStmt]);
                else
                    this.replace(assignNode,[modStmt,';',reassignStmt]);
                end
            end

            function res=isMatrixDeletion(assignNode)
                res=this.isLiteralEmptyMatrix(assignNode.Right)&&this.isIndexingExpr(assignNode.Left);
            end
        end

        function handleNullCopy(this,subScrNode,lValNodes)
            lhsVarNode=lValNodes{1};
            if~isempty(lhsVarNode)&&this.treeAttributes(lhsVarNode).IsCastRedundant


                return;
            end

            varInfo=getIDType(this,lhsVarNode);

            exprNode=subScrNode.Right;
            exprNodeStr=exprNode.tree2str(0,1,this.replacements);
            annotatedExprStr=this.encloseCodeWithFiCast(exprNodeStr,varInfo,exprNode);
            this.replace(exprNode,annotatedExprStr);
        end












        function transformForLoopIndex(this,forNode)
            body=forNode.Body;
            indexNode=forNode.Index;
            index=indexNode.string;
            indexIntVar=[index,'_iter'];
            this.replace(indexNode,indexIntVar);

            varInfo=this.functionTypeInfo.getVarInfo(indexNode);

            castStmtTxt=this.encloseCodeWithFiCast(indexIntVar,varInfo,indexNode);
            castStmtTxt=[index,' = ',castStmtTxt,';'];


            indentStr=' ';
            sameLine=true;

            if~isempty(body)
                [indentStr,sameLine]=body.getOriginalIndentString();
                if sameLine
                    indentStr=' ';
                end
            end

            proposedType=varInfo.proposed_Type;
            isFixed=(isnumerictype(proposedType)&&proposedType.isfixed);
            if(isFixed&&body.isempty)






                this.replace(forNode.Vector,[tree2str(forNode.Vector),newline,indentStr,castStmtTxt,newline]);
            elseif~isempty(body)
                firstStmt=body;
                firstStmtStr=firstStmt.tree2str(0,1,this.replacements);
                if sameLine
                    firstStmtStr=[castStmtTxt,indentStr,firstStmtStr];
                else
                    firstStmtStr=[castStmtTxt,newline,indentStr,firstStmtStr];
                end
                this.replace(firstStmt,firstStmtStr);
            end
        end

        function encloseWithFiCastIfNeeded(this,baseVarInfo,arg)
            if~isempty(baseVarInfo)&&...
                ~isempty(baseVarInfo.userSpecifiedAnnotation)&&...
                ~isequal(baseVarInfo.userSpecifiedAnnotation,baseVarInfo.proposed_Type)
                argStr=arg.tree2str(0,1,this.replacements);
                annotatedRhsStr=this.encloseCodeWithFiCast(argStr,baseVarInfo,arg);
                this.replace(arg,annotatedRhsStr);
            end
        end
    end
end
