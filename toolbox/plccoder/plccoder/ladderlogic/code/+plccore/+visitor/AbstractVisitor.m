classdef AbstractVisitor<plccore.common.Object




    properties
debug
    end

    methods
        function obj=AbstractVisitor
            obj.Kind='AbstractVisitor';
            obj.debug=plcfeature('PLCLadderDebug');
        end

        function showDebugMsg(obj)
            if(obj.debug)
                fprintf('\n\n------>Running %s\n',obj.kind);
            end
        end

        function ret=visitObject(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitArrayType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitStructType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitPOUType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitTIMEType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitNamedType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitSlotType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitTimeValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitArrayValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitStructValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitContext(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConfiguration(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitFunction(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitFunctionBlock(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitGlobalScope(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitProgram(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitRoutine(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitScope(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitVar(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitDINTType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitINType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitBitFieldType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitBOOLType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitLINType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitSINType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitLREALType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitREALType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitLINTType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitUDINTType(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitCallExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitFBCallExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitVarExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitArrayRefExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitStructRefExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitIntegerBitRefExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitWildCardExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitStringExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitRoutineExpr(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitLadderDiagram(obj,host,input)
            ret=[];
            rungs=host.rungs;
            for i=1:length(rungs)
                rungs{i}.accept(obj,input);
            end
        end

        function ret=visitLadderRung(obj,host,input)
            ret=[];
            rungops=host.rungOps;
            for i=1:length(rungops)
                rungops{i}.accept(obj,input);
            end
        end

        function ret=visitRungOpAtom(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitRungOpTimer(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitRungOpFBCall(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitRungOpPar(obj,host,input)
            ret=[];
            rungops=host.rungOps;
            for i=1:length(rungops)
                rungops{i}.accept(obj,input);
            end
        end

        function ret=visitRungOpSeq(obj,host,input)
            ret=[];
            rungops=host.rungOps;
            for i=1:length(rungops)
                rungops{i}.accept(obj,input);
            end
        end

        function ret=visitLadderInstruction(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitCoilInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitGEQInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitLEQInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitNCCInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitNOCInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitNTCInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitNTCoilInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitNegCoilInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitPTCInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitPTCoilInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitResetCoilInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitSetCoilInstr(obj,host,input)
            ret=obj.visitLadderInstruction(host,input);
        end

        function ret=visitTask(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitContinuousTask(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitPeriodicTask(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitEventTask(obj,host,input)%#ok<INUSD>
            ret=[];
        end
    end
end

