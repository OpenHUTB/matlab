


classdef DTypeSignednessT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'Unsigned','Signed'};
        intValues=int32([0,1]);
    end
    methods
        function this=DTypeSignednessT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end