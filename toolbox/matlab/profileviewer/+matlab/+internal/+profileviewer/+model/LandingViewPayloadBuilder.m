classdef LandingViewPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder




    methods
        function obj=LandingViewPayloadBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            mlock;
        end

        function landingViewPayload=build(obj,isDataPayloadLoaded)
            landingViewPayload.ProfilerInvokedStatus=obj.ProfileInterface.getProfilerInvokedStatus();
            landingViewPayload.DataPayloadLoadStatus=isDataPayloadLoaded;
        end
    end
end
