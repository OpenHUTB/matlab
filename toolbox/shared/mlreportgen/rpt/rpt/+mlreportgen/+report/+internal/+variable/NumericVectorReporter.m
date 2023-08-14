classdef NumericVectorReporter<mlreportgen.report.internal.variable.StringReporter





    methods
        function this=NumericVectorReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.StringReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)
        function textualContent=getTextualContent(this)





            textualContent=...
            getTextualContent@mlreportgen.report.internal.variable.StringReporter(this);

            textualContent=...
            mlreportgen.utils.normalizeString(textualContent);
        end
    end

end