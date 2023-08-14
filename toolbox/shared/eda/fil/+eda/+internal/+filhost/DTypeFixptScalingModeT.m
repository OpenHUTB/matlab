


classdef DTypeFixptScalingModeT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'Fixed-point: unspecified scaling',...
        'Fixed-point: binary point scaling',...
        'Fixed-point: slope and bias scaling'};
        intValues=int32([0,1,2]);
    end
    methods
        function this=DTypeFixptScalingModeT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end