classdef CellVectorReporter<mlreportgen.report.internal.variable.ObjectVectorReporter





    methods
        function this=CellVectorReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.ObjectVectorReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)

        function element=getVectorElement(this,index)


            element=this.VarValue{index};
        end

        function leftBracket=getLeftBracket(this)%#ok<MANU>


            leftBracket="{";
        end

        function rightBracket=getRightBracket(this)%#ok<MANU>


            rightBracket="}";
        end

    end

end