classdef ThirdPartyInfo<handle

















    properties

        PreviouslyInstalled=false;
        InstallDir='';
    end

    methods
        function set.PreviouslyInstalled(obj,value)

            validateattributes(value,{'logical','numeric'},{'nonempty'},'set.PreviouslyInstalled','value');
            obj.PreviouslyInstalled=logical(value);
        end

        function set.InstallDir(obj,value)

            validateattributes(value,{'char'},{'nonempty'},'set.InstallDir','value');
            obj.InstallDir=value;

        end

    end

end

