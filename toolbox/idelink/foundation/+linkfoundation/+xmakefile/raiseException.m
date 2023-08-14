function raiseException(arg1,arg2,arg3,arg4,varargin)





















    if isobject(arg1)&&isa(arg1,'message')

        msgobj=arg1;
        if(nargin>=2)
            ex=arg2;
        else
            ex=[];
        end
        exception=MException(msgobj.Identifier,msgobj.getString);

    else

        module=arg1;
        func=arg2;
        reason=arg3;
        if(nargin>=4)
            ex=arg4;
        else
            ex=[];
        end

        try
            if(isempty(reason))
                msgID=sprintf('xmakefile:xmk_exception_%s_%s',module,func);
            else
                msgID=sprintf('xmakefile:xmk_exception_%s_%s_%s',module,func,reason);
            end
            exception=MException(['ERRORHANDLER:',msgID],DAStudio.message(['ERRORHANDLER:',msgID],varargin{:}));
        catch ex
            msg=message('ERRORHANDLER:xmakefile:xmk_exception_ExceptionProblem',module,func,ex.message);
            disp(msg.getString);
            return;
        end
    end




    if~isempty(ex)
        exception=addCause(exception,ex);
    end




    if isobject(exception)
        exception.throwAsCaller();
    end

end
