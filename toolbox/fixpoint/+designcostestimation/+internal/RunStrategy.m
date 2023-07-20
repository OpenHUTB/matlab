classdef RunStrategy




    properties(Access=public)
Map
    end

    methods


        function obj=RunStrategy(aMap)
            obj.Map=aMap;
        end


        function executeStrategy(obj,aAnalysisStrategy)
            aAnalysisStrategy.analyze(obj.Map);
        end
    end

end
