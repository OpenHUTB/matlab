classdef AeroTypes

    properties(Constant)

        AeroGeometrySourceEnum=matlab.internal.EnumType({'Auto','Variable',...
        'MatFile','Ac3d','Custom'});
        AeroVideoProfileTypeEnum=matlab.internal.EnumType({'Motion JPEG AVI',...
        'Archival','Motion JPEG 2000','MPEG-4','Uncompressed AVI'});
    end

end
