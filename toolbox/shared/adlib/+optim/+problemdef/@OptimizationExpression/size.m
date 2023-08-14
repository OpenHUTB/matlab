function varargout=size(obj,varargin)




























    narginchk(1,2);


    nOut=max(nargout,1);
    varargout=cell(1,nOut);


    [varargout{:}]=optim.internal.problemdef.sizeInterfaceHandler(obj,varargin{:});

end
