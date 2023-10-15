classdef SubsystemReferenceBehavior < systemcomposer.internal.validator.BaseReference


    methods

        function this = SubsystemReferenceBehavior( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end
    end
end
