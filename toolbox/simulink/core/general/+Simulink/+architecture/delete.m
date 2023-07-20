function varargout=delete(varargin)
















    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.delete(varargin{:});
    catch err

        throw(err);
    end

end
