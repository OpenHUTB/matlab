classdef(Abstract)Comparison<...
    comparisons.internal.api.Object&...
    comparisons.internal.mixin.NonSerializable

    methods(Abstract)

        report=publish(comparison,varargin);

        filter(comparison,filter);

    end

    methods(Hidden,Access=protected)

        function comparison=Comparison(varargin)
            comparison@comparisons.internal.api.Object(varargin{:});
        end

    end

end
