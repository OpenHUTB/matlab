function varargout=lookupCheckID(varargin)













    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    [varargout{1:nargout}]=ModelAdvisor.convertCheckID(varargin{1:end});
