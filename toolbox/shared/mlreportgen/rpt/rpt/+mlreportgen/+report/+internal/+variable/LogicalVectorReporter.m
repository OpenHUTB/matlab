classdef LogicalVectorReporter<mlreportgen.report.internal.variable.StringReporter





    methods
        function this=LogicalVectorReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.StringReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)
        function textValue=getTextValue(this)


            textValue="[";
            numElems=length(this.VarValue);

            for i=1:numElems
                if this.VarValue(i)
                    textValue=strcat(textValue,...
                    getString(message("mlreportgen:report:VariableReporter:logicalTrue")));
                else
                    textValue=strcat(textValue,...
                    getString(message("mlreportgen:report:VariableReporter:logicalFalse")));
                end

                if i<numElems
                    textValue=strcat(textValue," ");
                else
                    textValue=strcat(textValue,"]");
                end
            end
        end
    end

end