classdef RTEDataItemPIM<handle




    properties(Access='protected')
        PIMName;
    end

    methods(Access='public')
        function this=RTEDataItemPIM(pimName)
            this.PIMName=pimName;
        end
    end

    methods(Static,Access='protected')
        function instanceArg=getInstanceArg(isMultiInstantiable)
            if isMultiInstantiable
                instanceArg=[AUTOSAR.CSC.getRTEInstanceType,' ',...
                AUTOSAR.CSC.getRTEInstanceName];
            else
                instanceArg='void';
            end
        end
    end
end
