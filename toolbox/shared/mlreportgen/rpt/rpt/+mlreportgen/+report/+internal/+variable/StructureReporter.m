classdef StructureReporter<mlreportgen.report.internal.variable.StructuredObjectReporter





    methods
        function this=StructureReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.StructuredObjectReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)

        function propNames=getObjectProperties(this)


            propNames=fieldnames(this.VarValue);
        end

        function tableHeader=getTableHeader(this)%#ok<MANU>


            tableHeader={...
            getString(message("mlreportgen:report:VariableReporter:field"))...
            ,getString(message("mlreportgen:report:VariableReporter:value"))...
            };
        end

    end

end