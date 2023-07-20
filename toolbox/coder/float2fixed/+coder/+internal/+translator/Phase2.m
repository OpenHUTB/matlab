
classdef Phase2<coder.internal.translator.Phase
    properties(Access=private)
lhsVarNodes
structFieldNodes
    end

    methods(Access=public)
        function phase2=Phase2(translatorData)
            phase2=phase2@coder.internal.translator.Phase(translatorData);
            phase2.TranslatorData=translatorData;
            phase2.lhsVarNodes={};
            phase2.structFieldNodes={};
        end
    end


    methods(Access=public)

        function[needsFiMathFcn,needsFiMathVar]=run(this,indentLevel)
            if nargin>=2
                this.indentLevel=indentLevel;
            end
            this.visit(this.functionMTree,[]);
            replacements=this.replacements;
            needsFiMathFcn=this.emitFiMathFcn;
            needsFiMathVar=this.emittedFiCast;

            this.TranslatorData.Replacements=replacements;
        end

        function output=visitDOT(this,dotNode,~)%#ok<INUSL>
            output=[];

            assert(~isempty(dotNode));
            if strcmp(dotNode.tree2str,'coder.varsize')
                return
            end
        end

        function output=visitCALL(this,callNode,~)
            callee=string(callNode.Left);

            output=[];
            if strcmp(callee,'struct')
                this.handleStructCall(callNode);
                output.tag=callNode.STRUCT;
            end
        end

        function output=visitID(this,idNode,~)
            output=[];
            varName=idNode.string;

            if strcmp(varName,'end')
                return;
            end

            output.varTypeInfo=this.functionTypeInfo.getVarInfo(idNode);
        end

        function output=visitNoNameVar(~,~,~)
            output=[];
        end


        function output=visitEQUALS(this,assignNode,~)
            output.tag=assignNode.UNDEF;
            assert(isempty(this.lhsVarNodes));
            clnUpObj=onCleanup(@()stateCleanup(this));

            lhs=assignNode.Left;

            this.visit(lhs,[]);

            this.lhsVarNodes=this.getLValNodes(assignNode);






            isSingleOutputAssignment=~isempty(this.lhsVarNodes)&&length(this.lhsVarNodes)==1;
            if isSingleOutputAssignment
                varInfo=getIDType(this,this.lhsVarNodes{1});

                if isempty(varInfo)||~varInfo.isStruct()
                    return;
                end

                output.tag=assignNode.STRUCT;%#ok<STRNU>


                rhs=assignNode.Right;
                output=this.visit(rhs,[]);

                if strcmp(rhs.kind,'SUBSCR')&&strcmp(rhs.Left.tree2str,'coder.nullcopy')
                    handleRhsVarInfoNotAvailable(varInfo,rhs.Right);
                    return;
                end

                rhsMxLocInfo=this.mtreeAttributes(rhs).MxLocInfo;
                if~isempty(rhsMxLocInfo)
                    mxInfo=this.functionTypeInfoRegistry.mxInfos{rhsMxLocInfo.MxInfoID};
                    isEmptyStruct=any(mxInfo.Size==0);
                    if isa(mxInfo,'eml.MxStructInfo')&&isEmptyStruct

                        return;
                    end
                end





                if this.isLiteralEmptyMatrix(rhs)

                    return;
                end



                if strcmp(rhs.kind,'CALL')
                    rhsVarInfo=getVarInfoForUserFcnCall();
                else
                    rhsVarInfo=getIDType(this,rhs);
                end



                if strcmp(rhs.kind,'LB')&&isfield(output,'varTypeInfo')&&~isempty(output.varTypeInfo)
                    rhsVarInfo=output.varTypeInfo;
                end

                if~isempty(rhsVarInfo)

                    if isGlobalVarName(varInfo.SymbolName)
                        varInfo.setSymbolName(this.globalUniqNameMap(varInfo.SymbolName));
                    end
                    if strcmp(rhs.kind,'CALL')||~isempty(this.mtreeAttributes(rhs).CalledFunction)
                        ReassignFcnOutAndExplodeReturnStructVar(rhs,varInfo)
                    else



                        if isGlobalVarName(rhsVarInfo.SymbolName)
                            rhsVarInfo.setSymbolName(this.globalUniqNameMap(rhsVarInfo.SymbolName));
                        end


                        [isCopyFcnNeeded,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,varInfo,rhsVarInfo,this,this.uniqueNamesService);
                        if isCopyFcnNeeded
                            this.emitFiMathFcn=true;
                            this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                            this.replace(rhs,[fcnName,'(',this.tree2str(rhs),')']);
                        end
                    end
                elseif strcmp(rhs.kind,'CALL')&&strcmpi(string(rhs.Left),'repmat')













                    firstArg=rhs.Right;
                    argVarInfo=getIDType(this,firstArg);
                    if~isempty(argVarInfo)
                        baseVarName=strtok(varInfo.SymbolName,'.');


                        newTmpSampleName=this.getUniqueNameLike([baseVarName,'_tmp']);
                        newTmpVarInfo=varInfo.clone();


                        newTmpVarInfo.inferred_Type=argVarInfo.inferred_Type;
                        newTmpVarInfo.setSymbolName(newTmpSampleName);

                        [isCopyFcnNeeded,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,newTmpVarInfo,argVarInfo,this,this.uniqueNamesService);
                        if isCopyFcnNeeded
                            this.emitFiMathFcn=true;
                            this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                            this.replace(firstArg,[fcnName,'(',this.tree2str(firstArg),')']);
                        end
                    else
                        handleRhsVarInfoNotAvailable(varInfo,rhs);
                    end
                else

                    isArrayofStructs=~all(ones(1,length(varInfo.inferred_Type.Size))==varInfo.inferred_Type.Size');
                    isStructConstructorCall=strcmp(rhs.kind,'CALL')&&strcmpi(string(rhs.Left),'struct');
                    hasNoCellArrayConstructs=isempty(rhs.Tree.mtfind('Kind','LC'));
                    if(isStructConstructorCall&&~isArrayofStructs&&hasNoCellArrayConstructs)...
                        ||coder.internal.translator.Phase.isCoderLoad(rhs)
                        return;
                    end





                    handleRhsVarInfoNotAvailable(varInfo,rhs);
                end
            end



            function handleRhsVarInfoNotAvailable(lhsVarInfo,rhs)
                [fcnStr,fcnName]=this.givenSingularStructVarInfoCreateCopyFcn(lhsVarInfo);
                if~isempty(fcnStr)&&~isempty(fcnName)
                    this.structCopyHandler.addCopyStruct(fcnName,fcnStr);

                    this.replace(rhs,[fcnName,'(',this.tree2str(rhs),')']);
                end
            end

            function ReassignFcnOutAndExplodeReturnStructVar(callNode,lhsVarInfo)

                convertedFlag=false;

                callee=string(callNode.Left);
                calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
                if~isempty(calleeFcnInfo)
                    fcnOutVarName=calleeFcnInfo.outputVarNames{1};
                    fcnOutVarInfo=calleeFcnInfo.getVarInfo(fcnOutVarName);

                    if~isempty(fcnOutVarInfo)
                        tmpRhsName=this.getUniqueNameLike([callee,'_return']);
                        rhsCallVarInfo=fcnOutVarInfo.clone;
                        rhsCallVarInfo.setSymbolName(tmpRhsName);

                        convertedFlag=true;

                        [isCopyFcnNeeded,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,lhsVarInfo,rhsCallVarInfo,this,this.uniqueNamesService);
                        if isCopyFcnNeeded
                            this.emitFiMathFcn=true;
                            this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                            this.replace(rhs,[fcnName,'(',this.tree2str(rhs),')']);
                        end
                    end
                end

















                if~convertedFlag
                    convertedFlag=true;%#ok<NASGU>
                    [fcnStr,fcnName]=this.givenSingularStructVarInfoCreateCopyFcn(lhsVarInfo);
                    if~isempty(fcnStr)&&~isempty(fcnName)
                        this.structCopyHandler.addCopyStruct(fcnName,fcnStr);

                        origLhsStr=this.tree2str(lhs);
                        this.replace(lhs,tmpRhsName);
                        newAssgnStmt=[this.tree2str(assignNode),';',newline...
                        ,origLhsStr,' = ',fcnName,'(',tmpRhsName,')'];
                        this.replace(assignNode,newAssgnStmt);
                    end
                end
            end

            function varInfo=getVarInfoForUserFcnCall()
                varInfo=[];
                [isUserWrittenFcn,calleeFcnInfo]=this.isUserWrittenFcn(rhs);
                if isUserWrittenFcn
                    opVarName=calleeFcnInfo.outputVarNames{1};
                    varInfo=calleeFcnInfo.getVarInfo(opVarName);
                end
            end

            function res=isGlobalVarName(name)
                res=this.globalUniqNameMap.isKey(name);
            end

            function stateCleanup(that)
                assert(isempty(that.structFieldNodes));
                that.lhsVarNodes={};
            end
        end
    end

    methods(Access=private)





        function handleStructCall(this,callNode)




            if isempty(this.lhsVarNodes)
                return;
            end
            lhsVarNode=this.lhsVarNodes{end};
            varInfo=getIDType(this,lhsVarNode);


            isArrayofStructs=~all(ones(1,length(varInfo.inferred_Type.Size))==varInfo.inferred_Type.Size');
            if isArrayofStructs||~isempty(callNode.Tree.mtfind('Kind','LC'))




                return;
            end

            arg=callNode.Right;
            argCount=1;
            while(~isempty(arg))
                if(rem(argCount,2)==0)
                    prop=getFullPropName(this);
                    propVarInfo=varInfo.getStructPropVarInfo([varInfo.SymbolName,'.',prop]);

                    op=this.visit(arg,[]);

                    if isfield(op,'varTypeInfo')&&~isempty(op.varTypeInfo)
                        [isCopyFcnNeeded,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,propVarInfo,op.varTypeInfo,this,this.uniqueNamesService);
                        if isCopyFcnNeeded
                            this.emitFiMathFcn=true;
                            this.structCopyHandler.addCopyStruct(fcnName,fcnStr);
                            this.replace(arg,[fcnName,'(',this.tree2str(arg),')']);
                        end
                    end

                    if~isempty(propVarInfo)&&propVarInfo.needsFiCast()
                        argStr=arg.tree2str(0,1,this.replacements);
                        annotatedArgStr=this.encloseCodeWithFiCast(argStr,propVarInfo,arg);
                        this.replace(arg,annotatedArgStr);
                    end
                    this.structFieldNodes(end)=[];
                else
                    try
                        if~isempty(this.structFieldNodes)&&isempty(this.structFieldNodes{end})
                            this.structFieldNodes{end}=strtrim(eval(tree2str(arg)));
                        else
                            this.structFieldNodes{end+1}=strtrim(eval(tree2str(arg)));
                        end
                    catch ex %#ok<NASGU>



                        this.structFieldNodes{end+1}='';
                    end
                end
                arg=arg.Next;
                argCount=argCount+1;
            end

            function propName=getFullPropName(that)
                propName='';
                for ii=1:length(that.structFieldNodes)
                    propName=strcat(propName,'.',that.structFieldNodes{ii});
                end
                if~isempty(propName)
                    propName(1)='';
                end
            end
        end
    end
end