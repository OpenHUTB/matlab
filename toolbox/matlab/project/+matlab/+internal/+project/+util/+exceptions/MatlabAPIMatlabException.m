classdef MatlabAPIMatlabException<handle



    methods(Access=public,Static)
        function throwAPIException(exception)
            import matlab.internal.project.util.exceptions.Prefs;
            if(Prefs.ShortenStacks)
                exception.throwAsCaller;
            else
                exception.rethrow;
            end
        end
    end

end

