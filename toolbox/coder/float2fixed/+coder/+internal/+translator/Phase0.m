


classdef Phase0<coder.internal.translator.Phase
    properties(Constant)
        NO_TEST_CASE='No unit test case written';
        TAG_NOT_ANALYSED='The output type is not analysed here';
        INCONSISTENT_TYPES='The types here at unexpected';
        POTENTIAL_ISSUE='A potential issue with mex';
    end

    properties(Access=private)
unSprtFcnErrMsgs
doubleLoopIndexVars
autoScaleLoopIndexVars
lValNodes

simExprInfo
fcnMtreeStr
unicodeMap



subScrLeftNodeStack






forNodeIndices



















doubleConstLiteralVars
    end

    methods(Access=public)
        function phase0=Phase0(translatorData)
            phase0=phase0@coder.internal.translator.Phase(translatorData);
            phase0.TranslatorData=translatorData;
            phase0.unSprtFcnErrMsgs={};
            phase0.doubleLoopIndexVars=coder.internal.lib.Map();
            phase0.autoScaleLoopIndexVars=translatorData.FxpConversionSettings.autoScaleLoopIndexVars;
            phase0.lValNodes={};

            phase0.simExprInfo=translatorData.FunctionSimulationExprInfo;
            phase0.fcnMtreeStr=translatorData.FunctionTypeInfo.scriptText;
            phase0.unicodeMap=translatorData.FunctionTypeInfo.unicodeMap;

            phase0.subScrLeftNodeStack={};

            phase0.forNodeIndices=phase0.buildForNodeIndicesMap();
            phase0.TranslatorData.ForNodeIndices=phase0.forNodeIndices;
            phase0.doubleConstLiteralVars=phase0.getAllDoubleConstLiteralNodes();
            import coder.internal.translator.*;
        end
    end

    methods(Access=private)


        function dblConstLiteralVars=getAllDoubleConstLiteralNodes(this)
            otherVars={};
            dblConstLiteralVars={};

            assignNodes=this.functionMTree.subtree.mtfind('Kind','EQUALS');
            aIndices=assignNodes.indices;
            for ii=1:count(assignNodes)
                asgnNode=assignNodes.select(aIndices(ii));

                lhsNodes=asgnNode.lhs;
                if isSingleAssignmentNode(this,asgnNode)
                    lIindices=lhsNodes.indices;
                    for jj=1:length(lIindices)
                        node=lhsNodes.select(lIindices(jj));
                        varName=node.tree2str;
                        if strcmp(node.kind,'ID')&&isConst(this,asgnNode.Right)...
                            &&~isOutputVariable(this,varName)...
                            &&~isInputVariable(this,varName)


                            if~isOtherVar(varName)

                                dblConstLiteralVars{end+1}=varName;%#ok<AGROW>
                            end
                        elseif strcmp(node.kind,'ID')&&~isempty(asgnNode.Right)...
                            &&strcmp(asgnNode.Right.kind,'CALL')...
                            &&~isOutputVariable(this,varName)...
                            &&~isInputVariable(this,varName)...
                            &&any(strcmp(asgnNode.Right.Left.string,{'size','length','numel'}))
                            pos=num2str(node.position);
                            if this.simExprInfo.isKey(pos)&&this.simExprInfo(pos).MxInfoID>0
                                dblConstLiteralVars{end+1}=varName;%#ok<AGROW>
                            else
                                otherVars{end+1}=varName;%#ok<AGROW>
                                removeFromConstDoubleList(varName);
                            end
                        else
                            otherVars{end+1}=varName;%#ok<AGROW>
                            removeFromConstDoubleList(varName);
                        end
                    end
                else
                    lVNodes=coder.internal.translator.Phase.getLValNodes(asgnNode);

                    for lv=lVNodes
                        lnode=lv{1};
                        lVarName=lnode.tree2str;
                        otherVars{end+1}=lVarName;%#ok<AGROW>
                        removeFromConstDoubleList(lVarName)
                    end
                end
            end






            function removeFromConstDoubleList(varName)
                if isDoubleConstLitral(varName)
                    dblConstLiteralVars(strcmp(dblConstLiteralVars,varName))=[];
                end
            end



            function ret=isOtherVar(varName)
                ret=any(strcmp(varName,otherVars));
            end



            function ret=isDoubleConstLitral(varName)
                ret=any(strcmp(varName,dblConstLiteralVars));
            end
        end

        function forNodeIndices=buildForNodeIndicesMap(this)
            forNodeIndices=coder.internal.lib.Map();
            forNodes=this.functionMTree.subtree.mtfind('Kind','FOR');
            indices=forNodes.indices;
            for ii=1:count(forNodes)
                forNode=forNodes.select(indices(ii));
                indexNode=forNode.Index;
                indexVarName=indexNode.string;


                if forNodeIndices.isKey(indexVarName)
                    forNodeIndices.add(indexVarName,[forNodeIndices(indexVarName),{indexNode}]);
                else
                    forNodeIndices.add(indexVarName,{indexNode});
                end
            end
        end




        function buildMtreeAttributesFromVarTypeInfo(this,node,varTypeInfo)
            if~isempty(varTypeInfo)
                simMin=varTypeInfo.SimMin;
                simMax=varTypeInfo.SimMax;
                isAlwaysInteger=varTypeInfo.IsAlwaysInteger;

                this.fillMtreeAttributes(node,simMin,simMax,isAlwaysInteger);
            end
        end

        function fillMtreeAttributes(this,node,simMin,simMax,isAlwaysInteger)
            if this.typeProposalSettings.useSimulationRanges
                this.mtreeAttributes(node).SimMin=simMin;
                this.mtreeAttributes(node).SimMax=simMax;
            end
            this.mtreeAttributes(node).IsAlwaysInteger=isAlwaysInteger;
        end

        function fillMxLocationInfo(this,node)
            pos=num2str(node.position);

            if this.simExprInfo.isKey(pos)
                mxlocInfo=this.simExprInfo(pos);

                this.mtreeAttributes(node).MxLocInfo=mxlocInfo;
                simMin=mxlocInfo.SimMin;
                simMax=mxlocInfo.SimMax;
                isAlwaysInteger=mxlocInfo.IsAlwaysInteger;

                this.fillMtreeAttributes(node,simMin,simMax,isAlwaysInteger);

                exprLength=mxlocInfo.TextLength;
                textStart=mxlocInfo.TextStart;
                [textStart,exprLength]=coder.internal.FcnInfoRegistryBuilder.getUnicodedStartLenght(this.unicodeMap,textStart,exprLength);
                textEnd=textStart+exprLength-1;

                this.mtreeAttributes(node).ScriptString=this.fcnMtreeStr(textStart:textEnd);
                this.mtreeAttributes(node).Kind=node.kind;
            else

            end
        end

        function pushSubScrStack(this,subScrLeftNode)
            this.subScrLeftNodeStack{end+1}=subScrLeftNode;
        end

        function subScrLeftNode=peekSubScrStack(this)
            subScrLeftNode=this.subScrLeftNodeStack{end};
        end

        function popSubScrStack(this)
            this.subScrLeftNodeStack(end)=[];
        end
    end

    methods(Access=protected)


        function replace(this,node,str)%#ok<INUSD>
            error('No replacements allowed in Phase0! This is against the philosophy of this phase, which is meant for only information processing/synthesizing and not mtree replacements/modification');
        end
    end

    methods(Access=public)

        function output=visit(this,node,input)
            this.fillMxLocationInfo(node);
            output=visit@coder.internal.translator.Phase(this,node,input);
        end

        function[replacements,mtreeAttribs,uniqueNamesService]=run(this,indentLevel)
            if nargin>=2
                this.indentLevel=indentLevel;
            end
            this.visit(this.functionMTree,[]);
            replacements=this.replacements;
            mtreeAttribs=this.mtreeAttributes;
            uniqueNamesService=this.uniqueNamesService;

            cellfun(@(varName)setIsLiteralDoubleConstantPropertyFor(varName)...
            ,this.doubleConstLiteralVars);


            this.debugAssert(@()isempty(this.subScrLeftNodeStack));


            this.TranslatorData.ForNodeIndices=this.forNodeIndices;





            function setIsLiteralDoubleConstantPropertyFor(varName)
                varInfos=this.functionTypeInfo.getVarInfosByName(varName);
                cellfun(@(varInfo)varInfo.setIsLiteralDoubleConstant(true),varInfos);
            end
        end


        function output=visitFUNCTION(this,functionNode,input)
            if this.fxpConversionSettings.detectDeadCode&&~this.treeAttributes(functionNode).isExecutedInSimulation
                output.tag=functionNode.UNDEF;
            else
                output=this.visitBody(functionNode.Body,input);
            end
        end


        function output=visitEQUALS(this,assignNode,input)
            lValueNodes=coder.internal.translator.Phase.getLValNodes(assignNode);
            lValVarNames=cellfun(@(node)node.tree2str,lValueNodes,'UniformOutput',false);

            for ii=1:numel(lValVarNames)
                lValVar=lValVarNames{ii};
                if this.forNodeIndices.isKey(lValVar)
                    assignedForIndexNodes=this.forNodeIndices.get(lValVar);
                    for kk=1:numel(assignedForIndexNodes)
                        forIndexNode=assignedForIndexNodes{kk};
                        this.mtreeAttributes(forIndexNode).ForIndexUsedLater=true;
                    end
                end
            end

            this.visit(assignNode.Left,input);
            output=this.visit(assignNode.Right,input);
        end


        function output=visitID(this,idNode,~)
            output=[];
            varName=idNode.string;

            this.uniqueNamesService.distinguishName(varName);

            varInfo=getIDType(this,idNode);
            if~isempty(varInfo)&&isempty(varInfo.annotated_Type)







                varInfo=[];
            end
            this.buildMtreeAttributesFromVarTypeInfo(idNode,varInfo);

            output.varTypeInfo=varInfo;

            if this.forNodeIndices.isKey(varName)




                parent=idNode.trueparent;
                usedInSubscript=true;
                while~isempty(parent)&&~this.isRootStatementNode(parent)
                    if this.isBinaryArithmeticOp(parent)||parent.iskind('CALL')
                        usedInSubscript=false;
                    end
                    if parent.iskind('SUBSCR')||parent.iskind('FOR')||...
                        parent.iskind('COLON')




                        usedInSubscript=true;
                        break
                    end
                    parent=parent.trueparent;
                end
                if~usedInSubscript
                    setForNodeAssignedLater(this,varName,true);
                end
            end
        end




        function output=visitSUBSCR(this,subScrNode,input)

            this.pushSubScrStack(subScrNode.Left);
            output=handleSubScrNode(subScrNode,input);
            this.popSubScrStack();

            function output=handleSubScrNode(subScrNode,input)
                output=[];
                vector=subScrNode.Left;
                this.visit(vector,input);
                promoteRangeFromTo(vector,subScrNode);

                index=subScrNode.Right;
                this.visitNodeList(index,input);




                function promoteRangeFromTo(virtualIDNode,subScriptNode)
                    this.copyAttributesFromTo(virtualIDNode,subScriptNode);
                end
            end
        end


        function output=visitDOT(this,dotNode,~)

            this.debugAssert(@()~isempty(dotNode));


            varInfo=getIDType(this,dotNode);

            this.buildMtreeAttributesFromVarTypeInfo(dotNode,varInfo);
            output.varTypeInfo=varInfo;
        end



        function output=visitPARENS(this,node,input)
            output=this.visit(node.Arg,input);
            mtreeAttrib=this.mtreeAttributes(node);
            if isempty(mtreeAttrib.SimMin)||isempty(mtreeAttrib.SimMax)||isempty(mtreeAttrib.IsAlwaysInteger)
                mtreeAttrib=this.mtreeAttributes(node.Arg);
                this.mtreeAttributes(node).SimMin=mtreeAttrib.SimMin;
                this.mtreeAttributes(node).SimMax=mtreeAttrib.SimMax;
                this.mtreeAttributes(node).IsAlwaysInteger=mtreeAttrib.IsAlwaysInteger;
            end
        end


        function output=visitUNEXPR(this,unaryExpr,input)
            expr=unaryExpr.Arg;
            kind=unaryExpr.kind;
            output=[];
            switch kind
            case{'NOT'}
                this.visit(expr,input);

            case{'UMINUS'}
                output=this.visit(expr,input);
                this.copyAttributesFromTo(expr,unaryExpr);

            case{'TRANS'}
                output=this.visit(expr,input);
                this.copyAttributesFromTo(expr,unaryExpr);
            case{'DOTTRANS','UPLUS'}
                output=this.visit(expr,input);
            end
        end


        function output=visitCALL(this,callNode,input)

            callee=string(callNode.Left);

            switch callee
            case{'end'}

                subScrLeftNode=this.peekSubScrStack();

                nodeAttrib=this.mtreeAttributes(subScrLeftNode);
                mxInfoID=[];
                if~isempty(nodeAttrib.MxLocInfo)
                    mxInfoID=nodeAttrib.MxLocInfo.MxInfoID;
                else
                    varInfo=this.getIDType(subScrLeftNode);
                    if~isempty(varInfo)
                        mxInfoID=varInfo.MxInfoID;
                    end
                end
                if~isempty(mxInfoID)
                    mxInfo=this.functionTypeInfoRegistry.mxInfos{mxInfoID};
                    exprSize=mxInfo.Size;




                    if~any(exprSize<0)
                        minValue=0;
                        maxValue=double(prod(exprSize));

                        this.mtreeAttributes(callNode).SimMin=minValue;
                        this.mtreeAttributes(callNode).SimMax=maxValue;
                        this.mtreeAttributes(callNode).IsAlwaysInteger=true;
                    end
                end
                output=[];
            case{'zeros','ones','eye'}
                arg=callNode.Right;
                while~isempty(arg)
                    this.visit(arg,[]);
                    arg=arg.Next;
                end

                if strcmp(callee,'zeros')
                    exprValue=0;
                elseif strcmp(callee,'ones')||strcmp(callee,'eye')
                    exprValue=1;
                else
                    assert(0,'incorrect callee, expected zeros or ones');
                end
                this.mtreeAttributes(callNode).SimMin=exprValue;
                this.mtreeAttributes(callNode).SimMax=exprValue;
                this.mtreeAttributes(callNode).IsAlwaysInteger=true;
                output=[];

            case{'ndims'}
                this.visit(callNode.Left,input);
                expr=callNode.Right;
                output=this.visitNodeList(expr,input);
                [isConst,exprValue,~]=this.getConstType(expr);
                if isConst
                    exprSize=size(exprValue);
                    this.mtreeAttributes(callNode).SimMin=length(exprSize);
                    this.mtreeAttributes(callNode).SimMax=length(exprSize);
                    this.mtreeAttributes(callNode).IsAlwaysInteger=true;
                else
                    lenExprAttrib=this.mtreeAttributes(expr);
                    if~isempty(lenExprAttrib.MxLocInfo)
                        mxInfoID=lenExprAttrib.MxLocInfo.MxInfoID;
                        exprSize=this.functionTypeInfoRegistry.mxInfos{mxInfoID}.Size;

                        this.mtreeAttributes(callNode).SimMin=length(exprSize);
                        this.mtreeAttributes(callNode).SimMax=length(exprSize);
                        this.mtreeAttributes(callNode).IsAlwaysInteger=true;
                    end
                end

            case{'length','size'}
                this.visit(callNode.Left,input);
                expr=callNode.Right;
                output=this.visitNodeList(expr,input);
                [isConst,exprValue,~]=this.getConstType(expr);
                if isConst
                    this.mtreeAttributes(callNode).SimMin=min(exprValue);
                    this.mtreeAttributes(callNode).SimMax=max(exprValue);
                    this.mtreeAttributes(callNode).IsAlwaysInteger=true;
                else
                    lenExprAttrib=this.mtreeAttributes(expr);
                    if~isempty(lenExprAttrib.MxLocInfo)
                        mxInfoID=lenExprAttrib.MxLocInfo.MxInfoID;
                        exprSize=this.functionTypeInfoRegistry.mxInfos{mxInfoID}.Size;
                        minValue=double(min(exprSize));
                        maxValue=double(max(exprSize));

                        this.mtreeAttributes(callNode).SimMin=minValue;
                        this.mtreeAttributes(callNode).SimMax=maxValue;
                        this.mtreeAttributes(callNode).IsAlwaysInteger=true;
                    end
                end
            otherwise
                this.visit(callNode.Left,input);
                output=this.visitNodeList(callNode.Right,input);
            end
        end
    end

    methods(Access=private)
        function copyAttributesFromTo(this,fromNode,node)
            fromAttribs=this.mtreeAttributes(fromNode);
            this.mtreeAttributes(node).SimMin=fromAttribs.SimMin;
            this.mtreeAttributes(node).SimMax=fromAttribs.SimMax;
            this.mtreeAttributes(node).IsAlwaysInteger=fromAttribs.IsAlwaysInteger;
        end
    end
    methods(Static,Access=private)
        function out=isBinaryArithmeticOp(node)
            arithOps={'PLUS','MINUS','MUL','DIV','LDIV','EXP',...
            'DOTMUL','DOTDIV','DOTLDIV','DOTEXP'};
            out=node.iskind(arithOps);
        end
        function out=isRootStatementNode(node)
            statementNodes={'EXPR','PRINT','EQUALS','IF','SWITCH',...
            'WHILE'};
            out=node.iskind(statementNodes);
        end
    end
end