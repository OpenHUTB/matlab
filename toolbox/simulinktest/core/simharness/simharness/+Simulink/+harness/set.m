function set(varargin)






































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        Simulink.harness.internal.set(varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end
