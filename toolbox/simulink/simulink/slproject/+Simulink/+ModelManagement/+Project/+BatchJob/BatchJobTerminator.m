classdef BatchJobTerminator<handle




    methods(Abstract,Access=public)

        terminate(terminator);

        terminated=isTerminated(terminator);

    end

end

