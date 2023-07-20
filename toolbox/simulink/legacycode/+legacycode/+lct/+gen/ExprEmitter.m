





classdef ExprEmitter<legacycode.lct.spec.ExprVisitor&legacycode.lct.gen.CodeEmitter


    properties(SetAccess=protected,GetAccess=protected)
TxtBuffer
    end


    properties
Optimize
    end


    methods




        function this=ExprEmitter(expr,lctObj)


            narginchk(1,2);


            this@legacycode.lct.spec.ExprVisitor(expr);


            if nargin==2
                this.setLctSpecInfo(lctObj);
            end


            this.Optimize=false;
        end




        function str=emit(this,varargin)


            this.TxtBuffer='';


            visit(this);


            str=this.TxtBuffer;
        end




        function set.Optimize(this,val)
            validateattributes(val,{'logical'},{'scalar','nonempty'},1);
            this.Optimize=val;
        end
    end


    methods(Access=protected)




        function visitParens(this,node)

            [ok,val]=this.evalExpr(node);

            if this.Optimize&&ok
                this.sprintf('%g',val);
            else

                this.sprintf('(');
                this.visit(node);
                this.sprintf(')');
            end
        end




        function visitBinaryOp(this,op,lnode,rnode)

            [ok1,val1]=this.evalExpr(lnode);
            [ok2,val2]=this.evalExpr(rnode);

            if ok1&&ok2

                this.sprintf('%g',eval(sprintf('%g%c%g',val1,op,val2)));
            else

                this.emitNode(lnode,val1);
                this.sprintf('%c',op);
                this.emitNode(rnode,val2);
            end
        end




        function visitUnaryOp(this,op,node)

            [~,val]=this.evalExpr(node);

            this.sprintf('%c',op);
            this.emitNode(node,val);
        end




        function visitInt(this,val)
            this.sprintf('%d',val);
        end




        function visitDouble(this,val)
            this.sprintf('%g',val);
        end




        function visitParamValue(this,idx)
            this.sprintf('p%d',idx);
        end




        function visitSizeFcn(this,radix,idx,val)
            this.sprintf('size(%s%d, %d)',radix,idx,val);
        end




        function visitNumelFcn(this,radix,idx)
            this.sprintf('numel(%s%d)',radix,idx);
        end




        function emitNode(this,node,val)
            if~isempty(val)

                this.sprintf('%g',val);
            else


                if this.Optimize
                    this.sprintf('(');
                end
                this.visit(node);
                if this.Optimize
                    this.sprintf(')');
                end
            end
        end




        function[status,val]=evalExpr(this,node)
            status=false;
            val=[];
            if this.Optimize&&this.hasLiteralExprOnly(node)
                try
                    val=eval(tree2str(node));
                    status=true;
                catch
                end
            end
        end





        function status=hasLiteralExprOnly(this,node)

            if nargin<2
                node=root(this.Tree);
            end

            status=kernel(node,true);

            function status=kernel(node,status)
                if~status||isnull(node)||isnull(wholetree(node))
                    return
                end

                switch node.kind
                case{'PRINT','EXPR','PARENS','UMINUS','UPLUS'}
                    status=kernel(Arg(node),status);
                case{'DIV','MUL','PLUS','MINUS'}
                    status=kernel(Left(node),status);
                    status=kernel(Right(node),status);
                case{'INT','DOUBLE'}
                    status=true;
                otherwise
                    status=false;
                end
            end
        end




        function sprintf(this,varargin)
            this.TxtBuffer=[this.TxtBuffer,sprintf(varargin{:})];
        end
    end

end


