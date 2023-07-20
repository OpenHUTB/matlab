



classdef(Abstract)BaseVisitor<handle

    properties(Access=protected)

tree



        messages=internal.mtree.Message.empty
    end

    properties(Abstract,Access=protected)



defaultMsgID
    end

    methods(Abstract,Access=protected)


        addMessage(this,node,msgType,msgId,msgParams)

        isit=treatAsFunctionCall(this,node)
    end

    methods(Access=public)

        function this=BaseVisitor(tree)
            this.tree=tree;
        end

        function messages=run(this)
            try
                this.visit(this.tree)
                messages=this.messages;
            catch ex
                internal.mtree.utils.errorWithContext(ex,...
                'Constraining error: ',...
                fullfile('+internal','+ml2pir'))
            end
        end

    end

    methods(Access=protected)










































































































        function visitID(this,node)
            this.preProcessID(node)
        end

        function preProcessID(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitFIELD(this,node)
            this.preProcessFIELD(node)
        end

        function preProcessFIELD(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitANONID(this,node)
            this.preProcessANONID(node)
        end

        function preProcessANONID(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitINT(this,node)
            this.preProcessINT(node)
        end

        function preProcessINT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitDOUBLE(this,node)
            this.preProcessDOUBLE(node)
        end

        function preProcessDOUBLE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end







        function visitSTRING(this,node)
            this.preProcessSTRING(node)
        end

        function preProcessSTRING(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end






        function visitCHARVECTOR(this,node)
            this.preProcessCHARVECTOR(node)
        end

        function preProcessCHARVECTOR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end





        function visitBANG(this,node)
            this.preProcessBANG(node)
        end

        function preProcessBANG(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitBREAK(this,node)
            this.preProcessBREAK(node)
        end

        function preProcessBREAK(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitCONTINUE(this,node)
            this.preProcessCONTINUE(node)
        end

        function preProcessCONTINUE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitRETURN(this,node)
            this.preProcessRETURN(node)
        end

        function preProcessRETURN(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end








        function visitTRANS(this,node)
            this.preProcessTRANS(node)
            this.visitUnary(node)
        end

        function preProcessTRANS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitDOTTRANS(this,node)
            this.preProcessDOTTRANS(node)
            this.visitUnary(node)
        end

        function preProcessDOTTRANS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end






        function visitNOT(this,node)
            if isempty(node.Arg)
                this.visitIgnoredVar(node)
            else
                this.preProcessNOT(node)
                this.visitUnary(node)
            end
        end

        function preProcessNOT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitIgnoredVar(this,node)
            this.preProcessIgnoredVar(node)
        end

        function preProcessIgnoredVar(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitUMINUS(this,node)
            this.preProcessUMINUS(node)
            this.visitUnary(node)
        end

        function preProcessUMINUS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitUPLUS(this,node)
            this.preProcessUPLUS(node)
            this.visitUnary(node)
        end

        function preProcessUPLUS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end








        function visitPARENS(this,node)
            this.preProcessPARENS(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessPARENS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitAT(this,node)
            this.preProcessAT(node)
        end

        function preProcessAT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end





        function visitEXPR(this,node)
            this.preProcessEXPR(node)
            this.visitUnary(node)
        end

        function preProcessEXPR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end





        function visitPRINT(this,node)
            this.preProcessPRINT(node)
            this.visitUnary(node)
        end

        function preProcessPRINT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end







        function visitERR(this,node)
            this.preProcessERR(node)
            this.visitUnary(node)
        end

        function preProcessERR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end





        function visitQUEST(this,node)
            this.preProcessQUEST(node)
            this.visitUnary(node)
        end

        function preProcessQUEST(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitGLOBAL(this,node)
            this.preProcessGLOBAL(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessGLOBAL(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitPERSISTENT(this,node)
            this.preProcessPERSISTENT(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessPERSISTENT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end










        function visitLB(this,node)
            if node.Arg.iskind('ROW')

                this.preProcessLB(node)
                this.visitNodeList(node.Arg)
            else

                this.visitMultipleAssign(node)
            end
        end

        function preProcessLB(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end


        function visitMultipleAssign(this,node)
            this.preProcessMultipleAssign(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessMultipleAssign(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end





        function visitLC(this,node)
            this.preProcessLC(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessLC(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitROW(this,node)
            this.preProcessROW(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessROW(this,node)%#ok<INUSD>


        end









        function visitPLUS(this,node)
            this.preProcessPLUS(node)
            this.visitBinary(node)
        end

        function preProcessPLUS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitMINUS(this,node)
            this.preProcessMINUS(node)
            this.visitBinary(node)
        end

        function preProcessMINUS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitMUL(this,node)
            this.preProcessMUL(node)
            this.visitBinary(node)
        end

        function preProcessMUL(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitDIV(this,node)
            this.preProcessDIV(node)
            this.visitBinary(node)
        end

        function preProcessDIV(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitLDIV(this,node)
            this.preProcessLDIV(node)
            this.visitBinary(node)
        end

        function preProcessLDIV(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitEXP(this,node)
            this.preProcessEXP(node)
            this.visitBinary(node)
        end

        function preProcessEXP(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitDOTMUL(this,node)
            this.preProcessDOTMUL(node)
            this.visitBinary(node)
        end

        function preProcessDOTMUL(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitDOTDIV(this,node)
            this.preProcessDOTDIV(node)
            this.visitBinary(node)
        end

        function preProcessDOTDIV(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitDOTLDIV(this,node)
            this.preProcessDOTLDIV(node)
            this.visitBinary(node)
        end

        function preProcessDOTLDIV(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitDOTEXP(this,node)
            this.preProcessDOTEXP(node)
            this.visitBinary(node)
        end

        function preProcessDOTEXP(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitAND(this,node)
            this.preProcessAND(node)
            this.visitBinary(node)
        end

        function preProcessAND(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitOR(this,node)
            this.preProcessOR(node)
            this.visitBinary(node)
        end

        function preProcessOR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitANDAND(this,node)
            this.preProcessANDAND(node)
            this.visitBinary(node)
        end

        function preProcessANDAND(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitOROR(this,node)
            this.preProcessOROR(node)
            this.visitBinary(node)
        end

        function preProcessOROR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitLT(this,node)
            this.preProcessLT(node)
            this.visitBinary(node)
        end

        function preProcessLT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitGT(this,node)
            this.preProcessGT(node)
            this.visitBinary(node)
        end

        function preProcessGT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitLE(this,node)
            this.preProcessLE(node)
            this.visitBinary(node)
        end

        function preProcessLE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitGE(this,node)
            this.preProcessGE(node)
            this.visitBinary(node)
        end

        function preProcessGE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitEQ(this,node)
            this.preProcessEQ(node)
            this.visitBinary(node)
        end

        function preProcessEQ(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end



        function visitNE(this,node)
            this.preProcessNE(node)
            this.visitBinary(node)
        end

        function preProcessNE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end

















        function visitCALL(this,node)
            this.preProcessCALL(node)
            this.visitNodeList(node.Right)
        end

        function preProcessCALL(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end






        function visitDCALL(this,node)
            this.preProcessDCALL(node)
            this.visit(node.Left)
            this.visitNodeList(node.Right)
        end

        function preProcessDCALL(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end












        function visitEQUALS(this,node)
            this.preProcessEQUALS(node)
            this.visitBinary(node)
        end

        function preProcessEQUALS(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end










        function visitNAMEVALUE(this,node)
            this.preProcessNAMEVALUE(node)
            this.visitBinary(node)
        end

        function preProcessNAMEVALUE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end














        function visitSUBSCR(this,node)
            this.preProcessSUBSCR(node);

            if~this.treatAsFunctionCall(node)
                this.visit(node.Left);
            end

            this.visitNodeList(node.Right);
        end

        function preProcessSUBSCR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitCELL(this,node)
            this.preProcessCELL(node)
            this.visit(node.Left)
            this.visitNodeList(node.Right)
        end

        function preProcessCELL(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end







        function visitDOT(this,node)
            this.preProcessDOT(node)
            if~this.treatAsFunctionCall(node)
                this.visit(node.Left)
                this.visit(node.Right)
            end
        end

        function preProcessDOT(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end






        function visitDOTLP(this,node)
            this.preProcessDOTLP(node)
            this.visitBinary(node)
        end

        function preProcessDOTLP(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end










        function visitCOLON(this,node)

            if isempty(node.Left)||~strcmp(node.Left.kind,'COLON')
                start=node.Left;
                step=node.null;
                stop=node.Right;
            else
                start=node.Left.Left;
                step=node.Left.Right;
                stop=node.Right;
            end
            this.preProcessCOLON(node,start,step,stop)
            this.visit(start)
            this.visit(step)
            this.visit(stop)
        end




        function preProcessCOLON(this,node,start,step,stop)%#ok<INUSD>
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end








        function visitANON(this,node)
            this.preProcessANON(node)
            this.visitNodeList(node.Left)
            this.visit(node.Right)
        end

        function preProcessANON(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end












        function visitIF(this,node)
            this.preProcessIF(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessIF(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end






        function visitIFHEAD(this,node)
            this.preProcessIFHEAD(node)
            this.visit(node.Left)
            this.visitNodeList(node.Body)
        end

        function preProcessIFHEAD(this,node)%#ok<INUSD>


        end





        function visitELSEIF(this,node)
            this.preProcessELSEIF(node)
            this.visit(node.Left)
            this.visitNodeList(node.Body)
        end

        function preProcessELSEIF(this,node)%#ok<INUSD>


        end




        function visitELSE(this,node)
            this.preProcessELSE(node)
            this.visitNodeList(node.Body)
        end

        function preProcessELSE(this,node)%#ok<INUSD>


        end




        function visitSWITCH(this,node)
            this.preProcessSWITCH(node)
            this.visit(node.Left)
            this.visitNodeList(node.Body)
        end

        function preProcessSWITCH(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitCASE(this,node)
            this.preProcessCASE(node)
            this.visit(node.Left)
            this.visitNodeList(node.Body)
        end

        function preProcessCASE(this,node)%#ok<INUSD>


        end



        function visitOTHERWISE(this,node)
            this.preProcessOTHERWISE(node)
            this.visitNodeList(node.Body)
        end

        function preProcessOTHERWISE(this,node)%#ok<INUSD>


        end





        function visitWHILE(this,node)
            this.preProcessWHILE(node)
            this.visit(node.Left)
            this.visitNodeList(node.Body)
        end

        function preProcessWHILE(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end






        function visitFOR(this,node)
            this.preProcessFOR(node)
            this.visit(node.Index)
            this.visit(node.Vector)
            this.visitNodeList(node.Body)
        end

        function preProcessFOR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




        function visitPARFOR(this,node)
            this.preProcessPARFOR(node)
            this.visit(node.Index)
            this.visit(node.Vector)
            this.visitNodeList(node.Body)
        end

        function preProcessPARFOR(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end





        function visitSPMD(this,node)
            this.preProcessSPMD(node)
            this.visit(node.Left)
            this.visitNodeList(node.Body)
        end

        function preProcessSPMD(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end







        function visitTRY(this,node)
            this.preProcessTRY(node)
            this.visitNodeList(node.Try)
            this.visit(node.CatchID)
            this.visitNodeList(node.Catch)
        end

        function preProcessTRY(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




















        function visitFUNCTION(this,node)
            this.preProcessFUNCTION(node)
            this.visit(node.Fname)
            this.visitNodeList(node.Ins)
            this.visitNodeList(node.Outs)
            this.visitNodeList(node.Body)
        end

        function preProcessFUNCTION(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end




















        function visitCLASSDEF(this,node)
            this.preProcessCLASSDEF(node)
            this.visitClassName(node.Cexpr)
            this.visit(node.Cattr)
            this.visitNodeList(node.Body)
        end

        function preProcessCLASSDEF(this,node)
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            this.defaultMsgID,...
            node.tree2str);
        end


        function visitClassName(this,node)
            if node.iskind('ID')
                this.preProcessClassName(node)
            elseif node.iskind('LT')||node.iskind('AND')
                this.visitClassName(node.Left)
                this.visitClassName(node.Right)
            else
                this.visitOther(node)
            end
        end

        function preProcessClassName(this,node)%#ok<INUSD>


        end




        function visitATTRIBUTES(this,node)
            this.preProcessATTRIBUTES(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessATTRIBUTES(this,node)%#ok<INUSD>


        end









        function visitATTR(this,node)
            this.preProcessATTR(node)
            if~node.Right.iskind('NOT')||...
                ~(isempty(node.Right.Left)&&isempty(node.Right.Right))
                this.visit(node.Right)
            end
        end

        function preProcessATTR(this,node)%#ok<INUSD>


        end










        function visitPROPERTIES(this,node)
            this.preProcessPROPERTIES(node)
            this.visit(node.Attr)
            this.visitNodeList(node.Body)
        end

        function preProcessPROPERTIES(this,node)%#ok<INUSD>


        end










        function visitMETHODS(this,node)
            this.preProcessMETHODS(node)
            this.visit(node.Attr)
            this.visitNodeList(node.Body)
        end

        function preProcessMETHODS(this,node)%#ok<INUSD>


        end



        function visitPROTO(this,node)
            this.preProcessPROTO(node)
            this.visit(node.Fname)
            this.visitNodeList(node.Ins)
            this.visitNodeList(node.Outs)
        end

        function preProcessPROTO(this,node)%#ok<INUSD>


        end






        function visitEVENTS(this,node)
            this.preProcessEVENTS(node)
            this.visit(node.Attr)
            this.visitNodeList(node.Body)
        end

        function preProcessEVENTS(this,node)%#ok<INUSD>


        end





        function visitEVENT(this,node)
            this.preProcessEVENTS(node)
            this.visit(node.Left)
            if~isempty(node.Right)
                this.visitClassName(node.Right)
            end
        end

        function preProcessEVENT(this,node)%#ok<INUSD>


        end







        function visitENUMERATION(this,node)
            this.preProcessENUMERATION(node)
            this.visit(node.Attr)
            this.visitNodeList(node.Body)
        end

        function preProcessENUMERATION(this,node)%#ok<INUSD>


        end







        function visitLP(this,node)
            this.preProcessLP(node)
            this.visit(node.Left)
            this.visitNodeList(node.Right)
        end

        function preProcessLP(this,node)%#ok<INUSD>


        end





        function visitATBASE(this,node)
            this.preProcessATBASE(node)
            this.visit(node.Left)
            this.visitClassName(node.Right)
        end

        function preProcessATBASE(this,node)%#ok<INUSD>


        end




















        function visitCOMMENT(this,node)
            this.preProcessCOMMENT(node)
        end

        function preProcessCOMMENT(this,node)%#ok<INUSD>


        end





        function visitBLKCOM(this,node)
            this.preProcessBLKCOM(node)
            this.visitNodeList(node.Arg)
        end

        function preProcessBLKCOM(this,node)%#ok<INUSD>


        end



        function visitCELLMARK(this,node)
            this.preProcessCELLMARK(node)
        end

        function preProcessCELLMARK(this,node)%#ok<INUSD>


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

        function visitOther(~,node)
            error(['Unknown node type found: ',node.kind]);
        end

        function visit(this,node)
            if~isempty(node)
                switch node.kind
                case 'ID'
                    this.visitID(node)
                case 'FIELD'
                    this.visitFIELD(node)
                case 'ANONID'
                    this.visitANONID(node)
                case 'INT'
                    this.visitINT(node)
                case 'DOUBLE'
                    this.visitDOUBLE(node)
                case 'STRING'
                    this.visitSTRING(node)
                case 'CHARVECTOR'
                    this.visitCHARVECTOR(node)
                case 'BANG'
                    this.visitBANG(node)
                case 'BREAK'
                    this.visitBREAK(node)
                case 'CONTINUE'
                    this.visitCONTINUE(node)
                case 'RETURN'
                    this.visitRETURN(node)
                case 'TRANS'
                    this.visitTRANS(node)
                case 'DOTTRANS'
                    this.visitDOTTRANS(node)
                case 'NOT'
                    this.visitNOT(node)
                case 'UMINUS'
                    this.visitUMINUS(node)
                case 'UPLUS'
                    this.visitUPLUS(node)
                case 'PARENS'
                    this.visitPARENS(node)
                case 'AT'
                    this.visitAT(node)
                case 'EXPR'
                    this.visitEXPR(node)
                case 'PRINT'
                    this.visitPRINT(node)
                case 'ERR'
                    this.visitERR(node)
                case 'QUEST'
                    this.visitQUEST(node)
                case 'GLOBAL'
                    this.visitGLOBAL(node)
                case 'PERSISTENT'
                    this.visitPERSISTENT(node)
                case 'LB'
                    this.visitLB(node)
                case 'LC'
                    this.visitLC(node)
                case 'ROW'
                    this.visitROW(node)
                case 'PLUS'
                    this.visitPLUS(node)
                case 'MINUS'
                    this.visitMINUS(node)
                case 'MUL'
                    this.visitMUL(node)
                case 'DIV'
                    this.visitDIV(node)
                case 'LDIV'
                    this.visitLDIV(node)
                case 'EXP'
                    this.visitEXP(node)
                case 'DOTMUL'
                    this.visitDOTMUL(node)
                case 'DOTDIV'
                    this.visitDOTDIV(node)
                case 'DOTLDIV'
                    this.visitDOTLDIV(node)
                case 'DOTEXP'
                    this.visitDOTEXP(node)
                case 'AND'
                    this.visitAND(node)
                case 'OR'
                    this.visitOR(node)
                case 'ANDAND'
                    this.visitANDAND(node)
                case 'OROR'
                    this.visitOROR(node)
                case 'LT'
                    this.visitLT(node)
                case 'GT'
                    this.visitGT(node)
                case 'LE'
                    this.visitLE(node)
                case 'GE'
                    this.visitGE(node)
                case 'EQ'
                    this.visitEQ(node)
                case 'NE'
                    this.visitNE(node)
                case 'CALL'
                    this.visitCALL(node)
                case 'DCALL'
                    this.visitDCALL(node)
                case 'EQUALS'
                    this.visitEQUALS(node)
                case 'NAMEVALUE'
                    this.visitNAMEVALUE(node)
                case 'SUBSCR'
                    this.visitSUBSCR(node)
                case 'CELL'
                    this.visitCELL(node)
                case 'DOT'
                    this.visitDOT(node)
                case 'DOTLP'
                    this.visitDOTLP(node)
                case 'COLON'
                    this.visitCOLON(node)
                case 'ANON'
                    this.visitANON(node)
                case 'IF'
                    this.visitIF(node)
                case 'IFHEAD'
                    this.visitIFHEAD(node)
                case 'ELSEIF'
                    this.visitELSEIF(node)
                case 'ELSE'
                    this.visitELSE(node)
                case 'SWITCH'
                    this.visitSWITCH(node)
                case 'CASE'
                    this.visitCASE(node)
                case 'OTHERWISE'
                    this.visitOTHERWISE(node)
                case 'WHILE'
                    this.visitWHILE(node)
                case 'FOR'
                    this.visitFOR(node)
                case 'PARFOR'
                    this.visitPARFOR(node)
                case 'SPMD'
                    this.visitSPMD(node)
                case 'TRY'
                    this.visitTRY(node)
                case 'FUNCTION'
                    this.visitFUNCTION(node)
                case 'CLASSDEF'
                    this.visitCLASSDEF(node)
                case 'ATTRIBUTES'
                    this.visitATTRIBUTES(node)
                case 'ATTR'
                    this.visitATTR(node)
                case 'PROPERTIES'
                    this.visitPROPERTIES(node)
                case 'METHODS'
                    this.visitMETHODS(node)
                case 'PROTO'
                    this.visitPROTO(node)
                case 'EVENTS'
                    this.visitEVENTS(node)
                case 'EVENT'
                    this.visitEVENT(node)
                case 'ENUMERATION'
                    this.visitENUMERATION(node)
                case 'LP'
                    this.visitLP(node)
                case 'ATBASE'
                    this.visitATBASE(node)
                case 'COMMENT'
                    this.visitCOMMENT(node)
                case 'BLKCOM'
                    this.visitBLKCOM(node)
                case 'CELLMARK'
                    this.visitCELLMARK(node)
                otherwise
                    this.visitOther(node)
                end
            end
        end
    end
end





