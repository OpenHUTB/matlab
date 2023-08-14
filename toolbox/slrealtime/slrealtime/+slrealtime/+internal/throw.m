classdef throw






    methods(Static)

        function Warning(warnId,varargin)
            w=warning('off','backtrace');
            c=onCleanup(@()warning(w));
            msg=message(warnId,varargin{:});
            warning(warnId,msg.getString());
        end


        function Error(errId,varargin)
            msg=message(errId,varargin{:});
            exc=MException(errId,'%s',msg.getString());
            throwAsCaller(exc);
        end


        function ErrorWithCause(errId,cause,varargin)
            msg=message(errId,varargin{:});
            exc=MException(errId,'%s',msg.getString());
            throwAsCaller(exc.addCause(cause));
        end
    end
end
