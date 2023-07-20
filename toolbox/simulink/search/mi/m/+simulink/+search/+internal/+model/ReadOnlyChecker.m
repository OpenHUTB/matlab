



classdef ReadOnlyChecker<handle
    methods(Access=public)
        function obj=ReadOnlyChecker()
        end

        function dependsOnProp=dependsOnPropertyName(this)
            dependsOnProp=false;
        end
    end
end
