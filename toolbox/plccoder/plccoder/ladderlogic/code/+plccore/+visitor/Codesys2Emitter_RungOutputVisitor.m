classdef Codesys2Emitter_RungOutputVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=Codesys2Emitter_RungOutputVisitor
            obj.Kind='Codesys2Emitter_RungOutputVisitor';
        end
    end

    methods
        function ret=visitRungOpAtom(obj,host,input)
            ret=host.instr.accept(obj,input);
        end

        function ret=visitRungOpPar(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitRungOpSeq(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitLadderInstruction(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitCoilInstr(obj,host,input)%#ok<INUSD>
            ret=true;
        end

        function ret=visitNCCInstr(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitNOCInstr(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitNTCInstr(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitNTCoilInstr(obj,host,input)%#ok<INUSD>
            ret=true;
        end

        function ret=visitNegCoilInstr(obj,host,input)%#ok<INUSD>
            ret=true;
        end

        function ret=visitPTCInstr(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitPTCoilInstr(obj,host,input)%#ok<INUSD>
            ret=true;
        end

        function ret=visitResetCoilInstr(obj,host,input)%#ok<INUSD>
            ret=true;
        end

        function ret=visitSetCoilInstr(obj,host,input)%#ok<INUSD>
            ret=true;
        end
    end
end

