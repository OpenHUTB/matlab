function varargout=globalconfig(varargin)




    if nargin>0

        switch varargin{1}
        case{'get','set','reset'}
            varargin{1}=['-',varargin{1}];
        case 'list'
            varargin{1}='-view';
        end
    end

    if nargout>0
        [varargout{1:nargout}]=coderapp.internal.globalconfig(varargin{:});
    else
        coderapp.internal.globalconfig(varargin{:});
    end
end
