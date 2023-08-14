classdef GroundSettings<driving.internal.groundTruthLabeler.tool.GroundSettings




    methods

        function this=GroundSettings(tool)
            this@driving.internal.groundTruthLabeler.tool.GroundSettings(tool);
        end


        function open(this)
            if isempty(this.Dialog)||~isvalid(this.Dialog)||~isvalid(this.Dialog.Dlg)
                this.Dialog=lidar.internal.lidarLabeler.tool.GroundSettingsDialog(this.Container,this.ToolName);

                isLTLicensePresent=checkForLidarLicense();
                if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                    updateWithLTlicense(this.Dialog,this.ModeInternal,this.ElevationAngleDelta,...
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
                updateSliderDisplay(this)
                this.Dialog.Visible='on';
            else
                figure(this.Dialog.Dlg);
            end
        end
    end

    methods(Access=private)

        function settingsChangedCallback(this,evt)

            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                evtChangedCallback(this,evt)
                this.GridResolution=evt.GridResolution;
                this.ElevationThreshold=evt.ElevationThreshold;
                this.SlopeThreshold=evt.SlopeThreshold;
                this.MaxWindowRadius=evt.MaxWindowRadius;
            end

            packageEventData(this);
            updateSliderDisplay(this);
        end

        function settingsChangingCallback(this,evt)

            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                evtChangingCallback(this,evt)
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

            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                eventData=driving.internal.groundTruthLabeler.tool.LidarHideGroundEventData(...
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
            end

            try %#ok<TRYNC>
                updateSliderDisplay(this.Dialog,eventData);
            end
        end

        function packageEventData(this)

            isLTLicensePresent=checkForLidarLicense();
            if this.ToolName==vision.internal.toolType.LidarLabeler||isLTLicensePresent
                eventData=driving.internal.groundTruthLabeler.tool.LidarHideGroundEventData(...
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
    end
end

function tf=checkForLidarLicense()
    [tf,~]=license('checkout','Lidar_Toolbox');
end