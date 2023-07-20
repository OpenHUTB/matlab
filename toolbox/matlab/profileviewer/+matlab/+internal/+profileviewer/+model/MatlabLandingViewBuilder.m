classdef MatlabLandingViewBuilder<matlab.internal.profileviewer.model.LandingViewPayloadBuilder




    methods
        function obj=MatlabLandingViewBuilder(profilerModel)
            obj@matlab.internal.profileviewer.model.LandingViewPayloadBuilder(profilerModel);
            mlock;
        end
    end
end
