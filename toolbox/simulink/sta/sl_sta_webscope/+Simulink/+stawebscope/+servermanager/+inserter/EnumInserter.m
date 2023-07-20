classdef EnumInserter<Simulink.stawebscope.servermanager.inserter.NotInterpolable





    methods
        function obj=EnumInserter(item,inputData)
            obj@Simulink.stawebscope.servermanager.inserter.NotInterpolable(item,inputData);
        end

        function preProcess(obj)


            preProcess@Simulink.stawebscope.servermanager.inserter.Inserter(obj);
            if isnumeric(obj.DataToBeInserted.y)


                castFcn=str2func(obj.MetaData.DataType);
                castedToEnum=castFcn(obj.DataToBeInserted.y);
                obj.DataToBeInserted.y=arrayfun(@(e)char(e),castedToEnum,'UniformOutput',false);
            end
        end

        function data=extractValue(obj,data)
            if ischar(data)
                castFcn=str2func(obj.MetaData.DataType);
                data=castFcn(data);
            end
        end

        function val=formatData(~,data)
            if isnumeric(data)
                val=num2str(data);
            elseif iscell(data)
                val=data{1};
            else
                val=data;
            end
        end
    end
end

