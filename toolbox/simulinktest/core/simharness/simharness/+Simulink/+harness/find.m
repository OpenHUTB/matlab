function harnessList=find(harnessOwner,varargin)


































    harnessOwner=convertStringsToChars(harnessOwner);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        harnessList=Simulink.harness.internal.find(harnessOwner,varargin{:});
    catch ME
        throwAsCaller(ME);
    end
end
