classdef LegacySupportPackage<handle
















    properties(SetAccess=immutable,GetAccess=private)
        SpPkg=[];
    end


    methods
        function obj=LegacySupportPackage(spkg)

            validateattributes(spkg,{'hwconnectinstaller.SupportPackage'},{'nonempty'});
            obj.SpPkg=spkg;
        end
    end

    methods(Access={?hwconnectinstaller.PackageInfo})
        function spPkgObj=getInternalSupportPkgObj(obj)
            spPkgObj=obj.SpPkg;
        end
    end
end
