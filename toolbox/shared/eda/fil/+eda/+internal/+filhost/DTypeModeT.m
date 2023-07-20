


classdef DTypeModeT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'Use builtin',...
        'Use fixed point'};
        intValues=int32([1,2]);
    end
    methods
        function this=DTypeModeT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end
