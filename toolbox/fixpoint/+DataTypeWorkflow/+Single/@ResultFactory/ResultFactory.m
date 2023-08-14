classdef ResultFactory<handle




    methods


        function res=createResult(~,data)
            assert(isfield(data,'ID'));
            res=DataTypeWorkflow.Single.Result(data.ID);
            res.updateResult(data);
        end
    end
end


