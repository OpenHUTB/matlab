classdef Phase<coder.internal.MTreeVisitor





    properties(Access=public)
functionMTree
functionTypeInfo
functionTypeInfoRegistry
typeProposalSettings
fxpConversionSettings
fiOperatorMapper



autoReplaceHndlr
structCopyHandler

expressionTypes






globalUniqNameMap



uniqueNamesService



fimathFcnName



        emittedFiCast;



        emitFiMathFcn=false;
    end

    properties(Access=protected)
inputParamNames
outputParamNames

replacements
indentLevel

globalFimathStr
globalFimath
fiMathVarName

debugEnabled
mtreeAttributes

messages


globalVarIDs


TranslatorData
    end

    properties(Access=private)



replacementsStack

replacementSnapshots
    end

    properties(Constant)
        DEAD='dead';
        CFOLD='cfold';
        FIMATHFCNNAME='get_fimath';
    end

    methods
        function set.emittedFiCast(this,val)
            this.emittedFiCast=val;
        end
    end

    methods(Access=public)
        function phase=Phase(translatorData)
            phase=phase@coder.internal.MTreeVisitor(translatorData.MtreeAttributes);
            phase.functionMTree=translatorData.Tree;
            phase.replacements=translatorData.Replacements;
            phase.mtreeAttributes=translatorData.MtreeAttributes;
            phase.functionTypeInfo=translatorData.FunctionTypeInfo;
            phase.functionTypeInfoRegistry=translatorData.FunctionTypeInfoRegistry;
            phase.typeProposalSettings=translatorData.TypeProposalSettings;
            phase.fxpConversionSettings=translatorData.FxpConversionSettings;

            phase.globalFimathStr=translatorData.FxpConversionSettings.globalFimathStr;
            phase.globalFimath=eval(phase.globalFimathStr);
            phase.fiMathVarName=translatorData.FxpConversionSettings.fiMathVarName;

            phase.fiOperatorMapper=translatorData.FiOperatorMapper;
            phase.autoReplaceHndlr=translatorData.AutoReplaceHndlr;
            phase.structCopyHandler=translatorData.StructCopyHandler;
            phase.uniqueNamesService=translatorData.UniqueNamesService;
            phase.indentLevel=0;
            phase.debugEnabled=translatorData.FxpConversionSettings.debugEnabled;
            phase.replacementsStack={};
            phase.messages=coder.internal.lib.Message.empty();
            phase.inputParamNames=phase.functionTypeInfo.inputVarNames;
            phase.outputParamNames=phase.functionTypeInfo.outputVarNames;

            phase.expressionTypes=translatorData.ExpressionTypes;
            phase.globalUniqNameMap=translatorData.GlobalUniqNameMap;
            phase.globalVarIDs={};
            phase.fimathFcnName=translatorData.FimathFcnName;
            phase.emittedFiCast=false;
        end

        function[replacements,messages]=run(this,indentLevel)
            if nargin>=2
                this.indentLevel=indentLevel;
            end
            messages={};
            this.visit(this.functionMTree,[]);
            replacements=this.replacements;
        end

        function description=nodeDescription(this,node)
            link=coder.internal.Helper.getLinkFcn(this.functionTypeInfo.scriptPath,node);
            switch node.kind
            case 'LDIV'
                description=link{1}('mldivide function(operator ''\'')');
            otherwise
                description=link{1}(['',node.kind,'',' node']);
            end
        end

        function res=isANumericalType(~,mxInfo)
            assert(isa(mxInfo,'eml.MxInfo'));
            res=any(strcmp(mxInfo.Class,coder.internal.VarTypeInfo.MLNUMERICTYPES));
        end

        function mxInfo=getMxInfo(this,expr)
            mxInfo=[];
            compiledMxLocInfo=this.mtreeAttributes(expr).CompiledMxLocInfo;
            if~isempty(compiledMxLocInfo)
                mxInfo=this.functionTypeInfoRegistry.mxInfos{compiledMxLocInfo.MxInfoID};
            end
        end

        function typeInfo=getOriginalInferredTypeInfo(this,node)
            typeInfo=[];
            mxTypeInfo=this.getMxInfo(node);
            if~isempty(mxTypeInfo)
                typeInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(mxTypeInfo,this.functionTypeInfoRegistry.mxArrays);
            end
        end

        function tag=getTagFromClassname(~,className)
            tmp=coder.internal.translator.F2FMTree('');
            switch className
            case 'double'
                tag=tmp.DOUBLE;
            case 'embedded.fi'
                tag=tmp.FIXPT;
            case{'int8','uint8','int16','uint16',...
                'int32','uint32','int64','uint64'}
                tag=tmp.INT;
            case 'char'
                tag=tmp.CHAR;
            case 'logical'
                tag=tmp.BOOLEAN;
            case 'struct'
                tag=tmp.STRUCT;
            otherwise
                tag=tmp.UNKNOWN;
            end
        end

        function tag=getTagFromValue(this,value)
            className=class(value);
            tag=this.getTagFromClassname(className);
        end

        function tag=getOriginalTag(this,varInfo)
            if varInfo.isEnum()
                tmp=coder.internal.translator.F2FMTree('');
                tag=tmp.ENUM;
                return;
            end
            className=varInfo.inferred_Type.Class;
            tag=this.getTagFromClassname(className);
        end

        function tag=getTag(this,node,lType,rType,varargin)
            nodeKind=node.kind();
            if strcmp(nodeKind,'CALL')
                assert(any(ismember({'complex'},node.Left.string)));
            else
                assert(any(ismember({'DIV','MUL','PLUS','MINUS','LDIV','DOTMUL','DOTLDIV','COLON'},nodeKind)));
            end

            if strcmp(nodeKind,'COLON')&&~isempty(varargin)



                stepType=varargin{1};
                tmpTag=this.getTag(node,lType,stepType);
                tag=this.getTag(node,tmpTag,rType);
            else
                tag=node.UNKNOWN;
                if lType==node.DOUBLE||rType==node.DOUBLE
                    tag=node.DOUBLE;
                end
                if lType==node.INT||rType==node.INT
                    tag=node.INT;
                end
                if lType==node.FIXPT||rType==node.FIXPT
                    tag=node.FIXPT;
                end
            end
        end


        function[hasFi,doubleNs,doubleNids,argTags,lastArg]=visitArgList(this,arg,input)
            doubleNs={};
            doubleNids=[];
            hasFi=false;
            argTags=[];
            lastArg=arg;
            ii=0;
            while~isempty(arg)
                ii=ii+1;
                lastArg=arg;
                in=input;
                argOp=this.visit(arg,in);
                argTags(end+1)=argOp.tag;
                if argOp.tag==arg.DOUBLE
                    doubleNs{end+1}=arg;
                    doubleNids(end+1)=ii;
                end
                hasFi=hasFi||argOp.tag==arg.FIXPT;
                arg=arg.Next;
            end
        end

        function output=visit(this,node,in)
            try
                output=this.visit@coder.internal.MTreeVisitor(node,in);
            catch ex
                if(strcmp(ex.identifier,'MATLAB:noSuchMethodOrField'))
                    if isprop(this,'functionTypeInfo')&&ismethod(this,'nodeDescription')

                        link=coder.internal.Helper.getLinkFcn(this.functionTypeInfo.scriptPath,node);
                        disp(message('Coder:FxpConvDisp:FXPCONVDISP:convLineNoErr',link{1}(int2str(node.lineno)),int2str(node.charno)).getString);
                        error(message('Coder:FXPCONV:UnhandledNodeEncountered',coder.internal.Helper.getPrintLinkStr(this.functionTypeInfo.scriptPath,node),this.nodeDescription(node)));
                    else
                        error(message('Coder:FXPCONV:UnhandledNodeEncounteredUpdated',node.tree2str(0,1)));
                    end
                elseif~isempty(strfind(ex.identifier,'Coder:'))
                    rethrow(ex);
                else
                    disp(coder.internal.Helper.getPrintLinkStr(this.functionTypeInfo.scriptPath,node));
                    disp(message('Coder:FxpConvDisp:FXPCONVDISP:convLineNoErr',int2str(node.lineno),int2str(node.charno)).getString);
                    error(message('Coder:FXPCONV:UnHandledException'));
                end
            end
        end

        function r=DoubleToSingle(this)
            r=this.typeProposalSettings.DoubleToSingle;
        end

    end


    methods(Access=public)


        function output=visitFUNCTION(this,functionNode,input)
            [inParamNames,outParamNames]=coder.internal.MTREEUtils.fcnInputOutputParamNames(functionNode);
            if this.fxpConversionSettings.detectDeadCode&&~this.treeAttributes(functionNode).isExecutedInSimulation
                output.tag=functionNode.UNDEF;
            else
                assert(all(strcmp(inParamNames,this.inputParamNames)));
                assert(all(strcmp(outParamNames,this.outputParamNames)));

                output=visitFUNCTION@coder.internal.MTreeVisitor(this,functionNode,input);
            end
            cellfun(@(n)this.registerUniqueName(n),union(inParamNames,outParamNames));
        end


        function output=visitGLOBAL(this,globalNode,~)
            output=globalNode.UNDEF;
            this.globalVarIDs=[this.globalVarIDs{:},strings(globalNode.Arg.list)];



            this.visitNodeList(globalNode.Arg,[]);
        end


        function output=visitPARENS(visitor,node,input)
            output=visitor.visit(node.Arg,input);
        end

        function output=visitNodeList(visitor,nodeList,input)
            output=[];
            node=nodeList;
            while~isempty(node)
                output=visitor.visit(node,input);
                node=node.Next;
            end
        end

        function output=visitSUBSCR(this,subScrNode,input)
            output=[];
            vector=subScrNode.Left;
            this.visit(vector,input);

            index=subScrNode.Right;
            this.visitNodeList(index,input);
        end


        function output=visitAT(~,node,~)
            output.tag=node.UNDEF;
        end
    end

    methods(Access=public)
        function cstr=wrapCodeWithType(this,codeStr,numericType,fimathStr,varInfo)
            if nargin<5
                varInfo=[];
            end
            if nargin<4
                fimathStr=this.fiMathVarName;
            end

            if this.fxpConversionSettings.DoubleToSingle
                if~isempty(varInfo)&&isa(varInfo,'coder.internal.VarTypeInfo')
                    if strcmp(strtrim(codeStr),varInfo.SymbolName)


                        cstr=codeStr;
                    else
                        cstr=sprintf('%s(%s)',varInfo.annotated_Type,codeStr);
                    end
                else
                    cstr=sprintf('single(%s)',codeStr);
                end
                return;
            end

            specializedVar=isa(varInfo,'coder.internal.VarTypeInfo')&&varInfo.isSpecialized();

            if this.fxpConversionSettings.GenerateParametrizedCode&&~isempty(varInfo)&&~specializedVar
                tyesTableVar=this.functionTypeInfo.typesTableName;
                if isa(varInfo,'coder.internal.VarTypeInfo')
                    cstr=sprintf('cast(%s, ''like'', %s.%s)',codeStr,tyesTableVar,varInfo.SymbolName);
                else

                    node=varInfo;

                    typeStr=sprintf('fi([], %d, %3d, %3d, %s)',numericType.Signed,numericType.WordLength,numericType.FractionLength,fimathStr);
                    if this.expressionTypes.isKey(typeStr)
                        entry=this.expressionTypes(typeStr);
                    else
                        entry.TypesTableField=sprintf('T%02d',length(this.expressionTypes)+1);
                        entry.AppliesTo=containers.Map();
                    end
                    cstr=sprintf('cast(%s, ''like'', %s.%s)',codeStr,tyesTableVar,entry.TypesTableField);
                    entry.AppliesTo(codeStr)=true;
                    this.expressionTypes(typeStr)=entry;
                end
                this.emittedFiCast=true;
            else
                fideclBody=sprintf('%s, %d, %d, %d, %s',codeStr,numericType.Signed,numericType.WordLength,numericType.FractionLength,fimathStr);
                if this.fxpConversionSettings.detectFixptOverflows
                    switch coder.FixPtConfig.FixptOverflowDetectionStrategy
                    case coder.FixPtConfig.FixptODS_ScaledDoubleInFixedPointCode
                        cstr=sprintf('fi(%s, ''DataType'', ''ScaledDouble'')',fideclBody);
                    case coder.FixPtConfig.FixptODS_DataTypeOverride
                        cstr=sprintf('fi(%s)',fideclBody);
                    case coder.FixPtConfig.FixptODS_FiCastFunction
                        cstr=sprintf('ficast(%s)',fideclBody);
                    otherwise
                        assert(false);
                    end
                else
                    cstr=sprintf('fi(%s)',fideclBody);
                end
                this.emittedFiCast=true;
            end

        end

        function fmStr=emitFiMathStr(this)
            fmStr='';
            if~this.fxpConversionSettings.DoubleToSingle
                if this.fxpConversionSettings.EmitSeperateFimathFunction
                    fmStr=sprintf('%s = %s();',this.fiMathVarName,this.fimathFcnName);
                else
                    fmStr=sprintf('%s = %s;',this.fiMathVarName,this.globalFimathStr);
                end
            end
        end
    end

    methods(Access=protected)


        function ret=isSingleAssignmentNode(this,assignNode)
            this.debugAssert(@()strcmp(assignNode.kind,'EQUALS'));

            lhsNodes=assignNode.lhs;
            ret=(1==lhsNodes.count);
        end



        function ret=isOutputVariable(this,varName)
            assert(ischar(varName));
            ret=any(strcmp(varName,this.outputParamNames));
        end



        function ret=isInputVariable(this,varName)
            assert(ischar(varName));
            ret=any(strcmp(varName,this.inputParamNames));
        end


        function res=shouldTransformLoopIndex(this,indexNode)
            indexAsgnLater=this.mtreeAttributes(indexNode).ForIndexUsedLater;
            res=~isempty(indexAsgnLater)&&indexAsgnLater;
        end


        function msg=buildMessage(this,node,msgType,msgId,msgParams)
            if nargin<5
                msgParams={};
            end

            if~iscell(msgParams)
                msgParams={msgParams};
            end

            if this.DoubleToSingle
                switch msgId
                case{'Coder:FXPCONV:unsupportedFunc'}
                    msgId=[msgId,'_DTS'];
                end
            end

            msg=coder.internal.lib.Message();
            msg.functionName=this.functionTypeInfo.functionName;%#ok<*AGROW>
            if strcmp(this.functionTypeInfo.specializationName,[this.functionTypeInfo.functionName,this.fxpConversionSettings.FixPtFileNameSuffix])



                msg.specializationName=this.functionTypeInfo.functionName;
            else
                msg.specializationName=this.functionTypeInfo.specializationName;
            end
            msg.file=this.functionTypeInfo.scriptPath;
            msg.type=msgType;



            msg.position=node.position-1;
            msg.length=node.rightposition-node.position+1;

            msg.text=message(msgId,msgParams{:}).getString();
            msg.id=msgId;
            msg.params=msgParams;

            msg.node.lineno=node.lineno;
            msg.node.charno=node.charno;
            msg.node.str=node.tree2str();
        end

        function addMessage(this,msg)
            this.messages(end+1)=msg;
        end

        function[nodeMin,nodeMax]=getMinMax(this,node)
            varDesc=internal.mtree.getVarDesc(node,this.functionTypeInfo);

            if varDesc.isConst
                nodeMin=varDesc.constVal;
                nodeMax=nodeMin;
            else
                nodeMin=this.mtreeAttributes(node).SimMin;
                nodeMax=this.mtreeAttributes(node).SimMax;
            end
        end

        function res=isNodeScalar(this,node)
            res=false;
            nodeAttrib=this.mtreeAttributes(node);


            varDesc=internal.mtree.getVarDesc(node,this.functionTypeInfo);
            nodeSize=varDesc.type.Dimensions;
            if all(nodeSize==1)
                res=true;
            end

        end

        function res=isNodeComplex(this,node)
            nodeAttrib=this.mtreeAttributes(node);


            varDesc=internal.mtree.getVarDesc(node,this.functionTypeInfo);
            if isa(varDesc.type,'internal.mtree.type.UnknownType')
                res=false;
            else
                res=varDesc.type.Complex;
            end
        end

        function res=isNodeIntValued(this,node)
            nodeAttrib=this.mtreeAttributes(node);
            varDesc=internal.mtree.getVarDesc(node,this.functionTypeInfo);


            if isa(varDesc.type,'internal.mtree.type.UnknownType')
                res=true;
            elseif(nodeAttrib.IsConstant)||~isempty(varDesc.constVal)

                varDesc=internal.mtree.getVarDesc(node,this.functionTypeInfo);
                nodeVal=varDesc.constVal;
                res=all(nodeVal==floor(nodeVal));
            else

                res=nodeAttrib.IsAlwaysInteger;
            end
        end

        function res=isNodeNonNegative(this,node)
            [nodeMin,~]=this.getMinMax(node);
            res=all(nodeMin>=0);
        end



        function[isConst,cVal,constType]=getExpressionConstType(this,op)
            constType=[];
            isConst=false;
            cVal=[];
            try
                nodes=mtfind(op.Tree,'Kind',{'ID','DCALL','CALL'});
                if isempty(nodes)
                    opCode=op.tree2str(0,1,{});
                    switch opCode
                    case{':'}
                        return;
                    end
                    code=['cVal = ',opCode,';'];
                    evalc(code);
                    constType=getConstantFixPtType(this,cVal);
                    isConst=true;
                else
                    isConst=false;
                end
            catch ex %#ok<*NASGU>
                isConst=false;
            end
        end


        function type=getConstantFixPtType(this,value)


            isAlwaysInt=[];
            type=this.getFixPtTypeForValue(value,isAlwaysInt,this.typeProposalSettings);
        end


        function res=isConst(this,node)
            res=getConstType(this,node);
        end



        function[isConst,cVal,constType]=getConstType(this,op)
            constType=[];
            isConst=true;
            cVal=[];
            try
                nonConstantNodes=mtfind(op.Tree,'Kind',{'ID','DCALL','CALL','LC'});


                hasLocalPi=~isempty(this.functionTypeInfo.getVarInfo('pi'))||~isempty(this.functionTypeInfoRegistry.getFunctionTypeInfo('pi'));

                hasNonConstNodes=~isempty(nonConstantNodes);
                if~hasLocalPi&&hasNonConstNodes

                    indxs=nonConstantNodes.indices;
                    for ii=1:length(indxs)
                        node=nonConstantNodes.select(indxs(ii));
                        if strcmp(node.kind,'CALL')&&strcmp(node.Left.string,'pi')
                            hasNonConstNodes=false;
                        elseif strcmp(node.kind,'ID')&&strcmp(node.string,'pi')
                            hasNonConstNodes=false;
                        else
                            hasNonConstNodes=true;
                            break;
                        end
                    end
                end

                if strcmp(op.kind,'LC')&&(strcmp(op.kind,'CALL')&&...
                    (strcmp(string(op.Left),'ones')||strcmp(string(op.Left),'zeros')))||...
                    ~hasNonConstNodes




                    isConst=true;
                    code=['cVal = ',op.tree2str(0,1,{}),';'];
                    evalc(code);
                    constType=getConstantFixPtType(this,cVal);
                else
                    isConst=false;
                end
            catch ex %#ok<*NASGU>
                isConst=false;
            end
        end



        function output=visitBody(this,body,input)
            this.indentLevel=this.indentLevel+1;
            output=this.visitNodeList(body,input);
            this.indentLevel=this.indentLevel-1;

            output.tag=body.UNDEF;
        end


        function assertTag(this)
            if this.debugEnabled
                evalin('caller','assert(~isempty(output.tag))');
            end
        end


        function debugAssert(this,fExpr)
            if this.debugEnabled
                if isa(fExpr,'function_handle')
                    builtin('assert',fExpr());
                else
                    builtin('assert',fExpr);
                end
            end
        end




        function replmnts=getReplacementsAt(this,position)
            replmnts=this.replacementSnapshots(num2str(position));
        end

        function snapshotReplacements(this)
            this.replacementsStack{end+1}=this.replacements;
        end

        function discardSnapshot(this)
            this.replacements(end)=[];
        end

        function restoreReplacements(this)
            this.replacements=this.replacements{end};
            this.discardSnapshot();
        end



        function replace(this,node,str)
            this.replacements{end+1}=node;
            this.replacements{end+1}=str;
        end

        function str=tree2str(this,node)
            str=node.tree2str(0,1,this.replacements);
        end

        function[mapping,varArgStr]=fetchMappingAndArgs(~,mapping)
            [mapping,varArgStr]=strtok(mapping,',');
            if(~isempty(varArgStr))
                varArgStr(1)='';
            end
        end

        function mappingCallCode=getMappingCallCode(~,varArgStr,varargin)
            formatStr='';
            commaStr=', ';
            for ii=1:nargin-2
                if(2==ii)
                    formatStr=[formatStr,'('];
                end
                formatStr=[formatStr,'%s'];
                if(ii>1)
                    formatStr=[formatStr,commaStr];
                end
            end

            if(~isempty(varArgStr))
                formatStr=[formatStr,'%s',commaStr];
            end
            if(strcmp(formatStr(end-1:end),commaStr))
                formatStr(end-1:end)='';
            end
            if(ii>1)
                formatStr=[formatStr,')'];
            end
            if(~isempty(varArgStr))
                mappingCallCode=sprintf(formatStr,varargin{:},varArgStr);
            else
                mappingCallCode=sprintf(formatStr,varargin{:});
            end
        end


        function str=encloseCodeWithFiCast(this,code,type,node)
            str=code;

            if isempty(type)||strcmp(type.inferred_Type.Class,'struct')
                str=sprintf('%s',code);
                return
            end

            if~type.isFimathSet()
                fmDecl=this.fxpConversionSettings.fiMathVarName;
            else
                baseFimath=this.globalFimath;
                varFimath=type.getFimath();
                fmDecl=sprintf('%s, %s',this.fxpConversionSettings.fiMathVarName,coder.internal.Helper.diffFimathString(varFimath,baseFimath));
            end

            if~isempty(node)
                [isConst,~,~]=getConstType(this,node);
            else
                isConst=false;
            end

            if~isempty(type.annotated_Type)&&isnumerictype(type.annotated_Type)&&type.annotated_Type.FractionLength==1000




                try
                    value=eval(code);
                    if isnumeric(value)
                        type.annotated_Type=this.getConstantFixPtType(value);
                    end
                catch ex

                end
            end

            if isempty(type.annotated_Type)
                if~isConst&&~isempty(node)

                    this.addMessage(this.buildMessage(node,coder.internal.lib.Message.USRLOG,'Coder:FxpConvDisp:FXPCONVDISP:propType4ExprNotFound',{code}));
                end
                return;
            end
            str=this.wrapCodeWithType(code,type.annotated_Type,fmDecl,type);
        end

        function expr=getPropertyAccessExpr(this,varNode)
            expr=this.parseForStructFieldName(varNode);
        end






        function[varInfo,baseVarInfo]=getIDType(this,varNode)
            baseVarInfo=[];

            if strcmp(varNode.kind,'SUBSCR')

                [varInfo,baseVarInfo]=this.getIDType(varNode.Left);

            elseif strcmp(varNode.kind,'DOT')||strcmp(varNode.kind,'DOTLP')
                varName=tree2str(varNode);
                baseVarName=strtok(varName,'.');

                baseVarName=regexprep(strtrim(baseVarName),'\((\s)?.+(\s)?\)$','');
                baseVarInfo=this.functionTypeInfo.getVarInfo(baseVarName);

                if coder.internal.Float2FixedConverter.supportMCOSClasses
                    if~isempty(baseVarInfo)&&baseVarInfo.isMCOSClass()
                        varName=this.getPropertyAccessExpr(varNode);
                        varInfo=this.functionTypeInfo.getVarInfo(varName);
                        assert(~isempty(varInfo));
                        return;
                    end
                end

                if isempty(baseVarInfo)
                    varInfo=[];
                elseif baseVarInfo.isStruct()
                    nonIndxedVarName=this.parseForStructFieldName(varNode);

                    varInfo=baseVarInfo.getStructPropVarInfo(nonIndxedVarName);
                elseif baseVarInfo.isEnum()
                    varInfo=baseVarInfo;
                elseif baseVarInfo.isVarInSrcFixedPoint()
                    varInfo=baseVarInfo;
                elseif~isempty(baseVarInfo)

                    error(message('Coder:FXPCONV:DotIndexNotSupportForType',...
                    baseVarInfo.SymbolName,baseVarInfo.inferred_Type.Class));
                end

                assert(isempty(varInfo)||baseVarInfo.isStruct()||varInfo.isStruct()||varInfo.isEnum()||baseVarInfo.isVarInSrcFixedPoint());
            elseif strcmp(varNode.kind,'ID')
                varInfo=this.functionTypeInfo.getVarInfo(varNode);
            else
                varInfo=[];
                return;
            end
        end


        function[isUserWrittenFcn,calleeFcnInfo]=isUserWrittenFcn(this,callNode)
            this.debugAssert(@()strcmp(callNode.kind,'CALL'));
            isUserWrittenFcn=false;
            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
            if~isempty(calleeFcnInfo)
                isUserWrittenFcn=true;
            end
        end




        function[fcnStr,fcnName,tmpRhsName]=givenSingularStructVarInfoCreateCopyFcn(this,varInfo)
            fcnStr='';fcnName='';tmpRhsName='';
            if isempty(varInfo.loggedFields)||varInfo.isVarInSrcEmpty()




                return;
            end
            tmpRhsName=this.getUniqueNameLike(varInfo.SymbolName);
            tempVarInfo=varInfo.clone;
            tempVarInfo.setSymbolName(tmpRhsName);

            convertedFlag=true;

            isCopyFcnNeeded=true;
            [~,fcnStr,fcnName]=coder.internal.translator.Helper.CreateCopyStructFunction(this.fxpConversionSettings,varInfo,tempVarInfo,this,this.uniqueNamesService,isCopyFcnNeeded);
        end



        function uniqueName=getUniqueNameLike(this,name)



            uniqueName=this.uniqueNamesService.distinguishName(name);

        end

        function registerUniqueName(this,name)
            this.uniqueNamesService.distinguishName(name);
        end

        function fullStructFieldName=parseForStructFieldName(~,dotNode)
            node=dotNode;
            fieldList={};
            while(~isempty(node))
                if strcmp(node.kind,'ID')
                    fieldList{end+1}=node.string;
                    break;
                end
                assert(strcmp(node.kind,'DOT')||strcmp(node.kind,'SUBSCR')||strcmp(node.kind,'DOTLP'));
                if strcmp(node.kind,'DOT')
                    assert(strcmp(node.Right.kind,'FIELD'));
                    fieldList{end+1}=node.Right.string;
                elseif strcmp(node.kind,'DOTLP')
                    assert(strcmp(node.Right.kind,'CHARVECTOR'));
                    tmp=node.Right.string;

                    fieldList{end+1}=tmp(2:end-1);
                end
                node=node.Left;
            end
            fullStructFieldName=strjoin(fliplr(fieldList),'.');
        end

        function vector=getProperForLoopVectorFromPragmas(~,vector)
            try
                if strcmp(vector.kind,'SUBSCR')
                    switch strtrim(vector.Left.tree2str(0,1))
                    case{'coder.unroll'}
                        vector=vector.Right;
                    end
                end
            catch
            end
        end

        function setForNodeAssignedLater(this,varName,value)
            assignedForIndexNodes=this.TranslatorData.ForNodeIndices.get(varName);
            for kk=1:numel(assignedForIndexNodes)
                forIndexNode=assignedForIndexNodes{kk};
                this.mtreeAttributes(forIndexNode).ForIndexUsedLater=value;
            end
        end
    end


    methods(Static)








        function res=isIndexingExpr(node)
            res=strcmp(node.kind,'SUBSCR');
        end


        function res=isLiteralEmptyMatrix(node)
            nodeStr=node.tree2str(0,1);
            res=strcmp(strrep(strtrim(nodeStr),' ',''),'[]');
        end


        function res=isCoderLoad(node)
            res=false;
            if~strcmp(node.kind,'SUBSCR')
                return
            end
            dotNode=node.Left.mtfind('Kind','DOT','Left.Kind','ID','Left.String','coder','Right.Kind','FIELD','Right.String','load');
            if~isempty(dotNode)
                res=true;
            end
        end









        function[res,growAssgnType,lhsNode]=isGrowingAssignment(assignNode)
            res=false;
            growAssgnType=[];
            lhsNode=[];
            lhs=assignNode.Left;
            lValNodes=coder.internal.translator.Phase.getLValNodes(assignNode);

            rowItemCount=0;
            if 1==length(lValNodes)&&strcmp(lValNodes{1}.kind,'ID')
                lhsNode=lValNodes{1};
                lhsVar=string(lhsNode);
                rhs=assignNode.Right;
                if strcmp(rhs.kind,'LB')
                    row=rhs.Arg;
                    while~isempty(row)
                        rowItem=row.Arg;
                        while~isempty(rowItem)
                            rowItemCount=rowItemCount+1;
                            if strcmp(rowItem.kind,'ID')&&strcmp(string(rowItem),lhsVar)
                                res=true;
                                if 1==rowItemCount
                                    growAssgnType=1;
                                else
                                    growAssgnType=2;
                                end
                                return;
                            end
                            rowItem=rowItem.Next;
                        end
                        row=row.Next;
                    end
                end
            end
        end




        function nodes=getLValNodes(assignNode)
            assert(strcmp(assignNode.kind,'EQUALS'));
            lhsNodes=assignNode.lhs;
            nodes=cell(1,lhsNodes.count);
            indices=lhsNodes.indices;
            for ii=1:length(indices)
                node=lhsNodes.select(indices(ii));
                if strcmp(node.kind,'SUBSCR')
                    nodes{ii}=node.Left;
                elseif strcmp(node.kind,'DOT')||strcmp(node.kind,'ID')
                    nodes{ii}=node;
                elseif strcmp(node.kind,'LP')



                    nodes{ii}=node.Left;
                else
                    nodes{ii}=node;
                end
            end
        end


        function[type,alwaysInt]=getFixPtTypeForValue(value,alwaysInt,typeProposalSettings)
            if~isnumeric(value)
                type=[];
                return;
            end
            value=value(:);
            if isreal(value)
                minValue=min(value);
                maxValue=max(value);
            else


                realParts=real(value);
                imagParts=imag(value);
                minValue=min([min(realParts),min(imagParts)]);
                maxValue=max([max(realParts),max(imagParts)]);
            end
            if isempty(alwaysInt)
                alwaysInt=all(floor(value)==value);
            end
            type=coder.internal.getBestNumericTypeForVal(minValue,maxValue,alwaysInt,typeProposalSettings);
        end

        function cstr=wrapExpressionCodeWithType(code,numericType,fimathStr,detectFixptOverflows,doubleToSingle)

            if doubleToSingle
                cstr=sprintf('single(%s)',code);
                return;
            end

            fideclBody=sprintf('%s, %d, %d, %d, %s',code,numericType.Signed,numericType.WordLength,numericType.FractionLength,fimathStr);
            if detectFixptOverflows
                switch coder.FixPtConfig.FixptOverflowDetectionStrategy
                case coder.FixPtConfig.FixptODS_ScaledDoubleInFixedPointCode
                    cstr=sprintf('fi(%s, ''DataType'', ''ScaledDouble'')',fideclBody);
                case coder.FixPtConfig.FixptODS_DataTypeOverride
                    cstr=sprintf('fi(%s)',fideclBody);
                case coder.FixPtConfig.FixptODS_FiCastFunction
                    cstr=sprintf('ficast(%s)',fideclBody);
                otherwise
                    assert(false);
                end
            else
                cstr=sprintf('fi(%s)',fideclBody);
            end
        end
    end
end



