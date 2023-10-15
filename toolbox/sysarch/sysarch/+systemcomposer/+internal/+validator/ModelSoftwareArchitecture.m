classdef ModelSoftwareArchitecture < systemcomposer.internal.validator.BaseReference

    properties
        parentHandle;
    end

    methods

        function this = ModelSoftwareArchitecture( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end
    end
end

