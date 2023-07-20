classdef UltrasonicPropertySheet<driving.internal.scenarioApp.SensorPropertySheet




    properties(Hidden)
hAzimuthFieldOfView
hElevationFieldOfView
hMinRange
hMinDetectionOnlyRange
    end
    methods
        function this=UltrasonicPropertySheet(dlg)
            this@driving.internal.scenarioApp.SensorPropertySheet(dlg)
        end

        function label=getTypeLabel(~)
            label=getString(message('driving:scenarioApp:UltrasonicTypeLabel'));
        end

        function update(this)
            update@driving.internal.scenarioApp.SensorPropertySheet(this);
            sensor=getSpecification(this);
            enable=getEnable(this);
            set(this.hAzimuthFieldOfView,...
            'String',sensor.FieldOfView(1),...
            'Enable',enable);
            set(this.hElevationFieldOfView,...
            'String',sensor.FieldOfView(2),...
            'Enable',enable);
            simpleProps={'MaxRange','MinRange','MinDetectionOnlyRange'};
            setupWidgets(this,sensor,simpleProps);
        end

        function updateLayout(this)
            layout=this.Layout;
            insertPanel(this,layout,'DetectionParameters',2);
            clean(layout);
        end
    end

    methods(Access=protected)

        function tags=getDetectionCoordinatesTag(~)
            tags={'Ego Cartesian'};
        end

        function labels=getDetectionCoordinatesLabels(~)
            labels={getString(message('driving:scenarioApp:EgoCartesian'))};
        end

        function createWidgets(this)

            layoutInputs={'VerticalGap',3,'HorizontalGap',3};

            p=this.Panel;
            this.hShowDetectionParameters=createToggle(this,p,'ShowDetectionParameters');

            detectionParameters=uipanel(p,...
            'Tag','DetectionParameters',...
            'Visible','off',...
            'AutoResizeChildren','off',...
            'BorderType','none');
            this.hDetectionParameters=detectionParameters;

            azimuthFOVLabel=createLabelEditPair(this,detectionParameters,...
            'AzimuthFieldOfView',@this.FOVCallback,...
            'TooltipString',getString(message('driving:scenarioApp:AzimuthFieldOfViewDescription')));
            elevationFOVLabel=createLabelEditPair(this,detectionParameters,...
            'ElevationFieldOfView',@this.FOVCallback,...
            'TooltipString',getString(message('driving:scenarioApp:ElevationFieldOfViewDescription')));
            maxRangeLabel=createLabelEditPair(this,detectionParameters,'MaxRange',...
            'TooltipString',getString(message('driving:scenarioApp:MaxRangeDescription')));
            minRangeLabel=createLabelEditPair(this,detectionParameters,'MinRange',...
            'TooltipString',getString(message('driving:scenarioApp:MinRangeDescription')));
            minDetOnlyRangeLabel=createLabelEditPair(this,detectionParameters,'MinDetectionOnlyRange',...
            'TooltipString',getString(message('driving:scenarioApp:MinDetectionOnlyRangeDescription')));

            layout=matlabshared.application.layout.GridBagLayout(detectionParameters,...
            layoutInputs{:},'HorizontalWeights',[0,1,0,1]);
            this.DetectionLayout=layout;
            inset=layout.LabelOffset;
            labelProps={'Anchor','West','TopInset',inset,'MinimumHeight',20-inset};

            labelWidth1=layout.getMinimumWidth([maxRangeLabel,minRangeLabel,minDetOnlyRangeLabel]);
            labelWidth2=layout.getMinimumWidth(elevationFOVLabel);
            add(layout,azimuthFOVLabel,1,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hAzimuthFieldOfView,1,2,...
            'Fill','Horizontal');
            add(layout,elevationFOVLabel,1,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(layout,this.hElevationFieldOfView,1,4,...
            'Fill','Horizontal');
            add(layout,maxRangeLabel,2,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hMaxRange,2,2,...
            'Fill','Horizontal');
            add(layout,minRangeLabel,3,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hMinRange,3,2,...
            'Fill','Horizontal');
            add(layout,minDetOnlyRangeLabel,4,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hMinDetectionOnlyRange,4,2,...
            'Fill','Horizontal');
            setLayoutHeight(layout);

            layout=matlabshared.application.layout.GridBagLayout(p,...
            layoutInputs{:},'VerticalWeights',[0,1]);
            layout.add(this.hShowDetectionParameters,1,1,...
            'Fill','Horizontal');
            this.Layout=layout;

        end
        function FOVCallback(this,~,~)
            setVectorProperty(this,'FieldOfView','hAzimuthFieldOfView','hElevationFieldOfView');
        end
    end
end


