function varargout=get_param(varargin)






















    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.get_param(varargin{:});
    catch err

        throw(err);
    end

end

