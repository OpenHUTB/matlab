classdef CellArrayReporter<mlreportgen.report.internal.variable.ObjectArrayReporter




    methods
        function this=CellArrayReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.ObjectArrayReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)

        function element=getArrayElement(this,rowIdx,colIdx)


            element=this.VarValue{rowIdx,colIdx};
        end

        function leftBracket=getLeftBracket(this)%#ok<MANU>


            leftBracket="{";
        end

        function rightBracket=getRightBracket(this)%#ok<MANU>


            rightBracket="}";
        end
    end

end