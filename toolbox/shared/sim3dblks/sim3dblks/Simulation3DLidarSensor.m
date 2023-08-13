classdef Simulation3DLidarSensor<Simulation3DSensor&...
Simulation3DHandleMap


    properties(Nontunable)

        DetectionRange(1,1)single{mustBePositive,mustBeLessThanOrEqual(DetectionRange,500)}=single(120);

        RangeResolution(1,1)single{mustBePositive}=0.002;

        VerticalFOV(1,1)single{mustBePositive,mustBeLessThanOrEqual(VerticalFOV,90)}=40;

        VerticalResolution(1,1)single{mustBePositive,mustBeLessThanOrEqual(VerticalResolution,10)}=1.25;

        HorizontalFOV(1,1)single{mustBePositive,mustBeLessThanOrEqual(HorizontalFOV,360)}=360;

        HorizontalResolution(1,1)single{mustBePositive,mustBeLessThanOrEqual(HorizontalResolution,10)}=0.16;

        DistanceOutputEnabled(1,1)logical=true;

        ReflectivityOutportEnabled(1,1)logical=true;

        SemanticOutportEnabled(1,1)logical=true;

        TransformOutportEnabled(1,1)logical=true;
    end

    properties(Access=private)
        UnitVector;
        ModelName=[];
        OutputBusName='BusPositionVelocity';
    end


    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DSensor(self);
            if coder.target('MATLAB')
                lidarProperties=sim3d.sensors.LidarSensor.getLidarSensorProperties();
                lidarProperties.MaxRange=self.DetectionRange;
                lidarProperties.VertFOV=self.VerticalFOV;
                lidarProperties.VertAngularResolution=self.VerticalResolution;
                lidarProperties.HorzFOV=self.HorizontalFOV;
                lidarProperties.HorzAngularResolution=self.HorizontalResolution;
                lidarProperties.RangeQuantizationFactor=self.RangeResolution;
                transform=sim3d.utils.Transform(self.Translation,self.Rotation);

                self.Sensor=sim3d.sensors.LidarSensor(self.SensorIdentifier,...
                self.VehicleIdentifier,lidarProperties,transform);
                self.Sensor.setup();
                self.UnitVector=createUnitVector(self);
                self.Sensor.reset();
                self.ModelName=['Simulation3DLidarSensor/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.UnitVector=s.UnitVector;
            if self.loadflag
                self.ModelName=s.ModelName;
                self.Sensor=self.Sim3dSetGetHandle([self.ModelName,'/Sensor']);
                loadObjectImpl@matlab.System(self,s,wasInUse);
            else
                loadObjectImpl@Simulation3DSensor(self,s,wasInUse);
            end
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DSensor(self);
            s.UnitVector=self.UnitVector;
            s.ModelName=self.ModelName;
        end

        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);

            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end

        end

        function[pointCloud,pvBus,varargout]=stepImpl(self)
            varargout={};
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    [range,reflectivity,semantic]=self.Sensor.readSignal();
                    pointCloud=constructPointCloud(self,range);


                    pos(1,:)=reshape(pointCloud(:,:,1),1,[]);
                    pos(2,:)=reshape(pointCloud(:,:,2),1,[]);
                    pvBus=struct('Position',pos,'Velocity',0);

                    if self.DistanceOutputEnabled
                        varargout{end+1}=range;
                    end
                    if self.ReflectivityOutportEnabled
                        varargout{end+1}=reflectivity;
                    end
                    if self.SemanticOutportEnabled
                        varargout{end+1}=semantic;
                    end
                    if self.TransformOutportEnabled
                        groundTruth=self.Sensor.readGroundTruth();
                        varargout{end+1}=groundTruth.Translation;
                        varargout{end+1}=groundTruth.Rotation;
                    end
                end
            end
        end


        function validatePropertiesImpl(self)
            validateattributes(self.DetectionRange,{'single'},{'<=',500,'nonnegative'});
            validateattributes(self.RangeResolution,{'numeric'},{'>=',self.DetectionRange/pow2(24)});
            validateattributes(self.VerticalFOV,{'single'},{'<=',90,'positive'});
            validateattributes(self.VerticalResolution,{'single'},{'<=',10,'positive'});
            validateattributes(self.HorizontalFOV,{'single'},{'<=',360,'positive'});
            validateattributes(self.HorizontalResolution,{'single'},{'<=',10,'positive'});
            validateattributes(self.Translation,{'numeric'},{'size',[1,3]});
            validateattributes(self.Rotation,{'numeric'},{'size',[1,3]});
        end

        function num=getNumOutputsImpl(self)
            num=2;
            if self.DistanceOutputEnabled
                num=num+1;
            end
            if self.ReflectivityOutportEnabled
                num=num+1;
            end
            if self.SemanticOutportEnabled
                num=num+1;
            end
            if self.TransformOutportEnabled
                num=num+2;
            end
        end

        function[sz1,pvBus,varargout]=getOutputSizeImpl(self)
            numVertPoints=ceil(self.VerticalFOV/self.VerticalResolution);
            numHorzPoints=ceil(self.HorizontalFOV/(sim3d.sensors.LidarSensor.NumQuadrants*self.HorizontalResolution));
            numHorzPoints=double(numHorzPoints*sim3d.sensors.LidarSensor.NumQuadrants);
            sz1=[numVertPoints,numHorzPoints,3];
            pvBus=[1,1];
            varargout={};
            if self.DistanceOutputEnabled
                varargout{end+1}=[numVertPoints,numHorzPoints,1];
            end
            if(self.ReflectivityOutportEnabled)
                varargout{end+1}=[numVertPoints,numHorzPoints,1];
            end
            if(self.SemanticOutportEnabled)
                varargout{end+1}=[numVertPoints,numHorzPoints,1];
            end
            if self.TransformOutportEnabled
                varargout{end+1}=[1,3];
                varargout{end+1}=[1,3];
            end
        end

        function[fz1,pvBus,varargout]=isOutputFixedSizeImpl(self)
            fz1=true;
            pvBus=true;
            varargout={};
            if self.DistanceOutputEnabled
                varargout{end+1}=true;
            end
            if(self.ReflectivityOutportEnabled)
                varargout{end+1}=true;
            end
            if(self.SemanticOutportEnabled)
                varargout{end+1}=true;
            end
            if self.TransformOutportEnabled
                varargout{end+1}=true;
                varargout{end+1}=true;
            end
        end

        function[dt1,pvBus,varargout]=getOutputDataTypeImpl(self)


            parentBlk=get_param(gcb,'Parent');
            sensorId=get_param(parentBlk,'sensorId');
            busName='BusPositionVelocity';
            if~any(strcmp(sensorId,{'0','1'}))
                busName=['BusPositionVelocity',char(sensorId-1)];
            end

            if~strcmp(self.OutputBusName,busName)
                self.OutputBusName=busName;
            end

            if~self.existBus(self.OutputBusName)

                evalStr=getBusCreationString(self.OutputBusName);
                localevalin(evalStr);
            end

            size=computePVBusSize(self);

            currentSize=localevalin([self.OutputBusName,'.Elements(1).Dimensions(2);']);
            if~isequal(size,currentSize)
                localevalin([self.OutputBusName,'.Elements(1).Dimensions = [2,',num2str(size),'];']);
            end


            dt1='single';
            pvBus=self.OutputBusName;

            varargout={};
            if self.DistanceOutputEnabled
                varargout{end+1}='single';
            end
            if self.ReflectivityOutportEnabled
                varargout{end+1}='single';
            end
            if self.SemanticOutportEnabled
                varargout{end+1}='uint8';
            end
            if self.TransformOutportEnabled
                varargout{end+1}='single';
                varargout{end+1}='single';
            end
        end

        function[cp1,pvBus,varargout]=isOutputComplexImpl(self)
            cp1=false;
            pvBus=false;
            varargout={};
            if self.DistanceOutputEnabled
                varargout{end+1}=false;
            end
            if self.ReflectivityOutportEnabled
                varargout{end+1}=false;
            end
            if self.SemanticOutportEnabled
                varargout{end+1}=false;
            end
            if self.TransformOutportEnabled
                varargout{end+1}=false;
                varargout{end+1}=false;
            end
        end

        function[pn1,pn2,varargout]=getOutputNamesImpl(self)

            pn1='PointCloud';
            pn2='PositionVelocity Bus';
            varargout={};
            if self.DistanceOutputEnabled
                varargout{end+1}='Distance';
            end
            if self.ReflectivityOutportEnabled
                varargout{end+1}='Reflectivity';
            end
            if self.SemanticOutportEnabled
                varargout{end+1}='Class IDs';
            end
            if self.TransformOutportEnabled
                varargout{end+1}='Translation';
                varargout{end+1}='Rotation';
            end
        end

        function icon=getIconImpl(~)
            icon={'Lidar Sensor','Get'};
        end
    end



    methods(Hidden)
        function[vehicleLength,vehicleOverhang]=getVehicleDims(self,blockPath)
            vehicleID=self.VehicleIdentifier;
            vehicleType='SimulinkVehicle';
            if~contains(vehicleID,vehicleType)
                vehicleType='Custom';
            end
            allVehicleOverhangs=struct('MuscleCar',0.945,...
            'Sedan',1.119,...
            'Hatchback',0.589,...
            'SmallPickupTruck',1.321,...
            'SportUtilityVehicle',0.939);
            hVehBlk=sim3d.utils.SimPool.getActorBlock(blockPath,vehicleType,vehicleID);
            if isempty(hVehBlk)
                error('Sensor not connected to a vehicle');
            end
            vehicleMesh=sim3d.utils.internal.StringMap.fwd(get_param(hVehBlk,'PassVehMesh'));
            vehicleLength=double(sim3d.auto.internal.(vehicleMesh).FrontBumper.translation(1)-sim3d.auto.internal.(vehicleMesh).RearBumper.translation(1));
            vehicleOverhang=allVehicleOverhangs.(vehicleMesh);
        end

        function[sensorType,sensorIndex,fov,maxRange,orientation,...
            location,detCoordSys,detOffset]=getSensorExtrinsicsForBES(self,blockPath)
            sensorType='LIDAR';
            sensorIndex=double(self.SensorIdentifier);
            fov=double(self.HorizontalFOV);
            maxRange=double(self.DetectionRange);
            orientation=double(self.Rotation).*[1,1,-1];

            [vehicleLength,vehicleOverhang]=self.getVehicleDims(blockPath);
            xOffset=vehicleLength/2-vehicleOverhang;
            translation=double(self.Translation);
            location=[translation(1)+xOffset,-translation(2)];
            detCoordSys='Sim3D Sensor Cartesian';
            detOffset=[xOffset,0,0];
        end
    end

    methods(Access=private)
        function unitVector=createUnitVector(self)







            VertHalfAngle_rad=deg2rad(floor(self.VerticalFOV/2.0));
            VerticalResolution_rad=deg2rad(self.VerticalResolution);
            HorizHalfAngle_rad=deg2rad(floor(self.HorizontalFOV/2.0));
            HorizontalResolution_rad=deg2rad(self.HorizontalResolution);

            unitVector=zeros(self.Sensor.getNumVertPoints(),self.Sensor.getNumHorzPoints(),3,'single');
            Az=-HorizHalfAngle_rad;
            for hIdx=1:self.Sensor.getNumHorzPoints()
                El=VertHalfAngle_rad;
                for vIdx=1:self.Sensor.getNumVertPoints()
                    [Px,Py,Pz]=sph2cart(Az,El,1);
                    unitVector(vIdx,hIdx,:)=[Px,-Py,Pz];


                    El=El-VerticalResolution_rad;
                end


                Az=Az+HorizontalResolution_rad;
            end
        end

        function pointCloud=constructPointCloud(self,range)
            pointCloud=self.UnitVector.*repmat(range,[1,1,3]);
        end

        function size=computePVBusSize(self)
            numVertPoints=ceil(self.VerticalFOV/self.VerticalResolution);
            numHorzPoints=ceil(self.HorizontalFOV/(sim3d.sensors.LidarSensor.NumQuadrants*self.HorizontalResolution));
            numHorzPoints=double(numHorzPoints*sim3d.sensors.LidarSensor.NumQuadrants);
            size=double(numVertPoints*numHorzPoints);
        end
    end


    methods(Static,Access=protected)
        function flag=showSimulateUsingImpl

            flag=false;
        end

        function flag=existBus(busName)


            flag=false;


            if~isvarname(busName)
                return
            end


            if~localevalin(['exist(''',busName,''',''var'')'])
                return
            end


            var=localevalin(busName);
            if~isa(var,'Simulink.Bus')
                return
            end


            flag=true;
        end
    end

end

function out=localevalin(evalstr)


    if nargout>0
        out=evalinGlobalScope(bdroot,evalstr);

    else
        evalinGlobalScope(bdroot,evalstr);

    end
end

function str=getBusCreationString(busName)
    part1=[busName,' = Simulink.Bus; ',...
    'el1 = Simulink.BusElement; ',...
    'el1.Name = ''Position''; ',...
    'el1.DataType = ''single''; ',...
    'el1.Dimensions = [2 72000]; ',...
    'el2 = Simulink.BusElement; ',...
    'el2.Name = ''Velocity''; ',...
    'el2.DataType = ''double''; ',...
    'el2.Dimensions = [1 1]; '];
    part2=[busName,'.Elements = [el1, el2]; ',...
    'clear el1 el2;'];

    str=[part1,part2];
end



