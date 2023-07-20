function varargout=pstesthelper(varargin)









    if nargin<1||~ischar(varargin{end})||...
        ~strcmp(varargin{end},'283a1d0fbe9c766e3d0832a49ee0558743e9297b00b1141fd593')
        varargout{1:nargout}=[];
        return
    end


    for k=coder.internal.evalinArgs(varargin)
        try
            varargin{k}=evalin('caller',varargin{k});
        catch
        end
    end


    report=emlcprivate('callfcn','emlckernel','pstest',varargin{1:end-1});


    if nargout>0
        varargout{1}=report;
    else
        coder.internal.emcError('pstest',report);
    end


