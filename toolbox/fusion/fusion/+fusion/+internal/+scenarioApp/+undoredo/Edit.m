classdef Edit<handle

    properties(SetAccess=protected,Hidden)
DataModel
    end

    methods
        function this=Edit(hDataModel)
            this.DataModel=hDataModel;
        end
    end
end
