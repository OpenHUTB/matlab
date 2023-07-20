classdef(Sealed)CloneDetectionExceptionLog<handle






    properties(GetAccess=public,SetAccess=private)
        ExceptionLoglist={};
    end

    methods(Access=private)
        function obj=CloneDetectionExceptionLog
        end
    end

    methods(Static)

        function singleObj=getInstance
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=slEnginePir.util.CloneDetectionExceptionLog;
            end
            singleObj=localObj;
        end

    end

    methods
        function addException(obj,exceptionLog)
            if~isempty(exceptionLog)&&(ischar(exceptionLog)||isstring(exceptionLog))
                if isstring(exceptionLog)
                    exceptionLog=convertStringsToChars(exceptionLog);
                end
                obj.ExceptionLoglist{end+1,1}=exceptionLog;
                obj.ExceptionLoglist=unique(obj.ExceptionLoglist);
            end
        end
    end
end