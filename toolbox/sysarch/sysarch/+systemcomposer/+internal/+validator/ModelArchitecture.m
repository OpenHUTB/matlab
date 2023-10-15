classdef ModelArchitecture < systemcomposer.internal.validator.BaseReference

    properties
        parentHandle;
    end

    methods

        function this = ModelArchitecture( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end
    end
end
