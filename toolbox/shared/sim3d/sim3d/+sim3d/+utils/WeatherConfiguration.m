classdef WeatherConfiguration<handle


    properties
        WeatherConfigParas(1,6)single=[40,90,10,0,0,1]

        RefreshWeather=false
    end

    properties(Constant=true)
        Suffix='/WeatherConfiguration_OUT';
    end

    properties(Access=private)
        CreateActor=[];
        Writer=[];
        Reader=[];
        Translation=[0,0,2];
        Rotation=[0,0,0];
        Scale=[1,1,1];
        WeatherConfigStruct=[];
    end
    properties(SetAccess='private',GetAccess='public')

        ActorTag='weatherconfig';

        ActorID=80;
    end

    methods
        function self=WeatherConfiguration(actorTag,WeatherConfigParas,RefreshWeather)
            narginchk(3,inf);


            self.ActorTag=actorTag;

            actorLocation.translation=self.Translation;
            actorLocation.rotation=self.Rotation;
            actorLocation.scale=self.Scale;


            self.CreateActor=sim3d.utils.CreateActor;
            self.CreateActor.setActorName(self.ActorTag);
            self.CreateActor.setParentName('Scene Origin');
            self.CreateActor.setCreateActorType(self.getActorType());
            self.CreateActor.setActorLocation(actorLocation);
            self.CreateActor.setActorId(self.ActorID);
            self.CreateActor.write;


            self.Writer=sim3d.io.Publisher([self.ActorTag,sim3d.utils.WeatherConfiguration.Suffix]);
            sim3d.engine.EngineReturnCode.assertObject(self.Writer);

            result=self.write(WeatherConfigParas,RefreshWeather);
        end
        function result=write(self,WeatherConfigParas,RefreshWeather)
            self.WeatherConfigParas=single(WeatherConfigParas);
            self.WeatherConfigStruct=struct(...
            'SunAltitude',single(WeatherConfigParas(1)),...
            'SunAzimuth',single(WeatherConfigParas(2)),...
            'CloudDensity',single(WeatherConfigParas(3)),...
            'FogDensity',single(WeatherConfigParas(4)),...
            'RainDensity',single(WeatherConfigParas(5)),...
            'WindDensity',single(WeatherConfigParas(6)),...
            'UpdateWeather',logical(RefreshWeather));
            self.Writer.publish(self.WeatherConfigStruct);
            result=sim3d.engine.EngineReturnCode.OK;
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.WeatherController;
        end

        function delete(self)

            if~isempty(self.CreateActor)
                self.CreateActor.delete();
                self.CreateActor=[];
            end
            if~isempty(self.Writer)&&self.Writer~=uint64(0)
                self.Writer.delete();
                self.Writer=[];
            end
        end

        function result=step(self,WeatherConfigParas,RefreshWeather)
            result=self.write(WeatherConfigParas,RefreshWeather);
        end


    end
end

