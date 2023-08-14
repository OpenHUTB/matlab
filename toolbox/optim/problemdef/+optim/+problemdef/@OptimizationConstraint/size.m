function varargout=size(obj,dim)




























    nOut=max(nargout,1);
    varargout=cell(1,nOut);


    if(nargin==1)
        [varargout{:}]=optim.internal.problemdef.sizeInterfaceHandler(obj);
    else
        [varargout{:}]=optim.internal.problemdef.sizeInterfaceHandler(obj,dim);
    end
