classdef DimensionConstraintBase
    properties(SetAccess=protected)
        Type matlab.system.DimensionConstraintType='Unknown';
        Size(1,1)int32{mustBePositive(Size)}=1
    end
end