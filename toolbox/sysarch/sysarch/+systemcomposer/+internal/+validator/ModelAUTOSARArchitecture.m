classdef ModelAUTOSARArchitecture < systemcomposer.internal.validator.BaseReference

    properties
        parentHandle;
    end

    methods

        function this = ModelAUTOSARArchitecture( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end
    end
end

