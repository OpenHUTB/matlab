classdef Preferences<matlabshared.application.Preferences
    properties(Hidden,Constant)
        Instance=driving.internal.scenarioApp.Preferences;
    end

    properties
        MajorArrowMoveDistance(1,1)double{mustBeGreaterThan(MajorArrowMoveDistance,0),mustBeFinite}=1;
        MinorArrowMoveDistance(1,1)double{mustBeGreaterThan(MinorArrowMoveDistance,0),mustBeFinite}=0.1;
        MajorArrowRotateAngle(1,1)double{mustBeGreaterThan(MajorArrowRotateAngle,0),mustBeFinite}=15;
        MinorArrowRotateAngle(1,1)double{mustBeGreaterThan(MinorArrowRotateAngle,0),mustBeFinite}=1;
    end

    methods(Access=protected)
        function this=Preferences
            this@matlabshared.application.Preferences();
        end

        function app=getPreferenceTag(~)
            app='DrivingScenarioDesigner';
        end

        function props=getPreferenceProperties(~)
            props={'MajorArrowMoveDistance','MinorArrowMoveDistance',...
            'MajorArrowRotateAngle','MinorArrowRotateAngle'};
        end
    end
end


