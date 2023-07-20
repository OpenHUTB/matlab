classdef StringInserter<Simulink.stawebscope.servermanager.inserter.NotInterpolable






    methods
        function obj=StringInserter(item,inputData)
            obj@Simulink.stawebscope.servermanager.inserter.NotInterpolable(item,inputData);
        end
        function data=extractValue(~,data)
        end
    end
end
