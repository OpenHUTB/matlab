function move(harnessOwner,harnessName,varargin)










































    harnessOwner=convertStringsToChars(harnessOwner);

    harnessName=convertStringsToChars(harnessName);

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try

        Simulink.harness.internal.move(harnessOwner,harnessName,varargin{:});

    catch ME
        throwAsCaller(ME);
    end
end
