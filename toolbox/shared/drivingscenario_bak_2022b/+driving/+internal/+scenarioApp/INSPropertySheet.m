classdef INSPropertySheet<driving.internal.scenarioApp.PropertySheet




    properties
        ShowDetectionParameters=false;
    end

    properties(Hidden)


hRollAccuracy
hPitchAccuracy
hYawAccuracy
hPositionAccuracy
hVelocityAccuracy
hAccelerationAccuracy
hAngularVelocityAccuracy
hHasGNSSFix
hPositionErrorFactor
hRandomStream
hSeed

hShowDetectionParameters
hDetectionParameters

DetectionLayout

    end

    methods
        function this=INSPropertySheet(dlg)
            this@driving.internal.scenarioApp.PropertySheet(dlg)
        end

        function label=getTypeLabel(~)
            label=getString(message('driving:scenarioApp:INSTypeLabel'));
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
                string=getRandomStreamLabels(this);
                index=find(strcmp(sensor.RandomStream,{'Global stream','mt19937ar with seed'}));
            end
            set(this.hRandomStream,'String',string,...
            'Enable',enable,...
            'Value',index);
            set(this.hSeed,'String',sensor.Seed,...
            'Enable',matlabshared.application.logicalToOnOff(index==2));
            simpleProps={'RollAccuracy','PitchAccuracy','YawAccuracy','PositionAccuracy',...
            'VelocityAccuracy','AccelerationAccuracy','AngularVelocityAccuracy','HasGNSSFix',...
            'PositionErrorFactor'};
            set(this.hShowDetectionParameters,'Enable',enable);
            setupWidgets(this,sensor,simpleProps);
        end

        function updateLayout(this)
            layout=this.Layout;
            insertPanel(this,layout,'DetectionParameters',3);
            clean(layout);
        end
    end

    methods(Access=protected)

        function labels=getRandomStreamLabels(~)
            labels={...
            'Global stream',...
            'mt19937ar with seed'};
        end

        function randomStreamCallback(this,hItem,~)
            streams={...
            'Global stream',...
            'mt19937ar with seed'};
            setProperty(this,'RandomStream',streams{hItem.Value});
        end

        function createWidgets(this)
            p=this.Panel;
            this.hShowDetectionParameters=createToggle(this,p,'ShowDetectionParameters');
            layoutInputs={'VerticalGap',3};

            detectionParameters=uipanel(p,...
            'Tag','DetectionParameters',...
            'AutoResizeChildren','off',...
            'Visible','off',...
            'BorderType','none');
            this.hDetectionParameters=detectionParameters;

            rollLabel=createLabelEditPair(this,detectionParameters,'RollAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:RollAccuracyDescription')));
            pitchLabel=createLabelEditPair(this,detectionParameters,'PitchAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:PitchAccuracyDescription')));
            yawLabel=createLabelEditPair(this,detectionParameters,'YawAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:YawAccuracyDescription')));
            posLabel=createLabelEditPair(this,detectionParameters,'PositionAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:PositionAccuracyDescription')));
            velLabel=createLabelEditPair(this,detectionParameters,'VelocityAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:VelocityAccuracyDescription')));
            accelLabel=createLabelEditPair(this,detectionParameters,'AccelerationAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:AccelerationAccuracyDescription')));
            angularLabel=createLabelEditPair(this,detectionParameters,'AngularVelocityAccuracy',...
            'TooltipString',getString(message('driving:scenarioApp:AngularVelocityAccuracyDescription')));
            posErrorLabel=createLabelEditPair(this,detectionParameters,'PositionErrorFactor',...
            'TooltipString',getString(message('driving:scenarioApp:PositionErrorFactorDescription')));

            createCheckbox(this,detectionParameters,'HasGNSSFix',...
            'TooltipString',getString(message('driving:scenarioApp:HasGNSSFixDescription')));

            rsLabel=createLabelEditPair(this,detectionParameters,'RandomStream',@this.randomStreamCallback,'popupmenu',...
            'TooltipString',getString(message('driving:scenarioApp:RandomStreamDescription')));

            seedLabel=createLabelEditPair(this,detectionParameters,'Seed',...
            'TooltipString',getString(message('driving:scenarioApp:SeedDescription')));

            layout=matlabshared.application.layout.GridBagLayout(detectionParameters,...
            layoutInputs{:});
            inset=layout.LabelOffset;
            labelProps={'Anchor','West','TopInset',inset,'MinimumHeight',20-inset};
            this.DetectionLayout=layout;


            labelWidth=layout.getMinimumWidth([rollLabel,pitchLabel,yawLabel...
            ,posLabel,velLabel,accelLabel,angularLabel,posErrorLabel,rsLabel,seedLabel]);

            add(layout,rollLabel,1,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hRollAccuracy,1,2,...
            'Fill','Horizontal');

            add(layout,pitchLabel,2,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hPitchAccuracy,2,2,...
            'Fill','Horizontal');

            add(layout,yawLabel,3,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hYawAccuracy,3,2,...
            'Fill','Horizontal');

            add(layout,posLabel,4,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hPositionAccuracy,4,2,...
            'Fill','Horizontal');

            add(layout,velLabel,5,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hVelocityAccuracy,5,2,...
            'Fill','Horizontal');

            add(layout,accelLabel,6,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hAccelerationAccuracy,6,2,...
            'Fill','Horizontal');

            add(layout,angularLabel,7,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hAngularVelocityAccuracy,7,2,...
            'Fill','Horizontal');

            add(layout,this.hHasGNSSFix,8,1,'Fill','Horizontal');

            add(layout,posErrorLabel,9,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hPositionErrorFactor,9,2,...
            'Fill','Horizontal');

            add(layout,rsLabel,10,1,labelProps{:},'MinimumWidth',labelWidth);
            add(layout,this.hRandomStream,10,2,'MinimumWidth',labelWidth,'Fill','Horizontal');

            add(layout,seedLabel,11,1,...
            'MinimumWidth',labelWidth,labelProps{:});
            add(layout,this.hSeed,11,2,...
            'Fill','Horizontal');

            setLayoutHeight(layout);

            layout=matlabshared.application.layout.GridBagLayout(p,...
            layoutInputs{:},'VerticalWeights',[0,1,1]);
            layout.add(this.hShowDetectionParameters,2,1,...
            'Fill','Horizontal');
            this.Layout=layout;

        end
    end
end


