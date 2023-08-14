classdef TestItemIDData<slreq.report.rtmx.utils.ItemIDData
    properties
TestPath
TestAttributes
Description
    end

    methods
        function this=TestItemIDData(id)
            this@slreq.report.rtmx.utils.ItemIDData(id);
            this.Domain='sltest';
        end

    end
end

