classdef AssessmentResultDB


    properties(Constant)
        Data=sltest.assessments.internal.AssessmentResultDB.AssessmentResultDBStore
    end

    methods

        function id=addData(self,data)
            persistent dataID;
            if isempty(dataID)
                dataID=0;
            end
            dataID=dataID+1;
            id=dataID;
            self.Data.addData(id,data);
        end


        function removeData(self,id)
            self.Data.removeData(id);
        end


        function res=getData(self,id)
            res=self.Data.getData(id);
        end
    end
end

