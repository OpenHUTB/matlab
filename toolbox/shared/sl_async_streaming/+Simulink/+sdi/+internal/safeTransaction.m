function varargout=safeTransaction(func,varargin)



    numArgs=nargout(func);
    varargout=cell(1,numArgs);

    repo=sdi.Repository(1);
    [varargout{:}]=safeTransaction(repo,func,varargin{:});
end
