classdef InsertedBlocks<coder.report.ReportPageBase





    properties
ModelName


BuildDirectory
    end

    methods
        function obj=InsertedBlocks(model,data)
            obj.ModelName=model;
            obj.Data=data;
        end
    end

    methods(Access=private)
        out=getPortHandles(obj,sid)
    end
end


