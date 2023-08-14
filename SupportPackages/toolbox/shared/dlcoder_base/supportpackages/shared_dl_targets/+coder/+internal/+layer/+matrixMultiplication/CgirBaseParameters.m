classdef(Abstract)CgirBaseParameters














%#codegen

    properties
        SimdRegistersPerColumn(1,1){mustBeInteger,mustBePositive}=4
        RegisterBlockWidth(1,1){mustBeInteger,mustBePositive}=4
        SimdWidth(1,1){mustBeInteger,mustBeGreaterThanOrEqual(SimdWidth,-1),mustBeNonzero}=-1
        CacheBlockSizeM(1,1){mustBeInteger,mustBePositive}=384
        CacheBlockSizeN(1,1){mustBeInteger,mustBePositive}=384
        CacheBlockSizeK(1,1){mustBeInteger,mustBePositive}=384
    end

    methods(Static,Hidden)


        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end
    end

end

