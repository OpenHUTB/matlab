classdef Base<handle





    properties(Abstract,SetAccess=protected)
BoardName
    end

    methods(Abstract,Hidden)
        dr=getDataRecorderObject(obj,varargin);
        srcObj=getSource(obj,sourceName);
        srcList=getAvailableSources(obj);
    end
end
