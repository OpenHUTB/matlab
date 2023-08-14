classdef GridMapper<handle








    methods(Abstract)
        setKeyGrid(this,keyGrid,varargin);
        setValueGrid(this,valueGrid,varargin);
        constructMap(this);
        indices=getIndices(this,keys,varargin);
        values=getValues(this,keys,varargin);
    end
end