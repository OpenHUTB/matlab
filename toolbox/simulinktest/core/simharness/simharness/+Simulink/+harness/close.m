function close(harnessOwner,varargin)
    harnessOwner=convertStringsToChars(harnessOwner);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        if nargin==1
            openHarness=Simulink.harness.find(harnessOwner,'OpenOnly','on');

            if isempty(openHarness)
                DAStudio.error('Simulink:Harness:NoHarnessForOwner',harnessOwner);
            end
            harnessName=openHarness.name;
            harnessOwner=openHarness.ownerFullPath;
        elseif nargin==2
            harnessName=varargin{1};
        end
        Simulink.harness.internal.close(harnessOwner,harnessName);
    catch ME
        throwAsCaller(ME);
    end
end
