classdef MTreeAttributes<coder.internal.translator.MTreeAttributes&matlab.mixin.Copyable





    methods
        function obj=MTreeAttributes(tree)
            obj=obj@coder.internal.translator.MTreeAttributes(tree);
        end
    end

    methods(Access=private)
        function val=supportedSubsRefLen(~)
            val=1;
        end
    end
end

