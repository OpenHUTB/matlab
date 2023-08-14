classdef(ConstructOnLoad)SensorSpecification<driving.internal.scenarioApp.Specification




    properties
        Enabled=true;
        CoverageFaceAlpha=0.1;
        CoverageFaceColor;
        CoverageEdgeColor;
        DetectionMarker='o';
        DetectionMarkerSize=6;
        DetectionMarkerEdgeColor;
        DetectionMarkerFaceColor='none';
        DetectionFontSize=10;
        DetectionLabelOffset=[0,0];
        DetectionVelocityScaling=0.5;
UpdateInterval
SensorLocation
Height
Yaw
Pitch
Roll
FieldOfView
MaxRange
DetectionProbability
MaxNumDetectionsSource
MaxNumDetections
HasNoise
DetectionCoordinates
    end

    properties(SetAccess=protected,Hidden,Transient)
Type
Sensor
    end

    methods

        function this=SensorSpecification(varargin)
            w=warning('off','MATLAB:system:nonRelevantProperty');
            c=onCleanup(@()warning(w));
            if nargin>0&&~ischar(varargin{1})



                this.Sensor=clone(varargin{1});
                varargin(1)=[];
            else
                getSensor(this);
                setDefaultValues(this);
            end

            color=getDefaultColor(this);
            varargin=[{'CoverageFaceColor',color,...
            'CoverageEdgeColor',color,...
            'DetectionMarkerFaceColor',color,...
            'DetectionMarkerEdgeColor',color},varargin];

            for indx=1:2:numel(varargin)
                this.(varargin{indx})=varargin{indx+1};
            end
        end

        function convertAxesOrientation(this,old,new)
            if strcmpi(old,'ned')&&strcmpi(new,'enu')||strcmpi(old,'enu')&&strcmpi(new,'ned')
                release(getSensor(this));
                if this.SensorLocation(2)~=0
                    this.SensorLocation(2)=this.SensorLocation(2)*-1;
                end
                if this.Yaw~=0
                    this.Yaw=-this.Yaw;
                end
            end
        end

        function str=generateMatlabCode(this,index,profileVariableName)

            str="";



            if~this.Enabled
                return;
            end

            currentSensor=this.Sensor;

            sensorName=class(currentSensor);

            str=sensorName+"(";



            if this.hasSensorIndex
                pvPairs=[{'SensorIndex',mat2str(index)},getPVPairsForMatlabCode(this,getDefaultSensor(this))];
            else
                pvPairs=getPVPairsForMatlabCode(this,getDefaultSensor(this));
            end
            if nargin>2
                if this.hasActorProfiles
                    pvPairs=[pvPairs,{getProfilesPropertyName(this),profileVariableName}];
                end
            end

            for indx=1:2:numel(pvPairs)
                str=str+"'"+pvPairs{indx}+"'"+", "+pvPairs{indx+1};
                if indx<numel(pvPairs)-1
                    str=str+', ...'+newline+"    ";
                end
            end

            str=str+");";
        end

        function set.UpdateInterval(this,interval)

            interval=interval/1000;
            setSensorUpdateInterval(this,interval)
            this.UpdateInterval=interval;
        end

        function interval=get.UpdateInterval(this)
            interval=getSensorUpdateInterval(this)*1000;
        end

        function set.SensorLocation(this,location)
            setSensorSensorLocation(this,location);
            this.SensorLocation=location;
        end

        function location=get.SensorLocation(this)
            location=getSensorSensorLocation(this);
        end

        function set.Height(this,height)
            setSensorHeight(this,height);
            this.Height=height;
        end

        function height=get.Height(this)
            height=getSensorHeight(this);
        end

        function set.Yaw(this,yaw)
            yaw=driving.scenario.internal.fixAngle(yaw);
            setSensorYaw(this,yaw);
            this.Yaw=yaw;
        end

        function yaw=get.Yaw(this)
            yaw=getSensorYaw(this);
        end

        function set.Pitch(this,pitch)
            pitch=driving.scenario.internal.fixAngle(pitch);
            setSensorPitch(this,pitch);
            this.Pitch=pitch;
        end

        function pitch=get.Pitch(this)
            pitch=getSensorPitch(this);
        end

        function set.Roll(this,roll)
            roll=driving.scenario.internal.fixAngle(roll);
            setSensorRoll(this,roll);
            this.Roll=roll;
        end

        function roll=get.Roll(this)
            roll=getSensorRoll(this);
        end

        function set.MaxRange(this,maxRange)
            setSensorMaxRange(this,maxRange);
            this.MaxRange=maxRange;
        end

        function maxRange=get.MaxRange(this)
            maxRange=getSensorMaxRange(this);
        end

        function set.DetectionProbability(this,detectionProbability)
            s=getSensor(this);
            s.DetectionProbability=detectionProbability;
            this.DetectionProbability=detectionProbability;
        end

        function detectionProbability=get.DetectionProbability(this)
            detectionProbability=this.Sensor.DetectionProbability;
        end

        function set.FieldOfView(this,fov)
            s=getSensor(this);
            if isa(s,'lidarPointCloudGenerator')
                this.AzimuthLimits=[-fov/2,fov/2];
            else
                setFieldOfView(this,fov);
                this.FieldOfView=fov;
            end
        end

        function fov=get.FieldOfView(this)
            s=getSensor(this);
            if isa(s,'lidarPointCloudGenerator')
                fov=diff(s.AzimuthLimits);
            elseif isa(s,'insSensor')
                fov=360;
            else
                fov=s.FieldOfView;
            end
        end

        function set.MaxNumDetectionsSource(this,source)
            setSensorMaxNumDetectionsSource(this,source);
            this.MaxNumDetectionsSource=source;
        end
        function source=get.MaxNumDetectionsSource(this)
            source=getSensorMaxNumDetectionsSource(this);
        end

        function set.MaxNumDetections(this,num)
            setSensorMaxNumDetections(this,num);
            this.MaxNumDetections=num;
        end
        function num=get.MaxNumDetections(this)
            num=getSensorMaxNumDetections(this);
        end

        function set.HasNoise(this,noise)
            s=getSensor(this);
            s.HasNoise=noise;
            this.HasNoise=noise;
        end
        function noise=get.HasNoise(this)
            noise=this.Sensor.HasNoise;
        end

        function set.DetectionCoordinates(this,coords)
            this.DetectionCoordinates=setSensorDetectionCoordinates(this,coords);
        end
        function coords=get.DetectionCoordinates(this)
            s=getSensor(this);
            if isa(s,'ultrasonicDetectionGenerator')
                coords='Body';
            else
                coords=s.DetectionCoordinates;
            end
        end

        function[pvPairs,specPairs]=getPVPairs(this,defaultSensor)
            if nargin<2
                defaultSensor=getDefaultSensor(this);
            end
            propsToCheck=getExposedProperties(this);
            currentSensor=this.Sensor;
            pvPairs={};

            for indx=1:numel(propsToCheck)
                prop=propsToCheck{indx};
                if~isequal(currentSensor.(prop),defaultSensor.(prop))
                    pvPairs=[pvPairs,{prop,currentSensor.(prop)}];%#ok<AGROW>
                end
            end
            specPairs={};
        end

        function pvPairs=getPVPairsForSimulinkBlock(this,actorProfilesExpression)
            sensorParams=getSensorBlockParameterNames(this);
            pvPairs=cell(1,2*length(sensorParams)+2);
            setParamPInd=1:2:2*length(sensorParams);
            setParamVInd=setParamPInd+1;
            for jnd=1:length(sensorParams)
                switch sensorParams{jnd}
                case{'ActorProfilesExpression','Profiles','ProfilesExpression'}
                    if strcmp(actorProfilesExpression,'[]')
                        continue
                    end
                    setParamV=actorProfilesExpression;
                case 'ActorProfilesSource'




                    setParamV='From Scenario Reader block';
                case{'SimulateUsing','ActorProfilesParameters','ProfilesParameters'}
                    continue;
                case 'UseAccelAndAngVel'
                    setParamV='on';
                case 'SeedDouble'
                    setParamV=num2str(this.Sensor.Seed);
                otherwise
                    setParamV=getSpecificSimulinkBlockPV(this,sensorParams{jnd});
                    if isempty(setParamV)
                        setParamV=this.Sensor.(sensorParams{jnd});
                        if strcmp(setParamV,'Auto')||isempty(setParamV)
                            continue
                        elseif isnumeric(setParamV)
                            setParamV=mat2str(setParamV);
                        elseif islogical(setParamV)
                            setParamV=char(matlab.lang.OnOffSwitchState(setParamV));
                        end
                    end
                end
                pvPairs{setParamPInd(jnd)}=sensorParams{jnd};
                pvPairs{setParamVInd(jnd)}=setParamV;
            end
            pvPairs=pvPairs(~cellfun('isempty',pvPairs));
        end

        function[pvPairs,warnings]=getPVPairsForSimulation3DBlock(this,sim3DSensorParams)

            warnings={};
            pvPairs=cell(1,2*length(sim3DSensorParams)+2);
            setParamPInd=1:2:2*length(sim3DSensorParams);
            setParamVInd=setParamPInd+1;
            sensor=this.Sensor;
            for jnd=1:length(sim3DSensorParams)
                prop=sim3DSensorParams{jnd};
                prop(1)=upper(prop(1));
                switch prop

                case 'DetectionRange'
                    if isnan(str2double(get_param(getSimulation3DBlockName(this),'DetectionRange')))
                        setParamV=sprintf('[1 %s]',string(this.MaxRange));
                    else
                        setParamV=string(sensor.MaxRange);
                    end


                case 'OpticalCenter'
                    setParamV=mat2str(sensor.Intrinsics.PrincipalPoint);
                case{'FocalLength','ImageSize'}
                    setParamV=mat2str(sensor.Intrinsics.(prop));
                case 'RangeResolution'
                    try
                        setParamV=mat2str(sensor.RangeResolution);
                    catch ME %#ok<NASGU>
                        setParamV=mat2str(sensor.RangeAccuracy);
                    end
                case 'VerticalFOV'
                    setParamV=mat2str(diff(sensor.ElevationLimits));
                case 'HorizontalFOV'
                    setParamV=mat2str(diff(sensor.AzimuthLimits));
                case 'VerticalResolution'
                    setParamV=mat2str(sensor.ElevationResolution);
                case 'HorizontalResolution'
                    setParamV=mat2str(sensor.AzimuthResolution);
                case 'SensorId'
                    setParamV=mat2str(sensor.SensorIndex);
                case 'DetectionCoordinates'
                    setParamV=this.DetectionCoordinates;
                    if strcmp(setParamV,'Sensor rectangular')
                        setParamV='Sensor Cartesian';
                    elseif strcmp(setParamV,'Body')
                        setParamV='Ego Cartesian';
                    end
                otherwise
                    try
                        setParamV=sensor.(prop);
                    catch ME %#ok<NASGU>
                        continue;
                    end
                    if strcmp(setParamV,'Auto')||isempty(setParamV)
                        continue
                    elseif isnumeric(setParamV)
                        setParamV=mat2str(setParamV);
                    elseif islogical(setParamV)
                        setParamV=char(matlab.lang.OnOffSwitchState(setParamV));
                    end
                end
                pvPairs{setParamPInd(jnd)}=prop;
                pvPairs{setParamVInd(jnd)}=setParamV;
            end
            pvPairs=pvPairs(~cellfun('isempty',pvPairs));
        end

        function b=hasUpdateInterval(~)
            b=true;
        end

        function b=hasOrientation(~)
            b=true;
        end

    end

    methods(Access=protected)

        function setDefaultValues(~)

        end

        function coords=setSensorDetectionCoordinates(this,coords)
            s=getSensor(this);
            s.DetectionCoordinates=coords;
        end

        function setSensorSensorLocation(this,location)
            s=getSensor(this);
            s.SensorLocation=location;
        end

        function location=getSensorSensorLocation(this)
            s=getSensor(this);
            location=s.SensorLocation;
        end

        function setSensorHeight(this,height)
            s=getSensor(this);
            s.Height=height;
        end

        function height=getSensorHeight(this)
            s=getSensor(this);
            height=s.Height;
        end

        function setSensorYaw(this,yaw)
            s=getSensor(this);
            s.Yaw=yaw;
        end

        function yaw=getSensorYaw(this)
            s=getSensor(this);
            yaw=s.Yaw;
        end

        function setSensorPitch(this,pitch)
            s=getSensor(this);
            s.Pitch=pitch;
        end

        function pitch=getSensorPitch(this)
            s=getSensor(this);
            pitch=s.Pitch;
        end

        function setSensorRoll(this,roll)
            s=getSensor(this);
            s.Roll=roll;
        end

        function roll=getSensorRoll(this)
            s=getSensor(this);
            roll=s.Roll;
        end

        function setSensorMaxRange(this,maxRange)
            s=getSensor(this);
            s.MaxRange=maxRange;
        end

        function maxRange=getSensorMaxRange(this)
            s=getSensor(this);
            maxRange=s.MaxRange;
        end

        function setSensorMaxNumDetectionsSource(this,source)
            s=getSensor(this);
            if isObjectDetections(this)
                s.MaxNumDetectionsSource=source;
                if strcmp(source,'property')
                    s.MaxNumDetections=this.MaxNumDetections;
                end
            end
        end

        function source=getSensorMaxNumDetectionsSource(this)
            s=getSensor(this);
            source=s.MaxNumDetectionsSource;
        end

        function setSensorMaxNumDetections(this,num)
            s=getSensor(this);
            if hasMaxNumDetections(this)&&strcmpi(this.MaxNumDetectionsSource,'property')
                s.MaxNumDetections=num;
            end
        end

        function num=getSensorMaxNumDetections(this)
            s=getSensor(this);
            num=s.MaxNumDetections;
        end

        function setSensorUpdateInterval(this,interval)
            s=getSensor(this);
            s.UpdateInterval=interval;
        end

        function interval=getSensorUpdateInterval(this)
            s=getSensor(this);
            interval=s.UpdateInterval;
        end

        function name=getProfilesPropertyName(~)
            name='ActorProfiles';
        end

        function newObject=copyElement(this)
            newObject=copyElement@matlab.mixin.Copyable(this);
            newSensor=getDefaultSensor(this);
            newObject.Sensor=newSensor;
            [pvPairs,specPairs]=getPVPairs(this,newSensor);
            for indx=1:2:numel(pvPairs)
                newObject.Sensor.(pvPairs{indx})=pvPairs{indx+1};
            end
            for indx=1:2:numel(specPairs)
                newObject.(specPairs{indx})=specPairs{indx+1};
            end
        end

        function color=getDefaultColor(~)
            color=[0,0,0];
        end

        function setFieldOfView(this,fov)
            if isscalar(fov)
                fov(2)=this.Sensor.FieldOfView(2);
            end
            this.Sensor.FieldOfView=fov;
        end

        function pvPairs=getPVPairsForMatlabCode(this,varargin)

            [pvPairs,specPairs]=getPVPairs(this,varargin{:});

            pvPairs=[pvPairs,specPairs];

            for indx=2:2:numel(pvPairs)
                pvPairs{indx}=mat2str(pvPairs{indx});
            end

        end

        function props=getExposedProperties(this)
            props={'UpdateInterval',...
            'SensorLocation',...
            'Height',...
            'Yaw',...
            'Pitch',...
            'Roll',...
            'MaxRange',...
            'HasNoise'};

            if hasDetectionProbability(this)
                props=[props,{'DetectionProbability'}];
            end

            if hasMaxNumDetections(this)
                props=[props,{'MaxNumDetectionsSource'}];
                if strcmp(this.MaxNumDetectionsSource,'Property')
                    props=[props,{'MaxNumDetections'}];
                end
            end
            props=[props,{'DetectionCoordinates'}];
        end
        function b=hasMaxNumDetections(~)
            b=true;
        end

        function b=isObjectDetections(~)
            b=true;
        end

        function b=hasDetectionProbability(~)
            b=true;
        end

        function names=getSensorBlockParameterNames(this)
            names=fieldnames(get_param(getDefaultSimulinkBlockName(this),'DialogParameters'));
        end

        function b=hasSensorIndex(~)
            b=true;
        end

        function b=hasActorProfiles(~)
            b=true;
        end

    end

    methods(Static)
        function s=fromDetectionGenerators(generators)
            s=driving.internal.scenarioApp.SensorSpecification.empty;
            cameraCount=0;
            radarCount=0;
            lidarCount=0;
            insCount=0;
            ultrasonicCount=0;
            for indx=1:numel(generators)
                if isa(generators{indx},'visionDetectionGenerator')
                    cameraCount=cameraCount+1;
                    if cameraCount>1
                        mod=sprintf('%d',cameraCount-1);
                    else
                        mod='';
                    end
                    s(indx)=driving.internal.scenarioApp.VisionSensorSpecification(generators{indx},...
                    'Name',sprintf('%s%s',getString(message('driving:scenarioApp:DefaultVisionName')),mod));
                elseif isa(generators{indx},'radarDetectionGenerator')||isa(generators{indx},'drivingRadarDataGenerator')
                    radarCount=radarCount+1;
                    if radarCount>1
                        mod=sprintf('%d',radarCount-1);
                    else
                        mod='';
                    end
                    s(indx)=driving.internal.scenarioApp.RadarSensorSpecification(generators{indx},...
                    'Name',sprintf('%s%s',getString(message('driving:scenarioApp:DefaultRadarName')),mod));
                elseif isa(generators{indx},'lidarPointCloudGenerator')
                    lidarCount=lidarCount+1;
                    if lidarCount>1
                        mod=sprintf('%d',lidarCount-1);
                    else
                        mod='';
                    end
                    s(indx)=driving.internal.scenarioApp.LidarSensorSpecification(generators{indx},...
                    'Name',sprintf('%s%s',getString(message('driving:scenarioApp:DefaultLidarName')),mod));
                elseif isa(generators{indx},'insSensor')
                    generators{indx}.TimeInput=true;
                    insCount=insCount+1;
                    if insCount>1
                        mod=sprintf('%d',insCount-1);
                    else
                        mod='';
                    end
                    s(indx)=driving.internal.scenarioApp.INSSensorSpecification(generators{indx},...
                    'Name',sprintf('%s%s',getString(message('driving:scenarioApp:DefaultINSName')),mod));
                elseif isa(generators{indx},'ultrasonicDetectionGenerator')
                    ultrasonicCount=ultrasonicCount+1;
                    if ultrasonicCount>1
                        mod=sprintf('%d',ultrasonicCount-1);
                    else
                        mod='';
                    end
                    s(indx)=driving.internal.scenarioApp.UltrasonicSensorSpecification(generators{indx},...
                    'Name',sprintf('%s%s',getString(message('driving:scenarioApp:DefaultUltrasonicName')),mod));
                end
            end
        end

        function[intervals,changed]=fixUpdateIntervals(intervals,sampleTime)
            ratios=intervals/sampleTime;
            if any(abs(round(ratios)-ratios)>0.001)
                ratios(ratios<1)=1;
                ratios=round(ratios);
                intervals=ratios*sampleTime;
                changed=true;
            else
                changed=false;
            end
        end
    end

    methods(Hidden)

        function fixBackwardsCompatibility(~)

        end

        function s=getSensor(this)
            s=this.Sensor;
            if isempty(s)

                try
                    sensor=getDefaultSensor(this);
                catch ME %#ok<NASGU>
                    sensor=struct;
                end
                this.Sensor=sensor;
            end
        end

        function block=getSimulation3DBlockName(~)
            block='';
        end
    end

    methods(Access=protected,Abstract)
        sensor=getDefaultSensor(this)
        value=getSpecificSimulinkBlockPV(this,parameter)
    end

    methods(Abstract,Hidden)
        block=getDefaultSimulinkBlockName(this)
    end
end


