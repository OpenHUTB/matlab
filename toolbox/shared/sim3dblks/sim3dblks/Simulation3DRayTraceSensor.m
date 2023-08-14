classdef Simulation3DRayTraceSensor<Simulation3DSensor&...
Simulation3DHandleMap




    properties(Nontunable)
        NumberOfBounces;
        NumberOfRays;
        RayOrigins;
        RayDirections;
        RayLengths;
        VisualizeRaytraceLines=true;
        EnableOptimization=false;
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


                transform=sim3d.utils.Transform(self.Translation,self.Rotation);
                sensorProperties=sim3d.sensors.RayTraceSensor.getRayTraceSensorProperties();
                sensorProperties.RayOrigins=self.RayOrigins;
                sensorProperties.RayDirections=self.RayDirections;
                sensorProperties.RayLengths=self.RayLengths;
                sensorProperties.NumberOfBounces=self.NumberOfBounces;
                sensorProperties.VisualizeTraceLines=self.VisualizeRaytraceLines;
                sensorProperties.EnableOptimization=self.EnableOptimization;


                self.Sensor=sim3d.sensors.RayTraceSensor(self.SensorIdentifier,self.VehicleIdentifier,...
                sensorProperties,transform);
                self.Sensor.setup();
                self.Sensor.reset();
                self.ModelName=['Simulation3DRayTraceSensor/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end

        function[hitLocations,hitNormals,hitDistances,surfaceIds,validHits]=stepImpl(self)
            if coder.target('MATLAB')
                [surfaceIds,hitDistances,hitLocations,hitNormals,validHits]=self.Sensor.read();

                hitLocations=hitLocations*0.01;
                hitDistances=hitDistances*0.01;
            end
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    self.Sensor.reset();
                end
            end
        end

        function num=getNumOutputsImpl(~)
            num=5;
        end

        function[fz1,fz2,fz3,fz4,fz5]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
            fz3=true;
            fz4=true;
            fz5=true;
        end

        function[sz1,sz2,sz3,sz4,sz5]=getOutputSizeImpl(self)
            sz1=[(self.NumberOfBounces+1)*self.NumberOfRays,3];
            sz2=[(self.NumberOfBounces+1)*self.NumberOfRays,3];
            sz3=[(self.NumberOfBounces+1)*self.NumberOfRays,1];
            sz4=[(self.NumberOfBounces+1)*self.NumberOfRays,1];
            sz5=[(self.NumberOfBounces+1)*self.NumberOfRays,1];
        end
        function[dt1,dt2,dt3,dt4,dt5]=getOutputDataTypeImpl(~)
            dt1='single';
            dt2='single';
            dt3='single';
            dt4='uint32';
            dt5='logical';
        end
        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end

        end
        function[cp1,cp2,cp3,cp4,cp5]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
            cp3=false;
            cp4=false;
            cp5=false;
        end

        function[pn1,pn2,pn3,pn4,pn5]=getOutputNamesImpl(self)

            pn1='Hit locations';
            pn2='Hit normals';
            pn3='Hit distances';
            pn4='Surface ids';
            pn5='Is valid hit';
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

            icon=matlab.system.display.Icon('sim3draytracesensor.png');
        end
    end

    methods(Access=public,Hidden=true)
        function tag=getTag(self)
            tag=sprintf('RayTraceSensor%d',self.SensorIdentifier);
        end
    end
end
