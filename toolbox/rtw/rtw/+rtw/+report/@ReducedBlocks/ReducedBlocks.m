classdef ReducedBlocks<coder.report.ReportPageBase





    properties
ModelName
    end

    methods
        function obj=ReducedBlocks(modelName,data)
            obj.ModelName=modelName;
            obj.Data=data;
        end
    end

    methods(Access=private)
        out=getTableData(obj,htmlEscape)
    end
end


