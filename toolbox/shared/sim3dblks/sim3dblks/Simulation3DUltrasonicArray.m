classdef Simulation3DUltrasonicArray<Simulation3DSensor&...
Simulation3DHandleMap


    properties(Nontunable)
        RelativeMountingLocations=[]
        RelativeMountingRotations=[]

        MinimumDetectionOnlyRange{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;
        MinimumRangeWithDistance{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;
        MaximumRange{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;

        HorizontalFOV{mustBeInRange(HorizontalFOV,0,90,"exclude-lower")}=70;
        VerticalFOV{mustBeInRange(VerticalFOV,0,90,"exclude-lower")}=35;

        SoundSpeedInMetersPerSecond{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;
        AcousticFrequencyInKilohertz{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;
        SamplingFrequencyInKilohertz{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;
        PulseWidthInSeconds{mustBeNonnegative,mustBeReal,mustBeScalarOrEmpty}=0;
        Gain{mustBeReal}=0;
    end

    properties(Access=protected)
        NumTransducers=[]
        FrequencyDomainSignalTemplate=[];
        SignalSampleTimes=[];
    end

    properties(Access=protected,Constant)
        NumTraceBounces=1;
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DSensor(self);

            if~coder.target('MATLAB')
                return;
            end

            self.NumTransducers=size(self.RelativeMountingLocations,1);

            targetTags=self.TargetTags();

            sensorConfiguration=self.RayTraceConfiguration();
            sensorConfiguration.NumberOfBounces=self.NumTraceBounces;
            sensorConfiguration.TargetActorTags=targetTags;
            self.Sensor=sim3d.sensors.RayTraceSensor(...
            self.SensorIdentifier,...
            self.VehicleIdentifier,...
            sensorConfiguration,...
            sim3d.utils.Transform(...
            self.Translation,...
            self.Rotation...
            )...
            );

            for i=1:self.NumTransducers
                self.CreateTarget(self.RelativeMountingLocations(i,:),targetTags(i));
            end

            self.Sensor.createActor();
            self.Sensor.setup();

            dt=1/(1000*self.SamplingFrequencyInKilohertz);
            self.SignalSampleTimes=-self.SampleTime:dt:self.SampleTime;
            signalTemplate=modulatedGaussian(...
            self.SignalSampleTimes,...
            self.PulseWidthInSeconds,...
            1000*self.AcousticFrequencyInKilohertz...
            );
            self.FrequencyDomainSignalTemplate=fft(signalTemplate);
        end

        function configuration=RayTraceConfiguration(self)
            sim3dToUnreal=100;

            numRays=500;

            configuration=sim3d.sensors.RayTraceSensor.getRayTraceSensorProperties();

            configuration.RayOrigins=[];
            configuration.RayDirections=[];
            configuration.RayLengths=...
            repmat(sim3dToUnreal*self.MaximumRange,self.NumTransducers*numRays,1);

            for i=1:self.NumTransducers
                origins=repmat(sim3dToUnreal*self.RelativeMountingLocations(i,:),numRays,1);
                configuration.RayOrigins=vertcat(...
                configuration.RayOrigins,...
origins...
                );

                angles=linspace(-self.HorizontalFOV/2,self.HorizontalFOV/2,numRays);
                directions=transpose([...
                cosd(angles);...
                sind(angles);...
                zeros(1,numRays);...
                ]);
                configuration.RayDirections=vertcat(...
                configuration.RayDirections,...
directions...
                );
            end
        end

        function[targetTags]=TargetTags(self)
            targetTags=strings(1,self.NumTransducers);

            for i=1:self.NumTransducers
                targetTags(i)=self.getTag()+sprintf("::Target%02d",i);
            end
        end

        function[actor]=CreateTarget(self,position,tag)
            actor=sim3d.StaticActor(...
            tag,...
            '/Engine/BasicShapes/Sphere',...
            position,...
            'AttachToActor',self.Sensor.getTag(),...
            'CustomDepthStencilValue',10,...
            'Scale',[1/10,1/10,1/10]...
            );
            actor.createActor();
            actor.setup();
        end

        function[hasObject,hasRange,distance]=stepImpl(self)
            if~coder.target('MATLAB')
                return
            end

            [~,hitDistances,~,~,validHits]=self.Sensor.read();
            timeDelays=self.timeDelays(hitDistances,validHits);

            resultantAnalyticSignal=self.resultantAnalyticSignal(timeDelays);
            [~,maxTime]=findpeaks(...
            abs(resultantAnalyticSignal),...
            self.SignalSampleTimes,...
            "SortStr","descend",...
            "NPeaks",1...
            );

            hasObject=true;
            hasRange=true;
            distance=single(maxTime*self.SoundSpeedInMetersPerSecond/2);


        end

        function timeDelays=timeDelays(self,hitDistances,validHits)




            numPoints=self.NumTraceBounces+1;
            dimensions=[size(validHits,1)/numPoints,numPoints];
            hitDistances=reshape(hitDistances,dimensions);
            hitDistances(~reshape(validHits,dimensions))=0;
            rowSum=sum(hitDistances,2);
            timeDelays=(rowSum(rowSum>0)/100)*(1/self.SoundSpeedInMetersPerSecond);
        end

        function frequencyTable=frequencyTable(self,integerDelays)
            numSamples=length(self.FrequencyDomainSignalTemplate);




            table=integerDelays*(0:numSamples-1);
            frequencyTable=exp(-2*pi*1i/numSamples.*table);
        end

        function resultantAnalyticSignal=resultantAnalyticSignal(self,timeDelays)
            integerDelays=floor(timeDelays*1000*self.SamplingFrequencyInKilohertz);
            numSamples=length(self.FrequencyDomainSignalTemplate);

            dr=timeDelays.*self.SoundSpeedInMetersPerSecond;
            frequencyDomainSignal=(self.frequencyTable(integerDelays).*self.FrequencyDomainSignalTemplate)./dr;

            frequencyDomainResultantSignal=sum(frequencyDomainSignal,1);
            hilbertTransform=ifft(1i*sign((1:numSamples)-(numSamples/2)).*frequencyDomainResultantSignal);
            resultantSignal=real(ifft(frequencyDomainResultantSignal));

            resultantAnalyticSignal=resultantSignal+1i*hilbertTransform;
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
                self.Sensor.setup();
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
    end

    methods(Access=public,Hidden=true)
        function tag=getTag(self)
            tag=sprintf('UltrasonicSensorArray%d',self.SensorIdentifier);
        end
    end
end

function modulatedGaussian=modulatedGaussian(ts,width,frequency)
    modulatedGaussian=exp(-(ts.^2)/(2*width^2)).*cos(2*pi*frequency.*ts);
end

