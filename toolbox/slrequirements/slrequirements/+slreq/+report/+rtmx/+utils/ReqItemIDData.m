classdef ReqItemIDData<slreq.report.rtmx.utils.ItemIDData
    properties
CustomAttributesInfo
        Index;
    end

    methods
        function this=ReqItemIDData(id)
            this@slreq.report.rtmx.utils.ItemIDData(id);
            this.Domain='slreq';
        end

    end
end

