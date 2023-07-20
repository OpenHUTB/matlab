classdef FixedPointInserter<Simulink.stawebscope.servermanager.inserter.Inserter







    methods
        function obj=FixedPointInserter(item,inputData)
            obj@Simulink.stawebscope.servermanager.inserter.Inserter(item,inputData);
        end

        function preProcess(obj)
            obj.InsertedData=repmat(obj.InputData{1}(2),1,obj.NumOfColumns-1);
        end

        function data=extractValue(~,data)
            if isstruct(data)
                data=data.value;
                if ischar(data)
                    data=str2double(data);
                end
            end
        end

        function val=formatData(obj,data)

            val=obj.InputData{1}{2};
            val.value=data;
        end

        function copyData(obj)
            obj.InsertedData=cell(1,obj.NumOfColumns-1);
            for id=2:obj.NumOfColumns
                if iscell(obj.DataToBeInserted.y(id-1))
                    obj.InsertedData(id-1)=obj.DataToBeInserted.y(id-1);
                else
                    obj.InsertedData(id-1)={obj.DataToBeInserted.y(id-1)};
                end
            end
        end
    end
end