classdef(Abstract)TrackingStrategy<handle






    methods(Abstract)
        initialize(this)
        diagnostic=check(this)
        diagnostic=advance(this)
    end

    methods
        function reset(this)%#ok<MANU>
        end
    end
end