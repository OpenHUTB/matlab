classdef GeoSpatialConfiguration<sim3d.AbstractActor
    properties
        ActorTag;
        AuthManager;
        TokenID;
        Config=[];
        ConfigPublisher=[];
    end

    properties(Access=protected,Constant)
        Suffix='/GeoSpatialConfiguration_OUT';
    end

    methods
        function self=GeoSpatialConfiguration(actorName,accessTokenID,geoSpatialProperties)
            self@sim3d.AbstractActor(uint32(1),'Scene Origin',[0,0,0],[0,0,0],[1,1,1],'ActorName',actorName);
            self.ActorTag=actorName;
            self.AuthManager=sim3d.geospatial.AuthManager();
            geoSpatialProperties.AccessToken=string(self.AuthManager.getTokenValue(accessTokenID));
            self.Config=geoSpatialProperties;
            self.setup();
            self.reset();
        end

        function setup(self)
            setup@sim3d.AbstractActor(self);
            self.ConfigPublisher=sim3d.io.Publisher([self.getTag(),self.Suffix]);
        end

        function reset(self)
            self.ConfigPublisher.publish(self.Config);
        end

        function delete(self)
            delete@sim3d.AbstractActor(self);
        end
    end

    methods(Access=public,Hidden=true)
        function tag=getTag(self)
            tag=self.ActorTag;
        end
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.GeoSpatialActor;
        end
    end
    methods(Static)
        function configProperties=getGeoSpatialConfigProperties()
            configProperties=struct(...
            'AccessToken',"",...
            'OriginLatitude',40.744652,...
            'OriginLongitude',-73.988864,...
            'OriginHeight',200.0,...
            'UseAdvancedSunSky',true,...
            'TimeZone',-5.0,...
            'SolarTime',11,...
            'Day',int32(21),...
            'Month',int32(9),...
            'Year',int32(2022),...
            'UseDaylightSavingTime',false,...
            'DSTStartMonth',int32(3),...
            'DSTStartDay',int32(10),...
            'DSTEndMonth',int32(11),...
            'DSTEndDay',int32(3),...
            'DSTSwitchHour',2.0,...
            'Azimuth',0.0,...
            'Elevation',0.0,...
            'MapStyle',int64(2),...
            'AdditionalAssetIDs',[]);
        end
    end
end