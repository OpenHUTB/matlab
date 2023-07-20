classdef GroundSettings<handle




    properties
Dialog
ToolName
        OrganizedPC=false;
    end

    properties(Dependent)
HideGround
ElevationAngleDelta
InitialElevationAngle
MaxDistance
MaxAngularDistance
GridResolution
ElevationThreshold
SlopeThreshold
MaxWindowRadius
    end

    events
GroundSettingsChanged
ViewGroundDataRequest
StopViewGroundDataRequest
GroundSettingsCloseRequest
    end

    properties

        ModeInternal='segmentGroundFromLidarData';
        HideGroundInternal=false;

        ElevationAngleDeltaInternal=5;
        InitialElevationAngleInternal=30;

        ElevationAngleDeltaRange=[1,20];
        InitialElevationAngleRange=[10,35];

        MaxDistanceInternal=0.5;
        ReferenceVectorInternal=[0,0,1];
        MaxAngularDistanceInternal=5;

        MaxDistanceRange=[0,10];
        MaxAngularDistanceRange=[0,45];

        GridResolutionInternal=1;
        ElevationThresholdInternal=0.5;
        SlopeThresholdInternal=0.15;
        MaxWindowRadiusInternal=18;

        GridResolutionRange=[1,99];
        ElevationThresholdRange=[0,10];
        SlopeThresholdRange=[0,5];
        MaxWindowRadiusRange=[1,75];

