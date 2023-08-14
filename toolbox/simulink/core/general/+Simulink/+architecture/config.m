function varargout=config(varargin)



































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.config(varargin{:});
    catch err

        throw(err);
    end

end
