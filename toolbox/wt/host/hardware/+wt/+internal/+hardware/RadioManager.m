classdef RadioManager

    properties
claimedRadios
    end
    methods(Access=private)
        function obj=RadioManager(varargin)
            obj.claimedRadios=containers.Map;
        end
    end

    methods(Static)
        function singleObj=getInstance(varargin)

            persistent localObj
            if isempty(localObj)
                localObj=wt.internal.hardware.RadioManager(varargin{:});
            end
            singleObj=localObj;
        end
        function radioObj=leaseRadio(radioID,token)
            manager=wt.internal.hardware.RadioManager.getInstance();
            if isstring(radioID)||ischar(radioID)
                if manager.claimedRadios.isKey(radioID)
                    error(message("wt:radio:RadioInUse"));
                end
                radioObj=wt.internal.hardware.RadioDevice(radioID);
            elseif isa(radioID,'wt.internal.hardware.DeviceManager')


                radioObj=radioID;
                plugin=getPlugin(radioObj);
                radioID=plugin.DeviceName;
                if manager.claimedRadios.isKey(radioID)
                    error(message("wt:radio:RadioInUse"));
                end
            else
                error(message("wt:radio:InvalidRadio"));
            end
            claim(radioObj,token);
            manager.claimedRadios(radioID)=radioObj;
        end

        function returnRadio(radioID,token)
            manager=wt.internal.hardware.RadioManager.getInstance();
            if isa(radioID,'wt.internal.hardware.DeviceManager')


                radioObj=radioID;
                plugin=getPlugin(radioObj);
                radioID=plugin.DeviceName;
            end
            if manager.claimedRadios.isKey(radioID)
                radio=manager.claimedRadios(radioID);
                if strcmp(getClaimOwner(radio),token)
                    unClaim(radio,token);
                    manager.claimedRadios.remove(radioID);
                end
            end
        end
    end

end