DialogListener

    end


    methods

        function this=GroundSettings()

            dlgTitle=vision.getMessage('lidar:lidarViewer:LidarHideGroundOneLine');
            this.ToolName=dlgTitle;
        end

        function open(this,viewGroundDataFlag)
            if isempty(this.Dialog)||~isvalid(this.Dialog)||~isvalid(this.Dialog.FigureHandle)
                this.Dialog=lidar.internal.lidarViewer.view.dialog.GroundSettingsDialog(this.ToolName,this.OrganizedPC);


                if this.OrganizedPC
                    updateWithOrganizedPC(this.Dialog,this.ModeInternal,this.ElevationAngleDelta,...
                    this.InitialElevationAngle,...
                    this.MaxDistance,...
                    this.MaxAngularDistance,...
                    this.GridResolution,...
                    this.ElevationThreshold,...
                    this.SlopeThreshold,...
                    this.MaxWindowRadius);
                else
                    update(this.Dialog,this.ModeInternal,this.ElevationAngleDelta,...
                    this.InitialElevationAngle,...
                    this.MaxDistance,...
                    this.MaxAngularDistance);

                end
                this.DialogListener{1}=event.listener(this.Dialog,'GroundSettingsChanged',@(src,evt)settingsChangedCallback(this,evt));
                this.DialogListener{2}=event.listener(this.Dialog,'GroundSettingsChanging',@(src,evt)settingsChangingCallback(this,evt));
                this.DialogListener{3}=event.listener(this.Dialog,'ViewGroundDataRequest',@(~,~)viewGroundDataRequest(this));
                this.DialogListener{4}=event.listener(this.Dialog,'StopViewGroundDataRequest',@(~,~)stopViewGroundDataRequest(this));
                addlistener(this.Dialog,'GroundSettingsCloseRequest',@(~,~)groundSettingsClose(this));
                updateSliderDisplay(this)
                this.Dialog.Visible='on';
                this.Dialog.ViewGroundDataCheckbox.Value=viewGroundDataFlag;
            else
                figure(this.Dialog.FigureHandle);
            end
        end

        function groundSettingsClose(this)
            notify(this,'GroundSettingsCloseRequest');
        end

        function close(this)
            try %#ok<TRYNC>
                this.DialogListener={};
                delete(this.Dialog);
                this.Dialog=[];
            end
        end

        function delete(this)
            close(this);
            delete(this);
        end

    end

    methods(Access=private)

        function settingsChangedCallback(this,evt)

            evtChangedCallback(this,evt)
            if this.OrganizedPC
                this.GridResolution=evt.GridResolution;
                this.ElevationThreshold=evt.ElevationThreshold;
                this.SlopeThreshold=evt.SlopeThreshold;
                this.MaxWindowRadius=evt.MaxWindowRadius;
            end

            packageEventData(this);
            updateSliderDisplay(this);
        end

        function settingsChangingCallback(this,evt)

            evtChangingCallback(this,evt);
            if this.OrganizedPC
                if evt.GridResolution~=0
                    this.GridResolution=evt.GridResolution;
                end
                if evt.ElevationThreshold~=0
                    this.ElevationThreshold=evt.ElevationThreshold;
                end
                if evt.SlopeThreshold~=0
                    this.SlopeThreshold=evt.SlopeThreshold;
                end
                if evt.MaxWindowRadius~=0
                    this.MaxWindowRadius=evt.MaxWindowRadius;
                end
            end

            updateSliderDisplay(this);
        end

        function updateSliderDisplay(this)

            if this.OrganizedPC
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(...
                this.HideGroundInternal,...
                this.ModeInternal,...
                this.ElevationAngleDeltaInternal,...
                this.InitialElevationAngleInternal,...
                this.MaxDistanceInternal,...
                this.ReferenceVectorInternal,...
                this.MaxAngularDistanceInternal,...
                this.GridResolutionInternal,...
                this.ElevationThresholdInternal,...
                this.SlopeThresholdInternal,...
                this.MaxWindowRadiusInternal);
            else
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(...
                this.HideGroundInternal,...
                this.ModeInternal,...
                this.ElevationAngleDeltaInternal,...
                this.InitialElevationAngleInternal,...
                this.MaxDistanceInternal,...
                this.ReferenceVectorInternal,...
                this.MaxAngularDistanceInternal);
            end

            try %#ok<TRYNC>
                updateSliderDisplay(this.Dialog,eventData);
            end
        end

        function packageEventData(this)

            if this.OrganizedPC
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(...
                this.HideGroundInternal,...
                this.ModeInternal,...
                this.ElevationAngleDeltaInternal,...
                this.InitialElevationAngleInternal,...
                this.MaxDistanceInternal,...
                this.ReferenceVectorInternal,...
                this.MaxAngularDistanceInternal,...
                this.GridResolutionInternal,...
                this.ElevationThresholdInternal,...
                this.SlopeThresholdInternal,...
                this.MaxWindowRadiusInternal);
            else
                eventData=lidar.internal.lidarViewer.events.LidarViewerHideGroundEventData(...
                this.HideGroundInternal,...
                this.ModeInternal,...
                this.ElevationAngleDeltaInternal,...
                this.InitialElevationAngleInternal,...
                this.MaxDistanceInternal,...
                this.ReferenceVectorInternal,...
                this.MaxAngularDistanceInternal);
            end

            notify(this,'GroundSettingsChanged',eventData);
        end

        function evtChangedCallback(this,evt)
            this.ModeInternal=evt.Mode;
            this.HideGroundInternal=evt.HideGround;
            this.ElevationAngleDelta=evt.ElevationAngleDelta;
            this.InitialElevationAngle=evt.InitialElevationAngle;
            this.MaxDistance=evt.MaxDistance;
            this.ReferenceVectorInternal=evt.ReferenceVector;
            this.MaxAngularDistance=evt.MaxAngularDistance;
        end

        function evtChangingCallback(this,evt)
            this.ElevationAngleDelta=evt.ElevationAngleDelta;
            this.InitialElevationAngle=evt.InitialElevationAngle;
            if evt.MaxDistance~=0
                this.MaxDistance=evt.MaxDistance;
            end
            this.ReferenceVectorInternal=evt.ReferenceVector;
            if evt.MaxAngularDistance~=0
                this.MaxAngularDistance=evt.MaxAngularDistance;
            end
        end

        function viewGroundDataRequest(this)
            notify(this,'ViewGroundDataRequest');
        end

        function stopViewGroundDataRequest(this)
            notify(this,'StopViewGroundDataRequest');
        end
    end

    methods

        function set.HideGround(this,TF)

            this.HideGroundInternal=TF;

            if~TF
                close(this)
            end

            packageEventData(this);

        end

        function TF=get.HideGround(this)
            TF=this.HideGroundInternal;
        end

        function set.ElevationAngleDelta(this,percent)

            this.ElevationAngleDeltaInternal=this.ElevationAngleDeltaRange(1)+...
            percent*(this.ElevationAngleDeltaRange(2)-this.ElevationAngleDeltaRange(1));
        end

        function percent=get.ElevationAngleDelta(this)

            percent=(this.ElevationAngleDeltaInternal-this.ElevationAngleDeltaRange(1))/...
            (this.ElevationAngleDeltaRange(2)-this.ElevationAngleDeltaRange(1));
        end

        function set.InitialElevationAngle(this,percent)

            this.InitialElevationAngleInternal=this.InitialElevationAngleRange(1)+...
            percent*(this.InitialElevationAngleRange(2)-this.InitialElevationAngleRange(1));
        end

        function percent=get.InitialElevationAngle(this)

            percent=(this.InitialElevationAngleInternal-this.InitialElevationAngleRange(1))/...
            (this.InitialElevationAngleRange(2)-this.InitialElevationAngleRange(1));
        end

        function set.MaxDistance(this,percent)

            if(percent~=0)
                this.MaxDistanceInternal=this.MaxDistanceRange(1)+...
                percent*(this.MaxDistanceRange(2)-this.MaxDistanceRange(1));
            else
                uialert(this.Dialog.FigureHandle,...
                vision.getMessage("lidar:lidarViewer:FitGroundPlaneMaxDistSliderValuesNotZero"),...
                vision.getMessage("lidar:lidarViewer:Warning"));
                resetMaxDistanceSliderValue(this.Dialog,'maxDistance');
            end
        end

        function percent=get.MaxDistance(this)

            percent=(this.MaxDistanceInternal-this.MaxDistanceRange(1))/...
            (this.MaxDistanceRange(2)-this.MaxDistanceRange(1));
        end

        function set.MaxAngularDistance(this,percent)

            if(percent~=0)
                this.MaxAngularDistanceInternal=this.MaxAngularDistanceRange(1)+...
                percent*(this.MaxAngularDistanceRange(2)-this.MaxAngularDistanceRange(1));
            else
                uialert(this.Dialog.FigureHandle,...
                vision.getMessage("lidar:lidarViewer:FitGroundPlaneMaxAngularDistSliderValuesNotZero"),...
                vision.getMessage("lidar:lidarViewer:Warning"));
                resetMaxDistanceSliderValue(this.Dialog,'maxAngularDistance');
            end
        end

        function percent=get.MaxAngularDistance(this)

            percent=(this.MaxAngularDistanceInternal-this.MaxAngularDistanceRange(1))/...
            (this.MaxAngularDistanceRange(2)-this.MaxAngularDistanceRange(1));
        end

        function set.GridResolution(this,percent)

            this.GridResolutionInternal=this.GridResolutionRange(1)+...
            percent*(this.GridResolutionRange(2)-this.GridResolutionRange(1));
        end

        function percent=get.GridResolution(this)

            percent=(this.GridResolutionInternal-this.GridResolutionRange(1))/...
            (this.GridResolutionRange(2)-this.GridResolutionRange(1));
        end

        function set.ElevationThreshold(this,percent)

            this.ElevationThresholdInternal=this.ElevationThresholdRange(1)+...
            percent*(this.ElevationThresholdRange(2)-this.ElevationThresholdRange(1));
        end

        function percent=get.ElevationThreshold(this)

            percent=(this.ElevationThresholdInternal-this.ElevationThresholdRange(1))/...
            (this.ElevationThresholdRange(2)-this.ElevationThresholdRange(1));
        end

        function set.SlopeThreshold(this,percent)

            this.SlopeThresholdInternal=this.SlopeThresholdRange(1)+...
            percent*(this.SlopeThresholdRange(2)-this.SlopeThresholdRange(1));
        end

        function percent=get.SlopeThreshold(this)

            percent=(this.SlopeThresholdInternal-this.SlopeThresholdRange(1))/...
            (this.SlopeThresholdRange(2)-this.SlopeThresholdRange(1));
        end

        function set.MaxWindowRadius(this,percent)

            this.MaxWindowRadiusInternal=this.MaxWindowRadiusRange(1)+...
            percent*(this.MaxWindowRadiusRange(2)-this.MaxWindowRadiusRange(1));
        end

        function percent=get.MaxWindowRadius(this)

            percent=(this.MaxWindowRadiusInternal-this.MaxWindowRadiusRange(1))/...
            (this.MaxWindowRadiusRange(2)-this.MaxWindowRadiusRange(1));
        end
    end

end