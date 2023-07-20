classdef ApproximateLUTDecisionVariableSet






    properties(SetAccess=private)
        StorageTypes(1,:)
    end

    methods
        function this=setStorageTypes(this,storageTypes)
            this.StorageTypes=storageTypes;
        end
    end
end