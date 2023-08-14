classdef AssessmentResultDBStore<handle


    properties
data
    end

    methods
        function self=AssessmentResultDBStore()
            self.data=containers.Map('KeyType','int32','ValueType','any');
        end


        function addData(self,id,data)
            self.data(id)=data;
        end


        function removeData(self,id)
            self.data.remove(id);
        end


        function res=getData(self,id)
            res=self.data(id);
        end
    end
end

