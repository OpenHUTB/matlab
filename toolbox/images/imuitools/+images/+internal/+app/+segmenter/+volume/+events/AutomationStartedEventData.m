classdef(ConstructOnLoad)AutomationStartedEventData<event.EventData





    properties

Algorithm
VolumeBased
Settings
Parent

    end

    methods

        function data=AutomationStartedEventData(alg,isVolume,settingsStruct,hfig)

            data.Algorithm=alg;
            data.VolumeBased=isVolume;
            data.Settings=settingsStruct;
            data.Parent=hfig;

        end

    end

end