classdef(Abstract)BaseExtractor<matlab.mixin.Heterogeneous
    properties(SetAccess=protected)
Identifier
DataIndex
    end

    properties(Abstract=true,Dependent=true,SetAccess=private)

StringIndex
    end


    methods(Abstract)

        getData(obj,simOut);
    end
end
