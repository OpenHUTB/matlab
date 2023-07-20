classdef CreateDataRestorePoint<restorepoint.internal.create.CreateDataStrategy



    properties(Access=private)
        Model char
    end

    methods
        function setModelName(obj,model)
            obj.Model=model;
        end

        function createData=run(obj)
            createData=restorepoint.internal.utils.ModelRestoreData(obj.Model);
        end
    end
end
