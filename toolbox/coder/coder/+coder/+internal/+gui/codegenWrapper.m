function varargout=codegenWrapper(varargin)




    if nargout>0
        [varargout{1:nargout}]=emlcprivate('emlckernel','appCodegen',varargin{:});
    else
        emlcprivate('emlckernel','appCodegen',varargin{:});
    end
end
