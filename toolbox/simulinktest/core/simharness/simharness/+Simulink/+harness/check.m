function[CheckResult,CheckDetails]=check(varargin)

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [CheckResult,CheckDetails]=Simulink.harness.internal.check(varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end

