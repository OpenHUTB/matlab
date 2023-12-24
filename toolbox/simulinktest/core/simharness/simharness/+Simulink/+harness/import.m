function import(harnessOwner,varargin)
    harnessOwner=convertStringsToChars(harnessOwner);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        Simulink.harness.internal.import(harnessOwner,varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end
