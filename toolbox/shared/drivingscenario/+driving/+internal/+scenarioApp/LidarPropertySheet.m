classdef LidarPropertySheet<driving.internal.scenarioApp.PropertySheet


    properties
        ShowPointCloudReportingParameters=false;
        ShowDetectionParameters=false;
    end

    properties(Hidden)

hDetectionCoordinates
hHasOrganizedOutput
hHasEgoVehicle
hHasRoadsInputPort


hMaxRange
hRangeAccuracy
hAzimuthResolution
hElevationResolution
hAzimuthLimits
hElevationLimits
hHasNoise

hShowPointCloudReportingParameters
hShowDetectionParameters

hPointCloudReportingParameters
hDetectionParameters

PointCloudReportingLayout
DetectionLayout

    end

    methods
        function this=LidarPropertySheet(dlg)
            this@driving.internal.scenarioApp.PropertySheet(dlg)
        end

        function label=getTypeLabel(~)
            label=getString(message('driving:scenarioApp:LidarTypeLabel'));
        end

        function update(this)
            update@driving.internal.scenarioApp.PropertySheet(this);
            sensor=getSpecification(this);
            if isempty(sensor)
                enable='off';
                string={''};
                index=1;
            else
                enable=getEnable(this);
                string=getDetectionCoordinatesLabels(this);
                index=find(strcmp(sensor.DetectionCoordinates,{'Ego Cartesian','Sensor Cartesian'}));
            end
            set(this.hDetectionCoordinates,'String',string,...
            'Enable',enable,...
            'Value',index);
            simpleProps={'HasOrganizedOutput','HasEgoVehicle','HasRoadsInputPort',...
            'MaxRange','RangeAccuracy','AzimuthResolution','ElevationResolution',...
            'AzimuthLimits','ElevationLimits','HasNoise'};
            setupWidgets(this,sensor,simpleProps);
            set([this.hShowDetectionParameters,this.hShowPointCloudReportingParameters],'Enable',enable);
        end

        function updateLayout(this)
            layout=this.Layout;
            nextRow=insertPanel(this,layout,'PointCloudReportingParameters',2);
            insertPanel(this,layout,'DetectionParameters',nextRow+1);
            clean(layout);
        end
    end

    methods(Access=protected)

        function labels=getDetectionCoordinatesLabels(~)
            labels={getString(message('driving:scenarioApp:EgoCartesian')),...
            getString(message('driving:scenarioApp:SensorCartesian'))};
        end

        function detectionCoordinatesCallback(this,hItem,~)
            coordinates={'Ego Cartesian','Sensor Cartesian'};
            setProperty(this,'DetectionCoordinates',coordinates{hItem.Value});
        end

        function createWidgets(this)
            p=this.Panel;
            this.hShowPointCloudReportingParameters=createToggle(this,p,'ShowPointCloudReportingParameters');
            this.hShowDetectionParameters=createToggle(this,p,'ShowDetectionParameters');

            props={'Visible','off','BorderType','none'};
            if useAppContainer(this.Dialog.Application)
                props=[props,{'AutoResizeChildren','off'}];
            end
            ptcloudReportingParameters=uipanel(p,props{:},'Tag','PointCloudReportingParameters');
            this.hPointCloudReportingParameters=ptcloudReportingParameters;

            dcLabel=createLabelEditPair(this,ptcloudReportingParameters,'DetectionCoordinates',@this.detectionCoordinatesCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:DetectionCoordinatesDescription')));
            createCheckbox(this,ptcloudReportingParameters,'HasOrganizedOutput',...
            'TooltipString',getString(message('driving:scenarioApp:HasOrganizedOutputDescription')));
            createCheckbox(this,ptcloudReportingParameters,'HasEgoVehicle',...
            'TooltipString',getString(message('driving:scenarioApp:HasEgoVehicleDescription')));
            createCheckbox(this,ptcloudReportingParameters,'HasRoadsInputPort',...
            'TooltipString',getString(message('driving:scenarioApp:HasRoadsInputPortDescription')));

            layoutInputs={'VerticalGap',3};
            layout=matlabshared.application.layout.GridBagLayout(ptcloudReportingParameters,...
            layoutInputs{:});
            this.PointCloudReportingLayout=layout;

            labelWidth=max(layout.getMinimumWidth(dcLabel));
            inset=layout.LabelOffset;
            labelProps={'Anchor','West','TopInset',inset,'MinimumHeight',20-inset};

            add(layout,dcLabel,1,1,labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hDetectionCoordinates,1,2,'Fill','Horizontal');
            add(layout,this.hHasOrganizedOutput,2,[1,2],'Fill','Horizontal');
            add(layout,this.hHasEgoVehicle,3,[1,2],'Fill','Horizontal');
            add(layout,this.hHasRoadsInputPort,4,[1,2],'Fill','Horizontal');
            setLayoutHeight(layout);


            detectionParameters=uipanel(p,props{:},'Tag','DetectionParameters');
            this.hDetectionParameters=detectionParameters;

            maxRangeLabel=createLabelEditPair(this,detectionParameters,'MaxRange',...
            'TooltipString',getString(message('driving:scenarioApp:MaxRangeDescription')));

            raLabel=createLabelEditPair(this,detectionParameters,'RangeAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:RangeAccuracyDescription')));

            hAzimuthResolutionLabel=createLabelEditPair(this,detectionParameters,'AzimuthResolution',...
            'TooltipString',getString(message('driving:scenarioApp:AzimuthResolutionDescription')));
            hElevationResolutionLabel=createLabelEditPair(this,detectionParameters,'ElevationResolution',...
            'TooltipString',getString(message('driving:scenarioApp:ElevationResolutionDescription')));
            azimuthLimitsLabel=createLabelEditPair(this,detectionParameters,'AzimuthLimits',...
            'TooltipString',getString(message('driving:scenarioApp:RangeAccuracyDescription')));
            elevationLimitsLabel=createLabelEditPair(this,detectionParameters,'ElevationLimits',...
            'TooltipString',getString(message('driving:scenarioApp:RangeAccuracyDescription')));
            createCheckbox(this,detectionParameters,'HasNoise',...
            'TooltipString',getString(message('driving:scenarioApp:HasNoiseDescription')));

            layout=matlabshared.application.layout.GridBagLayout(detectionParameters,...
            layoutInputs{:});
            this.DetectionLayout=layout;


            labelWidth1=layout.getMinimumWidth([raLabel,hAzimuthResolutionLabel,hElevationResolutionLabel...
            ,azimuthLimitsLabel,elevationLimitsLabel]);
            add(layout,maxRangeLabel,1,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hMaxRange,1,2,...
            'Fill','Horizontal');
            add(layout,raLabel,2,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hRangeAccuracy,2,2,...
            'Fill','Horizontal');
            add(layout,hAzimuthResolutionLabel,3,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hAzimuthResolution,3,2,...
            'Fill','Horizontal');
            add(layout,hElevationResolutionLabel,4,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hElevationResolution,4,2,...
            'Fill','Horizontal');
            add(layout,azimuthLimitsLabel,5,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hAzimuthLimits,5,2,...
            'Fill','Horizontal');
            add(layout,elevationLimitsLabel,6,1,...
            'MinimumWidth',labelWidth1,labelProps{:});
            add(layout,this.hElevationLimits,6,2,...
            'Fill','Horizontal');
            add(layout,this.hHasNoise,7,1,'Fill','Horizontal');
            setLayoutHeight(layout);

            layout=matlabshared.application.layout.GridBagLayout(p,...
            layoutInputs{:},'VerticalWeights',[0,1,1]);
            layout.add(this.hShowPointCloudReportingParameters,1,1,...
            'Fill','Horizontal');
            layout.add(this.hShowDetectionParameters,2,1,...
            'Fill','Horizontal');
            this.Layout=layout;

        end
    end
end


