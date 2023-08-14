classdef LogicalInserter<Simulink.stawebscope.servermanager.inserter.NotInterpolable





    methods
        function obj=LogicalInserter(item,inputData)
            obj@Simulink.stawebscope.servermanager.inserter.NotInterpolable(item,inputData);
        end

        function preProcess(obj)
            preProcess@Simulink.stawebscope.servermanager.inserter.Inserter(obj);
            boolData=obj.DataToBeInserted.y;
            diff_1=abs(boolData-1);
            diff_0=abs(boolData);
            if diff_0<diff_1

                obj.DataToBeInserted.y=false;
            else

                obj.DataToBeInserted.y=true;
            end
        end

    end
end