classdef(Hidden)SensorConnectivityBase<matlab.System




    methods
        function obj=SensorConnectivityBase()
            try
                [navSuccess,errmsg]=builtin('license','checkout','Navigation_Toolbox');
                if(navSuccess~=1)
                    error(message('shared_gps:general:NoLicense'));
                end
                if~isempty(errmsg)
                    error(message(errmsg));
                end
            catch ME
                throwAsCaller(ME);
            end
        end
    end
end

