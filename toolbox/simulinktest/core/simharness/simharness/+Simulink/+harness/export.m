function export(harnessOwner,harnessName,varargin)
    harnessOwner=convertStringsToChars(harnessOwner);
    harnessName=convertStringsToChars(harnessName);

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        Simulink.harness.internal.export(harnessOwner,harnessName,true,varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end
