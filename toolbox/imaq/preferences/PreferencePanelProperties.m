classdef PreferencePanelProperties<handle





    properties(Access='private')
PreferenceSettings
    end

    methods(Access='private')
        function obj=PreferencePanelProperties()
            s=settings;
            obj.PreferenceSettings=s.imaq;
        end
    end


    methods(Access='public')
        function out=getGigeCommandPacketRetries(obj)
            out=obj.PreferenceSettings.gige.CommandRetries.ActiveValue;
        end

        function out=getGigeHeartbeatTimeout(obj)
            out=obj.PreferenceSettings.gige.HeartbeatTimeout.ActiveValue;
        end

        function out=getGigePacketAckTimeout(obj)
            out=obj.PreferenceSettings.gige.PacketAckTimeout.ActiveValue;
        end

        function out=getGigeDisableForceIP(obj)
            out=obj.PreferenceSettings.gige.DisableForceIP.ActiveValue;
        end

        function out=getMacvideoDiscoveryTimeout(obj)
            out=obj.PreferenceSettings.macvideo.DiscoveryTimeout.ActiveValue;
        end

        function setGigeCommandPacketRetries(obj,value)
            obj.PreferenceSettings.gige.CommandRetries.PersonalValue=value;
        end

        function setGigeHeartbeatTimeout(obj,value)
            obj.PreferenceSettings.gige.HeartbeatTimeout.PersonalValue=value;
        end

        function setGigePacketAckTimeout(obj,value)
            obj.PreferenceSettings.gige.PacketAckTimeout.PersonalValue=value;
        end

        function setGigeDisableForceIP(obj,value)
            obj.PreferenceSettings.gige.DisableForceIP.PersonalValue=value;
        end

        function setMacvideoDiscoveryTimeout(obj,value)
            obj.PreferenceSettings.macvideo.DiscoveryTimeout.PersonalValue=value;
        end
    end


    methods(Access='public',Static=true)
        function singleObj=getOrResetInstance(reset)
            persistent localStaticObj;
            if(nargin==1)&&(reset==true)
                delete(localStaticObj);
                localStaticObj=[];
                singleObj=[];
            else
                if isempty(localStaticObj)||~isvalid(localStaticObj)
                    localStaticObj=PreferencePanelProperties;
                end
                singleObj=localStaticObj;
            end
        end
    end
end

