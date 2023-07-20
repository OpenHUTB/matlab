




classdef MTreeVisitor<handle

    properties
treeAttributes
    end

    methods(Access=public)
        function this=MTreeVisitor(attribs)
            if nargin==0
                attribs=[];
            end
            this.treeAttributes=attribs;
        end
    end

    methods(Access=public)
        function output=visit(visitor,node,input)
            method=visitor.resolveMethod(node);
            output=method(node,input);
        end

        function output=visitNodeList(visitor,nodeList,input)
            output=[];
            node=nodeList;
            while~isempty(node)
                output=visitor.visit(node,input);
                node=node.Next;
            end
        end
    end

    methods(Access=public)


        function output=visitUNEXPR(visitor,node,input)
            output=visitor.visit(node.Arg,input);
        end


        function output=visitBINEXPR(visitor,node,input)
            visitor.visit(node.Left,input);
            output=visitor.visit(node.Right,input);
        end


        function output=visitRELBINEXPR(visitor,node,input)
            visitor.visit(node.Left,input);
            output=visitor.visit(node.Right,input);
        end


        function output=visitLOGBINEXPR(visitor,node,input)
            visitor.visit(node.Left,input);
            output=visitor.visit(node.Right,input);
        end


        function output=visitDOTBINEXPR(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitPARENS(visitor,node,input)
            output=visitor.visit(node.Arg,input);
        end


        function output=visitEQUALS(visitor,assignNode,input)
            visitor.visit(assignNode.Left,input);
            output=visitor.visit(assignNode.Right,input);
        end


        function output=visitID(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitSUBSCR(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitLITERAL(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitCALL(visitor,callNode,input)
            visitor.visit(callNode.Left,input);
            output=visitor.visitNodeList(callNode.Right,input);
        end


        function output=visitDCALL(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitLB(visitor,node,input)
            output=[];

            row=node.Arg;
            if row.iskind('ROW')
                while(~isempty(row))
                    items=row.Arg;



                    if~isempty(items)
                        output=visitor.visitNodeList(items,input);
                    end

                    row=row.Next;
                end
            else
                lhsArgs=row;
                if~isempty(lhsArgs)
                    output=visitor.visitNodeList(lhsArgs,input);
                end
            end
        end


        function output=visitLC(visitor,node,input)
            row=node.Arg;
            items=row.Arg;
            if isempty(items)
                items=row;
            end
            output=visitor.visitNodeList(items,input);
        end


        function output=visitCOLON(visitor,node,input)
            output=[];
            start=node.Left;
            step=[];
            stop=node.Right;

            if~isempty(start)
                if strcmp(start.kind,'COLON')
                    cNode=start;
                    start=cNode.Left;
                    step=cNode.Right;
                end
            end

            if~isempty(start)
                visitor.visit(start,input);
            end
            if~isempty(step)
                visitor.visit(step,input);
            end
            if~isempty(stop)
                visitor.visit(stop,input);
            end
        end


        function output=visitLP(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitCOMMENT(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitBLOCKCOMMENT(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitARGUMENTS(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitFUNCTION(visitor,node,input)
            args=node.Arguments;
            if~isempty(args)
                visitor.visit(args,input);
            end
            output=visitor.visitBody(node.Body,input);
        end


        function output=visitIF(visitor,node,input)
            ifHead=node.Arg;


            condition=ifHead.Left;
            visitor.visit(condition,input);


            visitor.visitBody(ifHead.Body,input);


            output=visitor.visitNodeList(ifHead.Next,input);
        end


        function output=visitELSEIF(visitor,node,input)

            condition=node.Left;
            visitor.visit(condition,input);

            output=visitor.visitBody(node.Body,input);
        end


        function output=visitELSE(visitor,node,input)
            output=visitor.visitBody(node.Body,input);
        end


        function output=visitFOR(visitor,forNode,input)
            vector=forNode.Vector;
            visitor.visit(vector,input);


            body=forNode.Body;
            output=visitor.visitBody(body,input);
        end


        function output=visitBREAK(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitCONTINUE(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitWHILE(visitor,node,input)

            condition=node.Left;
            visitor.visit(condition,input);


            output=visitor.visitBody(node.Body,input);
        end



        function output=visitSWITCH(visitor,switchNode,input)
            switchExpr=switchNode.Left;
            visitor.visit(switchExpr,input);


            output=visitor.visitBody(switchNode.Body,input);
        end



        function output=visitCASE(visitor,caseNode,input)



            output=visitor.visitBody(caseNode.Body,input);
        end


        function output=visitOTHERWISE(visitor,node,input)
            output=visitor.visitBody(node.Body,input);
        end


        function output=visitEXPR(visitor,node,input)
            output=visitor.visit(node.Arg,input);
        end


        function output=visitCELL(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitDOT(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitDOTLP(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitPERSISTENT(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitGLOBAL(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitPRINT(visitor,node,input)
            output=[];
            visitor.visit(node.Arg,input);
        end


        function output=visitRETURN(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitPARFOR(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitNoNameVar(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitAT(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitANON(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitROW(visitor,node,input);output=[];end %#ok<INUSD>


        function output=visitCLASSDEF(visitor,node,input)
            cexpr=node.Cexpr;
            classNameNode=[];
            baseClassNode=[];
            switch cexpr.kind
            case 'ID'
                classNameNode=cexpr;
            case 'LT'
                classNameNode=cexpr.Left;
                baseClassNode=cexpr.Right;

            end
            visitor.visitClassName(classNameNode,input);
            visitor.visitBaseClass(baseClassNode,input);

            output=visitor.visitClassBody(node.Body,input);
        end


        function output=visitClassName(visitor,classNameNode,input);output=[];end %#ok<INUSD>


        function output=visitBaseClass(visitor,baseClassNode,input);output=[];end %#ok<INUSD>

        function output=visitClassBody(visitor,body,input)
            output=[];
            node=body;
            while~isempty(node)
                output=visitor.visit(node,input);
                node=node.Next;
            end
        end

        function output=visitATBASE(visitor,node,input);output=[];end %#ok<INUSD>

        function output=visitPROPERTIES(visitor,properties,input)
            output=[];
            propDecl=properties.Body;
            while~isempty(propDecl)
                propName=[];
                value=[];
                switch propDecl.kind
                case 'ID'
                    propName=propDecl;
                case 'EQUALS'
                    propName=propDecl.Left;
                    value=propDecl.Right;
                case 'COMMENT'

                end
                if~isempty(propName)
                    output=visitor.visitProperty(propName,value,input);
                end

                propDecl=propDecl.Next;
            end
        end


        function output=visitProperty(visitor,propName,value,input);output=[];end %#ok<INUSD>

        function output=visitMETHODS(visitor,methods,input)
            output=[];
            meth=methods.Body;
            while~isempty(meth)
                output=visitor.visit(meth,input);
                meth=meth.Next;
            end
        end

        function output=visitNAMEVALUE(visitor,node,input)
            visitor.visit(node.Left,input);
            output=visitor.visit(node.Right,input);
        end

        function output=visitFIELD(visitor,node,input)%#ok<INUSD>
            output=[];
        end


        function output=visitMethodCall(this,node,input)%#ok<INUSD>
            output=[];
        end
    end

    methods(Access=protected)
        function output=visitBody(visitor,body,data)
            output=visitor.visitNodeList(body,data);
        end
    end

    methods(Access=public)

        function method=resolveMethod(this,node)
            kind=node.kind;
            switch kind

            case{'ID'}
                if~isempty(this.treeAttributes)&&~isempty(this.treeAttributes(node).CalledFunction)

                    method=@this.visitMethodCall;
                else
                    method=@this.visitID;
                end

            case{'EQUALS'}
                if~isempty(this.treeAttributes)&&~isempty(this.treeAttributes(node).CalledFunction)

                    method=@this.visitMethodCall;
                else
                    method=@this.visitEQUALS;
                end

            case{'UMINUS','UPLUS','TRANS','DOTTRANS'}
                method=@this.visitUNEXPR;

            case{'PLUS','MINUS','MUL','DIV','EXP','DOTMUL','DOTDIV','DOTLDIV','DOTEXP','LDIV'}
                method=@this.visitBINEXPR;

            case{'EQ','NE','GT','GE','LT','LE'}
                method=@this.visitRELBINEXPR;

            case{'ANDAND','OROR','AND','OR'}
                method=@this.visitLOGBINEXPR;

            case{'PARENS'}
                method=@this.visitPARENS;

            case{'SUBSCR'}
                if~isempty(this.treeAttributes)&&~isempty(this.treeAttributes(node).CalledFunction)

                    method=@this.visitMethodCall;
                else
                    method=@this.visitSUBSCR;
                end

            case{'INT','DOUBLE','HEX','BINARY','CHARVECTOR','STRING'}
                method=@this.visitLITERAL;

            case{'CALL'}
                if~isempty(this.treeAttributes)
                    callee=this.treeAttributes(node).CalledFunction;
                    if~isempty(callee)&&~isempty(callee.className)

                        method=@this.visitMethodCall;
                    else
                        method=@this.visitCALL;
                    end
                else
                    method=@this.visitCALL;
                end

            case{'DCALL'}
                method=@this.visitDCALL;

            case{'NOT'}
                arg=node.Arg;
                if isempty(arg)
                    method=@this.visitNoNameVar;
                else
                    method=@this.visitUNEXPR;
                end

            case{'LB'}
                method=@this.visitLB;

            case{'LC'}
                method=@this.visitLC;

            case{'COLON'}
                method=@this.visitCOLON;

            case{'LP'}
                if~isempty(this.treeAttributes)&&~isempty(this.treeAttributes(node).CalledFunction)

                    method=@this.visitMethodCall;
                else
                    method=@this.visitLP;
                end

            case{'COMMENT'}
                method=@this.visitCOMMENT;

            case{'BLKCOM'}
                method=@this.visitBLOCKCOMMENT;

            case{'FUNCTION'}
                method=@this.visitFUNCTION;

            case{'IF'}
                method=@this.visitIF;

            case{'ELSEIF'}
                method=@this.visitELSEIF;

            case{'ELSE'}
                method=@this.visitELSE;

            case{'FOR'}
                method=@this.visitFOR;

            case{'WHILE'}
                method=@this.visitWHILE;

            case{'BREAK','CONTINUE'}
                method=@this.visitBREAK;

            case{'SWITCH'}
                method=@this.visitSWITCH;

            case{'CASE'}
                method=@this.visitCASE;

            case{'OTHERWISE'}
                method=@this.visitOTHERWISE;

            case{'EXPR'}
                method=@this.visitEXPR;

            case{'CELL'}
                method=@this.visitCELL;

            case{'DOT'}
                if~isempty(this.treeAttributes)&&~isempty(this.treeAttributes(node).CalledFunction)

                    method=@this.visitMethodCall;
                else
                    method=@this.visitDOT;
                end

            case{'DOTLP'}
                method=@this.visitDOTLP;

            case{'PERSISTENT'}
                method=@this.visitPERSISTENT;

            case 'GLOBAL'
                method=@this.visitGLOBAL;

            case{'PRINT'}
                method=@this.visitPRINT;

            case{'RETURN'}
                method=@this.visitRETURN;

            case{'PARFOR'}
                method=@this.visitPARFOR;

            case{'CLASSDEF'}
                method=@this.visitCLASSDEF;

            case{'PROPERTIES'}
                method=@this.visitPROPERTIES;

            case{'METHODS'}
                method=@this.visitMETHODS;

            case{'ATBASE'}
                method=@this.visitATBASE;

            case{'NAMEVALUE'}
                method=@this.visitNAMEVALUE;

            case{'FIELD'}
                method=@this.visitFIELD;

            otherwise
                methodName=['visit',kind];%#ok<NASGU>
                evalc(['method = @this.visit',kind]);
            end
        end
    end
end



