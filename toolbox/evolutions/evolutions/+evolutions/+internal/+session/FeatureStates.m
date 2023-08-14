classdef FeatureStates<handle




    properties

        EnableReport(1,1)logical=false
        EnableCustomProfiles(1,1)logical=false
        EnableWebview(1,1)logical=false
    end

    methods(Access=?evolutions.internal.session.SessionManager)
        function obj=FeatureStates
        end
    end

end
