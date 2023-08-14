classdef Subsref




    properties(SetAccess=protected,GetAccess=protected)

OutSize
    end

    properties(SetAccess=protected)

OutLinIdx

OutIndexNames
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SubsrefVersion=2;
    end
end

