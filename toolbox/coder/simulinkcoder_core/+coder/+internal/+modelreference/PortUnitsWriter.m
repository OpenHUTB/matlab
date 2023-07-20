


classdef PortUnitsWriter<handle

    methods(Access=public)
        function writeSfunctionRegisterAndSetUnit(this,portType,portUnitExpr,portIdxStr)
            fcnCallStr=['ssSet',portType,'PortUnit'];
            this.Writer.writeString('if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {');
            this.Writer.writeLine('\n#if defined (MATLAB_MEX_FILE)\n','');
            this.Writer.writeString('UnitId unitIdReg;');
            this.Writer.writeLine('ssRegisterUnitFromExpr(\nS, \n"%s", \n&unitIdReg);',...
            portUnitExpr);
            this.Writer.writeString('if(unitIdReg == INVALID_UNIT_ID) return;');
            this.Writer.writeLine('%s(S, %s, unitIdReg);',fcnCallStr,portIdxStr);
            this.Writer.writeLine('\n#endif\n','');
            this.Writer.writeChar('}');
        end

        function this=PortUnitsWriter(writer)
            this.Writer=writer;
        end
    end

    properties(Access=protected)
Writer
    end
end


