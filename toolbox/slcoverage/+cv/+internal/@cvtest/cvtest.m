



classdef cvtest<handle

    methods(Abstract)
        res=valid(this)
    end

    methods(Abstract,Hidden)
        outTestObj=clone(this,varargin)
    end
end
