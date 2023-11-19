classdef DeviceManager<handle

    properties(Hidden,SetAccess=private)
        InUse=false
        ClaimedBy=""
    end
    properties(Access=private)
Plugin
    end

    methods
        function obj=DeviceManager(plugin)
            obj.Plugin=plugin;
        end
    end
    methods(Hidden)
        function success=claim(obj,token)
            if obj.InUse
                error(message("wt:radio:RadioAlreadyClaimed",obj.ClaimedBy));
            else
                obj.ClaimedBy=token;
                obj.InUse=true;
                success=true;
            end
        end

        function token=getClaimOwner(obj)
            token=obj.ClaimedBy;
        end

        function unClaim(obj,token)
            if strcmp(token,obj.ClaimedBy)
                obj.ClaimedBy="";
                obj.InUse=false;
            else
                error(message("wt:radio:InvalidToken"));
            end

        end

        function driver=getDriver(obj)
            driver=obj.Plugin.Driver;
        end

        function plugin=getPlugin(obj)
            plugin=obj.Plugin;
        end
    end

    methods(Hidden)
        function setDriver(obj,driver_name)
            obj.Plugin.Driver=driver_name;
        end
    end
end
