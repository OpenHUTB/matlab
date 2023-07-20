classdef ReportDirector<handle




    properties(Access=private)
Builder
    end

    methods

        function setBuilder(obj,builder)
            obj.Builder=builder;
        end

        function builder=getBuilder(obj)
            builder=obj.Builder;
        end


        function report=makeReport(obj,ru)

            obj.Builder.createReport();


            obj.Builder.buildCheckListStep(ru);


            obj.Builder.buildSummaryStep(ru);


            obj.Builder.buildDetailedStep(ru);


            report=obj.Builder.getReport();
        end
    end
end

