classdef(ConstructOnLoad)VisionSensorSpecification<driving.internal.scenarioApp.SensorSpecification
    properties



        DetectionType='objects';
    end
    properties
LaneUpdateInterval
MinLaneImageSize
LaneBoundaryAccuracy
MaxNumLanesSource
MaxNumLanes
MaxSpeed
MaxAllowedOcclusion
MinObjectImageSize
FalsePositivesPerImage
BoundingBoxAccuracy
ProcessNoiseIntensity


FocalLength
PrincipalPoint
ImageSize



    end

    methods
        function this=VisionSensorSpecification(varargin)


            this@driving.internal.scenarioApp.SensorSpecification(varargin{:});
            this.Type='vision';
        end

        function configureForFirstStep(this,sensorIndex,actorProfs,~)
            sensor=getSensor(this);
            release(sensor);
            sensor.SensorIndex=sensorIndex;
            sensor.ActorProfiles=actorProfs;
        end

        function set.DetectionType(this,dType)
            s=getSensor(this);
            if strcmp(dType,'lanes&objects')
                dType='Lanes and objects';
            elseif strcmp(dType,'lanes')
                dType='Lanes only';
            elseif strcmp(dType,'objects')
                dType='Objects only';
            end
            s.DetectorOutput=dType;
        end
        function dType=get.DetectionType(this)
            s=getSensor(this);
            dType=s.DetectorOutput;
            if strcmp(dType,'Lanes and objects')
                dType='lanes&objects';
            elseif any(strcmp(dType,{'Lanes only','Lanes with occlusion'}))
                dType='lanes';
            elseif strcmp(dType,'Objects only')
                dType='objects';
            end
        end

        function set.MinLaneImageSize(this,imageSize)
            s=getSensor(this);
            s.MinLaneImageSize=imageSize;
            this.MinLaneImageSize=imageSize;
        end
        function imageSize=get.MinLaneImageSize(this)
            s=getSensor(this);
            imageSize=s.MinLaneImageSize;
        end

        function set.LaneUpdateInterval(this,interval)
            interval=interval/1000;
            s=getSensor(this);
            s.LaneUpdateInterval=interval;
            this.LaneUpdateInterval=interval;
        end
        function interval=get.LaneUpdateInterval(this)
            s=getSensor(this);
            interval=s.LaneUpdateInterval*1000;
        end

        function set.LaneBoundaryAccuracy(this,accuracy)
            s=getSensor(this);
            s.LaneBoundaryAccuracy=accuracy;
            this.LaneBoundaryAccuracy=accuracy;
        end
        function accuracy=get.LaneBoundaryAccuracy(this)
            s=getSensor(this);
            accuracy=s.LaneBoundaryAccuracy;
        end

        function set.MaxNumLanesSource(this,source)
            obj=getSensor(this);
            if any(strcmp(obj.DetectorOutput,{'Lanes only','Lanes with occlusion','Lanes and objects'}))
                obj.MaxNumLanesSource=source;
            end
            this.MaxNumLanesSource=source;
        end
        function source=get.MaxNumLanesSource(this)
            s=getSensor(this);
            source=s.MaxNumLanesSource;
        end

        function set.MaxNumLanes(this,maxLanes)
            obj=getSensor(this);
            if any(strcmp(obj.DetectorOutput,{'Lanes only','Lanes with occlusion','Lanes and objects'}))&&strcmp(obj.MaxNumLanesSource,'Property')
                obj.MaxNumLanes=maxLanes;
            end
            this.MaxNumLanes=maxLanes;
        end
        function maxLanes=get.MaxNumLanes(this)
            s=getSensor(this);
            maxLanes=s.MaxNumLanes;
        end

        function set.MaxSpeed(this,maxSpeed)
            s=getSensor(this);
            s.MaxSpeed=maxSpeed;
            this.MaxSpeed=maxSpeed;
        end

        function maxSpeed=get.MaxSpeed(this)
            s=getSensor(this);
            maxSpeed=s.MaxSpeed;
        end

        function set.MaxAllowedOcclusion(this,maxSpeed)
            s=getSensor(this);
            s.MaxAllowedOcclusion=maxSpeed;
            this.MaxAllowedOcclusion=maxSpeed;
        end

        function maxSpeed=get.MaxAllowedOcclusion(this)
            s=getSensor(this);
            maxSpeed=s.MaxAllowedOcclusion;
        end

        function set.MinObjectImageSize(this,maxSpeed)
            s=getSensor(this);
            s.MinObjectImageSize=maxSpeed;
            this.MinObjectImageSize=maxSpeed;
        end

        function maxSpeed=get.MinObjectImageSize(this)
            s=getSensor(this);
            maxSpeed=s.MinObjectImageSize;
        end

        function set.FalsePositivesPerImage(this,maxSpeed)
            s=getSensor(this);
            s.FalsePositivesPerImage=maxSpeed;
            this.FalsePositivesPerImage=maxSpeed;
        end

        function maxSpeed=get.FalsePositivesPerImage(this)
            s=getSensor(this);
            maxSpeed=s.FalsePositivesPerImage;
        end

        function set.BoundingBoxAccuracy(this,maxSpeed)
            s=getSensor(this);s.BoundingBoxAccuracy=maxSpeed;
            this.BoundingBoxAccuracy=maxSpeed;
        end

        function maxSpeed=get.BoundingBoxAccuracy(this)
            s=getSensor(this);
            maxSpeed=s.BoundingBoxAccuracy;
        end

        function set.ProcessNoiseIntensity(this,maxSpeed)
            s=getSensor(this);
            s.ProcessNoiseIntensity=maxSpeed;
            this.ProcessNoiseIntensity=maxSpeed;
        end

        function maxSpeed=get.ProcessNoiseIntensity(this)
            s=getSensor(this);
            maxSpeed=s.ProcessNoiseIntensity;
        end

        function set.FocalLength(this,focalLength)
            pp=[];
            is=[];
            try

                pp=this.PrincipalPoint;%#ok<*MCSUP>
                is=this.ImageSize;
            catch me %#ok<*NASGU>
            end

            if~isempty(pp)&&~isempty(is)
                s=getSensor(this);
                s.Intrinsics=cameraIntrinsics(focalLength,pp,is);
            end
            this.FocalLength=focalLength;
        end

        function focalLength=get.FocalLength(this)
            s=getSensor(this);
            focalLength=s.Intrinsics.FocalLength;
        end

        function set.PrincipalPoint(this,principalPoint)
            fl=[];
            is=[];
            try

                fl=this.FocalLength;
                is=this.ImageSize;
            catch me %#ok<*NASGU>
            end
            s=getSensor(this);
            s.Intrinsics=cameraIntrinsics(fl,principalPoint,is);
            this.PrincipalPoint=principalPoint;
        end

        function principalPoint=get.PrincipalPoint(this)
            s=getSensor(this);
            principalPoint=s.Intrinsics.PrincipalPoint;
        end

        function set.ImageSize(this,imageSize)
            pp=[];
            fl=[];
            try

                pp=this.PrincipalPoint;%#ok<*MCSUP>
                fl=this.FocalLength;
            catch me %#ok<*NASGU>
            end

            s=getSensor(this);s.Intrinsics=cameraIntrinsics(fl,pp,imageSize);
            this.ImageSize=imageSize;
        end

        function focalLength=get.ImageSize(this)
            s=getSensor(this);
            focalLength=s.Intrinsics.ImageSize;
        end

































        function[sensorPairs,specPairs]=getPVPairs(this,varargin)
            sensorPairs=getPVPairs@driving.internal.scenarioApp.SensorSpecification(this,varargin{:});
            specPairs={'DetectionType',this.DetectionType};
        end
    end

    methods(Hidden)
        function c=getPropertySheetConstructor(~)
            c='driving.internal.scenarioApp.VisionPropertySheet';
        end

        function block=getDefaultSimulinkBlockName(~)
            block='drivingscenarioandsensors/Vision Detection Generator';
        end

        function block=getSimulation3DBlockName(~)
            load_system('drivingsim3d');
            block=find_system('drivingsim3d','Name','Simulation 3D Vision Detection Generator');
            if isempty(block)
                block='';
            else
                block=block{1};
            end
        end

        function[pvPairs,warnings]=getPVPairsForSimulation3DBlock(this,params)
            [pvPairs,warnings]=getPVPairsForSimulation3DBlock@driving.internal.scenarioApp.SensorSpecification(this,params);
            if~strcmp(this.DetectionCoordinates,'Ego Cartesian')
                warnings{end+1}='driving:scenarioApp:Export3dSimVisionDetectionCoordinatesWarning';
            end
        end
    end

    methods(Access=protected)
        function b=isObjectDetections(this)
            b=any(strcmp(this.DetectionType,{'lanes&objects','objects'}));
        end
        function color=getDefaultColor(~)
            color=[0,114,189]/255;
        end
        function sensor=getDefaultSensor(~)
            sensor=visionDetectionGenerator();
        end

        function value=getSpecificSimulinkBlockPV(this,parameter)
            switch parameter
            case 'Intrinsics'
                sensorParamExp='driving.internal.cameraIntrinsics(';
                sensorObj=this.Sensor.Intrinsics;
                sensorObjFields={'FocalLength','PrincipalPoint','ImageSize',...
                'RadialDistortion','TangentialDistortion','Skew'};
                for knd=1:length(sensorObjFields)
                    if~strcmp(sensorObjFields{knd},'IntrinsicMatrix')
                        value=mat2str(sensorObj.(sensorObjFields{knd}));
                        sensorParamExp=[sensorParamExp,'''',sensorObjFields{knd},''',',value,','];%#ok<AGROW>
                    end
                end
                value=[sensorParamExp(1:end-1),')'];
            otherwise
                value=[];
            end
        end

        function setFieldOfView(this,fov)
            sensor=getSensor(this);
            imageSize=sensor.Intrinsics.ImageSize;
            focalLength(1)=imageSize(2)/(2*tand(fov(1)/2));
            if isscalar(fov)
                focalLength(2)=focalLength(1);
            else
                focalLength(2)=imageSize(1)/(2*tand(fov(2)/2));
            end
            this.FocalLength=focalLength;
        end


        function props=getExposedProperties(this)



            props=getExposedProperties@driving.internal.scenarioApp.SensorSpecification(this);
            props=[props,{'MaxSpeed',...
            'MaxAllowedOcclusion',...
            'MinObjectImageSize',...
            'FalsePositivesPerImage',...
            'BoundingBoxAccuracy',...
            'ProcessNoiseIntensity'}];
            detType=string(this.DetectionType);
            if detType.contains('lanes')
                props=[props,{'MinLaneImageSize',...
                'LaneBoundaryAccuracy',...
                'MaxNumLanesSource'}];
                if strcmp(this.MaxNumLanesSource,'Property')
                    props=[props,{'MaxNumLanes'}];
                end
            end
        end

        function pvPairs=getPVPairsForMatlabCode(this,defaultSensor)
            pvPairs=getPVPairsForMatlabCode@driving.internal.scenarioApp.SensorSpecification(this,defaultSensor);


            index=find(strcmp(pvPairs(1:2:end),'DetectionType'));
            if~isempty(index)
                s=getSensor(this);
                pvPairs{2*index-1}='DetectorOutput';
                pvPairs{2*index}=mat2str(s.DetectorOutput);
            end

            intrinsics=defaultSensor.Intrinsics;
            if~isequal(intrinsics.FocalLength,this.FocalLength)||...
                ~isequal(intrinsics.PrincipalPoint,this.PrincipalPoint)||...
                ~isequal(intrinsics.ImageSize,this.ImageSize)
                pvPairs=[pvPairs,{'Intrinsics',['cameraIntrinsics(',mat2str(this.FocalLength),',',mat2str(this.PrincipalPoint),',',mat2str(this.ImageSize),')']}];
            end
        end

        function b=hasMaxNumDetections(this)
            detType=string(this.DetectionType);
            b=detType.contains('objects');
        end
    end
end


