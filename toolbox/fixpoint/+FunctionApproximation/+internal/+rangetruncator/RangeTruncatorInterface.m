classdef RangeTruncatorInterface<handle



    methods(Abstract)
        newRange=truncate(this,functionWrapper,oldRange,varargin)
    end
end
