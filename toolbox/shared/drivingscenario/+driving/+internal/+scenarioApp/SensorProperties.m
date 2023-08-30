classdef SensorProperties<driving.internal.scenarioApp.Properties&driving.internal.scenarioApp.HasPropertySheets

    properties
        ShowSensorPlacement=false;
    end


    properties(Hidden)
hName
hEnabled
hUpdateInterval
hType

hShowSensorPlacement
hSensorPlacement
hSensorLocationX
hSensorLocationY
hHeight
hYaw
hPitch
hRoll
    end

    properties(SetAccess=protected,Hidden)
PlacementLayout
    end


    methods
        function this=SensorProperties(varargin)
            this@driving.internal.scenarioApp.Properties(varargin{:});
            update(this);
        end


        function name=getName(~)
            name=getString(message('driving:scenarioApp:SensorPropertiesTitle'));
        end


        function tag=getTag(~)
            tag='Sensors';
        end


        function update(this)
            clearAllMessages(this);

            designer=this.Application;
            allSensors=designer.SensorSpecifications;

            if isempty(allSensors)
                sensor=[];

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
                set(this.hType,'String',getString(message('driving:scenarioApp:TypeLabel')));
            else
                sensor=allSensors(this.SpecificationIndex);
                allNames=cell(numel(allSensors),1);
                for indx=1:numel(allSensors)
                    name=allSensors(indx).Name;
                    if isempty(name)
                        allNames{indx}=sprintf('%d',indx);
                    else
                        allNames{indx}=sprintf('%d: %s',indx,name);
                    end
                end

                if this.Enabled
                    enable='on';
                else
                    enable='off';
                end
                set(this.hSpecificationIndex,...
                'String',allNames,...
                'Value',this.SpecificationIndex,...
                'Enable','on');
                simpleProps={'Name','Enabled','UpdateInterval',...
                'Height','Roll','Pitch','Yaw'};
                xyProps={'SensorLocation'};
                setupWidgets(this,sensor,simpleProps)
                setupWidgets(this,sensor,xyProps,{'X','Y'});
                set([this.hName,this.hDelete,this.hShowSensorPlacement],'Enable',enable);
                set(this.hUpdateInterval,'Enable',matlabshared.application.logicalToOnOff(this.Enabled&&sensor.hasUpdateInterval));
                if~sensor.hasUpdateInterval
                    set(this.hUpdateInterval,'String','');
                end
                orientationWidgets=[this.hRoll,this.hYaw,this.hPitch];
                set(orientationWidgets,'Enable',matlabshared.application.logicalToOnOff(this.Enabled&&sensor.hasOrientation));
                if~sensor.hasOrientation
                    set(orientationWidgets,'String','');
                end
            end
            update@driving.internal.scenarioApp.HasPropertySheets(this,sensor);
            set(this.hType,'String',getTypeLabel(this.CurrentPropertySheet));
            update(this.Layout,'force');
        end
    end


    methods(Hidden)

        function row=getFirstLabelRow(~)
            row=[];
        end


        function spec=getCurrentSpecification(this)
            allSpecs=this.Application.SensorSpecifications;
            index=this.SpecificationIndex;
            if numel(allSpecs)<index
                spec=[];
            else
                spec=allSpecs(index);
            end
        end


        function row=getPropertySheetRow(this)
            if this.ShowSensorPlacement
                row=7;
            else
                row=6;
            end
        end


        function c=getDefaultPropertySheet(~)
            c='driving.internal.scenarioApp.VisionPropertySheet';
        end


        function onKeyPress(this,~,ev)
            if strcmp(ev.Key,'delete')
                deleteCallback(this);
            end
        end


        function updateLayout(this)
            layout=this.Layout;

            nextRow=6;
            nextRow=insertPanel(this,layout,'SensorPlacement',nextRow);
            layout.VerticalWeights=[zeros(1,nextRow),1];

            clean(layout);
        end


        function edit=createEdit(this,varargin)
            hApp=this.Application;
            hSpec=hApp.SensorSpecifications(this.SpecificationIndex);
            edit=driving.internal.scenarioApp.undoredo.SetSensorProperty(...
            hApp,hSpec,varargin{:});
        end
    end


    methods(Access=protected)

        function event=getIndexEventName(~)
            event='CurrentSensorChanged';
        end


        function fig=createFigure(this,varargin)
            fig=createFigure@driving.internal.scenarioApp.Properties(this,varargin{:});
            icons=getIcon(this.Application);
            createEditbox(this,fig,'SpecificationIndex',[],'popupmenu');
            createCheckbox(this,fig,'Enabled',...
            'TooltipString',getString(message('driving:scenarioApp:SensorEnabledDescription')));
            nameLabel=createLabelEditPair(this,fig,'Name',@this.nameCallback);
            updateLabel=createLabelEditPair(this,fig,'UpdateInterval',...
            'TooltipString',getString(message('driving:scenarioApp:UpdateIntervalDescription')));
            this.hType=createLabel(this,fig,'Type');
            createToggle(this,fig,'ShowSensorPlacement');
            sensorPlacement=uipanel(fig,'Tag','SensorPlacement',...
            'Units','pixels','BorderType','none','AutoResizeChildren','off');
            this.hSensorPlacement=sensorPlacement;
            xLabel=createLabelEditPair(this,sensorPlacement,'SensorLocationX',@this.locationCallback);
            yLabel=createLabelEditPair(this,sensorPlacement,'SensorLocationY',@this.locationCallback);
            zLabel=createLabelEditPair(this,sensorPlacement,'Height');
            rollLabel=createLabelEditPair(this,sensorPlacement,'Roll');
            pitchLabel=createLabelEditPair(this,sensorPlacement,'Pitch');
            yawLabel=createLabelEditPair(this,sensorPlacement,'Yaw');

            layoutInputs={'VerticalGap',3,'HorizontalGap',3};
            layout=matlabshared.application.layout.GridBagLayout(sensorPlacement,...
            layoutInputs{:},'HorizontalWeights',[0,1,0,1,0,1]);
            this.PlacementLayout=layout;

            leftInset=5;

            inset=layout.LabelOffset;
            labelProps={'Anchor','West','TopInset',inset,'MinimumHeight',20-inset};
            labelWidth1=layout.getMinimumWidth([xLabel,rollLabel]);
            labelWidth2=layout.getMinimumWidth([yLabel,pitchLabel]);
            labelWidth3=layout.getMinimumWidth([zLabel,yawLabel]);

            add(layout,xLabel,1,1,...
            'MinimumWidth',labelWidth1,...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hSensorLocationX,1,2,...
            'Fill','Horizontal');
            add(layout,yLabel,1,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(layout,this.hSensorLocationY,1,4,...
            'Fill','Horizontal');
            add(layout,zLabel,1,5,...
            'MinimumWidth',labelWidth3,labelProps{:});
            add(layout,this.hHeight,1,6,...
            'Fill','Horizontal');
            add(layout,rollLabel,2,1,...
            'MinimumWidth',labelWidth1,...
            'LeftInset',leftInset,labelProps{:});
            add(layout,this.hRoll,2,2,...
            'Fill','Horizontal');
            add(layout,pitchLabel,2,3,...
            'MinimumWidth',labelWidth2,labelProps{:});
            add(layout,this.hPitch,2,4,...
            'Fill','Horizontal');
            add(layout,yawLabel,2,5,...
            'MinimumWidth',labelWidth3,labelProps{:});
            add(layout,this.hYaw,2,6,...
            'Fill','Horizontal');
            layout.setLayoutHeight;
            createPushButton(this,fig,'Delete',@this.deleteCallback,...
            'Interruptible','off',...
            'BusyAction','cancel',...
            'TooltipString',getString(message('driving:scenarioApp:DeleteSensorDescription')),...
            'CData',icons.delete16);
            layout=matlabshared.application.layout.ScrollableGridBagLayout(fig,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,1],...
            'VerticalWeights',[0,0,0,0,0,0,1]);
            this.Layout=layout;
            labelWidth=layout.getMinimumWidth([nameLabel,updateLabel]);
            add(layout,this.hSpecificationIndex,1,[1,2],...
            'Fill','Horizontal');
            add(layout,this.hEnabled,1,3,...
            'MinimumWidth',layout.getMinimumWidth(this.hEnabled)+20);
            add(layout,nameLabel,2,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hName,2,2,...
            'Fill','Horizontal');
            add(layout,updateLabel,3,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hUpdateInterval,3,2,...
            'Fill','Horizontal');
            add(layout,this.hType,4,1,...
            labelProps{:},...
            'Fill','Horizontal');
            add(layout,this.hShowSensorPlacement,5,[1,3],...
            'Anchor','West',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowSensorPlacement)+20);
            layout.setConstraints(sensorPlacement,...
            'Fill','Both',...
            'TopInset',-3);

            add(layout,this.hDelete,7,3,...
            'Anchor','SouthEast');

            update(layout,'force');
        end


        function currentSensorCallback(this,hList,~)
            this.SpecificationIndex=hList.Value;
            update(this);omfg
        end


        function locationCallback(this,~,~)
            setVectorProperty(this,'SensorLocation','hSensorLocationX','hSensorLocationY');
        end


        function nameCallback(this,hName,~)
            newName=hName.String;
            if isempty(newName)
                update(this);
                id='driving:scenarioApp:InvalidName';
                errorMessage(this,getString(message(id)),id);
                return;
            end
            setProperty(this,'Name',newName);
        end


        function deleteCallback(this,~,~)
            hApp=this.Application;
            if this.SpecificationIndex>numel(hApp.SensorSpecifications)
                return;
            end
            anyINS=any(string({hApp.SensorSpecifications.Type})=='ins');
            edit=driving.internal.scenarioApp.undoredo.DeleteSensor(hApp,this.SpecificationIndex);
            applyEdit(hApp,edit);
            this.SpecificationIndex=1;
            update(this);
            if anyINS
                update(hApp.ActorProperties);
            end
            setDirty(hApp);
        end


        function updateScenario(this)
            updateForSensors(this.Application);
        end
        function[id,str]=validateDoubleProperty(this,name,value)
            try
                switch name
                case 'UpdateInterval'
                    sampleTime=this.Application.SampleTime*1000;
                    ratio=value/sampleTime;
                    if abs(round(ratio)-ratio)>.001
                        id='driving:scenarioApp:InvalidUpdateInterval';
                        str=getString(message(id,sampleTime));
                        return;
                    end
                case{'FocalLength','PrincipalPoint','ImageSize'}
                    eval(['cameraIntrinsics.check',name,'(value)']);
                case{'SensorLocation','Height','Roll','Pitch','Yaw'...
                    ,'DetectionProbability'...
                    ,'MinObjectImageSize','MaxAllowedOcclusion','MaxSpeed'...
                    ,'BoundingBoxAccuracy','ProcessNoiseIntensity'}
                    if name=="Height"&&this.Application.SensorSpecifications(this.SpecificationIndex).Type=="ins"
                        validateattributes(value,{'double','single'},{'real','finite'},'','Height');
                    else
                        eval(['visionDetectionGenerator.check',name,'(value)']);
                    end
                case{'ReferenceRange','ReferenceRCS','FalseAlarmRate'...
                    ,'MaxRange','FieldOfView'...
                    ,'RangeResolution','RangeBiasFraction'...
                    ,'AzimuthResolution','AzimuthBiasFraction'...
                    ,'ElevationResolution','ElevationBiasFraction'...
                    ,'RangeRateResolution','RangeRateBiasFraction'...
                    }
                    eval(['radarDetectionGenerator.check',name,'(value)']);
                    sspec=this.Application.SensorSpecifications(this.SpecificationIndex);
                    if sspec.Type=="ultrasonic"
                        if name=="MaxRange"
                            x=[sspec.MinDetectionOnlyRange,sspec.MinRange,value];
                            validateattributes(x(1),{'numeric'},{'scalar','positive'},'','MinDetectionOnlyRange');
                            validateattributes(x(2),{'numeric'},{'scalar','>',x(1)},'','MinRange');
                            validateattributes(x(3),{'numeric'},{'scalar','>',x(2)},'','MaxRange');
                        end
                    end
                case{'MinRange','MinDetectionOnlyRange'}
                    validateattributes(value,{'double','single'},{'real','finite','positive'},'',name);

                    sspec=this.Application.SensorSpecifications(this.SpecificationIndex);
                    if sspec.Type=="ultrasonic"
                        x=[0,0,sspec.MaxRange];
                        if name=="MinRange"
                            x(1)=sspec.MinDetectionOnlyRange;
                            x(2)=value;
                        else
                            x(1)=value;
                            x(2)=sspec.MinRange;
                        end
                        validateattributes(x(1),{'numeric'},{'scalar','positive'},'','MinDetectionOnlyRange');
                        validateattributes(x(2),{'numeric'},{'scalar','>',x(1)},'','MinRange');
                        validateattributes(x(3),{'numeric'},{'scalar','>',x(2)},'','MaxRange');
                    end
                end
            catch ME
                id=ME.identifier;
                str=ME.message;
                return;
            end
            id='';
            str='';
        end
    end
end


