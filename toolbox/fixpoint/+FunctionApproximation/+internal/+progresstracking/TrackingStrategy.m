classdef(Abstract)TrackingStrategy<handle







    methods(Abstract)
        initialize(this)
        diagnostic=check(this)
        diagnostic=advance(this)
    end
end