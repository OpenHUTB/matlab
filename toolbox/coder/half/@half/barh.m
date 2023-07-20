function varargout=barh(varargin)







    c=todoublecell(varargin{:});
    [varargout{1:nargout}]=feval(mfilename,c{:});
