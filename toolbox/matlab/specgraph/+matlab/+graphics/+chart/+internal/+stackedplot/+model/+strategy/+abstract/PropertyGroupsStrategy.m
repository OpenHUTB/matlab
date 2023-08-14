classdef(Abstract)PropertyGroupsStrategy




    methods(Abstract)
        groups=getPropertyGroups(obj,chartData)
    end
end