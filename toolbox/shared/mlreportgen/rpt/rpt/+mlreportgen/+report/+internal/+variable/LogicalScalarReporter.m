classdef LogicalScalarReporter<mlreportgen.report.internal.variable.StringReporter





    methods
        function this=LogicalScalarReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.StringReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)
        function textValue=getTextValue(this)


            if this.VarValue
                textValue=getString(message("mlreportgen:report:VariableReporter:logicalTrue"));
            else
                textValue=getString(message("mlreportgen:report:VariableReporter:logicalFalse"));
            end
        end
    end

end