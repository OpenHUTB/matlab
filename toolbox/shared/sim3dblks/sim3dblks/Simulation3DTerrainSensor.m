classdef Simulation3DTerrainSensor<Simulation3DSensor&...
Simulation3DHandleMap

    properties(Nontunable)
NumberOfRays
NumberOfWheels
        RayOrigins(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}
        RayDirections(:,3)double{mustBeFinite,mustBeReal,mustBeNonmissing}
        RayLengths(:,1)double{mustBeFinite,mustBeReal,mustBeNonmissing}
        VisualizeRaytraceLines=true;
    end

    properties(Hidden=true,Constant=true,Access=private)
        ConstantNumberOfOutports=true;
    end

    properties(Access=private)
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DSensor(self);
            if coder.target('MATLAB')

                self.RayLengths=self.RayLengths*100;
                self.RayOrigins=self.RayOrigins*100;
                self.NumberOfRays=length(self.RayLengths);


                transform=sim3d.utils.Transform(self.Translation,self.Rotation);
                sensorProperties=sim3d.sensors.TerrainSensor.getTerrainSensorProperties();
                sensorProperties.RayOrigins=self.RayOrigins;
                sensorProperties.RayDirections=self.RayDirections;
                sensorProperties.RayLengths=self.RayLengths;
                sensorProperties.VisualizeTraceLines=logical(self.VisualizeRaytraceLines);


                self.Sensor=sim3d.sensors.TerrainSensor(self.SensorIdentifier,self.VehicleIdentifier,...
                sensorProperties,transform);
                self.Sensor.setup();
                self.Sensor.reset();
                self.ModelName=['Simulation3DTerrainSensor/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end

        function varargout=stepImpl(self)
            if coder.target('MATLAB')
                [hitLocations,validHits]=self.Sensor.read();

                positionsOut=mat2cell(hitLocations,ones(1,self.NumberOfWheels)*self.NumberOfRays,3)';
                statusOut=mat2cell(validHits,ones(1,self.NumberOfWheels)*self.NumberOfRays,1)';
                varargout=[positionsOut,statusOut];
            end
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    self.Sensor.reset();
                end
            end
        end

        function num=getNumOutputsImpl(self)
            num=self.NumberOfWheels*2;
        end

        function varargout=isOutputFixedSizeImpl(self)
            varargout=cell(1,getNumOutputs(self));
            for i=1:getNumOutputs(self)
                varargout{i}=true;
            end
        end

        function varargout=getOutputDataTypeImpl(self)
            varargout=cell(1,getNumOutputs(self));
            for i=1:self.NumberOfWheels
                varargout{i}='single';
                varargout{i+self.NumberOfWheels}='logical';
            end
        end

        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end

        end
        function varargout=isOutputComplexImpl(self)
            varargout=cell(1,getNumOutputs(self));
            for i=1:getNumOutputs(self)
                varargout{i}=false;
            end
        end

        function varargout=getOutputSizeImpl(self)
            varargout=cell(1,getNumOutputs(self));
            for i=1:self.NumberOfWheels
                varargout{i}=[self.NumberOfRays,3];
                varargout{i+self.NumberOfWheels}=[self.NumberOfRays,1];
            end
        end

        function varargout=getOutputNamesImpl(self)

            varargout=cell(1,getNumOutputs(self));
            for i=1:self.NumberOfWheels
                varargout{i}=['Wheel',num2str(i),'Positions'];
                varargout{i+self.NumberOfWheels}=['Wheel',num2str(i),'Status'];
            end
        end

        function validatePropertiesImpl(self)


            rayOriginsSize=size(self.RayOrigins,1);
            rayDirectionsSize=size(self.RayDirections,1);
            rayLengthsSize=size(self.RayLengths,1);
            isok=((rayOriginsSize==rayDirectionsSize)&&(rayDirectionsSize==rayLengthsSize));
            if isok
                isok=(rayOriginsSize==self.NumberOfRays);
            end
            if~isok
                error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidRaySize'));
            end
        end

        function loadObjectImpl(self,s,wasInUse)
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
            s.ModelName=self.ModelName;
        end

        function icon=getIconImpl(~)

            icon=matlab.system.display.Icon('sim3dterrainsensor.png');
        end
    end

    methods(Access=public,Hidden=true)
        function tag=getTag(self)
            tag=sprintf('TerrainSensor%d',self.SensorIdentifier);
        end
    end
end
