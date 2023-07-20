classdef(ConstructOnLoad)LidarViewerHideGroundEventData<event.EventData





    properties
HideGround
Mode
ElevationAngleDelta
InitialElevationAngle
MaxDistance
ReferenceVector
MaxAngularDistance
GridResolution
ElevationThreshold
SlopeThreshold
MaxWindowRadius
    end

    methods
        function eventData=LidarViewerHideGroundEventData(hide,mode,varargin)
            eventData.HideGround=hide;
            eventData.Mode=mode;
            eventData.ElevationAngleDelta=varargin{1};
            eventData.InitialElevationAngle=varargin{2};
            eventData.MaxDistance=varargin{3};
            eventData.ReferenceVector=varargin{4};
            eventData.MaxAngularDistance=varargin{5};
            if nargin>7
                eventData.GridResolution=varargin{6};
                eventData.ElevationThreshold=varargin{7};
                eventData.SlopeThreshold=varargin{8};
                eventData.MaxWindowRadius=varargin{9};
            end
        end
    end
end
