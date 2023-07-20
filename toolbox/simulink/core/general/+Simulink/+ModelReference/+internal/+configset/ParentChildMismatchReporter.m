classdef(Abstract)ParentChildMismatchReporter<handle






    methods
        function this=ParentChildMismatchReporter()
        end

        result=report(obj,varargin)

        setComparator(obj,aComparator)
    end
end