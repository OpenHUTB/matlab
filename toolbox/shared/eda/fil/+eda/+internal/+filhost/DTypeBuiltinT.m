



classdef DTypeBuiltinT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'double','single','int8','uint8',...
        'int16','uint16','int32','uint32',...
        'boolean','int64','uint64'};
        intValues=int32([0,1,2,3,4,5,6,7,8,9,10]);
    end
    methods
        function this=DTypeBuiltinT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end
