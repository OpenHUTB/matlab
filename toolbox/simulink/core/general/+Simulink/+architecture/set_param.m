function varargout=set_param(varargin)


















    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.set_param(varargin{:});
    catch err

        throw(err);
    end

end
