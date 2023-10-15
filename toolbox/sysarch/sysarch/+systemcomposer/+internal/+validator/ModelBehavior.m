classdef ModelBehavior < systemcomposer.internal.validator.BaseReference


    methods

        function this = ModelBehavior( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end
    end
end
