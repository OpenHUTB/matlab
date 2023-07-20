



classdef(Abstract)MtreeVisitor<handle

    properties(Access=protected)

tree





        unknownMsgID;



        messages;
    end

    properties(Abstract,Access=protected)



defaultMsgID
    end

    methods(Abstract,Access=protected)


        addMessage(this,node,msgType,msgId,msgParams)
    end
    methods(Abstract)
        messages=run(this)
    end

    methods(Access=public)

        function this=MtreeVisitor(tree)
            this.tree=tree;
        end
    end

    methods(Access=protected)










































































































        function visitID(this,node)
            this.preProcessID(node)
            this.postProcessID(node)
        end

        function preProcessID(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessID(this,node)%#ok<INUSD>

        end




        function visitFIELD(this,node)
            this.preProcessFIELD(node)
            this.postProcessFIELD(node)
        end

        function preProcessFIELD(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessFIELD(this,node)%#ok<INUSD>

        end




        function visitINT(this,node)
            this.preProcessINT(node)
            this.postProcessINT(node)
        end

        function preProcessINT(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessINT(this,node)%#ok<INUSD>

        end




        function visitDOUBLE(this,node)
            this.preProcessDOUBLE(node)
            this.postProcessDOUBLE(node)
        end

        function preProcessDOUBLE(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessDOUBLE(this,node)%#ok<INUSD>

        end




        function visitUMINUS(this,node)
            this.preProcessUMINUS(node)
            this.visitUnary(node)
            this.postProcessUMINUS(node)
        end

        function preProcessUMINUS(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessUMINUS(this,node)%#ok<INUSD>

        end












        function visitPARENS(this,node)
            this.preProcessPARENS(node)
            this.visitNodeList(node.Arg)
            this.postProcessPARENS(node)
        end

        function preProcessPARENS(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessPARENS(this,node)%#ok<INUSD>

        end









        function visitPLUS(this,node)
            this.preProcessPLUS(node)
            this.visitBinary(node)
            this.postProcessPLUS(node)
        end

        function preProcessPLUS(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessPLUS(this,node)%#ok<INUSD>

        end



        function visitMINUS(this,node)
            this.preProcessMINUS(node)
            this.visitBinary(node)
            this.postProcessMINUS(node)
        end

        function preProcessMINUS(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessMINUS(this,node)%#ok<INUSD>

        end



        function visitMUL(this,node)
            this.preProcessMUL(node)
            this.visitBinary(node)
            this.postProcessMUL(node)
        end

        function preProcessMUL(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessMUL(this,node)%#ok<INUSD>

        end



        function visitDIV(this,node)
            this.preProcessDIV(node)
            this.visitBinary(node)
            this.postProcessDIV(node)
        end

        function preProcessDIV(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessDIV(this,node)%#ok<INUSD>

        end




        function visitEXP(this,node)
            this.preProcessEXP(node)
            this.visitBinary(node)
            this.postProcessEXP(node)
        end

        function preProcessEXP(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessEXP(this,node)%#ok<INUSD>

        end

















        function visitCALL(this,node)
            this.preProcessCALL(node)
            this.visit(node.Left)
            this.visitNodeList(node.Right)
            this.postProcessCALL(node)
        end

        function preProcessCALL(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessCALL(this,node)%#ok<INUSD>

        end






        function visitSUBSCR(this,node)%#ok<INUSD>




        end
        function preProcessSUBSCR(this,node)%#ok<INUSD>




        end

        function postProcessSUBSCR(this,node)%#ok<INUSD>

        end




        function visitCELL(this,node)
            this.preProcessCELL(node)
            this.visit(node.Left)
            this.visitNodeList(node.Right)
            this.postProcessCELL(node)
        end

        function preProcessCELL(this,node)
            this.addMessage(node,...
            [],...
            this.defaultMsgID,...
            node.tree2str);
        end

        function postProcessCELL(this,node)%#ok<INUSD>

        end







        function visitDOT(this,node)
            this.preProcessDOT(node)
            this.visitBinary(node)
            this.postProcessDOT(node)
        end

        function preProcessDOT(this,node)%#ok<INUSD>

        end

        function postProcessDOT(this,node)%#ok<INUSD>

        end



        function visitNodeList(this,nodeList)
            node=nodeList;
            while~isempty(node)
                this.visit(node)
                node=node.Next;
            end
        end

        function visitUnary(this,node)
            this.visit(node.Arg)
        end

        function visitBinary(this,node)
            this.visit(node.Left)
            this.visit(node.Right)
        end

        function visitOther(this,node)
            this.addMessage(node,...
            [],...
            this.unknownMsgID,...
            node.tree2str);
        end

        function visit(this,node)
            if~isempty(node)
                switch node.kind
                case 'ID'
                    this.visitID(node)
                case 'FIELD'
                    this.visitFIELD(node)
                case 'INT'
                    this.visitINT(node)
                case 'DOUBLE'
                    this.visitDOUBLE(node)
                case 'UMINUS'
                    this.visitUMINUS(node)
                case 'UPLUS'
                    this.visitUPLUS(node)
                case 'PARENS'
                    this.visitPARENS(node)
                case 'PLUS'
                    this.visitPLUS(node)
                case 'MINUS'
                    this.visitMINUS(node)
                case 'MUL'
                    this.visitMUL(node)
                case 'DIV'
                    this.visitDIV(node)
                case 'EXP'
                    this.visitEXP(node)
                case 'SUBSCR'
                    this.visitSUBSCR(node)
                case 'CALL'
                    this.visitCALL(node)
                case 'CELL'
                    this.visitCELL(node)
                case 'DOT'
                    this.visitDOT(node)
                otherwise
                    this.visitOther(node)
                end
            end
        end
    end

end





