classdef Bicyclist<sim3d.AbstractActor
    properties(SetAccess='public',GetAccess='public')
        ActorID;
        ActorTag;
    end
    properties(Access=private)
        TerrainSensorPublisher=[];
        TerrainSensorSubscriber=[];
        TerrainSensorConfig;
        WheelBase=1.72;
        WheelRadius=0.35;
        RayStart=[0,0,0;0,0,0];
        RayEnd=[1,0,3;1,0,3];
        RayTraceMaxValueLimit=1.0e+10;
        TraceStart_cache;
        TraceEnd_cache;
    end
    properties(Access=private,Constant=true)
        TerrainSensorSuffixOut='/TerrainSensorConfiguration_OUT';
        TerrainSensorSuffixIn='/TerrainSensorDetection_IN';
    end
    methods
        function self=Bicyclist(actorName,varargin)
            narginchk(1,inf);
            numberOfParts=uint32(3);

            r=sim3d.pedestrians.Bicyclist.parseInputs(varargin{:});
            self@sim3d.AbstractActor(actorName,'Scene Origin',r.Translation,r.Rotation,r.Scale,'ActorClassId',r.ActorID,'NumberOfParts',numberOfParts);
            self.ActorTag=actorName;

            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorID=r.ActorID;
        end

        function reset(self)
            self.TerrainSensorConfig.RayStart=self.RayStart;
            self.TerrainSensorConfig.RayEnd=self.RayEnd;
            self.TerrainSensorPublisher=sim3d.io.Publisher([self.ActorTag,self.TerrainSensorSuffixOut]);
            self.TerrainSensorSubscriber=sim3d.io.Subscriber([self.ActorTag,self.TerrainSensorSuffixIn]);

            sim3d.engine.EngineReturnCode.assertObject(self.TransformWriter);
            if~isempty(self.Translation)&&~isempty(self.Rotation)&&~isempty(self.Scale)
                translation=self.Translation;
                rotation=self.Rotation;
                rotation(1,3)=rotation(1,3)-pi/2;
                scale=self.Scale;
                self.TransformWriter.write(translation,rotation,scale);
            end
            self.TerrainSensorPublisher.publish(self.TerrainSensorConfig);
        end

        function step(self,X,Y,Yaw)
            translation=zeros(self.NumberOfParts,3,'single');
            rotation=zeros(self.NumberOfParts,3,'single');
            [~,traceEnd]=self.readTerrainSensorDetections();
            [previousTranslation,previousRotation,~]=self.readTransform();
            if(any(traceEnd(:,3)>self.RayTraceMaxValueLimit))
                error('sim3d:TerrainSensor:InvalidZValue','Check the position of bicycle to make sure it did not encounter a large variation in terrain');
            end
            HitZ=median(traceEnd(:,3))+sign(traceEnd(1,3)-traceEnd(2,3))*0.01;

            pitch=real(asin((traceEnd(1,3)-traceEnd(2,3))/self.WheelBase));
            translation(1,:)=[X,Y,HitZ];
            rotation(1,:)=[0,pitch,Yaw];

            pX=previousTranslation(1,1);
            pY=previousTranslation(1,2);
            pYaw=previousRotation(1,3);
            pWheelRotation=previousRotation(2,2);
            currentWheelRotation=self.EstimateWheelRotationAndSteerAngle(pX,pY,pYaw,pWheelRotation,X,Y,Yaw,self.WheelBase,self.WheelRadius);


            rotation(2:3,2)=single(currentWheelRotation);
            self.writeTransform(translation,rotation,self.Scale);
        end

        function[traceStart,traceEnd]=readTerrainSensorDetections(self)
            if self.TerrainSensorSubscriber.has_message()
                terrainSensorDetections=self.TerrainSensorSubscriber.take();
                traceStart=terrainSensorDetections.TraceStart;
                traceEnd=terrainSensorDetections.TraceEnd;
                self.TraceStart_cache=traceStart;
                self.TraceEnd_cache=traceEnd;
            else
                traceStart=self.TraceStart_cache;
                traceEnd=self.TraceEnd_cache;
            end
        end





        function write(self,translation,rotation,scale)
            self.writeTransform(translation,rotation,scale);
        end

        function[translation,rotation,scale]=read(self)
            [translation,rotation,scale]=self.readTransform();
        end



        function[translation,rotation,scale]=getTransform(self)
            translation=self.Translation;
            rotation=self.Rotation;
            scale=self.Scale;
        end

        function writeTransform(self,translation,rotation,scale)

            if~isempty(self.TransformWriter)
                if(numel(translation)==3||numel(rotation)==3)
                    translation(2:3,:)=[0,0,0;0,0,0];
                    rotation(2:3,:)=[0,0,0;0,0,0];
                    scale(2:3,:)=[1,1,1;1,1,1];
                end
                rotation(1,3)=rotation(1,3)-pi/2;
                rotation(1,2)=-rotation(1,2);
                self.TransformWriter.write(single(translation),single(rotation),single(scale));

                self.TransformReader.read();
            end
        end

        function[translation,rotation,scale]=readTransform(self)

            if~isempty(self.TransformReader)
                sim3d.engine.EngineReturnCode.assertObject(self.TransformReader);
                [translation,rotation,scale]=self.TransformReader.read;
                rotation(1,3)=rotation(1,3)+pi/2;
                if(rotation(3)<0)
                    rotation(1,3)=rotation(1,3)+2*pi;
                end
            else
                translation=[];
                rotation=[];
                scale=[];
            end
        end

        function wheelRotation=EstimateWheelRotationAndSteerAngle(~,pX,pY,pYaw,pWheelRotation,X,Y,Yaw,WheelBase,WheelRadius)


            dX=X-pX;
            dY=Y-pY;
            dPsi=sign(Yaw-pYaw)*mod(Yaw-pYaw,2*pi);
            dx=dX*cos(Yaw)+dY*sin(Yaw);
            dy=dX*sin(Yaw)+dY*cos(Yaw);
            CGdisp=sqrt(dy^2+dx^2);
            if dPsi==0
                dPsi=.001;
            end

            beta=atan2(dy,dx);
            Rest=CGdisp/2/sin(dPsi/2);
            deltaL=atan(WheelBase/(Rest-1.9/2));
            deltaR=atan(WheelBase/(Rest+1.9/2));


            wheelRotation=cos(median([deltaL,deltaR]))*CGdisp/WheelRadius*cos(beta);
            wheelRotation=pWheelRotation+wheelRotation;
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.Bicyclist;
        end

        function delete(self)

            if~isempty(self.TerrainSensorPublisher)
                self.TerrainSensorPublisher=[];
            end
            if~isempty(self.TerrainSensorSubscriber)
                self.TerrainSensorSubscriber=[];
            end
        end

    end

    methods(Access=private,Static)
        function r=parseInputs(varargin)

            defaultParams=struct(...
            'Translation',single(zeros(3,3)),...
            'Rotation',single(zeros(3,3)),...
            'Scale',single(ones(3,3)),...
            'ActorID',10);


            parser=inputParser;
            parser.addParameter('Translation',defaultParams.Translation);
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ActorID',defaultParams.ActorID);


            parser.parse(varargin{:});
            r=parser.Results;
            r.Translation(2:3,:)=0;
            r.Rotation(2:3,:)=0;
            r.Scale(2:3,:)=1;
        end
    end
end

