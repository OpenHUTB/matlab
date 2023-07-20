classdef FirmwareUpdate<hwconnectinstaller.internal.PackageInfo





    properties(Hidden)







SupportPkg

    end

    methods

        function set.SupportPkg(obj,spPkg)

            validateattributes(spPkg,{'char'},{});
            obj.SupportPkg=spPkg;

        end
    end

    methods(Abstract)

        ret=isFirmwareUpdateNeeded(obj)
        tSteps=getFirmwareUpdateSteps(obj)
    end

end

