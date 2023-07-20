function obj=upgradeadvisor(system)

















































































    if nargin>0
        system=convertStringsToChars(system);
    end

    if nargout<1


        UpgradeAdvisor.open(system,'topmodel');
    else
        obj=UpgradeAdvisor.Upgrader(system);
    end

end

