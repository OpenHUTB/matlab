



classdef Phase1<coder.internal.translator.Phase
    properties(Constant)
        NO_TEST_CASE='No unit test case written';
        TAG_NOT_ANALYSED='The output type is not analysed here';
        INCONSISTENT_TYPES='The types here at unexpected';
        POTENTIAL_ISSUE='A potential issue with mex';
        FICAST_FAILED='failed to fi-castv';

        DISP='Display';
        WARN='Warning';
        ERR='Error';
    end

    properties(Access=private)
loopIndexVarType
autoScaleLoopIndexVars
lValNodes


autoReplaceCfgs


lbNodeId



isInTryFiCastingMode
    end

    methods(Access=public)
        function phase1=Phase1(translatorData)
            phase1=phase1@coder.internal.translator.Phase(translatorData);
            phase1.TranslatorData=translatorData;
            phase1.loopIndexVarType=coder.internal.lib.Map();
            phase1.autoScaleLoopIndexVars=translatorData.FxpConversionSettings.autoScaleLoopIndexVars;
            phase1.lValNodes={};

            phase1.autoReplaceCfgs=translatorData.FxpConversionSettings.autoReplaceCfgs;
            phase1.lbNodeId=[];
            phase1.isInTryFiCastingMode=false;
            import coder.internal.translator.*;
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
            needsFiMathFcn=this.emittedFiCast;

            this.TranslatorData.Replacements=replacements;
        end

        function output=visit(this,node,input)
            this.removeReplacement(node);
            output=visit@coder.internal.translator.Phase(this,node,input);
        end


        function output=visitFUNCTION(this,functionNode,input)
            output=this.visitBody(functionNode.Body,input);
        end


        function output=visitEQUALS(this,assignNode,input)
            this.lValNodes=assignNode.lhs;

            lhs=assignNode.Left;
            this.visit(lhs,input);


            this.lValNodes=null(mtree(''));
            rhs=assignNode.Right;
            output=this.visit(rhs,input);
        end


        function output=visitPARENS(visitor,node,input)
            output=visitor.visit(node.Arg,input);

            assertTag(visitor);
        end





        function output=visitNoNameVar(this,tildeNode,input)%#ok<INUSD>
            output.tag=tildeNode.UNDEF;

            assertTag(this);
        end


        function output=visitID(this,idNode,~)
            output=[];

            varName=idNode.string;


            if strcmp(varName,'end')
                return;
            end

            varInfo=this.functionTypeInfo.getVarInfo(idNode);
            if~isempty(varInfo)&&isempty(varInfo.annotated_Type)







                varInfo=[];
            end

            fiCastIntVars=this.fxpConversionSettings.fiCastIntegers;
            fiCastDoubleLiteralVars=this.fxpConversionSettings.fiCastDoubleLiteralVars;



            isGlobal=any(ismember(this.globalVarIDs,varName));
            isNeedGlbPsuedoName=this.globalUniqNameMap.isKey(varName);
            if isGlobal&&isNeedGlbPsuedoName








                psuedoName=this.globalUniqNameMap(varName);
                this.debugAssert(@()~isempty(psuedoName));
                this.replace(idNode,psuedoName);
            end

            if~isempty(varInfo)
                output.tag=idNode.FIXPT;
                if~isempty(this.lValNodes)
                    isaLValNode=anymember(this.lValNodes,idNode);
                else
                    isaLValNode=false;
                end
                if varInfo.isCoderConst
                    output.tag=this.getOriginalTag(varInfo);




                elseif~isaLValNode&&~this.autoScaleLoopIndexVars&&this.loopIndexVarType.isKey(varName)&&~strcmp(idNode.Parent.kind,'EQUALS')





                    output.tag=this.loopIndexVarType(varName);


                elseif varInfo.isEnum()
                    output.tag=idNode.ENUM;
                elseif varInfo.isVarInSrcFixedPoint()


                    output.tag=idNode.FIXPT;
                elseif varInfo.isVarInSrcInteger()&&~fiCastIntVars


                    output.tag=idNode.INT;
                elseif varInfo.isVarInSrcBoolean()||varInfo.isVarInSrcSystemObj

                    output.tag=idNode.BOOLEAN;
                elseif~fiCastDoubleLiteralVars&&varInfo.isLiteralDoubleConstant
                    output.tag=getOriginalTag(this,varInfo);
                end
                output.varTypeInfo=varInfo;
                if this.DoubleToSingle()&&varInfo.isNumericVar()
                    type=varInfo.annotated_Type;
                    if ischar(type)&&strcmp(type,this.typeProposalSettings.Config.IndexType)
                        output.tag=idNode.INT;
                    end
                end

                if~varInfo.isNumericVar()
                    output.tag=this.getOriginalTag(varInfo);
                end
            else
                output.tag=idNode.UNDEF;
            end

            assertTag(this);
        end


        function output=visitLITERAL(this,node,input)
            output=[];

            if isfield(input,'fiCastConst')
                fiCastConst=input.fiCastConst;
            else
                fiCastConst=false;
            end



            if strcmp(node.kind,'DOUBLE')
                if fiCastConst
                    handleFiCastINTOrDOUBLE(this,node);
                    output.tag=node.FIXPT;
                else
                    output.tag=node.DOUBLE;
                end
            end

            if strcmp(node.kind,'INT')
                if fiCastConst
                    handleFiCastINTOrDOUBLE(this,node);
                    output.tag=node.FIXPT;
                else
                    output.tag=node.DOUBLE;
                end
            end







            if strcmp(node.kind,'HEX')
                handleFiCastHEX(this,node);
                output.tag=node.FIXPT;
            end

            if strcmp(node.kind,'BINARY')
                handleFiCastBINARY(this,node);
                output.tag=node.FIXPT;
            end

            if strcmp(node.kind,'CHARVECTOR')||strcmp(node.kind,'STRING')
                output.tag=node.CHAR;
            end

            assertTag(this);
        end


        function output=visitUNEXPR(this,unaryExpr,input)
            expr=unaryExpr.Arg;
            kind=unaryExpr.kind;
            output=[];
            switch kind
            case{'NOT'}
                this.visit(expr,input);
                output.tag=unaryExpr.BOOLEAN;

                if~this.fxpConversionSettings.DoubleToSingle



                    isExprNumericalType=true;
                    exprMxInfo=this.getMxInfo(expr);
                    if~isempty(exprMxInfo)
                        if~this.isANumericalType(exprMxInfo)
                            isExprNumericalType=false;
                        end
                    end

                    if isExprNumericalType
                        exprStr=this.tree2str(expr);
                        annotatedExprStr=['(',exprStr,' ~= 0 )'];
                        this.replace(expr,annotatedExprStr);
                    end
                end

            case{'UMINUS'}
                op=this.visit(expr,input);
                output.tag=op.tag;

                if op.tag~=expr.INT&&op.tag~=expr.DOUBLE&&~this.fxpConversionSettings.DoubleToSingle

                    mapping=this.fiOperatorMapper.getMapping('UMINUS',true);
                    [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
                    if~isempty(mapping)
                        code=this.tree2str(expr);
                        newCode=this.getMappingCallCode(varArgStr,mapping,code);
                        this.replace(unaryExpr,newCode);
                    end
                end
            case{'TRANS','DOTTRANS','UPLUS'}
                op=this.visit(expr,input);
                output.tag=op.tag;
                if isfield(op,'range')
                    output.range=op.range;
                end
                if isfield(op,'IsRangeInt')
                    output.IsRangeInt=op.IsRangeInt;
                end
                log(this,this.NO_TEST_CASE);
            end
            assertTag(this);
        end


        function output=visitCELL(this,cellNode,input)

            node=cellNode.Left;
            this.debugAssert(@()node.iskind('ID')||node.iskind('DOT'));
            op=this.visit(node,input);
            output.tag=op.tag;

            index=cellNode.Right;
            while~isempty(index)
                if~this.isLiteralNumericNode(index)&&~strcmp(index.kind,'ID')
                    this.visit(index,input);
                end
                index=index.Next;
            end
        end



        function output=visitBINEXPR(this,binExprNode,input)

            output=[];

            switch(binExprNode.kind)
            case{'MUL'}

                lOpNode=binExprNode.Left;
                rOpNode=binExprNode.Right;
                lOp=this.visit(lOpNode,input);
                rOp=this.visit(rOpNode,input);
                lType=lOp.tag;
                rType=rOp.tag;
                this.debugAssert(@()~isempty(lType)&&~isempty(rType));
                [output.tag,lOp.tag,rOp.tag]=this.correctTypeMisMatchForBinaryOperations(binExprNode,lType,rType,lOpNode,rOpNode);
                normalizeFiMathSettings(binExprNode,lOpNode,rOpNode,lOp,rOp);


                if~this.DoubleToSingle


                    [lOpNodeSize,lOpNodeSizeDynamic]=getDynamicSize(lOpNode);
                    [rOpNodeSize,rOpNodeSizeDynamic]=getDynamicSize(rOpNode);
                    if~checkAnyNodeScalar(lOpNodeSize,lOpNodeSizeDynamic,rOpNodeSize,rOpNodeSizeDynamic)
                        if(lOp.tag==coder.internal.translator.F2FMTree.FIXPT)
                            changeSumModeStrForDynamicSize(lOpNode);
                        end
                        if(rOp.tag==coder.internal.translator.F2FMTree.FIXPT)
                            changeSumModeStrForDynamicSize(rOpNode);
                        end
                    end
                end
            case 'PLUS'
                lOpNode=binExprNode.Left;
                rOpNode=binExprNode.Right;

                [output.tag,~,~]=handlePlusMinus(binExprNode,lOpNode,rOpNode,input);
            case 'MINUS'
                lOpNode=binExprNode.Left;
                rOpNode=binExprNode.Right;

                [output.tag,lOp,rOp]=handlePlusMinus(binExprNode,lOpNode,rOpNode,input);

                if~this.fxpConversionSettings.DoubleToSingle
                    castUnsingedSubtraction(binExprNode,lOpNode,rOpNode,lOp,rOp)
                end
            case{'DIV'}
                output=this.handleDIV(binExprNode,input);
            case{'LDIV'}

                lOpNode=binExprNode.Left;
                rOpNode=binExprNode.Right;
                lOp=this.visit(lOpNode,input);
                rOp=this.visit(rOpNode,input);
                lType=lOp.tag;
                rType=rOp.tag;
                this.debugAssert(@()~isempty(lType)&&~isempty(rType));

                [output.tag,lOp.tag,rOp.tag]=this.correctTypeMisMatchForBinaryOperations(binExprNode,lType,rType,lOpNode,rOpNode);

                normalizeFiMathSettings(binExprNode,lOpNode,rOpNode,lOp,rOp);
            case{'EXP','DOTEXP'}
                tag=this.handlePowerOperators(binExprNode,input);
                output.tag=tag;
            case{'DOTDIV'}
                output=this.handleDOTDIV(binExprNode,input);
            case{'DOTMUL','DOTLDIV'}
                tag=this.handleDOTBINEXPR(binExprNode,input);
                output.tag=tag;
            end

            assertTag(this);

            function anyScalarNode=checkAnyNodeScalar(lSize,lSizeDynamic,rSize,rSizeDynamic)
                anyScalarNode=false;
                if(isempty(lSizeDynamic)||isempty(rSizeDynamic))&&...
                    isempty(lSize)&&isempty(rSize)
                    anyScalarNode=true;
                end
            end

            function changeSumModeStrForDynamicSize(node)
                newBaseStr=['fi(',this.tree2str(node),', '...
                ,'''SumMode'', ''KeepLSB'')'];
                this.replace(node,newBaseStr);
            end

            function[nodeSize,nodeSizeDynamic]=getDynamicSize(node)
                mxInfoLocation=this.treeAttributes(node).CompiledMxLocInfo;
                if~isempty(mxInfoLocation)
                    mxInfoID=mxInfoLocation.MxInfoID;
                    nodeSize=this.functionTypeInfoRegistry.mxInfos{mxInfoID}.SizeDynamic;
                    nodeSizeDynamic=this.functionTypeInfoRegistry.mxInfos{mxInfoID}.SizeDynamic;
                else
                    nodeSize=[];
                    nodeSizeDynamic=[];
                end
            end

            function[tag,lOp,rOp]=handlePlusMinus(binExprNode,lOpNode,rOpNode,input)

                lOp=this.visit(lOpNode,input);
                rOp=this.visit(rOpNode,input);
                lType=lOp.tag;
                rType=rOp.tag;
                this.debugAssert(@()~isempty(lType)&&~isempty(rType));

                [tag,lOp.tag,rOp.tag]=this.correctTypeMisMatchForBinaryOperations(binExprNode,lType,rType,lOpNode,rOpNode);

                normalizeFiMathSettings(binExprNode,lOpNode,rOpNode,lOp,rOp);
            end



            function castUnsingedSubtraction(binExprNode,lOpNode,rOpNode,lOp,rOp)
                needsSingedCast=(lOp.tag==lOpNode.FIXPT||rOp.tag==lOpNode.FIXPT)...
                &&isSignedRange(binExprNode)...
                &&~areOperandsAlreadySinged(lOpNode,rOpNode,lOp,rOp);

                if needsSingedCast

                    mapping=this.fiOperatorMapper.getMapping('PROMOTE_TO_SIGNED',true);
                    [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
                    if~isempty(mapping)
                        code=this.tree2str(lOpNode);
                        newCode=this.getMappingCallCode(varArgStr,mapping,code);
                        this.replace(lOpNode,newCode);
                    end
                end


                function res=areOperandsAlreadySinged(lOpNode,rOpNode,lOp,rOp)
                    res=isOpSinged(lOpNode,lOp)||isOpSinged(rOpNode,rOp);



                    function isSigned=isOpSinged(node,o)
                        isSigned=strcmp(node.kind,'ID')&&isfield(o,'varTypeInfo')...
                        &&~isempty(o.varTypeInfo)...
                        &&~isempty(o.varTypeInfo.annotated_Type)...
                        &&strcmp(o.varTypeInfo.annotated_Type.Signedness,'Signed');
                    end
                end


                function res=isSignedRange(node)

                    res=false;
                    nodeAttrib=this.mtreeAttributes(node);
                    simMin=nodeAttrib.SimMin;
                    simMax=nodeAttrib.SimMax;

                    if isempty(simMin)||coder.internal.translator.MTreeAttributes.IsImpossibleRange(simMin,simMax)...
                        ||simMin<0
                        res=true;
                    end
                end
            end

            function normalizeFiMathSettings(binExprNode,lOpNode,rOpNode,lOp,rOp)
                needsFiMathToReset=normalizeFixPtBinExprOps(this,lOpNode,rOpNode,lOp,rOp);



                if needsFiMathToReset&&~strcmp(binExprNode.Parent.kind,'EQUALS')
                    this.emittedFiCast=true;
                    binExprStr=sprintf('fi(%s, %s)',this.tree2str(binExprNode),this.fiMathVarName);
                    this.replace(binExprNode,binExprStr);
                end
            end
        end



        function output=visitRELBINEXPR(this,expr,input)
            lOpNode=expr.Left;
            rOpNode=expr.Right;
            lOp=this.visit(lOpNode,input);
            rOp=this.visit(rOpNode,input);

            output.tag=this.correctTypeMisMatchForBinaryOperations(expr,lOp.tag,rOp.tag,lOpNode,rOpNode);


            output.tag=expr.BOOLEAN;

            assertTag(this);
            log(this,this.NO_TEST_CASE);
        end



        function output=visitLOGBINEXPR(this,expr,input)
            output=[];
            switch expr.kind
            case{'AND','OR'}
                op=this.visit(expr.Left,input);
                if op.tag==expr.FIXPT
                    if this.DoubleToSingle

                    else
                        this.int32Cast(expr.Left);
                    end
                end
                op=this.visit(expr.Right,input);
                if op.tag==expr.FIXPT
                    if this.DoubleToSingle

                    else
                        this.int32Cast(expr.Right);
                    end
                end
            otherwise
                this.visit(expr.Left,input);
                this.visit(expr.Right,input);
            end
            output.tag=expr.BOOLEAN;

            assertTag(this);
            log(this,this.NO_TEST_CASE);
        end







        function output=visitLP(this,lpNode,input)
            output=[];

            node=lpNode.Left;
            if~isempty(node)
                varTypeInfo=getIDType(this,node);
                if~isempty(varTypeInfo)&&varTypeInfo.isEnum()

                    output.tag=this.handleEnumConstructor(lpNode,input);
                else
                    output.tag=lpNode.UNKNOWN;
                end
            else
                output.tag=lpNode.UNKNOWN;
            end
        end


        function output=visitLB(this,node,input)
            output=[];
            fiCastFirstElement=true;
            nodeAttrib=this.mtreeAttributes(node);
            if~isempty(nodeAttrib.MxLocInfo)
                mxInfoID=nodeAttrib.MxLocInfo.MxInfoID;
                mxInfo=this.functionTypeInfoRegistry.mxInfos{mxInfoID};
                if isa(mxInfo,'eml.MxNumericInfo')||isa(mxInfo,'eml. MxFiInfo')



                elseif isa(mxInfo,'eml.MxStructInfo')
                    row=node.Arg;
                    if strcmp(row.kind,'ROW')
                        while(~isempty(row))
                            items=row.Arg;

                            if~isempty(items)
                                n=items;
                                while~isempty(n)
                                    this.visit(n,input);
                                    n=n.Next;
                                end
                            end
                            row=row.Next;
                        end
                    end
                    output.tag=node.STRUCT;
                    return;
                else
                    output.tag=node.UNKNOWN;
                end
            end

            if strcmp(node.Parent.kind,'EQUALS')
                [isGrowingAssgn,growAssgnType,lhsNode]=coder.internal.translator.Phase.isGrowingAssignment(node.Parent);
                if isGrowingAssgn
                    lhsVarInfo=this.functionTypeInfo.getVarInfo(lhsNode);
                    if 1==growAssgnType&&...
                        ~isempty(lhsVarInfo)&&any(lhsVarInfo.inferred_Type.SizeDynamic)








                        fiCastFirstElement=false;
                    end
                end
            end

            [isConst,cVal,cType]=getConstType(this,node);
            if isConst
                output.range=[min(cVal(:)),max(cVal(:))];
                if~isempty(cType)
                    output.IsRangeInt=(cType.FractionLength==0);
                else
                    output.IsRangeInt=false;
                end
                output.tag=node.DOUBLE;
            else
                row=node.Arg;
                if strcmp(row.kind,'ROW')
                    typeTag=node.UNDEF;

                    widestRange=[Inf,-Inf];

                    widestRangeisInt=true;
                    rowCount=count(list(row));
                    doubleRows={};
                    doubleRowsWidestRange={};
                    doubleRowsIsInt={};




                    while(~isempty(row))
                        if row.Parent==node


                            input.fiCastFirstRowElement=false;
                        else
                            input.fiCastFirstRowElement=true;
                        end
                        [rowRange,rowRangeIsInt,rowTypeTag,elementCount]=handleRow(this,row,input);


                        if row.Parent~=node&&rowTypeTag==node.DOUBLE
                            doubleRows{end+1}=row;
                            doubleRowsWidestRange{end+1}=rowRange;
                            doubleRowsIsInt{end+1}=rowRangeIsInt;
                        end
                        typeTag=this.getTypeForRowNode(typeTag,rowTypeTag);
                        [widestRange,widestRangeisInt]=this.updateWidestRange(rowRange,rowRangeIsInt,widestRange,widestRangeisInt);
                        row=row.Next;
                    end

                    output.range=widestRange;
                    output.IsRangeInt=widestRangeisInt;

                    numberOfElements=rowCount*elementCount;
                    if typeTag==node.FIXPT&&numberOfElements>1
                        fiCastDoubleRowsFirstElements(doubleRows,doubleRowsWidestRange,doubleRowsIsInt)
                        if fiCastFirstElement
                            fiCastLBNodeFirstElement(node,widestRange,widestRangeisInt);
                        end
                    end

                    log(this,[this.NO_TEST_CASE,'for CHAR and BOOLEAN']);
                    output.tag=typeTag;
                else

                    lhsArgs=row;
                    if~isempty(lhsArgs)
                        output=this.visitNodeList(lhsArgs,input);
                    end

                    log(this,this.TAG_NOT_ANALYSED);
                    log(this,this.NO_TEST_CASE);
                end
            end

            assertTag(this);


            function fiCastLBNodeFirstElement(node,widestRange,widestRangeIsInt)

                if~any(isinf(widestRange))
                    firstRow=node.Arg;
                    output.typeTag=fiCastFirstElementOfRow(firstRow,widestRange,widestRangeIsInt);
                end
            end

            function fiCastDoubleRowsFirstElements(doubleRows,doubleRowsWidestRanges,doubleRowsIsInts)

                cellfun(@(row,rowWidestRange,rowWidesIsInt)fiCastFirstElementOfRow(row,rowWidestRange,rowWidesIsInt)...
                ,doubleRows...
                ,doubleRowsWidestRanges...
                ,doubleRowsIsInts);
            end

            function tag=fiCastFirstElementOfRow(row,range,rangeIsInt)
                firstElement=row.Arg;


                if(strcmp(firstElement.kind,'CALL')&&(strcmp(string(firstElement.Left),'horzcat')||strcmp(string(firstElement.Left),'vertcat')))

                    firstElement=firstElement.Right;


                    if isempty(firstElement)
                        firstElement=row.Arg;
                    end
                elseif strcmp(firstElement.kind,'TRANS')&&strcmp(firstElement.Arg.kind,'LB')

                    tmpRow=firstElement.Arg.Arg;
                    firstElement=tmpRow.Arg;
                end
                tag=this.castNodeToRangeNumericType(firstElement,range,rangeIsInt);
            end
        end

        function[widestRange,widestRangeIsInt,type]=handleRowItems(this,items,input)
            type=items.UNDEF;


            widestRange=[Inf,-Inf];
            widestRangeIsInt=true;

            if~isempty(items)
                n=items;
                while~isempty(n)
                    op=this.visit(n,input);
                    [range,rangeIsInt]=getSimMinMax(n,op);
                    [widestRange,widestRangeIsInt]=this.updateWidestRange(range,rangeIsInt,widestRange,widestRangeIsInt);
                    type=this.getTypeForRowNode(type,op.tag);
                    n=n.Next;
                end
            end

            function[rangeVal,isInt]=getSimMinMax(node,nodeOp)

                if(node.iskind('TRANS')&&node.Arg.iskind('LB'))||node.iskind('LB')||(node.iskind('CALL')&&(strcmp(string(node.Left),'horzcat')||strcmp(string(node.Left),'vertcat')))
                    rangeVal=nodeOp.range;
                    isInt=nodeOp.IsRangeInt;
                else
                    [isConst,cVal,cType]=this.getConstType(node);
                    if isConst
                        minVal=cVal;
                        maxVal=cVal;
                        if~isempty(cType)
                            isInt=(cType.FractionLength==0);
                        else
                            isInt=false;
                        end
                    else
                        minVal=this.mtreeAttributes(node).SimMin;
                        maxVal=this.mtreeAttributes(node).SimMax;
                        isInt=this.mtreeAttributes(node).IsAlwaysInteger;
                    end
                    rangeVal=[minVal,maxVal];
                end
            end

        end

        function rewriteColonToAvoidVarSize(this,colonNode,step,stop,startOp)

            if~isfield(startOp,'varTypeInfo')||isempty(startOp.varTypeInfo)||...
                ~isempty(step)||~stop.iskind('PLUS')||~stop.Right.iskind('INT')
                return;
            end
            startVarName=startOp.varTypeInfo.SymbolName;
            stopVarInfo=this.functionTypeInfo.getVarInfo(stop.Left);
            if isempty(stopVarInfo)
                return;
            end
            stopVarName=stopVarInfo.SymbolName;
            if~strcmp(startVarName,stopVarName)

                return;
            end


            currentStr=colonNode.tree2str;
            replacedStr=this.tree2str(colonNode);
            plusLoc=strfind(colonNode.tree2str,'+');
            currentStrWithfi=[currentStr(1:plusLoc),'fi(',currentStr(plusLoc+1:end)];
            if~strncmp(currentStrWithfi,replacedStr,numel(currentStrWithfi))
                return;
            end

            rightSideConst=replacedStr(plusLoc+1:end);
            newConstArray=strrep(rightSideConst,'fi(','fi(1:');

            colonReplacement=[newConstArray,'+',startVarName];
            this.replace(colonNode,colonReplacement);
        end


        function output=visitCOLON(this,colonNode,input)
            start=colonNode.Left;
            stop=colonNode.Right;

            if start.iskind('COLON')
                step=start.Right;
                start=start.Left;
            else
                step=[];
            end

            output=handleCOLONNodeAsData(colonNode,start,stop,input,step);

            function output=handleCOLONNodeAsData(colonNode,start,stop,input,step)

                [isConst,cVal,~]=getExpressionConstType(this,colonNode);

                if isConst
                    output.tag=this.getTagFromValue(cVal);
                else

                    if nargin<=4
                        if start.iskind('COLON')
                            step=start.Right;
                            start=start.Left;
                        else
                            step=[];
                        end
                    end

                    input.fiCastConst=false;

                    hasFi=false;
                    doubleNodes={};
                    startOpTag=[];
                    if~isempty(start)
                        startOp=this.visit(start,input);
                        hasFi=hasFi||colonNode.FIXPT==startOp.tag;

                        hasNonIntegerVal=hasNonIntegerValues(start);

                        if startOp.tag==colonNode.DOUBLE
                            doubleNodes{end+1}=start;
                        end
                        startOpTag=startOp.tag;
                    end
                    stepOpTag=[];
                    if~isempty(step)
                        stepOp=this.visit(step,input);
                        hasFi=hasFi||colonNode.FIXPT==stepOp.tag;

                        hasNonIntegerVal=hasNonIntegerVal||hasNonIntegerValues(step);

                        if stepOp.tag==colonNode.DOUBLE
                            doubleNodes{end+1}=step;
                        end
                        stepOpTag=stepOp.tag;
                    end
                    stopOpTag=[];
                    if~isempty(stop)
                        stopOp=this.visit(stop,input);
                        hasFi=hasFi||colonNode.FIXPT==stopOp.tag;

                        hasNonIntegerVal=hasNonIntegerVal||hasNonIntegerValues(stop);

                        if stopOp.tag==colonNode.DOUBLE
                            doubleNodes{end+1}=stop;
                        end
                        stopOpTag=stopOp.tag;
                    end

                    if hasFi&&~this.DoubleToSingle
                        success=cellfun(@(node)this.tryFiCasting(node,input),doubleNodes);


                        doubleNodes=doubleNodes(~success);
                        cellfun(@(node)this.int32Cast(node),doubleNodes);
                        if hasNonIntegerVal



                            this.addMessage(this.buildMessage(colonNode,this.WARN,'Coder:FXPCONV:NonIntegralValueWithFICOLON',colonNode.tree2str));
                        else
                            this.rewriteColonToAvoidVarSize(colonNode,step,stop,startOp);
                        end
                    end
                    if hasFi
                        output.tag=colonNode.FIXPT;
                    else
                        if~isempty(startOpTag)&&~isempty(stopOpTag)
                            if~isempty(stepOpTag)
                                output.tag=this.getTag(colonNode,startOpTag,stopOpTag,stepOpTag);
                            else
                                output.tag=this.getTag(colonNode,startOpTag,stopOpTag);
                            end
                        else
                            output.tag=colonNode.UNKNOWN;
                        end
                    end
                end

                function res=hasNonIntegerValues(node)
                    res=false;
                    mtreeAttrib=this.mtreeAttributes(node);
                    if~mtreeAttrib.IsAlwaysInteger
                        res=true;
                    end
                end
            end
        end


        function output=visitFOR(this,forNode,input)

            op=translateVector(forNode.Vector);

            if this.DoubleToSingle()
                opTag=translateVecForD2S(forNode);
                if~isempty(opTag)
                    op.tag=opTag;
                end
            end




            indexNode=forNode.Index;
            indexVarName=indexNode.string;

            isConst=getExpressionConstType(this,forNode.Vector);
            if~isConst


                setForNodeAssignedLater(this,indexVarName,false);
            end

            this.autoScaleLoopIndexVars=shouldTransformLoopIndex(this,indexNode);


            this.loopIndexVarType(indexVarName)=op.tag;



            output=this.visitBody(forNode.Body,input);











            function op=translateVector(vector)

                if vector.iskind('COLON')

                    op=this.visit(vector,input);
                elseif vector.iskind('SUBSCR')&&strcmp(vector.Left.tree2str,'coder.unroll')
                    op=handleCoderUnroll(vector);
                else
                    input.fiCastConst=false;
                    input.isForVectorExpr=true;
                    [op]=this.visit(vector,input);







                    input.fiCastConst=true;
                    input.isForVectorExpr=false;
                end


                function o=handleCoderUnroll(subscrNode)

                    node=subscrNode.Right;
                    if node.iskind('COLON')

                        o=this.visit(vector,input);
                    else
                        o=this.visit(node,input);



                    end

                    node=node.Next;
                    while~isempty(node)
                        this.visit(node,input);
                        node=node.Next;
                    end
                end
            end

            function opTag=translateVecForD2S(forNode)
                opTag=[];
                indexNode=forNode.Index;
                vector=forNode.Vector;
                vector=this.getProperForLoopVectorFromPragmas(vector);

                if strcmp(vector.kind,'COLON')
                    if strcmp(vector.Left.kind,'COLON')
                        vectorExps={vector.Left.Left,vector.Left.Right,vector.Right};
                    else
                        vectorExps={vector.Left,vector.Right};
                    end
                else

                    vectorExps={vector};
                end
                if~isempty(vectorExps)
                    forIdxVarInfo=this.functionTypeInfo.getVarInfo(indexNode);
                    nodesToCast={};
                    constNode=[];
                    if~isempty(forIdxVarInfo)&&forIdxVarInfo.isNumericVar()&&~forIdxVarInfo.isVarInSrcFixedPoint()
                        desiredTypeFound=false;
                        for ii=1:numel(vectorExps)
                            vecExp=vectorExps{ii};
                            switch vecExp.kind
                            case{'INT','HEX','BINARY'},constNode=vecExp;
                            case{'DOUBLE'},nodesToCast{end+1}=vecExp;%#ok<*AGROW>
                            case{'UMINUS'}
                                switch vecExp.Arg.kind
                                case{'INT','HEX','BINARY'},constNode=vecExp;
                                case 'DOUBLE',nodesToCast{end+1}=vecExp;
                                otherwise,nodesToCast{end+1}=vecExp;
                                end
                            case{'ID'}
                                vecVarInfo=this.functionTypeInfo.getVarInfo(vecExp);
                                if~isempty(vecVarInfo)
                                    if vecVarInfo.isNumericVar()
                                        if~strcmp(vecVarInfo.annotated_Type,forIdxVarInfo.annotated_Type)
                                            nodesToCast{end+1}=vecExp;
                                        else
                                            desiredTypeFound=true;
                                        end
                                    end
                                else
                                    nodesToCast{end+1}=vecExp;
                                end
                            otherwise
                                nodesToCast{end+1}=vecExp;
                            end
                        end

                        if numel(nodesToCast)==0&&~isempty(constNode)&&~desiredTypeFound
                            nodesToCast={vectorExps{1}};
                        end

                        for ii=1:numel(nodesToCast)
                            vecExp=nodesToCast{ii};
                            vecExpStr=this.tree2str(vecExp);
                            newVecExprStr=sprintf('%s(%s)',forIdxVarInfo.annotated_Type,vecExpStr);
                            this.replace(vecExp,newVecExprStr);

                            opTag=coder.internal.translator.F2FMTree.FIXPT;
                        end
                    end
                end
            end
        end


        function output=visitSWITCH(this,switchNode,input)
            indexExpr=switchNode.Left;
            this.visit(indexExpr,input);


            output=this.visitBody(switchNode.Body,input);

            output.tag=switchNode.UNDEF;
            assertTag(this);
        end


        function output=visitIF(this,ifNode,input)
            ifHead=ifNode.Arg;


            condition=ifHead.Left;
            op=this.visit(condition,input);
            if ifNode.DOUBLE==op.tag
                if~this.tryFiCasting(condition)
                    log(this,this.FICAST_FAILED);
                end
            end


            this.visitBody(ifHead.Body,input);


            output=this.visitNodeList(ifHead.Next,input);

            output.tag=ifNode.UNDEF;
            assertTag(this);
        end


        function output=visitELSEIF(this,elseIfNode,input)

            condition=elseIfNode.Left;
            op=this.visit(condition,input);
            if elseIfNode.DOUBLE==op.tag
                if~this.tryFiCasting(condition)
                    log(this,this.FICAST_FAILED);
                end
            end


            output=this.visitBody(elseIfNode.Body,input);

            output.tag=elseIfNode.UNDEF;
            assertTag(this);
        end


        function output=visitELSE(this,elseNode,input)

            output=this.visitBody(elseNode.Body,input);

            output.tag=elseNode.UNDEF;
            assertTag(this);
        end


        function output=visitCASE(this,caseNode,input)

            caseExpr=caseNode.Left;
            op=this.visit(caseExpr,input);

            if op.tag==caseNode.DOUBLE
                if~this.tryFiCasting(caseExpr)
                    log(this,this.FICAST_FAILED);
                end
            end


            this.visitBody(caseNode.Body,input);

            output.tag=caseNode.UNDEF;
            assertTag(this);
        end


        function output=visitOTHERWISE(this,otherwiseNode,input)

            output=this.visitBody(otherwiseNode.Body,input);

            output.tag=otherwiseNode.UNDEF;
            assertTag(this);
        end


        function output=visitWHILE(this,whileNode,input)


            condition=whileNode.Left;
            this.visit(condition,input);


            this.visitBody(whileNode.Body,input);

            output.tag=whileNode.UNDEF;
            assertTag(this);
            log(this,this.NO_TEST_CASE);
        end


        function output=visitEXPR(this,node,input)

            expr=node.Arg;
            op=this.visit(expr,input);
            output.tag=node.UNDEF;

            if this.DoubleToSingle











            else


                if op.tag==node.DOUBLE&&~node.Arg.iskind('EQUALS')
                    if this.tryFiCasting(expr)
                        output.tag=node.FIXPT;
                    else
                        output.tag=node.UNDEF;
                    end
                end
            end


            assertTag(this);
            log(this,this.NO_TEST_CASE);
        end


        function output=visitPRINT(this,node,input)
            expr=node.Arg;
            op=this.visit(expr,input);
            output.tag=node.UNDEF;





            if op.tag==node.DOUBLE&&~node.Arg.iskind('EQUALS')
                if this.castIfConst(expr)
                    output.tag=node.FIXPT;
                else
                    output.tag=node.UNDEF;
                end
            end

            assertTag(this);
            log(this,this.NO_TEST_CASE);
        end


        function output=visitRETURN(this,node,~)

            output.tag=node.UNDEF;
            assertTag(this);
            log(this,this.NO_TEST_CASE);
        end


        function output=visitSUBSCR(this,subScrNode,input)
            if(subScrNode.Left.iskind('DOT'))

                if strcmp(subScrNode.Left.tree2str,'coder.varsize')
                    output=handleCoderVarSize(subScrNode);
                    return;
                end
                if strcmp(subScrNode.Left.tree2str,'dsp.Delay')
                    output=handleDspDelay(subScrNode);
                    return;
                end
                if~isempty(subScrNode.Parent.Left)

                    varInfo=getIDType(this,subScrNode.Parent.Left);
                    if~isempty(varInfo)&&~isempty(varInfo.cppSystemObjectLoggedPropertiesInfo)

                        for kk=1:length(varInfo.cppSystemObjectLoggedPropertiesInfo)
                            if varInfo.cppSystemObjectLoggedPropertiesInfo{kk}.doApplyProposedType


                                output=handleSystemObjectConstructorCall(subScrNode,varInfo);
                                return;
                            end
                        end
                    end
                end
            end

            output=handleSubScrNode(subScrNode,input);

            function output=handleSystemObjectConstructorCall(subScrNode,varInfo)
                output.tag=subScrNode.UNKNOWN;

                appendStr={};
                for k=1:length(varInfo.loggedFields)
                    propName=regexp(varInfo.loggedFields{k},'\.','split');
                    propName=propName{end};
                    propInfo=varInfo.cppSystemObjectLoggedPropertiesInfo{k};
                    if~propInfo.doApplyProposedType



                        continue;
                    end
                    constraintStruct=propInfo.ConstraintStruct;
                    if isfield(constraintStruct,'Signedness')

                        if strcmpi(constraintStruct.Signedness,'Auto')
                            signedness='[]';
                        else
                            signedness=sprintf('%d',strcmpi(constraintStruct.Signedness,'Signed'));
                        end
                    else


                        if isa(varInfo.annotated_Type{k},'embedded.numerictype')
                            signedness=sprintf('%d',strcmpi(varInfo.annotated_Type{k}.Signedness,'Signed'));
                        else
                            signedness='[]';
                        end
                    end

                    wordLength=[];
                    if isfield(constraintStruct,'WordLength')

                        wordLength=constraintStruct.WordLength;
                    else


                        if isa(varInfo.annotated_Type{k},'embedded.numerictype')
                            wordLength=varInfo.annotated_Type{k}.WordLength;
                        end
                    end

                    propValue=[];
                    if~isempty(wordLength)
                        if isfield(constraintStruct,'FractionLength')

                            if isempty(constraintStruct.FractionLength)
                                propValue=sprintf('numerictype(%s, %d)',...
                                signedness,...
                                wordLength);
                            else
                                propValue=sprintf('numerictype(%s, %d, %d)',...
                                signedness,...
                                wordLength,...
                                constraintStruct.FractionLength);
                            end
                        else


                            if isa(varInfo.annotated_Type{k},'embedded.numerictype')
                                propValue=sprintf('numerictype(%s, %d, %d)',...
                                signedness,...
                                wordLength,...
                                varInfo.annotated_Type{k}.FractionLength);
                            end
                        end
                    end

                    node=subScrNode.Right;
                    replacementDone=false;
                    while~isempty(node)&&~isempty(propValue)
                        propNameArg=tree2str(node);
                        node=node.Next;
                        if strcmpi(propNameArg(2:end-1),propName)


                            this.replace(node,propValue);
                            replacementDone=true;
                        end
                        lastNode=node;
                        node=node.Next;
                    end
                    if~replacementDone&&~isempty(propValue)


                        appendStr{end+1}=sprintf('''%s''',propName);
                        appendStr{end+1}=propValue;
                    end
                end
                if~isempty(appendStr)
                    this.replace(lastNode,sprintf('%s %s',this.tree2str(lastNode),sprintf(', %s',appendStr{:})));
                end
            end

            function output=handleSubScrNode(subScrNode,input)
                node=subScrNode.Left;
                while strcmp(node.kind,'CELL')
                    node=node.Left;
                end


                this.debugAssert(@()node.iskind('ID')||node.iskind('DOT')||node.iskind('DOTLP'));
                op=this.visit(node,input);
                output.tag=op.tag;

                index=subScrNode.Right;
                while~isempty(index)
                    isGlobal=false;
                    if index.iskind('ID')
                        isGlobal=any(ismember(this.globalVarIDs,index.string));
                    end


                    if isGlobal||(~this.isLiteralNumericNode(index)&&~index.iskind('ID'))
                        this.visit(index,input);
                    end
                    index=index.Next;
                end
            end

            function revertNodeIfConstant(node)
                [isConst,~,~]=getExpressionConstType(this,node);
                if isConst
                    this.replace(node,node.tree2str(0,1,{}));
                else
                    log(this,this.POTENTIAL_ISSUE);
                end
            end

            function op=handleCoderVarSize(subScrNode)
                op.tag=subScrNode.UNKNOWN;

                index=subScrNode.Right;
                while~isempty(index)
                    if~this.isLiteralNumericNode(index)
                        this.visit(index,input);
                        revertNodeIfConstant(index)
                    end
                    index=index.Next;
                end
            end

            function output=handleDspDelay(subScrNode)
                output.tag=subScrNode.UNKNOWN;
                index=subScrNode.Right;
                while~isempty(index)
                    if~this.isLiteralNumericNode(index)
                        op=this.visit(index,input);
                        if op.tag==subScrNode.FIXPT
                            this.int32Cast(index);
                        end
                    end
                    index=index.Next;
                end
            end
            assertTag(this);
        end

        function output=visitDOT(this,dotNode,input)

            this.debugAssert(@()~isempty(dotNode));

            this.visit(dotNode.Left,input);


            varInfo=getIDType(this,dotNode);
            if~isempty(varInfo)&&varInfo.needsFiCast()
                output.tag=dotNode.FIXPT;
            else
                output.tag=dotNode.UNKNOWN;
            end

            assertTag(this);
        end


        function output=visitDOTLP(this,dotLPNode,input)


            this.visit(dotLPNode.Left,input);
            this.visit(dotLPNode.Right,input);


            varInfo=getIDType(this,dotLPNode);
            if~isempty(varInfo)&&varInfo.needsFiCast()
                output.tag=dotLPNode.FIXPT;
            else
                output.tag=dotLPNode.UNKNOWN;
            end

            assertTag(this);
        end


        function output=visitCALL(this,callNode,input)
            callee=string(callNode.Left);

            mapping=this.fiOperatorMapper.getMapping(callee,false);
            useReplacementFunctionIfExists=true;

            isUnSupportedFcn=coder.internal.Float2FixedConstrainer.isUnsupportedFunction(callee,this.DoubleToSingle);

            currFcnName=this.functionTypeInfo.functionName;
            isCurrentFcnReplaced=this.fiOperatorMapper.mappingTable.isKey(currFcnName)...
            ||this.autoReplaceCfgs.isKey(currFcnName);
            isCalleeReplaced=this.fiOperatorMapper.mappingTable.isKey(callee)...
            ||this.autoReplaceCfgs.isKey(callee);

            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
            isUserWrittenFcn=~isempty(calleeFcnInfo);



            if(~this.fxpConversionSettings.userFcnMap.isKey(callee)...
                &&~isUserWrittenFcn...
                &&isUnSupportedFcn...
                &&~isCurrentFcnReplaced...
                &&~isCalleeReplaced)
                msgParams={'',callee};
                if(this.fxpConversionSettings.suppressErrorMessages)
                    this.addMessage(this.buildMessage(callNode.Left,this.WARN,'Coder:FXPCONV:unsupportedFunc',msgParams));
                else
                    error(this.buildMessage(callNode.Left,this.ERR,'Coder:FXPCONV:unsupportedFunc',msgParams).getMatlabMessage());
                end
            end

            output=[];
            op=[];
            switch callee
            case 'step'
                isSystemObj=handleStepCall(this,callNode);
                if~isSystemObj
                    op=handleOtherCallNodes(this,callNode,input);
                    output.tag=op.tag;
                else
                    output.tag=callNode.UNKNOWN;
                end

            case 'class'
                handleOtherCallNodes(this,callNode,input);
                output.tag=callNode.CHAR;

            case{'bitget','bitset',...
                'bitandreduce','bitorreduce','bitxorreduce',...
                'bitrol','bitror'}





            case{'bitsll','bitsrl','bitsra'}
                this.handleBitCalls(callNode);

            case{'bitshift','circshift','fftshift','ifftshift'}
                this.handleBitshiftCall(callNode,input);

            case{'cast'}
                op=this.handleCastCall(callNode,input);
                output.tag=op.tag;

            case{'zeros','ones','eye','true','false'}
                [op,useReplacementFunctionIfExists]=this.handleZerosOnesEyeTrueFalse(callNode,input);
                output.tag=op.tag;

            case{'inv','and','or','not'}
                if this.DoubleToSingle

                    op=handleOtherCallNodes(this,callNode,input);
                    output.tag=op.tag;
                else
                    op=this.castInputArgsToInt(callNode,input);

                    output.tag=op.tag;
                end


            case{'fi','ufi'}
                op=this.handleFiCall(callNode);
                output.tag=op.tag;

            case 'mod'

                op=handleOtherCallNodes(this,callNode,input);
                output.tag=op.tag;

            case{'sum','prod'}
                op=this.handleSumAndProd(callNode,input);
                output.tag=op.tag;

            case{'triu','tril'}
                output.tag=this.handleTriuAndTril(callNode);

            case{'end'}
                if isfield(input,'treatEndAsFIXPT')&&input.treatEndAsFIXPT
                    success=this.tryFiCasting(callNode);
                    if success
                        tag=callNode.FIXPT;
                    else
                        tag=callNode.DOUBLE;
                    end
                else
                    tag=callNode.DOUBLE;
                end

                output.tag=tag;
            case{'logical'}



                handleOtherCallNodes(this,callNode,input);
                output.tag=callNode.BOOLEAN;

            case{'fimath','numerictype'}
                this.handleNumericTypeOrFiMath(callNode);
                output.tag=callNode.UNKNOWN;

            case{'divide'}





            case{'bitand','bitor','bitxor'}
                this.visitNodeList(callNode.Right,input);
                this.handleMappingForBitandBitorBitxor(callNode);
                output.tag=callNode.FIXPT;
                log(this,this.NO_TEST_CASE);

            case{'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                log(this,this.NO_TEST_CASE);
                this.handleIntCastCall(callNode,input);
                output.tag=callNode.INT;

            case{'size'}
                in=input;
                if this.DoubleToSingle



                else
                    in.fiCastConst=true;
                end
                this.visitNodeList(callNode.Right,in);
                output.tag=callNode.DOUBLE;

            case{'struct'}
                this.handleStructCall(callNode);
                output.tag=callNode.STRUCT;

            case{'flipdim','flip','rot90'}
                output=this.handleFlipDimRot90(callNode);




            case{'reshape','permute','repmat'}
                [output,useReplacementFunctionIfExists]=this.handleCallsFitoIntCastExceptFirstArg(callNode,input);

            case{'bitsliceget'}


            case{'hdlfimath'}
                output.tag=callNode.UNDEF;

            case{'power','mpower'}
                tag=this.handlePowers(callNode,callNode.Right,callNode.Right.Next);
                output.tag=tag;

            case{'pi'}
                output.tag=callNode.DOUBLE;


            case{'length','numel','ndims'}
                handleOtherCallNodes(this,callNode,input);
                output.tag=callNode.DOUBLE;

            case 'magic'
                handleMagicCall(this,callNode);
                output.tag=callNode.DOUBLE;

            case{'horzcat','vertcat'}
                if isfield(input,'fiCastFirstRowElement')
                    fiCastFirstRowElement=input.fiCastFirstRowElement;
                else
                    fiCastFirstRowElement=true;
                end
                items=callNode.Right;
                [range,rangeIsInt,typeTag]=this.handleRowItems(items,input);
                if fiCastFirstRowElement&&typeTag==callNode.FIXPT&&~any(isinf(range))

                    typeTag=this.castNodeToRangeNumericType(items,range,rangeIsInt);
                end
                output.range=range;
                output.IsRangeInt=rangeIsInt;
                output.tag=typeTag;

            case{'sort','shiftdim'}
                [op,useReplacementFunctionIfExists]=handleSortShiftDim(this,callNode,input);
                output.tag=op.tag;

            case 'sub2ind'
                [op,useReplacementFunctionIfExists]=handleSub2ind(this,callNode,input);
                output.tag=op.tag;

            case 'complex'
                [op,useReplacementFunctionIfExists]=handleComplexCall(this,callNode,input);
                output.tag=op.tag;

            case{'double'}

                op=handleOtherCallNodes(this,callNode,input);
                output.tag=op.tag;
                if this.DoubleToSingle
                    this.replace(callNode.Left,'single');
                    output.tag=callNode.FIXPT;
                end

            otherwise

                op=handleOtherCallNodes(this,callNode,input);
                output.tag=op.tag;
            end

            replaceFunction();
            autoReplaceFunction(op,isUnSupportedFcn);


            if isempty(output)
                output.tag=callNode.FIXPT;
            end

            assertTag(this);

            function replaceFunction()
                if useReplacementFunctionIfExists
                    mapping=this.fiOperatorMapper.getMapping(callee,true);
                    [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
                    if~isempty(mapping)
                        if~isempty(varArgStr)
                            lastArgNode=callNode.Right.list.last;
                            this.replace(lastArgNode,[lastArgNode.tree2str,',',varArgStr]);
                        end
                        this.replace(callNode.Left,mapping);
                    end
                end
            end


            function autoReplaceFunction(callOp,isUnSupportedFcn)



                if isUnSupportedFcn&&isfield(callOp,'argOps')...
                    &&~isempty(callOp.argOps)...
                    &&callNode.DOUBLE==callOp.argOps(1)
                    return;
                end

                if this.autoReplaceCfgs.isKey(callee)
                    autoRepCfg=this.autoReplaceCfgs(callee);

                    extentsValid=false;
                    areDesignExtents=~isempty(autoRepCfg.InputRange);

                    lookupCfg=coder.internal.F2FMathFcnGenHandler.buildLookupConfig(autoRepCfg);
                    if~areInputScalarsAndNonComplex()
                        return;
                    end

                    if areDesignExtents
                        extentsValid=checkDesignExtents();
                    end

                    if~extentsValid
                        extentsValid=inferAndCheckExtents();
                    end

                    lookupCfg.TypeProposalSettings=this.typeProposalSettings;
                    if extentsValid
                        codeArity=callNode.Right.list.count;
                        lookUpArity=lookupCfg.getNumInputs;
                        if codeArity~=lookUpArity
                            params={callee,lookUpArity,codeArity};
                            this.addMessage(this.buildMessage(callNode,this.WARN,'Coder:FXPCONV:MathFcnGenIncorrectArity',params));
                            return;
                        end


                        uniqueCalleeName=this.getUniqueNameLike([autoRepCfg.FunctionNamePrefix,callee]);

                        try


                            lookupCfg.setup(lookupCfg.InputExtents(1));
                            this.autoReplaceHndlr.addLookupFunction(uniqueCalleeName,lookupCfg);
                            this.replace(callNode.Left,uniqueCalleeName);
                        catch ex
                            reason='<unknown>';
                            if~isempty(ex.cause)
                                candidateFcnStr=func2str(lookupCfg.CandidateFunction);



                                if strcmp(ex.cause{1}.identifier,'MATLAB:UndefinedFunction')...
                                    &&~isempty(lookupCfg.CandidateFunction)...
                                    &&~isempty(which(['private/',candidateFcnStr]))
                                    reason=message('Coder:FXPCONV:MathFcnGenPrivateNoSupport',candidateFcnStr).getString();
                                else
                                    reason=ex.cause{1}.message;
                                end
                            end
                            this.addMessage(this.buildMessage(callNode.Left,this.ERR,'Coder:FXPCONV:MathFcnGenFailed',{callee,reason}));
                        end
                    end
                end

                function bVal=areInputScalarsAndNonComplex()
                    bVal=true;
                    node=callNode.Right;
                    while(~isempty(node))
                        nodeAttrib=this.mtreeAttributes(node);
                        if~isempty(nodeAttrib.MxLocInfo)
                            mxInfoID=nodeAttrib.MxLocInfo.MxInfoID;
                            mxInfo=this.functionTypeInfoRegistry.mxInfos{mxInfoID};
                            exprSize=mxInfo.Size;

                            if~isempty(mxInfo.Complex)&&mxInfo.Complex
                                bVal=false;
                                params={callee};
                                this.addMessage(this.buildMessage(callNode,this.WARN,'Coder:FXPCONV:MathFcnGenComplexNoSupport',params));
                                break
                            end
                            if~all(ones(1,length(exprSize))==exprSize')
                                bVal=false;
                                params={callee,strjoin(strsplit(num2str(exprSize')),'x'),node.tree2str};
                                this.addMessage(this.buildMessage(callNode,this.WARN,'Coder:FXPCONV:MathFcnGenScalarsOnly',params));
                                break
                            end
                        end
                        node=node.Next;
                    end
                end




                function extentsValid=inferAndCheckExtents()
                    inputExtents=getInferredInputExtents();

                    if isempty(inputExtents)
                        node=callNode.Right;
                        nodeStr=node.tree2str(1,0,{});
                        params={callee,nodeStr};
                        this.addMessage(this.buildMessage(callNode,this.WARN,'Coder:FXPCONV:MathFcnGenCannotInferRange',params));
                        extentsValid=false;
                        return;
                    end

                    lookupCfg.InputExtents=inputExtents;
                    [extentsValid,errorStr]=lookupCfg.InputRangeValidate();
                    if~extentsValid
                        this.debugAssert(@()2==length(inputExtents))
                        node=callNode.Right;
                        nodeStr=node.tree2str(1,0,{});
                        params={callee,num2str(inputExtents(1)),num2str(inputExtents(2)),nodeStr,errorStr};
                        this.addMessage(this.buildMessage(callNode,this.WARN,'Coder:FXPCONV:MathFcnGenIncorrectInferedRange',params));
                        extentsValid=false;
                        return;
                    end
                end

                function extentsValid=checkDesignExtents()
                    [extentsValid,errorStr]=lookupCfg.InputRangeValidate();
                    this.debugAssert(@()2==length(lookupCfg.InputExtents));
                    inputExtents=lookupCfg.InputExtents;
                    if~extentsValid
                        params={num2str(inputExtents(1)),num2str(inputExtents(2)),callee,errorStr};
                        this.addMessage(this.buildMessage(callNode,this.WARN,'Coder:FXPCONV:MathFcnGenIncorrectDesignExtents',params));
                    end
                end

                function inputExtents=getInferredInputExtents()
                    node=callNode.Right;
                    inputExtents=[];
                    while(~isempty(node))
                        nodeAttrib=this.mtreeAttributes(node);
                        simMin=nodeAttrib.SimMin;
                        simMax=nodeAttrib.SimMax;

                        inputExtents=[inputExtents;[simMin,simMax]];
                        node=node.Next;
                    end
                end
            end
        end


        function output=visitMethodCall(this,node,input)
            output.tag=node.UNKNOWN;
            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(node);
            this.debugAssert(@()~isempty(calleeFcnInfo));

            if strcmp(node.kind,'EQUALS')

                this.debugAssert(@()~isempty(strfind(calleeFcnInfo.functionName,'set.')));
                if strcmp(calleeFcnInfo.functionName,calleeFcnInfo.specializationName)



                    output=this.visitEQUALS(node,input);
                else


                    this.debugAssert(@()strcmp(node.Left.kind,'DOT')||strcmp(node.Left.kind,'DOTLP'));
                    this.replace(node.Left.Right,calleeFcnInfo.specializationName);
                    output=this.visit(node.Right,input);

                    code=sprintf('%s.%s( %s )',this.tree2str(node.Left.Left),...
                    calleeFcnInfo.specializationName,...
                    this.tree2str(node.Right));
                    this.replace(node,code);
                end
                return;
            end
            methodSpecializationName=calleeFcnInfo.specializationName;
            if~calleeFcnInfo.isStaticMethod&&~isempty(strfind(calleeFcnInfo.functionName,'.'))

                methodSpecializationName=strrep(methodSpecializationName,'set.','');
                methodSpecializationName=strrep(methodSpecializationName,'get.','');
            end

            if~strcmp(calleeFcnInfo.functionName,calleeFcnInfo.className)

                output.tag=node.FIXPT;
            end


            if strcmp(node.kind,'SUBSCR')
                methodNode=node.Left;
                this.debugAssert(@()strcmp(methodNode.kind,'DOT'));
                this.visitNodeList(node.Right,input);
                node=methodNode;
            end

            if strcmp(node.kind,'DOT')
                methodNode=node;
                this.replace(methodNode.Right,methodSpecializationName);
                if strcmp(methodNode.Left.kind,'ID')&&strcmp(string(methodNode.Left),calleeFcnInfo.className)


                    this.replace(methodNode.Left,calleeFcnInfo.classSpecializationName);
                elseif strcmp(methodNode.Left.kind,'LP')&&strcmp(methodNode.Left.Left.kind,'ID')
                    this.debugAssert(@()strcmp(string(methodNode.Left.Left),calleeFcnInfo.className));




                    this.replace(methodNode.Left.Left,calleeFcnInfo.classSpecializationName);
                else
                    if calleeFcnInfo.isStaticMethod




                        this.replace(methodNode.Left,calleeFcnInfo.classSpecializationName);
                    else

                    end
                end
                output.tag=node.FIXPT;
            elseif strcmp(node.kind,'CALL')||strcmp(node.kind,'LP')

                constructorNode=node.Left;
                this.debugAssert(@()strcmp(constructorNode.kind,'ID'));
                this.replace(constructorNode,calleeFcnInfo.specializationName);
                this.visitNodeList(node.Right,input);
            elseif strcmp(node.kind,'ID')

                this.replace(node,calleeFcnInfo.specializationName);
            else
                fprinf('error in visitMethodCall');
                assert(false);
            end

            assertTag(this);
        end
    end

    methods(Access=protected)

        function uniqueName=getUniqueNameLike(this,name)
            uniqueName=this.uniqueNamesService.distinguishName(name);
        end

        function addMessage(this,msg)


            if~this.isInTryFiCastingMode
                this.messages(end+1)=msg;
            end
        end

        function val=isLiteralNumericNode(~,node)
            val=node.iskind('INT')||node.iskind('DOUBLE')||node.iskind('HEX')||node.iskind('BINARY');
        end
    end
    methods(Access=private)

        function[op,useF2FPrimitive]=handleSub2ind(this,callNode,input)
            useF2FPrimitive=false;
            arg=callNode.Right;
            in=input;
            argCount=1;
            while~isempty(arg)
                argOp=this.visit(arg,in);
                if 1==argCount&&callNode.FIXPT==argOp.tag
                    if this.fxpConversionSettings.UseF2FPrimitives
                        useF2FPrimitive=true;
                    else
                        if this.DoubleToSingle

                        else
                            this.int32Cast(arg);
                        end
                    end
                end
                argCount=argCount+1;
                arg=arg.Next;
            end
            op.tag=callNode.DOUBLE;
        end



        function[op,useF2FPrimitive]=handleSortShiftDim(this,callNode,input)
            op.tag=callNode.UNDEF;
            arg=callNode.Right;
            in=input;
            argCount=1;
            useF2FPrimitive=false;
            while~isempty(arg)
                argOp=this.visit(arg,in);
                if 1==argCount
                    op.tag=argOp.tag;
                end
                if 2==argCount&&callNode.FIXPT==argOp.tag
                    if this.fxpConversionSettings.UseF2FPrimitives
                        useF2FPrimitive=true;
                    else
                        if this.DoubleToSingle




                        else
                            this.int32Cast(arg);
                        end
                    end
                end
                argCount=argCount+1;
                arg=arg.Next;
            end
        end




        function newType=getTypeForRowNode(~,prevType,currType)
            if prevType==coder.internal.translator.F2FMTree.UNDEF
                prevType=currType;
            elseif prevType==currType

            elseif prevType~=coder.internal.translator.F2FMTree.FIXPT
                if currType==coder.internal.translator.F2FMTree.FIXPT
                    prevType=coder.internal.translator.F2FMTree.FIXPT;
                elseif currType==coder.internal.translator.F2FMTree.CHAR
                    prevType=coder.internal.translator.F2FMTree.CHAR;
                elseif prevType~=coder.internal.translator.F2FMTree.CHAR

                    prevType=coder.internal.translator.F2FMTree.BOOLEAN;



                end
            end
            newType=prevType;
        end



        function[widestRange,widestRangeisInt]=updateWidestRange(~,rangeVal,rangeIsInt,widestRange,widestRangeisInt)
            if isempty(rangeVal)
                return;
            end
            if rangeVal(1)<widestRange(1)
                widestRange(1)=rangeVal(1);
            end
            if rangeVal(2)>widestRange(2)
                widestRange(2)=rangeVal(2);
            end
            widestRangeisInt=widestRangeisInt&&rangeIsInt;
        end






        function[widestRange,widestRangeIsInt,type,elementCount]=handleRow(this,row,input)
            if~isfield(input,'fiCastFirstRowElement')
                input.fiCastFirstRowElement=true;
            end
            items=row.Arg;
            elementCount=count(list(items));
            firstElement=items;
            [widestRange,widestRangeIsInt,type]=handleRowItems(this,items,input);
            if type~=row.DOUBLE&&~isempty(items)&&input.fiCastFirstRowElement&&elementCount>1
                if~any(isinf(widestRange))
                    this.castNodeToRangeNumericType(firstElement,widestRange,widestRangeIsInt);
                    type=row.FIXPT;
                end
            end
        end



        function tag=castNodeToRangeNumericType(this,node,range,rangeIsInt)

            rangeNumericType=this.getFixPtTypeForValue(range,rangeIsInt,this.typeProposalSettings);

            nodeStr=this.tree2str(node);



            if strcmp(node.kind,'DOT')&&strcmp(node.Right.kind,'FIELD')...
                &&~internal.mtree.getType(node.Left,this.functionTypeInfo,this.functionTypeInfoRegistry).isScalar
                nodeStr=sprintf('[%s]',nodeStr);
            end

            newNodeStr=this.wrapCodeWithType(nodeStr,rangeNumericType,this.fiMathVarName,node);
            this.replace(node,newNodeStr);
            tag=node.FIXPT;
        end


        function output=handleOtherCallNodes(this,callNode,input)
            callee=string(callNode.Left);
            isUserWrittenFcn=false;

            calleeFcnInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
            if~isempty(calleeFcnInfo)
                isUserWrittenFcn=true;
                if~strcmp(calleeFcnInfo.functionName,callee)
                    error(message('Coder:FXPCONV:InvalidCallInfo',coder.internal.Helper.getPrintLinkStr(this.functionTypeInfo.scriptPath,callNode.Left,2)));
                end
                specializationName=calleeFcnInfo.specializationName;
                calledFunction=this.treeAttributes(callNode).CalledFunction;




                if this.fxpConversionSettings.detectDeadCode&&calledFunction.isDead
                    this.replace(callNode.Left,coder.internal.Helper.newFunctionName(specializationName,this.DEAD));
                elseif this.fxpConversionSettings.detectDeadCode&&calledFunction.isConstantFolded
                    this.replace(callNode.Left,coder.internal.Helper.newFunctionName(specializationName,this.CFOLD));
                else
                    this.replace(callNode.Left,specializationName);
                end
            else










                mxLocInfo=this.mtreeAttributes(callNode).MxLocInfo;
                if~isempty(mxLocInfo)

                    cmxInfo=this.functionTypeInfoRegistry.mxInfos(mxLocInfo.MxInfoID);
                    if~isempty(cmxInfo)&&isa(cmxInfo{1},'eml.MxEnumInfo')
                        output.tag=this.handleEnumConstructor(callNode,input);
                        return;
                    end
                end


                if this.functionTypeInfoRegistry.classMap.isKey(callee)
                    newCallee=[callee,this.typeProposalSettings.Config.OutputFileNameSuffix];
                    this.replace(callNode.Left,newCallee);
                    output.tag=callNode.UNKNOWN;
                end
            end


            input.fiCastAllArgs=false;
            [anyArgsFi,doubleNodes,~,argTags,lastArg]=this.visitArgList(callNode.Right,input);

            if this.DoubleToSingle&&isUserWrittenFcn



                inputVars=calleeFcnInfo.inputVarNames;
                argNode=callNode.Right;
                idx=1;
                node=callNode;
                while~isempty(argNode)
                    if idx<=numel(inputVars)
                        argInfo=calleeFcnInfo.getVarInfo(inputVars{idx});
                        if~isempty(argInfo)
                            if argInfo.isNumericVar()&&ischar(argInfo.annotated_Type)
                                switch argInfo.annotated_Type
                                case this.typeProposalSettings.Config.IndexType
                                    if argTags(idx)==node.DOUBLE||argTags(idx)==node.FIXPT...
                                        ||argTags(idx)==node.BOOLEAN
                                        this.castToIndexType(argNode);
                                    end
                                case 'single'
                                    if argTags(idx)==node.DOUBLE
                                        this.tryFiCasting(argNode,input);
                                    end
                                end
                            end
                        else
                            this.tryFiCasting(argNode,input);
                        end
                    else

                        if anyArgsFi
                            this.tryFiCasting(argNode,input);
                        end
                    end
                    argNode=argNode.Next;
                    idx=idx+1;
                end

                output.tag=callNode.FIXPT;
                outVarNames=calleeFcnInfo.outputVarNames;
                if~isempty(outVarNames)
                    firstOutVar=outVarNames{1};
                    outVarInfo=calleeFcnInfo.getVarInfo(firstOutVar);

                    if~isempty(outVarInfo)
                        if outVarInfo.isNumericVar()&&ischar(outVarInfo.annotated_Type)
                            switch outVarInfo.annotated_Type
                            case this.typeProposalSettings.Config.IndexType
                                output.tag=callNode.INT;
                            end
                        end
                    end
                end

                return;
            end

            if anyArgsFi||isUserWrittenFcn
                cellfun(@(node)this.tryFiCasting(node,input),doubleNodes);
                output.tag=callNode.FIXPT;
            else

                output.tag=callNode.DOUBLE;
            end
            output.argOps=argTags;
            output.lastArg=lastArg;

            log(this,this.TAG_NOT_ANALYSED);
        end





        function tag=handleEnumConstructor(this,enumCallNode,input)
            this.debugAssert(@()enumCallNode.iskind('LP')||enumCallNode.iskind('CALL'));

            node=enumCallNode.Right;
            while~isempty(node)
                this.visit(node,input);
                this.int32Cast(node);
                node=node.Next;
            end
            tag=enumCallNode.ENUM;
        end



        function output=handleBitCalls(this,callNode)
            arg1=callNode.Right;
            arg2=callNode.Right.Next;

            isArg1ConstExpr=getExpressionConstType(this,arg1);
            isArg2NonConstExpr=~getExpressionConstType(this,arg2);

            if isArg1ConstExpr&&isArg2NonConstExpr
                op=int32CastForBitFcns(arg1);
                output=op;
            else

                output=callNode.INT;
            end

            if isArg2NonConstExpr
                op=this.visit(arg2,[]);
                if op.tag~=arg2.INT
                    this.int32Cast(arg2);
                end
            end


            function op=int32CastForBitFcns(expr)

                if strcmp(expr.kind,'CALL')
                    if strcmp(expr.Left.string,'end')
                        return
                    end
                end


                op=this.visit(expr,[]);

                if op.tag~=expr.INT
                    this.replaceMappingCall('FI2INT',expr);
                end
            end
        end





        function output=handleBitshiftCall(this,callNode,input)
            if count(callNode.Right.List)==2
                output=this.handleBitCalls(callNode);
            else
                output=this.handleCallsFitoIntCastExceptFirstArg(callNode,input);
            end
        end


        function output=handleFlipDimRot90(this,callNode)
            output=[];
            op1=callNode.Right;
            op2=callNode.Right.Next;

            op=this.visit(op1,[]);
            if~isempty(op2)
                [isConst,~,~]=getExpressionConstType(this,op2);
                if~isConst
                    dimOp=this.visit(op2,[]);
                    if callNode.FIXPT==dimOp.tag
                        if this.DoubleToSingle

                        else
                            this.int32Cast(op2);
                        end
                    end
                end
            end
            output.tag=op.tag;
        end


        function tag=handleTriuAndTril(this,callNode)
            arg=callNode.Right;
            op=this.visit(arg,[]);
            arg=arg.Next;
            if(~isempty(arg))
                [isConst,~,~]=getExpressionConstType(this,arg);
                if~isConst
                    diagOp=this.visit(arg,[]);
                    if callNode.FIXPT==diagOp.tag
                        this.int32Cast(arg);
                    end
                end
            end
            tag=op.tag;
        end

        function handleIntCastCall(this,callNode,input)
            arg=callNode.Right;
            while(~isempty(arg))
                if~this.isLiteralNumericNode(arg)
                    this.visit(arg,input);



                end
                arg=arg.Next;
            end
        end


        function output=castInputArgsToInt(this,callNode,input)
            output=[];
            intType=false;
            arg=callNode.Right;
            while~isempty(arg)
                op=this.visit(arg,input);
                if op.tag~=callNode.DOUBLE
                    this.int32Cast(arg);
                    intType=true;
                end
                arg=arg.Next;
            end
            if intType
                output.tag=callNode.INT;
            else
                output.tag=callNode.DOUBLE;
            end
        end


        function[output,useF2FPrimitive]=handleCallsFitoIntCastExceptFirstArg(this,callNode,input)
            output=[];
            useF2FPrimitive=false;
            op=callNode.Right;
            this.visit(op,input);
            arg=callNode.Right.Next;
            while(~isempty(arg))
                [isConst,~,~]=getExpressionConstType(this,arg);
                if~isConst
                    op=this.visit(arg,[]);
                    if op.tag~=callNode.INT&&op.tag~=callNode.DOUBLE
                        if this.fxpConversionSettings.UseF2FPrimitives
                            useF2FPrimitive=true;
                        else
                            if this.DoubleToSingle
                                if op.tag==callNode.FIXPT




                                else
                                    this.int32Cast(arg);
                                end
                            else
                                this.int32Cast(arg);
                            end
                        end
                    end
                end
                arg=arg.Next;
            end
        end

        function isSystemObj=handleStepCall(this,callNode)
            arg=callNode.Right;
            varInfo=this.getIDType(arg);
            if~isempty(varInfo)&&varInfo.isVarInSrcSystemObj()
                isSystemObj=true;
            else


                varName=tree2str(arg);
                isSystemObj=matlab.system.isSystemObjectName(varName);
                if~isSystemObj
                    return;
                end
            end
            arg=arg.Next;
            while~isempty(arg)
                op=this.visit(arg,[]);
                if op.tag~=callNode.INT&&op.tag~=callNode.DOUBLE

                end
                arg=arg.Next;
            end
        end

        function handleMagicCall(this,callNode)
            arg=callNode.Right;
            if~this.isLiteralNumericNode(arg)
                op=this.visit(arg,[]);
                if~op.tag==callNode.INT&&~op.tag==callNode.DOUBLE
                    this.int32Cast(arg);
                end
            end
        end

        function handleNumericTypeOrFiMath(this,callNode)
            callee=string(callNode.Left);
            this.debugAssert(@()strcmpi(callee,'FIMATH')||strcmpi(callee,'NUMERICTYPE'));
            if strcmpi('FIMATH',callee)
                potentialType='embedded.fimath';
            else
                potentialType='embedded.numerictype';
            end
            arg=callNode.Right;
            if 1==arg.list.count

            else
                while~isempty(arg)
                    if arg.iskind('ID')
                        varInfo=this.functionTypeInfo.getVarInfo(arg);
                        if~isempty(varInfo)&&~strcmp(potentialType,varInfo.getOriginalTypeClassName())
                            op=this.visit(arg,[]);
                            if op.tag==callNode.FIXPT
                                this.int32Cast(arg);
                            end
                        end
                    else
                        input.fiCastConst=false;
                        this.visit(arg,input);
                        input.fiCastConst=true;
                    end
                    arg=arg.Next;
                end
            end
        end

        function tag=handleDOTBINEXPR(this,expr,input)
            lOp=this.visit(expr.Left,input);
            rOp=this.visit(expr.Right,input);
            lType=lOp.tag;
            rType=rOp.tag;
            this.debugAssert(@()~isempty(lType)&&~isempty(rType));

            [tag,lOp.tag,rOp.tag]=this.correctTypeMisMatchForBinaryOperations(expr,lType,rType,expr.Left,expr.Right);
        end



        function tag=handlePowerOperators(this,powerNode,~)
            [isConst,~,~]=getConstType(this,powerNode);
            if isConst
                tag=powerNode.DOUBLE;
            else
                tag=this.handlePowers(powerNode,powerNode.Left,powerNode.Right);
            end
        end


        function tag=handlePowers(this,powRootNode,base,exp)
            [expIsConst,~,~]=getConstType(this,exp);


            if~this.DoubleToSingle()
                if this.isNodeComplex(exp)||~this.isNodeScalar(exp)||~this.isNodeIntValued(exp)||~this.isNodeNonNegative(exp)
                    sourceLink=coder.internal.Helper.getPrintLinkStr(this.functionTypeInfo.scriptPath,exp);
                    if strcmp(powRootNode.kind,'CALL')
                        funName=powRootNode.Left.string;
                    elseif strcmp(powRootNode.kind,'DOTEXP')
                        funName='.^';
                    else
                        funName='^';
                    end
                    error(this.buildMessage(exp,this.ERR,'Coder:FXPCONV:powerSupportLimitation',{sourceLink,funName}).getMatlabMessage());
                end
            end

            if expIsConst
                op=this.visit(base,[]);
                tag=op.tag;

            else



                baseOp=this.visit(base,[]);
                this.visit(exp,[]);

                if this.DoubleToSingle()
                    tag=base.FIXPT;
                    return;
                end

                if base.DOUBLE==baseOp.tag
                    if~this.tryFiCasting(base)
                        log(this,this.FICAST_FAILED);
                    end
                end




                [mpowMin,mpowMax]=this.getMinMax(powRootNode);
                if~isempty(mpowMin)&&~isempty(mpowMax)&&...
                    (all(isinf(mpowMin(:)))||all(isinf(mpowMax(:))))


                    [mpowMin,mpowMax]=deal([]);
                end


                if isempty(mpowMin)||isempty(mpowMax)
                    [baseMin,baseMax]=this.getMinMax(base);
                    [expMin,expMax]=this.getMinMax(exp);
                    mpowMin=baseMin.^expMin;
                    mpowMax=baseMax.^expMax;
                end


                if~isscalar(mpowMin)||~isscalar(mpowMax)
                    mpowMin=min(mpowMin,[],'all');
                    mpowMax=max(mpowMax,[],'all');
                end

                isInteger=this.mtreeAttributes(powRootNode).IsAlwaysInteger;
                if isempty(isInteger)
                    isInteger=false;
                end

                proposedType=coder.internal.getBestNumericTypeForVal(mpowMin...
                ,mpowMax...
                ,isInteger...
                ,this.typeProposalSettings);

                if~isempty(proposedType)
                    baseStr=this.tree2str(base);
                    if strcmp(powRootNode.kind,'DOTEXP')...
                        ||(strcmp(powRootNode.kind,'CALL')&&strcmp(powRootNode.Left.string,'power'))

                        newBaseStr=getBaseForPower(baseStr,proposedType);
                    else

                        newBaseStr=getBaseForMPower(base,baseStr,proposedType);
                    end
                    this.replace(base,newBaseStr);




                    if~powRootNode.Parent.iskind('EQUALS')
                        this.emittedFiCast=true;
                        powStr=sprintf('fi(%s, %s)',this.tree2str(powRootNode),this.fiMathVarName);
                        this.replace(powRootNode,powStr);
                    end
                end

                tag=base.FIXPT;
            end

            function newBaseStr=getBaseForPower(origBaseStr,proposedType)
                newBaseStr=['fi(',origBaseStr,', '...
                ,'''ProductMode'', ''SpecifyPrecision'', '...
                ,'''ProductWordLength'', ',num2str(proposedType.WordLength),', '...
                ,'''ProductFractionLength'', ',num2str(proposedType.FractionLength),', '...
                ,'''Signedness'', ''',proposedType.Signedness,''', '...
                ,'''WordLength'', ',num2str(proposedType.WordLength),', '...
                ,'''FractionLength'', ',num2str(proposedType.FractionLength),')'];
            end

            function newBaseStr=getBaseForMPower(base,origBaseStr,proposedType)
                basePostfix='';
                [isBaseConst,~,~]=getConstType(this,base);






                if this.isNodeScalar(base)
                    basePostfix=[basePostfix,', '...
                    ,'''ProductMode'', ''SpecifyPrecision'', '...
                    ,'''ProductWordLength'', ',num2str(proposedType.WordLength),', '...
                    ,'''ProductFractionLength'', ',num2str(proposedType.FractionLength)];
                end




                if~this.isNodeScalar(base)||~isBaseConst
                    basePostfix=[basePostfix,', '...
                    ,'''SumMode'', ''SpecifyPrecision'', '...
                    ,'''SumWordLength'', ',num2str(proposedType.WordLength),', '...
                    ,'''SumFractionLength'', ',num2str(proposedType.FractionLength)];
                end


                if~isempty(basePostfix)
                    basePostfix=[basePostfix,', '...
                    ,'''Signedness'', ''',proposedType.Signedness,''', '...
                    ,'''WordLength'', ',num2str(proposedType.WordLength),', '...
                    ,'''FractionLength'', ',num2str(proposedType.FractionLength)];
                end

                newBaseStr=['fi(',origBaseStr,basePostfix,')'];
            end
        end


        function handleMappingForBitandBitorBitxor(this,callNode,~)
            calleeNode=callNode.Left;
            callee=upper(string(calleeNode));
            mapping=this.fiOperatorMapper.getMapping(callee,true);
            [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
            if~isempty(mapping)
                mappingName=this.getMappingCallCode(varArgStr,mapping);
                this.replace(calleeNode,mappingName);
            end
        end


        function tag=int32Cast(this,expr)
            if this.DoubleToSingle
                code=this.tree2str(expr);
                newCode=sprintf('int32(%s)',code);
                this.replace(expr,newCode);
            else
                this.replaceMappingCall('FI2INT',expr);
            end
            tag=expr.INT;
        end


        function op=handleFiCall(this,callNode)
            arg=callNode.Right;



            [isConst,~,~]=getConstType(this,arg);
            if~isConst
                op=this.visit(arg,[]);
            end
            arg=arg.Next;

            while~isempty(arg)
                [isConst,~,~]=getConstType(this,arg);
                if~isConst
                    op=this.visit(arg,[]);
                    if op.tag==callNode.FIXPT&&~this.DoubleToSingle
                        this.int32Cast(arg);
                    end
                end
                arg=arg.Next;
            end
            op.tag=callNode.FIXPT;
        end


        function output=handleSumAndProd(this,callNode,input)
            callee=string(callNode.Left);
            this.debugAssert(@()strcmpi(callee,'SUM')||strcmpi(callee,'PROD'));

            op=this.handleOtherCallNodes(callNode,input);

            argsOps=op.argOps;
            prevArg=op.lastArg;

            if~isempty(argsOps)
                output.tag=getOutputType(argsOps(1));
            else
                output.tag=callNode.FIXPT;
            end


            if~isempty(prevArg)&&strcmp(prevArg.kind,'CHARVECTOR')...
                &&(strcmp(prevArg.string,'''double''')||strcmp(prevArg.string,'''native'''))
                arguments=getArgsList(callNode.Right);
                arguments(end)=[];
                argStrs=cellfun(@(node)this.tree2str(node),arguments,'UniformOutput',false);
                if ischar(argStrs)
                    argStrs={argStrs};
                end
                argListStr=strjoin(argStrs,', ');
                newSumCall=sprintf('%s( %s )',callee,argListStr);
                this.replace(callNode,newSumCall);
            end

            function type=getOutputType(inputType)
                if inputType==callNode.CHAR||inputType==callNode.DOUBLE||inputType==callNode.BOOLEAN||inputType==callNode.INT
                    type=callNode.DOUBLE;
                else
                    type=callNode.FIXPT;
                end
            end


            function args=getArgsList(arg)
                args=[];
                while(~isempty(arg))
                    args{end+1}=arg;
                    arg=arg.Next;
                end
            end
        end




        function output=handleCastCall(this,callNode,input)
            output.tag=callNode.UNKNOWN;

            arg=callNode.Right;


            while~isempty(arg)



                if strcmp(arg.kind,'ID')
                    this.visit(arg,input);
                end
                arg=arg.Next;
            end
        end

        function[output,useF2FPrimitive]=handleComplexCall(this,callNode,input)
            useF2FPrimitive=true;
            arg=callNode.Right;


            [isAnyFiArgs,doubleNodes,doubleNids,argTags,~]=this.visitArgList(arg,input);

            this.debugAssert(@()2>=length(argTags));
            if 2==length(argTags)

                if isAnyFiArgs


                    for ii=1:length(doubleNids)
                        doubleNId=doubleNids(ii);
                        if this.tryFiCasting(doubleNodes{ii},input)
                            argTags(doubleNId)=callNode.FIXPT;
                        end
                    end
                end

                realTag=argTags(1);
                imagTag=argTags(2);
                output.tag=this.getTag(callNode,realTag,imagTag);
            else
                output.tag=argTags(1);
            end
            if callNode.DOUBLE==output.tag


                useF2FPrimitive=false;
            end
        end



        function[output,useF2FPrimitive]=handleZerosOnesEyeTrueFalse(this,callNode,~)
            arg=callNode.Right;
            castLike=callNode.DOUBLE;
            useF2FPrimitive=false;
            while~isempty(arg)
                if(strcmp(arg.kind,'CHARVECTOR'))&&strcmpi(arg.string,'''like''')
                    arg=arg.Next;
                    arg=arg.Next;
                elseif arg.iskind('CHARVECTOR')



                    argStr=arg.tree2str;
                    if~isempty(strfind(argStr,'int'))
                        castLike=callNode.INT;
                    end
                    if strcmp(argStr,'''double''')
                        if this.DoubleToSingle
                            this.replace(arg,'''single''');
                            castLike=callNode.FIXPT;
                        else
                            this.replace(arg,'''int32''');
                            castLike=callNode.INT;
                        end
                    end
                elseif arg.iskind('CALL')&&strcmpi(string(arg.Left),'class')
                    if this.DoubleToSingle


                    else
                        this.int32Cast(arg.Right);
                    end
                elseif arg.iskind('NAMEVALUE')&&strcmpi(string(arg.Left),'like')
                    arg=arg.Next;
                else
                    [isConst,~,~]=getConstType(this,arg);
                    if~isConst
                        op=this.visit(arg,[]);
                        if op.tag~=callNode.INT&&op.tag~=callNode.CHAR&&op.tag~=callNode.DOUBLE
                            if this.fxpConversionSettings.UseF2FPrimitives
                                useF2FPrimitive=true;
                            else
                                if this.DoubleToSingle


                                else
                                    this.int32Cast(arg);
                                end
                            end
                        end
                    end
                end
                arg=arg.Next;
            end

            output.tag=castLike;
            assertTag(this);
        end


        function log(this,message,node)
            if this.debugEnabled
                if nargin<=2
                    disp(message);
                else
                    disp([message,' at : ',node.tree2str]);
                end
            end
        end



        function output=handleDOTDIV(this,expr,input)

            defaultMap=coder.internal.FiOperatorMapper.getMappingTable(this.DoubleToSingle());
            rDivStr='RDIVIDE';
            divMapping=this.fiOperatorMapper.getMapping(rDivStr,true);
            key=lower(rDivStr);
            if defaultMap.isKey(key)
                defaultDivMapping=defaultMap(key);
            else
                defaultDivMapping='';
            end
            if~isempty(defaultDivMapping)


                if~strcmp(defaultDivMapping,divMapping)
                    fcnName=rDivStr;
                else
                    fcnName='DOTDIV';
                end
            else
                fcnName='';
            end
            [lOpOut,rOpOut]=this.handleReplacementFcnForBinOperator(expr,input,fcnName);
            if lOpOut.tag==expr.FIXPT||rOpOut.tag==expr.FIXPT
                output.tag=expr.FIXPT;
            else
                output.tag=expr.DOUBLE;
            end
        end




        function replaceMappingCall(this,fcn,argExpr)
            code=this.tree2str(argExpr);
            mapping=this.fiOperatorMapper.getMapping(fcn,true);
            [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
            if~isempty(mapping)
                newCode=this.getMappingCallCode(varArgStr,mapping,code);
                this.replace(argExpr,newCode);
            end
        end





        function[lOpOut,rOpOut]=handleReplacementFcnForBinOperator(this,expr,input,replacementFcnName)
            lOp=expr.Left;
            rOp=expr.Right;
            lOpOut=this.visit(lOp,input);
            rOpOut=this.visit(rOp,input);

            if expr.DOUBLE==lOpOut.tag&&expr.DOUBLE==rOpOut.tag
                return;
            end

            if(expr.DOUBLE==lOpOut.tag&&expr.FIXPT==rOpOut.tag)||...
                (expr.FIXPT==lOpOut.tag&&expr.DOUBLE==rOpOut.tag)
                if expr.DOUBLE==lOpOut.tag
                    if~this.tryFiCasting(lOp)
                        log(this,this.FICAST_FAILED);
                    else
                        lOpOut.tag=expr.FIXPT;
                    end
                end

                if expr.DOUBLE==rOpOut.tag
                    if~this.tryFiCasting(rOp)
                        log(this,this.FICAST_FAILED);
                    else
                        rOpOut.tag=expr.FIXPT;
                    end
                end
            end

            mapping=this.fiOperatorMapper.getMapping(replacementFcnName,true);
            [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
            if~isempty(mapping)
                lOpCode=this.tree2str(lOp);
                rOpCode=this.tree2str(rOp);
                newCode=this.getMappingCallCode(varArgStr,mapping,lOpCode,rOpCode);
                this.replace(expr,newCode);
            end
        end



        function output=handleDIV(this,divExpr,~)
            output=[];

            op1=divExpr.Left;
            op2=divExpr.Right;

            [isNConst,~,~]=getConstType(this,op1);
            [isDConst,denomVal,~]=getConstType(this,op2);


            if isDConst&&~isNConst
                bits=floor(log2(denomVal));
                if pow2(bits)==denomVal

                    out=this.visit(op1,[]);
                    if out.tag~=op1.DOUBLE
                        replaceDIVPOW2();
                    end
                    output.tag=out.tag;
                else
                    op1Output=this.visit(op1,[]);
                    if op1Output.tag==divExpr.DOUBLE
                        output.tag=divExpr.DOUBLE;
                    else
                        if~this.DoubleToSingle
                            transformToMUL();
                        end
                        output.tag=divExpr.FIXPT;
                    end
                end
            else
                op1Output=this.visit(op1,[]);
                op2Output=this.visit(op2,[]);
                output.tag=this.correctTypeMisMatchForBinaryOperations(divExpr,op1Output.tag,op2Output.tag,op1,op2);

                if output.tag==divExpr.FIXPT&&~this.fxpConversionSettings.DoubleToSingle
                    replaceDiv();
                end
            end





            function transformToMUL()
                numerator=this.tree2str(op1);
                denominator=this.tree2str(op2);
                if op2.iskind('CALL')

                    demonConstType=this.getConstantFixPtType(1/eval(denominator));
                else
                    demonConstType=this.getConstantFixPtType(1/str2double(denominator));
                end
                fidemonStr=this.wrapCodeWithType(['1/',denominator],demonConstType,this.fiMathVarName,op2);
                code=sprintf('%s*%s',numerator,fidemonStr);
                this.replace(divExpr,code);
            end

            function replaceDIVPOW2()
                if this.fxpConversionSettings.DoubleToSingle
                    numerator=this.tree2str(op1);
                    code=sprintf('bitsra(%s, %d)',numerator,bits);
                    this.replace(divExpr,code);
                else
                    mapping=this.fiOperatorMapper.getMapping('DIVIDE_BY_POW2',true);
                    [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
                    numerator=this.tree2str(op1);
                    code=this.getMappingCallCode(varArgStr,mapping,numerator,num2str(bits));
                    this.replace(divExpr,code);
                end
            end

            function replaceDiv()
                numeratorStr=this.tree2str(op1);
                denominatorStr=this.tree2str(op2);


                defaultMap=coder.internal.FiOperatorMapper.getMappingTable(this.DoubleToSingle());
                divideStr='MRDIVIDE';
                divMapping=this.fiOperatorMapper.getMapping(divideStr,true);
                key=lower(divideStr);
                if defaultMap.isKey(key)
                    defaultDivMapping=defaultMap(key);
                else
                    defaultDivMapping='';
                end


                if~strcmp(defaultDivMapping,divMapping)
                    mapping=divMapping;
                else
                    mapping=this.fiOperatorMapper.getMapping('DIVIDE',true);
                end

                [mapping,varArgStr]=this.fetchMappingAndArgs(mapping);
                if~isempty(mapping)
                    annotatedDivideStr=this.getMappingCallCode(varArgStr,mapping,numeratorStr,denominatorStr);
                    this.replace(divExpr,annotatedDivideStr);
                end
            end
        end

        function tag=getTagForMUL(~,lType,rType)
            tag=[];

            n=coder.internal.translator.F2FMTree('');
            if lType==n.FIXPT||rType==n.FIXPT
                tag=n.FIXPT;
            elseif lType==n.BOOLEAN||rType==n.BOOLEAN
                tag=n.INT;
            elseif lType==n.INT||rType==n.INT
                tag=n.INT;
            end
            this.debugAssert(@()~isempty(tag));
        end








        function needsFiMathToReset=normalizeFixPtBinExprOps(this,op1Node,op2Node,op1Info,op2Info)
            needsFiMathToReset=false;


            if~(op1Node.FIXPT==op1Info.tag&&op2Node.FIXPT==op2Info.tag)
                return;
            end

            fim=this.globalFimath;

            if op1Node.iskind('ID')
                op1VarInfo=op1Info.varTypeInfo;
                op1Fimath=op1VarInfo.getFimath();
            elseif op1Node.iskind('CALL')
                [isOp1Supported,calleeFcnInfo]=this.isUserWrittenFcn(op1Node);
                if isOp1Supported
                    opVarName=calleeFcnInfo.outputVarNames{1};
                    op1VarTypeInfo=calleeFcnInfo.getVarInfo(opVarName);
                    op1Fimath=op1VarTypeInfo.getFimath();
                else
                    op1Fimath=fim;
                end
            else
                op1Fimath=fim;
            end

            if op2Node.iskind('ID')
                op2VarInfo=op2Info.varTypeInfo;
                op2Fimath=op2VarInfo.getFimath();
            elseif op2Node.iskind('CALL')
                [isOp2Supported,calleeFcnInfo]=this.isUserWrittenFcn(op2Node);
                if isOp2Supported
                    opVarName=calleeFcnInfo.outputVarNames{1};
                    op2VarTypeInfo=calleeFcnInfo.getVarInfo(opVarName);
                    op2Fimath=op2VarTypeInfo.getFimath();
                else
                    op2Fimath=fim;
                end
            else
                op2Fimath=fim;
            end

            isFimathEqual=isequal(op1Fimath,op2Fimath);
            if isFimathEqual
                if~isequal(op1Fimath,fim)


                    needsFiMathToReset=true;
                end
                return;
            end



            needsFiMathToReset=true;
            if isequal(op1Fimath,fim)&&~isequal(op2Fimath,fim)

                nodeToCast=op1Node;
            elseif~isequal(op1Fimath,fim)&&isequal(op2Fimath,fim)

                nodeToCast=op2Node;
            elseif~isequal(op1Fimath,fim)&&~isequal(op2Fimath,fim)


                nodeToCast=op2Node;
            end






            newOpString=sprintf('removefimath(%s)'...
            ,this.tree2str(nodeToCast));
            this.replace(nodeToCast,newOpString);
        end




        function visitFiCastINT(this,numericArg)
            this.debugAssert(@()numericArg.iskind('INT'));
            handleFiCastINTOrDOUBLE(this,numericArg);
        end




        function visiFiCastDOUBLE(this,numericArg)
            this.debugAssert(@()numericArg.iskind('DOUBLE'));
            handleFiCastINTOrDOUBLE(this,numericArg);
        end




        function handleFiCastINTOrDOUBLE(this,numericArg)
            this.debugAssert(@()numericArg.iskind('INT')||numericArg.iskind('DOUBLE'));

            numArgStr=this.tree2str(numericArg);
            constType=getConstantFixPtType(this,str2double(numArgStr));
            numArgStr=this.wrapCodeWithType(numArgStr,constType,this.fiMathVarName,numericArg);
            this.replace(numericArg,numArgStr);
        end




        function handleFiCastHEX(this,numericArg)
            this.debugAssert(@()numericArg.iskind('HEX'));

            numArgStr=this.tree2str(numericArg);
            constType=getConstantFixPtType(this,hex2dec(numArgStr(3:end)));
            numArgStr=this.wrapCodeWithType(numArgStr,constType,this.fiMathVarName,numericArg);
            this.replace(numericArg,numArgStr);
        end




        function handleFiCastBINARY(this,numericArg)
            this.debugAssert(@()numericArg.iskind('BINARY'));

            numArgStr=this.tree2str(numericArg);
            constType=getConstantFixPtType(this,bin2dec(numArgStr(3:end)));
            numArgStr=this.wrapCodeWithType(numArgStr,constType,this.fiMathVarName,numericArg);
            this.replace(numericArg,numArgStr);
        end


        function handleStructCall(this,callNode)
            arg=callNode.Right;
            argCount=1;


            while(~isempty(arg))
                if(rem(argCount,2)==0)
                    this.visit(arg,[]);
                else

                end
                arg=arg.Next;
                argCount=argCount+1;
            end
        end

        function isConst=castIfConst(this,node)
            nodeOrig=node;
            while strcmp(node.kind,'PARENS')
                node=node.Arg;
            end
            nodeStr=this.tree2str(node);
            [isConst,cVal,numericType]=getConstType(this,node);
            if isConst&&~isempty(cVal)&&~ischar(cVal)
                if this.DoubleToSingle
                    switch node.kind
                    case{'INT','DOUBLE','HEX','BINARY'}

                        nodeStr=this.wrapCodeWithType(nodeStr,numericType,this.fiMathVarName,node);
                    otherwise
                        mapping=this.fiOperatorMapper.getMapping('SINGLE_CONST',true);
                        if~isempty(mapping)
                            if strcmp(nodeOrig.kind,'PARENS')
                                node=nodeOrig;
                                nodeStr=this.tree2str(node);
                                nodeStr=sprintf('%s%s',mapping,nodeStr);
                            else
                                nodeStr=sprintf('%s(%s)',mapping,nodeStr);
                            end
                        else
                            nodeStr=this.wrapCodeWithType(nodeStr,numericType,this.fiMathVarName,node);
                        end
                    end
                else
                    nodeStr=this.wrapCodeWithType(nodeStr,numericType,this.fiMathVarName,node);
                end
                this.replace(node,nodeStr);
            end
        end

        function val=isLogged(this,node)
            attribs=this.mtreeAttributes(node);
            val=~isempty(attribs)&&~isempty(attribs.SimMin)&&~isempty(attribs.SimMax)&&~isinf(attribs.SimMin)&&~isinf(attribs.SimMax);
        end

        function success=tryfiCastUsingAttribs(this,node)
            if this.castIfConst(node)
                success=true;
            else
                nodeAttrib=this.mtreeAttributes(node);
                simMin=nodeAttrib.SimMin;
                simMax=nodeAttrib.SimMax;

                useNodeInfoForType=~isempty(simMin)&&~isempty(simMax)&&~isinf(simMin)&&~isinf(simMax);
                if useNodeInfoForType
                    alwaysInt=nodeAttrib.IsAlwaysInteger;
                    T=coder.internal.getBestNumericTypeForVal(simMin,simMax,alwaysInt,this.typeProposalSettings);
                    nodeStr=this.tree2str(node);
                    codeStr=this.wrapCodeWithType(nodeStr,T,this.fiMathVarName,node);
                    this.replace(node,codeStr);
                    success=true;
                else
                    success=false;
                end
            end
        end

        function checkConstantRepresentability(this,val,node)
            try
                if isnumeric(val)
                    val=val(:);
                    is_whole=all(floor(val)==val);
                    if is_whole

                        if~isreal(val)
                            representable=dts_exactd2s(imag(val))&&dts_exactd2s(real(val));
                        else
                            representable=dts_exactd2s(val);
                        end
                        if~representable
                            code=node.tree2str(0,1);
                            code=strrep(code,newline,' ');
                            code=strtrim(code);
                            if numel(code)>20
                                code=[code(1:20),'...'];
                            end
                            this.addMessage(this.buildMessage(node,this.WARN,'Coder:FXPCONV:DTS_NonRepresentableIntegerConstantM2M',code));
                        end
                    end
                end
            catch
            end
        end

        function castToGivenIntegerType(this,node,intType)
            nodeStr=this.tree2str(node);
            if nodeStr(1)=='('
                newNodeStr=sprintf('%s%s',intType,nodeStr);
            else
                newNodeStr=sprintf('%s(%s)',intType,nodeStr);
            end

            this.replace(node,newNodeStr);
        end

        function castToIndexType(this,node)
            this.castToGivenIntegerType(node,this.typeProposalSettings.Config.IndexType);
        end

        function type=getOriginalIntegerType(this,node)
            type='';
            typeInfo=this.getOriginalInferredTypeInfo(node);
            if~isempty(typeInfo)
                switch typeInfo.Class
                case{'int8','int16','int32','int64',...
                    'uint8','uint16','uint32','uint64'}
                    type=typeInfo.Class;
                end
            end
        end

        function res=isIntegerValuesDoubelLiteral(~,node)
            res=false;
            try
                if strcmp(node.kind,'DOUBLE')
                    [~,value]=evalc(string(node));
                    res=(value-floor(real(value)))==0;
                end
            catch
            end
        end

        function[tag,lType,rType]=correctTypeMisMatchForBinaryOperations(this,node,lType,rType,lOpNode,rOpNode)
            this.debugAssert(@()any(ismember({'DIV','MUL','PLUS','MINUS','EQ','NE','GT','GE','LT','LE','LDIV','DOTMUL','DOTLDIV'},node.kind())));

            nodeToFiCast=[];

            switch node.kind()
            case{'DIV','MUL','PLUS','MINUS','LDIV','DOTMUL','DOTLDIV'}
                tag=this.getTag(node,lType,rType);
            case{'EQ','NE','GT','GE','LT','LE'}
                tag=node.BOOLEAN;
            end

            if this.fxpConversionSettings.DoubleToSingle
                [tag,lType,rType,omitFurtherCasts]=handleIntegerConstantsForDouble2Single(this,node,tag,lType,rType,lOpNode,rOpNode);
                if omitFurtherCasts


                    return;
                end
            end


            if lType==node.FIXPT&&(rType==node.DOUBLE||rType==node.BOOLEAN)
                nodeToFiCast=rOpNode;
            elseif(lType==node.DOUBLE||lType==node.BOOLEAN)&&rType==node.FIXPT
                nodeToFiCast=lOpNode;
            end
            if~isempty(nodeToFiCast)
                succ=this.tryFiCasting(nodeToFiCast);
                if succ
                    tag=node.FIXPT;
                end

                if succ&&nodeToFiCast==rOpNode
                    rType=tag;
                end
                if succ&&nodeToFiCast==lOpNode
                    lType=tag;
                end
            end
        end

        function success=tryFiCasting(this,node,input)
            success=this.tryfiCastUsingAttribs(node);






            if~success&&~hasNoFiCastableNodes(node)
                this.isInTryFiCastingMode=true;

                input.treatEndAsFIXPT=true;
                input.fiCastConst=true;
                op=this.visit(node,input);
                success=node.FIXPT==op.tag;

                this.isInTryFiCastingMode=false;
            end












            function res=hasNoFiCastableNodes(n)
                res=isempty(subtree(n))||(n.iskind('CALL')&&isempty(n.Right));
            end
        end

        function removeReplacement(this,node)
            idx=find(node);

            if isempty(idx)
                return;
            end

            this.debugAssert(@()length(idx)<=1)


            this.replacements(idx+1)=[];
            this.replacements(idx)=[];

            function idx=find(node)
                idx=[];
                for ii=1:2:length(this.replacements)
                    if node==this.replacements{ii}
                        idx(end+1)=ii;
                    end
                end
            end
        end









        function[tag,lType,rType,omitFurtherCasts]=handleIntegerConstantsForDouble2Single(this,node,tag,lType,rType,lOpNode,rOpNode)





            omitFurtherCasts=false;
            [lIsConst,lcVal,~]=getConstType(this,node.Left);
            [rIsConst,rcVal,~]=getConstType(this,node.Right);

            if lIsConst&&rIsConst
                omitFurtherCasts=true;

                return;
            end


            if lType==node.INT
                tag=node.INT;
                integerType=this.getOriginalIntegerType(lOpNode);
                if isempty(integerType)

                    integerType=this.typeProposalSettings.Config.IndexType;
                else

                end

                if rIsConst



                    if rType==node.DOUBLE||rType==node.BOOLEAN
                        if numel(rcVal)==1


                        else

                            this.castToGivenIntegerType(rOpNode,integerType);
                            rType=node.INT;
                        end
                    end
                    omitFurtherCasts=true;
                    return;
                else

                    if rType==node.DOUBLE||rType==node.FIXPT||rType==node.BOOLEAN
                        this.castToGivenIntegerType(rOpNode,integerType);
                        rType=node.INT;
                    end
                    omitFurtherCasts=true;
                    return;
                end
            end

            if rType==node.INT
                tag=node.INT;
                integerType=this.getOriginalIntegerType(rOpNode);
                if isempty(integerType)

                    integerType=this.typeProposalSettings.Config.IndexType;
                else

                end

                if lIsConst



                    if lType==node.DOUBLE||lType==node.BOOLEAN
                        if numel(lcVal)==1


                        else

                            this.castToGivenIntegerType(lOpNode,integerType);
                            rType=node.INT;
                        end
                    end
                    omitFurtherCasts=true;
                    return;
                else
                    if lType==node.DOUBLE||lType==node.FIXPT||lType==node.BOOLEAN
                        this.castToGivenIntegerType(lOpNode,integerType);
                        lType=node.INT;
                    end
                    omitFurtherCasts=true;
                    return;
                end
            end

            if lIsConst&&rIsConst
                omitFurtherCasts=true;
                return;
            elseif lIsConst&&~rIsConst
                this.checkConstantRepresentability(lcVal,lOpNode);
                if strcmp(lOpNode.kind,'INT')||this.isIntegerValuesDoubelLiteral(lOpNode)


                    omitFurtherCasts=true;
                    return;
                end
            elseif~lIsConst&&rIsConst
                this.checkConstantRepresentability(rcVal,rOpNode);
                if strcmp(rOpNode.kind,'INT')||this.isIntegerValuesDoubelLiteral(rOpNode)


                    omitFurtherCasts=true;
                    return;
                end
            end
        end
    end
end






