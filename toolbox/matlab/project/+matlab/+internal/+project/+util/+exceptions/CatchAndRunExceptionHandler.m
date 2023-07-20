
classdef CatchAndRunExceptionHandler<...
    matlab.internal.project.util.exceptions.ExceptionHandler

    properties(Access=private)
MatlabExceptionID
RunOnCatchFunction
    end


    methods(Access=public)

        function obj=CatchAndRunExceptionHandler(matlabExceptionID,...
            runOnCatchFunction)

            obj.MatlabExceptionID=matlabExceptionID;
            obj.RunOnCatchFunction=runOnCatchFunction;
        end

        function handled=handleException(obj,exception)
            handled=false;
            if(strcmpi(exception.identifier,obj.MatlabExceptionID))
                obj.RunOnCatchFunction(exception);
                handled=true;
            end
        end

    end

end

