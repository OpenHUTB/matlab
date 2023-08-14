function varargout=find_system(varargin)























    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.find_system(varargin{:});
    catch err

        throw(err);
    end

end
