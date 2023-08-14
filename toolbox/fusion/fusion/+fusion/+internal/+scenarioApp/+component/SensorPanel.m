classdef SensorPanel<fusion.internal.scenarioApp.component.PropertyPanel&...
    fusion.internal.scenarioApp.component.HasSensorClassProperties


    properties
        ShowSensorMounting=false
EnableSensor
    end

    properties(Hidden)

hPlatformSelector
hSensorSelector
hName
hSensorEnabled
hUpdateRate
hType
hClassID


hShowSensorMounting
hSensorMountingPanel
MountingPanelLayout
hX
hY
hZ
hYaw
hPitch
hRoll


SensorMountingLayout

    end

    properties(SetAccess=protected)
PlatformSelectedIndex
SensorSelectedIndex
    end

    methods
        function index=get.PlatformSelectedIndex(this)
            [~,index]=getCurrentPlatform(this.Application);
        end

        function index=get.SensorSelectedIndex(this)
            [~,index]=getCurrentSensor(this.Application);
        end

        function set.PlatformSelectedIndex(this,index)
            selectPlatformByIndex(this.Application,index);
        end

        function set.SensorSelectedIndex(this,index)
            setCurrentSensorByIndex(this.Application,index);
        end
    end

    methods
        function this=SensorPanel(varargin)
            this@fusion.internal.scenarioApp.component.PropertyPanel(varargin{:});
            resetPropertyPanel(this);
            this.Figure.Visible='off';
        end

        function tag=getTag(~)
            tag='SensorPanel';
        end

        function[str,id]=msgString(this,key,varargin)
            id=strcat(this.ResourceCatalog,'SensorProperty',key);
            str=getString(message(id,varargin{:}));
        end

        function update(this,sensor,platitems,sensoritems)
            clearAllMessages(this);


            this.resetToggleValue('ShowAccuracyAndNoiseSettings',this.ShowAccuracyAndNoiseSettings);
            this.resetToggleValue('ShowAdvancedParameters',this.ShowAdvancedParameters);
            this.resetToggleValue('ShowDetectionParameters',this.ShowDetectionParameters);
            this.resetToggleValue('ShowScanningFOVParameters',this.ShowScanningFOVParameters);
            this.resetToggleValue('ShowSensorMounting',this.ShowSensorMounting);

            if isempty(sensor)
                resetPropertyPanel(this);
                return
            end

            enable=matlabshared.application.logicalToOnOff(this.Enabled);


            set(this.hPlatformSelector,'Enable',enable,...
            'String',platitems,'Value',this.PlatformSelectedIndex);

            set(this.hSensorSelector,'Enable',enable,...
            'String',sensoritems,'Value',this.SensorSelectedIndex);


            set(this.hSensorEnabled,'Enable',enable,'Value',sensor.SensorEnabled);
            category='Monostatic Radar';
            classSpecs=this.Application.getSensorClassSpecifications;
            classSpec=classSpecs.getSpecification(sensor.ClassID);
            set(this.hType,'Enable',enable,'String',strcat(classSpec.name," ",category));


            location=sensor.MountingLocation;
            angles=sensor.MountingAngles;
            set(this.hX,'Enable',enable,'String',location(1));
            set(this.hY,'Enable',enable,'String',location(2));
            set(this.hZ,'Enable',enable,'String',location(3));
            set(this.hRoll,'Enable',enable,'String',angles(1));
            set(this.hPitch,'Enable',enable,'String',angles(2));
            set(this.hYaw,'Enable',enable,'String',angles(3));
            set(this.hName,'Enable',enable,'String',sensor.Name);


            updateScanningPanel(this,sensor,enable);


            updateDetectionPanel(this,sensor,enable);


            updateLayout(this);
        end

        function updateLayout(this)
            layout=this.Layout;
            clean(layout);

            nextRow=this.insertPanel(layout,'SensorMounting',7);
            nextRow=this.insertScanningPanel(layout,nextRow+1);
            this.insertDetectionParameters(layout,nextRow+1);

            layout.VerticalWeights=[zeros(1,size(layout.Grid,1)-1),1];
            setAllToggleCData(this);
        end

    end

    methods(Access=protected)
        function resetPropertyPanel(this)
            fig=this.Figure;
            set(findall(fig,'style','popupmenu'),...
            'String',{' '},...
            'Value',1,...
            'Enable','off');
            set(findall(fig,'style','edit'),...
            'String','',...
            'Enable','off');
            checkboxes=findall(fig,'style','checkbox');
            tags=get(checkboxes,'Tag');
            checkboxes(strncmp(tags,'Show',4))=[];
            set(checkboxes,...
            'Value',false,...
            'Enable','off');
            set(findall(fig,'style','pushbutton'),'Enable','off');
            set(findall(fig,'Tag','Label'),'String','');
            updateLayout(this);
        end
    end


    methods(Access=protected)

        function fig=createFigure(this,varargin)
            fig=createFigure@matlabshared.application.Component(this,varargin{:});


            createToggle(this,fig,'ShowSensorMounting');
            createMountingPanel(this,fig);


            createToggle(this,fig,'ShowScanningFOVParameters');
            createScanningFOVParametersPanel(this,fig);

            createToggle(this,fig,'ShowDetectionParameters');
            createDetectionParametersPanel(this,fig);


            createFullPanel(this,fig);
            updateLayout(this);

        end

        function createFullPanel(this,fig)

            platformSelectorLabel=createLabelEditPair(this,fig,'PlatformSelector',...
            this.Application.initCallback(@this.platformSelectorCallback),'popupmenu',...
            'Tooltip',msgString(this,'PlatformSelectorTooltip'));
            sensorSelectorLabel=createLabelEditPair(this,fig,'SensorSelector',...
            this.Application.initCallback(@this.sensorSelectorCallback),'popupmenu',...
            'Tooltip',msgString(this,'SensorSelectorTooltip'));

            nameLabel=createLabelEditPair(this,fig,'Name',...
            this.Application.initCallback(@this.nameCallback));
            createCheckbox(this,fig,'SensorEnabled',...
            this.Application.initCallback(@this.sensorEnabledCallback));
            updateLabel=createLabelEditPair(this,fig,'UpdateRate',...
            this.Application.initCallback(@this.defaultEditboxCallback),...
            'Tooltip',msgString(this,'UpdateRateTooltip'));

            typeLabel=createLabelEditPair(this,fig,'Type',[],'text');


            layout=matlabshared.application.layout.ScrollableGridBagLayout(fig,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,1]);
            labelWidth=layout.getMinimumWidth([updateLabel,platformSelectorLabel,sensorSelectorLabel,typeLabel]);
            labelProps={'Fill','Horizontal','TopInset',5};

            add(layout,platformSelectorLabel,1,[1,2],'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hPlatformSelector,1,[3,5],'Fill','Horizontal',...
            'Anchor','NorthWest');
            add(layout,sensorSelectorLabel,2,[1,2],'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hSensorSelector,2,[3,5],'Fill','Horizontal',...
            'Anchor','NorthWest');

            add(layout,nameLabel,3,[1,2],...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hName,3,[3,4],...
            labelProps{:});

            add(layout,updateLabel,4,[1,2],...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hUpdateRate,4,[3,4],...
            labelProps{:});
            add(layout,typeLabel,5,1,...
            labelProps{:});
            add(layout,this.hType,5,[3,5],...
            labelProps{:},'MinimumWidth',200);



            add(layout,this.hShowSensorMounting,6,[1,5],...
            'Anchor','West',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowSensorMounting)+30);
            add(layout,this.hShowScanningFOVParameters,7,[1,5],...
            'Anchor','West',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowScanningFOVParameters)+30);
            add(layout,this.hShowDetectionParameters,8,[1,5],...
            'Anchor','North',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowSensorMounting)+30);

            this.Layout=layout;
        end

        function createMountingPanel(this,fig)
            mountingPanel=uipanel(fig,...
            'Tag','mountingpanel',...
            'BorderType','none');
            locCallback=this.Application.initCallback(@this.locationCallback);
            orientCallback=this.Application.initCallback(@this.orientationCallback);
            positionTip=msgString(this,'PositionTooltip');
            orientationTip=msgString(this,'OrientationTooltip');
            xLabel=createLabelEditPair(this,mountingPanel,'X',locCallback,'Tooltip',positionTip);
            yLabel=createLabelEditPair(this,mountingPanel,'Y',locCallback,'Tooltip',positionTip);
            zLabel=createLabelEditPair(this,mountingPanel,'Z',locCallback,'Tooltip',positionTip);
            rollLabel=createLabelEditPair(this,mountingPanel,'Roll',orientCallback,'Tooltip',orientationTip);
            pitchLabel=createLabelEditPair(this,mountingPanel,'Pitch',orientCallback,'Tooltip',orientationTip);
            yawLabel=createLabelEditPair(this,mountingPanel,'Yaw',orientCallback,'Tooltip',orientationTip);

            layoutInputs={'VerticalGap',3,'HorizontalGap',3};
            mountingLayout=matlabshared.application.layout.GridBagLayout(mountingPanel,...
            layoutInputs{:},'HorizontalWeights',[0,1,0,1,0,1]);
            inset=mountingLayout.LabelOffset;
            labelProps={'Anchor','West','TopInset',inset,'MinimumHeight',20-inset};

            labelWidth1=mountingLayout.getMinimumWidth([xLabel,rollLabel]);
            labelWidth2=mountingLayout.getMinimumWidth([yLabel,pitchLabel]);
            labelWidth3=mountingLayout.getMinimumWidth([zLabel,yawLabel]);

            add(mountingLayout,xLabel,1,1,...
            'MinimumWidth',labelWidth1,...
            labelProps{:});
            add(mountingLayout,this.hX,1,2,...
            'Fill','Horizontal');
            add(mountingLayout,yLabel,1,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(mountingLayout,this.hY,1,4,...
            'Fill','Horizontal');
            add(mountingLayout,zLabel,1,5,...
            'MinimumWidth',labelWidth3,labelProps{:});
            add(mountingLayout,this.hZ,1,6,...
            'Fill','Horizontal');
            add(mountingLayout,rollLabel,2,1,...
            'MinimumWidth',labelWidth1,...
            labelProps{:});
            add(mountingLayout,this.hRoll,2,2,...
            'Fill','Horizontal');
            add(mountingLayout,pitchLabel,2,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(mountingLayout,this.hPitch,2,4,...
            'Fill','Horizontal');
            add(mountingLayout,yawLabel,2,5,...
            'MinimumWidth',labelWidth3,labelProps{:});
            add(mountingLayout,this.hYaw,2,6,...
            'Fill','Horizontal');
            mountingLayout.setLayoutHeight;

            this.hSensorMountingPanel=mountingPanel;
            this.SensorMountingLayout=mountingLayout;
        end

    end

    methods(Hidden)
        function defaultEditboxCallback(this,h,~)

            newValue=str2double(h.String);
            oldValue=this.Application.getCurrentSensor.(h.Tag);
            if isequal(newValue,oldValue)
                return
            end

            fail=validateNonNegativeProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNonNegInput',msgString(this,h.Tag));
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return;
            end
            this.Application.setSensorProperty(h.Tag,newValue);
        end

        function defaultScalarRealCallback(this,h,~)

            newValue=str2double(h.String);
            oldValue=this.Application.getCurrentSensor.(h.Tag);
            if isequal(newValue,oldValue)
                return
            end

            fail=validateNumericProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNumericInput',msgString(this,h.Tag));
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return;
            end
            this.Application.setSensorProperty(h.Tag,newValue);
        end

        function detectionProbabilityCallback(this,h,~)
            newValue=str2double(h.String);
            oldValue=this.Application.getCurrentSensor.DetectionProbability;
            if isequal(newValue,oldValue)
                return
            end

            fail=validateProbability(this,newValue);
            if fail
                [str,id]=this.errorString('BadProbabilityInput',msgString(this,'DetectionProbability'));
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return
            end
            this.Application.setSensorProperty(h.Tag,newValue);
        end

        function farCallback(this,h,~)
            newValue=str2double(h.String);
            oldValue=this.Application.getCurrentSensor.FalseAlarmRate;
            if isequal(newValue,oldValue)
                return
            end

            fail=validateFAR(this,newValue);
            if fail
                [str,id]=this.errorString('BadFARInput',msgString(this,'FalseAlarmRate'));
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return
            end
            this.Application.setSensorProperty('FalseAlarmRate',newValue);
        end

        function hasPropertyCallback(this,h,~)
            if startsWith(h.Tag,'Has')
                setSensorProperty(this.Application,h.Tag,logical(h.Value));
            end
        end

        function maxNumDetCallback(this,h,~)

            newValue=str2double(h.String);
            try
                validateattributes(newValue,{'double'},{'nonnegative','scalar','real','nonnan'});
            catch
                [str,id]=errorString(this,'BadInfNumericInput',msgString(this,h.Tag));
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return;
            end
            this.Application.setSensorProperty(h.Tag,newValue);
        end

        function fovCallback(this,~,~)
            fov=getVectorFromWidgets(this,'hFOVAzimuth','hFOVElevation')';
            oldfov=this.Application.getCurrentSensor.FieldOfView;
            if isequal(fov(:),oldfov(:))

                return
            end

            if fov(2)<=0||fov(2)>180
                this.Application.updateSensorPanel;
                msgID='shared_radarfusion:RemoteSensors:invalidElFOV';
                msgStr=getString(message(msgID));
                errorMessage(this,msgStr,msgID);
                return
            end

            try
                fusionRadarSensor('SensorIndex',1,'FieldOfView',fov);
            catch ME
                this.Application.updateSensorPanel;
                errorMessage(this,ME.message,ME.identifier);
                return
            end
            setSensorProperty(this.Application,'FieldOfView',fov);
        end

        function nameCallback(this,h,~)
            newName=h.String;
            setSensorProperty(this.Application,'Name',newName)
        end


        function scanRateCallback(this,h,~)
            property='MaxMechanicalScanRate';
            fail=validateNumericProperty(this,str2double(h.String));
            if fail
                [str,id]=this.errorString('BadNumericInput',property);
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return
            end

            newValue=this.getVectorFromWidgets('hMaxMechanicalScanRateAz','hMaxMechanicalScanRateEl');
            oldValue=this.Application.getCurrentSensor.(property);
            if isequal(oldValue,newValue)
                return
            end

            if endsWith(h.Tag,'Az')
                testProperty='MaxAzimuthScanRate';
                testValue=newValue(1);
            elseif endsWith(h.Tag,'El')
                testProperty='MaxElevationScanRate';
                testValue=newValue(2);
            end

            try
                fusionRadarSensor('SensorIndex',1,'HasElevation',true,testProperty,testValue);
            catch ME
                this.Application.updateSensorPanel;
                errorMessage(this,ME.message,ME.identifier);
                return
            end

            setSensorProperty(this.Application,property,newValue);

        end

        function scanLimitsCallback(this,h,~)
            fail=validateNumericProperty(this,str2double(h.String));
            if startsWith(h.Tag,'MechanicalScan')
                property='MechanicalScanLimits';
                messageHole='Mechanical scan limits';
                newValue=reshape(this.getVectorFromWidgets(...
                'hMechanicalScanMinAz','hMechanicalScanMaxAz','hMechanicalScanMinEl','hMechanicalScanMaxEl'),...
                2,2)';
            else
                property='ElectronicScanLimits';
                messageHole='Electronic scan limits';
                newValue=reshape(this.getVectorFromWidgets(...
                'hElectronicScanMinAz','hElectronicScanMaxAz','hElectronicScanMinEl','hElectronicScanMaxEl'),...
                2,2)';
            end
            oldValue=this.Application.getCurrentSensor.(property);
            scanMode=this.Application.getCurrentSensor.ScanMode;
            if isequal(oldValue,newValue)
                return
            end

            if fail
                [str,id]=this.errorString('BadNumericInput',messageHole);
                this.Application.updateSensorPanel;
                errorMessage(this,str,id);
                return
            end

            if startsWith(h.Tag,'MechanicalScan')&&endsWith(h.Tag,'Az')
                testProperty='MechanicalAzimuthLimits';
                testValue=newValue(1,:);
            elseif startsWith(h.Tag,'MechanicalScan')&&endsWith(h.Tag,'El')
                testProperty='MechanicalElevationLimits';
                testValue=newValue(2,:);
            elseif startsWith(h.Tag,'ElectronicScan')&&endsWith(h.Tag,'Az')
                testProperty='ElectronicAzimuthLimits';
                testValue=newValue(1,:);
            elseif startsWith(h.Tag,'ElectronicScan')&&endsWith(h.Tag,'El')
                testProperty='ElectronicElevationLimits';
                testValue=newValue(2,:);
            end

            if testValue(1)>=testValue(2)
                this.Application.updateSensorPanel;
                msgID='shared_radarfusion:RemoteSensors:limitsNondecreasingOrder';
                msgStr=getString(message(msgID,messageHole));
                errorMessage(this,msgStr,msgID);
                return
            end

            try
                fusionRadarSensor('SensorIndex',1,'HasElevation',true,'ScanMode',scanMode,...
                testProperty,testValue);
            catch ME
                this.Application.updateSensorPanel;
                errorMessage(this,ME.message,ME.identifier);
                return
            end

            setSensorProperty(this.Application,property,newValue);
        end

        function sensorEnabledCallback(this,h,~)
            setSensorProperty(this.Application,'SensorEnabled',h.Value);
        end

        function locationCallback(this,h,~)
            newPosition=this.getVectorFromWidgets('hX','hY','hZ');
            oldPosition=this.Application.getCurrentSensor.MountingLocation;
            if isequal(newPosition,oldPosition)

                return
            end


            newValue=str2double(h.String);
            fail=validateNumericProperty(this,newValue);
            if fail
                [str,id]=this.errorString('BadNumericInput',h.Tag);
                this.Application.updateSensorPanel();
                errorMessage(this,str,id);
                return
            end
            setSensorProperty(this.Application,'MountingLocation',...
            newPosition);
        end

        function orientationCallback(this,h,~)
            newOrient=getVectorFromWidgets(this,'hRoll','hPitch','hYaw');
            oldOrient=this.Application.getCurrentSensor.MountingAngles;
            if isequal(newOrient,oldOrient)

                return
            end
            newValue=str2double(h.String);
            fail=validateNumericProperty(this,newValue);
            if fail
                [str,id]=errorString(this,'BadNumericInput',h.Tag);
                this.Application.updateSensorPanel();
                errorMessage(this,str,id);
                return;
            end
            setSensorProperty(this.Application,'MountingAngles',...
            newOrient);
        end

        function defaultPopupCallback(this,h,~)
            this.Application.setSensorProperty(h.Tag,h.String{h.Value});
        end

        function platformSelectorCallback(this,h,~)
            str=h.String{h.Value};
            this.PlatformSelectedIndex=str2double(str(1));
        end

        function sensorSelectorCallback(this,h,~)
            str=h.String{h.Value};
            this.SensorSelectedIndex=str2double(str(1));
        end

    end


end