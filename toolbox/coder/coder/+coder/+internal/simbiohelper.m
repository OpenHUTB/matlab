function varargout=simbiohelper(varargin)








    for i=coder.internal.evalinArgs(varargin)
        try
            varargin{i}=evalin('caller',varargin{i});
        catch
        end
    end

    report=emlcprivate('callfcn','emlckernel','simbio',varargin{:});
    if nargout>0
        varargout{1}=report;
    else
        coder.internal.emcError(mfilename,report);
    end

