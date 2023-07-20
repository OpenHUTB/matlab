






classdef ExprVisitor<handle


    properties(Constant,Access=protected)

        OpMap=containers.Map(...
        {'PLUS','MINUS','MUL','DIV','UPLUS','UMINUS'},...
        {'+','-','*','/','+','-'}...
        )
    end


    properties(SetAccess=protected)
Expr
    end


    properties(SetAccess=protected,Hidden)
Tree
Tree2StrFcn
ErrorFcn

ExprInfo
    end


    methods




        function this=ExprVisitor(expr)

            narginchk(1,1);
            validateattributes(expr,{'char','string'},{'scalartext'},1);
            expr=char(expr);


            this.Expr=expr;
            this.Tree=mtree(expr);



            this.Tree2StrFcn=@(node)regexprep(tree2str(node),'[\s|\n]+$','');


            this.ErrorFcn=@(id,args)throw(MException(message(['Simulink:tools:',id],args{:})));
        end




        function exprInfo=getExprInfo(this,removeExpression)

            if nargin<2
                removeExpression=true;
            end


            this.ExprInfo=legacycode.lct.spec.ExprInfo.empty();


            visit(this);



            exprInfo=this.ExprInfo;
            if~isempty(exprInfo)

                allKinds={exprInfo.Kind};
                idxExpr=find(strcmp('e',allKinds));

                if removeExpression

                    exprInfo(idxExpr)=[];
                else

                    exprInfo(idxExpr(2:end))=[];
                end
            end
        end

    end


    methods(Access=protected)





        function visit(this,node)

            if nargin<2
                node=root(this.Tree);
            end

            if isnull(node)||isnull(wholetree(node))
                return
            end

            switch node.kind
            case 'ERR'



                errResults=regexp(string(node),'^L\s*\S+\s*\(C\s*\S+\)\:\s*(\w+\:\s*.*)','tokens','once');
                if numel(errResults)==1
                    msg=regexprep(errResults{1},'.*SYNER:\s*(.*)','$1','preservecase');
                    this.ErrorFcn('LCTSizeSpecParserBadSizeSyntaxWithDesc',{msg});
                else

                    this.ErrorFcn('LCTSizeSpecParserBadSizeSyntax',{});
                end

            case{'PRINT','EXPR'}

                this.visit(Arg(node));

            case 'PARENS'
                this.visitParens(Arg(node));

            case{'UMINUS','UPLUS'}
                argNode=Arg(node);
                if~isnull(argNode)&&strcmp(argNode.kind,'INT')

                    val=sscanf(string(argNode),'%d');
                    if strcmp(node.kind,'UMINUS')
                        val=-val;
                    end
                    this.visitInt(val);
                else

                    this.visitUnaryOp(this.OpMap(node.kind),argNode);
                end

            case{'DIV','MUL','PLUS','MINUS'}
                this.visitBinaryOp(this.OpMap(node.kind),Left(node),Right(node));

            case 'ID'

                id=string(node);
                if lower(id)=="inf"&&legacycode.lct.util.feature('supportDynamicArrays')
                    return
                end
                [radix,idx]=legacycode.lct.spec.Common.splitIdentifier(id);
                if isempty(radix)||idx<1
                    this.ErrorFcn('LCTSpecBadId',{id});
                end


                if~strcmpi(radix,'p')
                    this.ErrorFcn('LCTSizeSpecParserSizeExprNotParameterAccess',{id});
                end

                this.visitParamValue(idx);

            case 'INT'
                this.visitInt(sscanf(string(node),'%d'));

            case 'DOUBLE'
                this.visitDouble(sscanf(string(node),'%g'));

            case 'CALL'

                callee=Left(node);
                firstArg=Right(node);

                if isnull(firstArg)


                    this.visit(callee);
                else


                    fcnName=string(callee);
                    if~ismember(fcnName,{'size','numel'})
                        this.ErrorFcn('LCTSizeSpecParserSizeExprNotSupportedFun',{fcnName});
                    end


                    if~strcmp(firstArg.kind,'CALL')
                        this.ErrorFcn('LCTSizeSpecParserSizeExprArg1NotCallNode',...
                        {this.Tree2StrFcn(firstArg),fcnName});
                    end
                    varName=string(Left(firstArg));
                    [radix,idx]=legacycode.lct.spec.Common.splitIdentifier(varName);
                    if isempty(radix)||idx<1
                        this.ErrorFcn('LCTSpecBadId',{varName});
                    end


                    numArgs=1;
                    arg=firstArg;
                    while~isnull(Next(arg))
                        numArgs=numArgs+1;
                        arg=Next(arg);
                    end


                    if strcmp(fcnName,'size')


                        if numArgs~=2
                            this.ErrorFcn('LCTSizeSpecParserSizeExprBadSizeNumArg',{numArgs});
                        end


                        secondArg=Next(firstArg);
                        if~strcmp(secondArg.kind,'INT')
                            this.ErrorFcn('LCTSizeSpecParserSizeExprArg2NotInt',...
                            {this.Tree2StrFcn(secondArg)});
                        end


                        val=sscanf(string(secondArg),'%d');
                        if val<1
                            this.ErrorFcn('LCTSizeSpecParserSizeExprArg2NotPosInt',{val});
                        end

                        this.visitSizeFcn(radix,idx,val);

                    else

                        if numArgs~=1
                            this.ErrorFcn('LCTSizeSpecParserSizeExprBadNumelNumArg',{numArgs});
                        end

                        this.visitNumelFcn(radix,idx);
                    end
                end

            otherwise
                this.ErrorFcn('LCTSizeSpecParserSizeExprBadOp',{this.Tree2StrFcn(node)});
            end
        end




        function visitParens(this,node)
            this.ExprInfo(end+1)=legacycode.lct.spec.ExprInfo('e');
            this.visit(node);
        end




        function visitBinaryOp(this,op,lnode,rnode)%#ok<INUSL>
            this.ExprInfo(end+1)=legacycode.lct.spec.ExprInfo('e');
            this.visit(lnode);
            this.visit(rnode);
        end




        function visitUnaryOp(this,op,node)%#ok<INUSL>
            this.ExprInfo(end+1)=legacycode.lct.spec.ExprInfo('e');
            this.visit(node);
        end




        function visitInt(this,val)
            this.ExprInfo(end+1)=...
            legacycode.lct.spec.ExprInfo('i',sprintf('%d',val),val);
        end




        function visitDouble(this,val)
            this.ExprInfo(end+1)=...
            legacycode.lct.spec.ExprInfo('d',sprintf('%g',val),val);
        end




        function visitParamValue(this,idx)
            this.ExprInfo(end+1)=...
            legacycode.lct.spec.ExprInfo('v',sprintf('p%d',idx),[],'p',idx);
        end




        function visitSizeFcn(this,radix,idx,val)
            this.ExprInfo(end+1)=...
            legacycode.lct.spec.ExprInfo('s',[radix,sprintf('%d',idx)],val,radix,idx);
        end




        function visitNumelFcn(this,radix,idx)
            this.ExprInfo(end+1)=...
            legacycode.lct.spec.ExprInfo('n',[radix,sprintf('%d',idx)],[],radix,idx);
        end

    end

end


