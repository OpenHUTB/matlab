function obj=createMemoryObject(h,objectType,varargin)










    if strcmp(objectType,'MemoryProfiler')
        obj=linkfoundation.autointerface.MemoryProfiler(varargin{:});
    elseif strcmp(objectType,'MemoryBuffer')
        obj=linkfoundation.autointerface.MemoryBuffer(varargin{:});
    end


