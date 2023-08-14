classdef FcnCallInserter<Simulink.stawebscope.servermanager.inserter.NotInterpolable






    methods
        function obj=FcnCallInserter(item,inputData)
            obj@Simulink.stawebscope.servermanager.inserter.NotInterpolable(item,inputData);
        end

        function preProcess(obj)
            preProcess@Simulink.stawebscope.servermanager.inserter.Inserter(obj);

            obj.DataToBeInserted.y=double(uint32(obj.DataToBeInserted.y));
        end

    end
end
