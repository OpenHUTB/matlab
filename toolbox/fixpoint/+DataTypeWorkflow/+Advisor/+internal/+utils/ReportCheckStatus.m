classdef ReportCheckStatus<uint8




    enumeration
        Pass(0)
        Warning(1)
        Error(2)
    end

    methods
        function status=consolidateStatus(this)





            status=DataTypeWorkflow.Advisor.internal.utils.ReportCheckStatus(max(this(:)));
        end
    end
end