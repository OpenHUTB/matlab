classdef VisionPropertySheet<driving.internal.scenarioApp.SensorPropertySheet
    properties
        ShowCameraSettings=false;
        ShowSensorLimits=false;
        ShowLaneSettings=false;
    end

    properties(Hidden)
hLaneUpdateInterval
hShowCameraSettings
hCameraSettings


hFocalLengthX
hFocalLengthY
hPrincipalPointX
hPrincipalPointY
hImageWidth
hImageHeight

hDetectionType

hFalsePositivesPerImage

hShowSensorLimits
hSensorLimits
hMaxSpeed
hMaxAllowedOcclusion
hMinObjectImageWidth
hMinObjectImageHeight

hShowLaneSettings
hLaneSettings
hMinLaneImageWidth
hMinLaneImageHeight
hLaneBoundaryAccuracy
hLimitLanes
hMaxNumLanes

hBoundingBoxAccuracy
hProcessNoiseIntensity
CameraLayout
SensorLimitsLayout
        LaneSettingsLayout;
    end

    properties(Constant,Hidden)
        DetectionTypes={'objects','lanes&objects','lanes'};
    end

    methods
        function this=VisionPropertySheet(dlg)
            this@driving.internal.scenarioApp.SensorPropertySheet(dlg);
        end

        function label=getTypeLabel(~)
            label=getString(message('driving:scenarioApp:VisionTypeLabel'));
        end

        function update(this)

            update@driving.internal.scenarioApp.SensorPropertySheet(this);

            sensor=getSpecification(this);
            if isempty(sensor)
                enable='off';
            else
                enable=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);
            end

            set(this.hDetectionType,'Enable',enable,...
            'String',{getString(message('driving:scenarioApp:DetectionTypeObjects')),...
            getString(message('driving:scenarioApp:DetectionTypeObjectsAndLanes')),...
            getString(message('driving:scenarioApp:DetectionTypeLanes'))});
            simpleProps={'FalsePositivesPerImage','DetectionProbability',...
            'MaxSpeed','MaxAllowedOcclusion','MaxRange','BoundingBoxAccuracy',...
            'ProcessNoiseIntensity','LaneBoundaryAccuracy','LaneUpdateInterval','HasNoise'};
            xyProps={'FocalLength','PrincipalPoint'};
            whProps={'MinObjectImage','Image','MinLaneImage'};
            setupWidgets(this,sensor,simpleProps);
            setupWidgets(this,sensor,whProps,{'Height','Width'},'Size');
            setupWidgets(this,sensor,xyProps,{'X','Y'});

            laneEnable=enable;
            maxDetsEnable=enable;
            if isempty(sensor)
                index=1;
            else
                detType=sensor.DetectionType;
                index=find(strcmp(this.DetectionTypes,detType));
                if~any(strcmp(detType,{'lanes','lanes&objects'}))
                    laneEnable='off';
                end
                if strcmp(detType,'lanes')
                    maxDetsEnable='off';
                end
            end
            updateMaxNumWidgets(this,sensor,'Lanes',laneEnable);
            set([this.hShowCameraSettings,this.hShowSensorLimits,this.hShowDetectionParameters...
            ,this.hShowLaneSettings,this.hShowAccuracyNoise],'Enable',enable);
            set([this.hLaneUpdateInterval,this.hMinLaneImageWidth,this.hMinLaneImageHeight...
            ,this.hLaneBoundaryAccuracy,this.hLimitLanes],'Enable',laneEnable);
            set(this.hDetectionType,'Enable',enable,'Value',index);
            updateMaxNumWidgets(this,sensor,'Detections',maxDetsEnable);

        end
    end

    methods(Hidden)
        function updateLayout(this)
            mainLayout=this.Layout;
            detectionLayout=this.DetectionLayout;


            nextRow=insertPanel(this,mainLayout,'CameraSettings',2);
            insertPanel(this,mainLayout,'DetectionParameters',nextRow+1);

            nextRow=insertPanel(this,detectionLayout,'SensorLimits',7);
            nextRow=insertPanel(this,detectionLayout,'LaneSettings',nextRow+1);
            insertPanel(this,detectionLayout,'AccuracyNoise',nextRow+1);
            clean(mainLayout);
            clean(detectionLayout);
            setLayoutHeight(detectionLayout);
            setLayoutHeight(mainLayout);
        end
    end

    methods(Access=protected)
        function createWidgets(this)

            p=this.Panel;
            leftInset=5;


            this.hShowCameraSettings=createToggle(this,p,'ShowCameraSettings');

            props={'Visible','off','BorderType','none','AutoResizeChildren','off'};

            cameraSettings=uipanel(p,props{:},'Tag','CameraSettings');
            this.hCameraSettings=cameraSettings;

            focalXLabel=createLabelEditPair(this,cameraSettings,'FocalLengthX',@this.focalLengthCallback,...
            'TooltipString',getString(message('driving:scenarioApp:FocalLengthXDescription')));
            focalYLabel=createLabelEditPair(this,cameraSettings,'FocalLengthY',@this.focalLengthCallback,...
            'TooltipString',getString(message('driving:scenarioApp:FocalLengthYDescription')));
            imageWLabel=createLabelEditPair(this,cameraSettings,'ImageWidth',@this.imageSizeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:ImageWidthDescription')));
            imageHLabel=createLabelEditPair(this,cameraSettings,'ImageHeight',@this.imageSizeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:ImageHeightDescription')));
            ppXLabel=createLabelEditPair(this,cameraSettings,'PrincipalPointX',@this.principalPointCallback,...
            'TooltipString',getString(message('driving:scenarioApp:PrincipalPointXDescription')));
            ppYLabel=createLabelEditPair(this,cameraSettings,'PrincipalPointY',@this.principalPointCallback,...
            'TooltipString',getString(message('driving:scenarioApp:PrincipalPointYDescription')));

            layoutInputs={'VerticalGap',3,'HorizontalGap',3};

            layout=matlabshared.application.layout.GridBagLayout(cameraSettings,...
            layoutInputs{:},'HorizontalWeights',[0,1,0,1]);
            this.CameraLayout=layout;

            inset=layout.LabelOffset;
            labelProps={'Anchor','West','TopInset',inset,'MinimumHeight',20-inset};

            labelWidth1=layout.getMinimumWidth([focalXLabel,imageWLabel,ppXLabel]);
            labelWidth2=layout.getMinimumWidth([focalYLabel,imageHLabel,ppYLabel]);
            add(layout,focalXLabel,1,1,...
            'MinimumWidth',labelWidth1,...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hFocalLengthX,1,2,...
            'Fill','Horizontal');
            add(layout,focalYLabel,1,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(layout,this.hFocalLengthY,1,4,...
            'Fill','Horizontal');
            add(layout,imageWLabel,2,1,...
            'MinimumWidth',labelWidth1,...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hImageWidth,2,2,...
            'Fill','Horizontal');
            add(layout,imageHLabel,2,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(layout,this.hImageHeight,2,4,...
            'Fill','Horizontal');
            add(layout,ppXLabel,3,1,...
            'MinimumWidth',labelWidth1,...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hPrincipalPointX,3,2,...
            'Fill','Horizontal');
            add(layout,ppYLabel,3,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(layout,this.hPrincipalPointY,3,4,...
            'Fill','Horizontal');

            layout.setLayoutHeight;

            this.hShowDetectionParameters=createToggle(this,p,'ShowDetectionParameters');

            detectionParameters=uipanel(p,props{:},'Tag','VisionDetectionParameters');
            this.hDetectionParameters=detectionParameters;

            hDetectionTypeLabel=createLabelEditPair(this,detectionParameters,'DetectionType',@this.detectionTypeCallback,'popupmenu');
            createLabelEditPair(this,detectionParameters,'DetectionProbability',...
            'TooltipString',getString(message('driving:scenarioApp:DetectionProbabilityDescription')));
            falsePositivesLabel=createLabelEditPair(this,detectionParameters,'FalsePositivesPerImage',...
            'TooltipString',getString(message('driving:scenarioApp:FalsePositivesPerImageDescription')));
            createCheckbox(this,detectionParameters,'LimitDetections',@this.limitDetectionsCallback,...
            'TooltipString',getString(message('driving:scenarioApp:LimitDetectionsDescription')));
            createEditbox(this,detectionParameters,'MaxNumDetections');
            createLabelEditPair(this,detectionParameters,'DetectionCoordinates',@this.detectionCoordinatesCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:DetectionCoordinatesDescription')));

            createToggle(this,detectionParameters,'ShowSensorLimits');
            sensorLimits=uipanel(detectionParameters,props{:},'Tag','SensorLimits');
            this.hSensorLimits=sensorLimits;

            hMaxSpeedLabel=createLabelEditPair(this,sensorLimits,'MaxSpeed',...
            'TooltipString',getString(message('driving:scenarioApp:MaxSpeedDescription')));
            createLabelEditPair(this,sensorLimits,'MaxRange',...
            'TooltipString',getString(message('driving:scenarioApp:MaxRangeDescription')));
            hMaxAllowedOcclusionLabel=createLabelEditPair(this,sensorLimits,'MaxAllowedOcclusion',...
            'TooltipString',getString(message('driving:scenarioApp:MaxAllowedOcclusionDescription')));
            hMinObjectImageWidthLabel=createLabelEditPair(this,sensorLimits,...
            'MinObjectImageWidth',@this.minObjectSizeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MinObjectImageWidthDescription')));
            hMinObjectImageHeightLabel=createLabelEditPair(this,sensorLimits,...
            'MinObjectImageHeight',@this.minObjectSizeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MinObjectImageHeightDescription')));

            layout=matlabshared.application.layout.GridBagLayout(sensorLimits,...
            layoutInputs{:},'HorizontalWeights',[0,1]);
            this.SensorLimitsLayout=layout;
            labelWidth=layout.getMinimumWidth([hMaxSpeedLabel,this.hMaxRangeLabel,hMaxAllowedOcclusionLabel,hMinObjectImageWidthLabel,hMinObjectImageHeightLabel]);
            add(layout,hMaxSpeedLabel,1,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMaxSpeed,1,2,...
            'Fill','Horizontal');
            add(layout,this.hMaxRangeLabel,2,1,...
            labelProps{:},'MinimumWidth',layout.getMinimumWidth(this.hMaxRangeLabel));
            add(layout,this.hMaxRange,2,2,...
            'Fill','Horizontal');
            add(layout,hMaxAllowedOcclusionLabel,3,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMaxAllowedOcclusion,3,2,...
            'Fill','Horizontal');
            add(layout,hMinObjectImageWidthLabel,4,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMinObjectImageWidth,4,2,...
            'Fill','Horizontal');
            add(layout,hMinObjectImageHeightLabel,5,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMinObjectImageHeight,5,2,...
            'Fill','Horizontal');
            layout.setLayoutHeight;


            this.hShowLaneSettings=createToggle(this,detectionParameters,'ShowLaneSettings');

            laneSettings=uipanel(detectionParameters,props{:},'Tag','VisionDetectionParameters');
            this.hLaneSettings=laneSettings;

            hLaneUpdateIntLabel=createLabelEditPair(this,laneSettings,'LaneUpdateInterval',...
            'TooltipString',getString(message('driving:scenarioApp:LaneUpdateIntervalDescription')));
            hMinLaneWidthLabel=createLabelEditPair(this,laneSettings,'MinLaneImageWidth',@this.minLaneImageSizeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MinLaneImageWidthDescription')));
            hMinLaneHeightLabel=createLabelEditPair(this,laneSettings,'MinLaneImageHeight',@this.minLaneImageSizeCallback,...
            'TooltipString',getString(message('driving:scenarioApp:MinLaneImageHeightDescription')));
            hAccuracyLabel=createLabelEditPair(this,laneSettings,'LaneBoundaryAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:LaneBoundaryAccuracyDescription')));
            createCheckbox(this,laneSettings,'LimitLanes',@this.limitNumLanesCallback,...
            'TooltipString',getString(message('driving:scenarioApp:LimitLanesDescription')));
            createEditbox(this,laneSettings,'MaxNumLanes');

            layout=matlabshared.application.layout.GridBagLayout(laneSettings,...
            layoutInputs{:},'HorizontalWeights',[0,1]);
            this.LaneSettingsLayout=layout;
            labelWidth=layout.getMinimumWidth([hLaneUpdateIntLabel,hMinLaneWidthLabel,hMinLaneHeightLabel,hAccuracyLabel]);
            add(layout,hLaneUpdateIntLabel,1,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hLaneUpdateInterval,1,2,...
            'Fill','Horizontal');
            add(layout,hMinLaneWidthLabel,2,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMinLaneImageWidth,2,2,...
            'Fill','Horizontal');
            add(layout,hMinLaneHeightLabel,3,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMinLaneImageHeight,3,2,...
            'Fill','Horizontal');
            add(layout,hAccuracyLabel,4,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hLaneBoundaryAccuracy,4,2,...
            'Fill','Horizontal');
            add(layout,this.hLimitLanes,5,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hMaxNumLanes,5,2,...
            'Fill','Horizontal');
            layout.setLayoutHeight;


            this.hShowAccuracyNoise=createToggle(this,detectionParameters,'ShowAccuracyNoise');
            accuracyNoise=uipanel(detectionParameters,props{:},'Tag','VisionAccuracyNoise');
            this.hAccuracyNoise=accuracyNoise;

            hBoundingBoxLabel=createLabelEditPair(this,detectionParameters,'BoundingBoxAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:BoundingBoxAccuracyDescription')));
            hProcessNoiseLabel=createLabelEditPair(this,detectionParameters,'ProcessNoiseIntensity',...
            'TooltipString',getString(message('driving:scenarioApp:ProcessNoiseIntensityDescription')));
            createCheckbox(this,detectionParameters,'HasNoise',...
            'TooltipString',getString(message('driving:scenarioApp:HasNoiseDescription')));

            layout=matlabshared.application.layout.GridBagLayout(accuracyNoise,...
            layoutInputs{:},'HorizontalWeights',[0,1]);
            this.AccuracyNoiseLayout=layout;
            labelWidth=layout.getMinimumWidth([hBoundingBoxLabel,hProcessNoiseLabel]);
            add(layout,hBoundingBoxLabel,1,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hBoundingBoxAccuracy,1,2,...
            'Fill','Horizontal');
            add(layout,hProcessNoiseLabel,2,1,...
            labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hProcessNoiseIntensity,2,2,...
            'Fill','Horizontal');
            add(layout,this.hHasNoise,3,[1,2],...
            'Anchor','west',...
            'MinimumWidth',layout.getMinimumWidth(this.hHasNoise)+20);
            [~,height]=getMinimumSize(layout);
            layout.setConstraints(accuracyNoise,'Fill','Both',...
            'MinimumHeight',height);

            layout=matlabshared.application.layout.GridBagLayout(detectionParameters,...
            layoutInputs{:},'HorizontalWeights',[0,1]);
            this.DetectionLayout=layout;

            limitDetectionsWidth=layout.getMinimumWidth(this.hLimitDetections)+20;
            labelWidth=max(layout.getMinimumWidth([hDetectionTypeLabel,this.hDetectionProbabilityLabel...
            ,falsePositivesLabel,this.hDetectionCoordinatesLabel]),limitDetectionsWidth);

            add(layout,hDetectionTypeLabel,1,1,...
            'MinimumWidth',labelWidth,...
            'Anchor','west',...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hDetectionType,1,2,...
            'Fill','Horizontal');
            add(layout,this.hDetectionProbabilityLabel,2,1,...
            'MinimumWidth',layout.getMinimumWidth(this.hDetectionProbabilityLabel),...
            'Anchor','west',...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hDetectionProbability,2,2,...
            'Fill','Horizontal');
            add(layout,falsePositivesLabel,3,1,...
            'MinimumWidth',labelWidth,...
            'Anchor','west',...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hFalsePositivesPerImage,3,2,...
            'Fill','Horizontal');
            add(layout,this.hLimitDetections,4,1,...
            'MinimumWidth',labelWidth,...
            'Anchor','west',...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hMaxNumDetections,4,2,...
            'Fill','Horizontal');
            add(layout,this.hDetectionCoordinatesLabel,5,1,...
            'MinimumWidth',labelWidth,...
            'Anchor','west',...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hDetectionCoordinates,5,2,...
            'Fill','Horizontal');
            add(layout,this.hShowSensorLimits,6,[1,2],...
            'Fill','Horizontal',...
            'LeftInset',leftInset);
            add(layout,this.hShowLaneSettings,7,[1,2],...
            'Fill','Horizontal',...
            'LeftInset',leftInset);
            add(layout,this.hShowAccuracyNoise,8,[1,2],...
            'Fill','Horizontal',...
            'LeftInset',leftInset);
            setConstraints(layout,this.hSensorLimits,'Fill','Both',...
            'LeftInset',2*leftInset,...
            'RightInset',-leftInset);
            setConstraints(layout,this.hLaneSettings,'Fill','Both',...
            'LeftInset',2*leftInset,...
            'RightInset',-leftInset);
            setConstraints(layout,this.hAccuracyNoise,'Fill','Both',...
            'LeftInset',2*leftInset,...
            'RightInset',-leftInset);
            layout.setLayoutHeight();

            layout=matlabshared.application.layout.GridBagLayout(p,...
            layoutInputs{:},'VerticalWeights',[0,1]);
            layout.add(this.hShowCameraSettings,1,1,...
            'Fill','Horizontal',...
            'TopInset',-2);
            layout.add(this.hShowDetectionParameters,2,1,...
            'Fill','Horizontal');
            this.Layout=layout;

            updateLayout(this);
        end

        function limitNumLanesCallback(this,hcbo,~)
            dlg=this.Dialog;
            if~isa(dlg.Application.SensorSpecifications(dlg.SpecificationIndex),'driving.internal.scenarioApp.VisionSensorSpecification')
                return
            end

            if hcbo.Value
                newValue='Property';
            else
                newValue='Auto';
            end
            setProperty(this,'MaxNumLanesSource',newValue);
        end

        function minLaneImageSizeCallback(this,~,~)
            setVectorProperty(this,'MinLaneImageSize','hMinLaneImageHeight','hMinLaneImageWidth');
        end

        function focalLengthCallback(this,~,~)
            setVectorProperty(this,'FocalLength','hFocalLengthX','hFocalLengthY');
        end

        function imageSizeCallback(this,~,~)
            setVectorProperty(this,'ImageSize','hImageHeight','hImageWidth');
        end

        function principalPointCallback(this,~,~)
            setVectorProperty(this,'PrincipalPoint','hPrincipalPointX','hPrincipalPointY');
        end
        function detectionTypeCallback(this,hItem,~)
            setProperty(this,'DetectionType',this.DetectionTypes{hItem.Value});
        end

        function minObjectSizeCallback(this,~,~)
            setVectorProperty(this,'MinObjectImageSize','hMinObjectImageHeight','hMinObjectImageWidth');
        end

    end
end


