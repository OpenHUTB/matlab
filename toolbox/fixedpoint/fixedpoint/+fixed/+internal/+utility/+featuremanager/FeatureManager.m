classdef FeatureManager



    methods(Static)
        function status=getStatus(keyword)
            status=slfeature(keyword);
        end

        function setStatus(keyword,value)
            slfeature(keyword,value);
        end
    end
end

