classdef RangeSensor<Simulation3DSensor&...
Simulation3DHandleMap

    properties(Nontunable)
        MinimumDetectionOnlyRange=[]
        MinimumRangeWithDistance=[]
        MaximumRange=[]

        HorizontalFOV=[]
        VerticalFOV=[]
    end


    methods(Access=protected)

        function setupImpl(self)
            setupImpl@Simulation3DSensor(self);

            if~coder.target('MATLAB')
                return;
            end
            sensorProperties=sim3d.sensors.RangeSensor.getRangeSensorProperties();
            sensorProperties.Range=self.MaximumRange;
            sensorProperties.HorizontalFOV=self.HorizontalFOV;
            sensorProperties.VerticalFOV=self.VerticalFOV;
            self.Sensor=sim3d.sensors.RangeSensor(...
            self.SensorIdentifier,...
            self.VehicleIdentifier,...
            sensorProperties,...
            sim3d.utils.Transform(...
            self.Translation,...
            self.Rotation,...
            [1,1,1])...
            );
            self.Sensor.setup();
            self.Sensor.reset();
        end


        function[hasObject,hasRange,distance]=stepImpl(self)
            if~coder.target('MATLAB')
                return
            end
            [objectInFoV,detectionPoint]=self.Sensor.readSignal();
            rangeSquared=dot(detectionPoint,detectionPoint);

            if~objectInFoV||rangeSquared<self.MinimumDetectionOnlyRange^2
                hasObject=false;
                hasRange=false;
                distance=single(0);
                return
            end

            if rangeSquared<self.MinimumRangeWithDistance^2
                hasObject=true;
                hasRange=false;
                distance=single(0);
                return
            end

            hasObject=true;
            hasRange=true;
            distance=sqrt(rangeSquared);
        end


        function num=getNumOutputsImpl(~)
            num=3;
        end

        function[fz1,fz2,fz3]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
            fz3=true;
        end


        function[sz1,sz2,sz3]=getOutputSizeImpl(~)
            sz1=[1,1];
            sz2=[1,1];
            sz3=[1,1];
        end


        function[dt1,dt2,dt3]=getOutputDataTypeImpl(~)
            dt1='logical';
            dt2='logical';
            dt3='single';
        end


        function[cp1,cp2,cp3]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
            cp3=false;
        end
        

        function[pn1,pn2,pn3]=getOutputNamesImpl(~)
            pn1='Has object';
            pn2='Has range';
            pn3='Range';
        end


        function resetImpl(self)
            if~coder.target('MATLAB')
                return
            end

            if~isempty(self.Sensor)
                self.Sensor.reset();
            end
        end


        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
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
            s.MinimumDetectionOnlyRange=self.MinimumDetectionOnlyRange;
            s.MinimumRangeWithDistance=self.MinimumRangeWithDistance;
            s.MaximumRange=self.MaximumRange;
            s.HorizontalFOV=self.HorizontalFOV;
            s.VerticalFOV=self.VerticalFOV;
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
