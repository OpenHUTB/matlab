



classdef LadderArgParser<plccore.frontend.L5X.MtreeVisitor




    properties
        IR;
    end

    properties(Access=protected)
        defaultMsgID;
        Ctx;
        POU;
        operand;
        rungTxt;
        operatorStack(1,:)cell;
        arrayStack(1,:)cell;
        DOTStack(1,:)cell;
        negation(1,1)logical=false;
    end

    methods(Access=public)

        function this=LadderArgParser(tree,ctx,pou,operand,rungTxt)
            this@plccore.frontend.L5X.MtreeVisitor(tree)
            this.messages='';
            this.Ctx=ctx;
            this.POU=pou;
            this.operand=operand;
            this.rungTxt=rungTxt;
        end

        function messages=run(this)
            this.visit(this.tree)
            messages=this.messages;
        end
    end

    methods(Access=protected)
        function addMessage(this,node,~,~,~)
            if~ismember(node.kind,{'ID','PRINT','CALL','DOT','INT','DOUBLE','STRING','UMINUS'})
                error(['Unsupported operator found in operand : ',this.operand,newline,' In rung : ',this.rungTxt]);
            end
        end

        function postProcessINT(this,node)
            nodeVal=this.getNodeVal(node);
            if isempty(this.operatorStack)
                retSimpleIR(this,nodeVal,node.kind)
            else
                this.putOnStack(nodeVal);
            end
        end

        function postProcessDOUBLE(this,node)
            nodeVal=this.getNodeVal(node);
            if isempty(this.operatorStack)
                retSimpleIR(this,nodeVal,node.kind)
            else
                this.putOnStack(nodeVal);
            end
        end

        function postProcessUMINUS(this,node)
            this.negation=true;
            this.visitUnary(node);

        end

        function postProcessSTRING(this,node)
            nodeVal=this.getNodeVal(node);
            if isempty(this.operatorStack)
                retSimpleIR(this,nodeVal,node.kind)
            else
                this.putOnStack(nodeVal);
            end
        end

        function postProcessID(this,node)
            nodeVal=this.getNodeVal(node);
            if isempty(this.operatorStack)
                retSimpleIR(this,nodeVal,node.kind)
            else
                this.putOnStack(nodeVal);
            end

        end

        function preProcessFIELD(this,node)
            nodeVal=this.getNodeVal(node);
            this.putOnStack(nodeVal);
        end

        function out=getNodeVal(this,node)%#ok<INUSL>
            out=node.string;
        end

        function putOnStack(this,nodeVal)

            lastOperator=this.operatorStack{end};
            switch lastOperator
            case 'DOT'
                this.DOTStack{end+1}=nodeVal;
            case 'CALL'
                this.arrayStack{end+1}=nodeVal;
            otherwise
            end
        end

        function retSimpleIR(this,nodeVal,nodeKind)
            if this.negation
                nodeVal=['-',nodeVal];
                this.negation=false;
            end
            import plccore.expr.ConstExpr;
            import plccore.common.ConstValue;
            import plccore.common.Utils.getVarInstance;
            import plccore.expr.VarExpr;
            switch nodeKind
            case 'ID'
                allowUnknownVar=true;
                varInst=getVarInstance(nodeVal,this.Ctx,this.POU,allowUnknownVar);
                if isempty(varInst)
                    this.IR=plccore.expr.UnknownExpr(varInst);
                else
                    this.IR=VarExpr(varInst);
                end
            case 'DOUBLE'
                this.IR=ConstExpr(ConstValue(plccore.type.REALType,nodeVal));
            case 'INT'
                this.IR=ConstExpr(ConstValue(plccore.type.DINTType,nodeVal));
            case 'STRING'
                this.IR=plccore.expr.StringExpr(plccore.type.DINTType,nodeVal);
            otherwise
                error(['Unsupported operator found in operand : ',this.operand,newline,' In rung : ',this.rungTxt]);
            end
        end

        function preProcessDOT(this,node)%#ok<INUSD>
            this.operatorStack{end+1}='DOT';
        end

        function postProcessDOT(this,node)%#ok<INUSD>
            this.IR=this.getDOTIR;
            this.operatorStack=this.operatorStack(1:end-1);

            if~isempty(this.operatorStack)
                this.putOnStack(this.IR);
            end
        end

        function out=getDOTIR(this)
            import plccore.common.Utils.getVarInstance;
            import plccore.expr.VarExpr;
            if length(this.DOTStack)==2
                if ischar(this.DOTStack{1})
                    lhs=VarExpr(getVarInstance(this.DOTStack{1},this.Ctx,this.POU));
                else
                    lhs=this.DOTStack{1};
                    assert(isa(lhs,'plccore.expr.StructRefExpr')||...
                    isa(lhs,'plccore.expr.ArrayRefExpr'));
                end
                rhs=this.DOTStack{2};
                out=plccore.expr.StructRefExpr(lhs,rhs);
            elseif length(this.DOTStack)==1
                lhs=this.IR;
                rhs=this.DOTStack{1};
                out=plccore.expr.StructRefExpr(lhs,rhs);
            else
                error(['Unsupported operator found in operand : ',this.operand,newline,' In rung : ',this.rungTxt]);
            end
            this.DOTStack={};
        end

        function visitSUBSCR(this,node)
            visitCALL(this,node);
        end

        function visitCALL(this,node)

            nodeIsID=node.Left;
            if strcmp('ID',nodeIsID.kind)&&node.Right.isempty
                this.visitID(nodeIsID);
            else
                assert(isempty(this.arrayStack),['Invalid array index in : ',this.operand,'. Array indices should be integer literals or variables'])
                this.operatorStack{end+1}='CALL';

                this.visit(node.Left)
                this.visitNodeList(node.Right)

                this.IR=this.getCALLIR;
                this.operatorStack=this.operatorStack(1:end-1);
            end


        end

        function out=getCALLIR(this)
            import plccore.common.Utils.getVarInstance;
            import plccore.expr.VarExpr;
            if ischar(this.arrayStack{1})
                arrayVarExpr=VarExpr(getVarInstance(this.arrayStack{1},this.Ctx,this.POU));
            else
                arrayVarExpr=this.arrayStack{1};
                assert(isa(arrayVarExpr,'plccore.expr.StructRefExpr')||...
                isa(arrayVarExpr,'plccore.expr.ArrayRefExpr'));
            end

            indexList={};
            import plccore.expr.ConstExpr;
            import plccore.common.ConstValue;
            import plccore.expr.ArrayRefExpr;
            for iv=2:length(this.arrayStack)
                indexExpr=this.arrayStack{iv};

                if ischar(indexExpr)
                    [~,isnum]=str2num(indexExpr);%#ok<ST2NM>
                    if isnum
                        indexList{iv-1}=ConstExpr(ConstValue(plccore.type.DINTType,indexExpr));%#ok<AGROW>
                    else

                        indexList{iv-1}=VarExpr(getVarInstance(indexExpr,this.Ctx,this.POU));%#ok<AGROW>
                    end
                else
                    indexList{iv-1}=this.arrayStack{iv};%#ok<AGROW>
                end
            end

            out=ArrayRefExpr(arrayVarExpr,indexList);

            this.arrayStack={};
        end
    end
end


