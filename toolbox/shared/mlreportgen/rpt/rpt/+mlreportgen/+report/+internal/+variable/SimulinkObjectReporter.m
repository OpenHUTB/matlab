classdef SimulinkObjectReporter<mlreportgen.report.internal.variable.UDDObjectReporter





    methods
        function this=SimulinkObjectReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.UDDObjectReporter(reportOptions,...
            varName,get_param(varValue,"Object"));
        end
    end

end