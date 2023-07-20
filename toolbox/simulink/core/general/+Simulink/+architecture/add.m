function varargout=add(varargin)


















    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.add(varargin{:});
    catch err

        throw(err);
    end

end
