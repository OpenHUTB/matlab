classdef ConstrainedSet<handle&matlab.mixin.internal.Scalar




    methods(Abstract)
        match=findMatch(obj,value,propName)
        values=getAllowedValues(obj)
    end
end
