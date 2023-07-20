function rebuild(harnessOwner,harnessName,varargin)


























    harnessOwner=convertStringsToChars(harnessOwner);

    harnessName=convertStringsToChars(harnessName);

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        Simulink.harness.internal.rebuild(harnessOwner,harnessName,varargin{:});
    catch ME
        throwAsCaller(ME);
    end

end
