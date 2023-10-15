classdef Adapter < systemcomposer.internal.validator.BaseComponentBlockType

    methods

        function this = Adapter( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end
    end
end
