classdef(Abstract)AbstractService<handle




    properties(Abstract,SetAccess=private)

        Started(1,1)logical
    end

    methods(Abstract)

        start(this)


        shutdown(this)
    end

    methods(Access=protected)
        function assertServiceStarted(this)
            assert(this.Started,message("coderApp:services:serviceNotStarted"));
        end
    end
end
