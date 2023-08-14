classdef Simulation3DGeoSpatial<Simulation3DActor&Simulation3DHandleMap



    properties(Nontunable)
        AccessTokenID="";
        OriginLatitude(1,1)double=40.744652;
        OriginLongitude(1,1)double=-73.988864;
        OriginHeight(1,1)double=200.0;

        UseAdvancedSunSky(1,1)logical=true;
        TimeZone(1,1)double=-5.0;
        SolarTime(1,1)double=11.0;
        Day(1,1)int32=21;
        Month(1,1)int32=9;
        Year(1,1)int32=2022;
        UseDaylightSavingTime(1,1)logical=false;
        DSTStartMonth(1,1)int32=3;
        DSTStartDay(1,1)int32=10;
        DSTEndMonth(1,1)int32=11;
        DSTEndDay(1,1)int32=3;
        DSTSwitchHour(1,1)double=2.0;
        Azimuth(1,1)double=0.0;
        Elevation(1,1)double=0.0;
        MapStyle(1,1)int64=2;
        AdditionalAssetIDs int64=[];
    end

    properties(Access=private)
GeoSpatialObj
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            geoSpatialConfiguration=sim3d.geospatial.GeoSpatialConfiguration.getGeoSpatialConfigProperties();
            geoSpatialConfiguration=self.setGeoSpatialConfig(geoSpatialConfiguration);
            self.GeoSpatialObj=sim3d.geospatial.GeoSpatialConfiguration('GeoActor',self.AccessTokenID,geoSpatialConfiguration);
            self.GeoSpatialObj.setup();
            self.GeoSpatialObj.reset();
            self.ModelName='Simulation3DGeoSpatial/GeoSpatialActor';
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/GeoSpatialObj'],self.GeoSpatialObj);
            end
        end

        function data=stepImpl(~)
            data=zeros(1,1,'double');
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'terminating')
                if coder.target('MATLAB')
                    if~isempty(self.GeoSpatialObj)
                        self.GeoSpatialObj.delete();
                        self.GeoSpatialObj=[];
                        if self.loadflag
                            self.Sim3dSetGetHandle([self.ModelName,'/GeoSpatialObj'],[]);
                        end
                    end
                end
            end
        end

        function resetImpl(~)

        end

        function loadObjectImpl(self,s,wasInUse)
            self.ModelName=s.ModelName;
            if self.loadflag
                self.GeoSpatialObj=self.Sim3dSetGetHandle([self.ModelName,'/GeoSpatialObj']);
            else
                self.GeoSpatialObj=s.GeoSpatialObj;
            end

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DActor(self);
            s.GeoSpatialObj=self.GeoSpatialObj;
            s.ModelName=self.ModelName;
        end
        function icon=getIconImpl(~)
            icon={'GeoSpatialConfiguration'};
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end

        function sz1=getOutputSizeImpl(~)
            sz1=[1,1];
        end

        function fz1=isOutputFixedSizeImpl(~)
            fz1=true;
        end

        function dt1=getOutputDataTypeImpl(~)
            dt1='double';
        end

        function cp1=isOutputComplexImpl(~)
            cp1=false;
        end
    end

    methods(Access=private)
        function geoSpatialConfiguration=setGeoSpatialConfig(self,geoSpatialConfiguration)
            geoSpatialConfiguration.OriginLatitude=self.OriginLatitude;
            geoSpatialConfiguration.OriginLongitude=self.OriginLongitude;
            geoSpatialConfiguration.OriginHeight=self.OriginHeight;
            geoSpatialConfiguration.UseAdvancedSunSky=self.UseAdvancedSunSky;
            geoSpatialConfiguration.TimeZone=self.TimeZone;
            geoSpatialConfiguration.SolarTime=self.SolarTime;
            geoSpatialConfiguration.Day=self.Day;
            geoSpatialConfiguration.Month=self.Month;
            geoSpatialConfiguration.Year=self.Year;
            geoSpatialConfiguration.UseDaylightSavingTime=self.UseDaylightSavingTime;
            geoSpatialConfiguration.DSTStartMonth=self.DSTStartMonth;
            geoSpatialConfiguration.DSTStartDay=self.DSTStartDay;
            geoSpatialConfiguration.DSTEndMonth=self.DSTEndMonth;
            geoSpatialConfiguration.DSTEndDay=self.DSTEndDay;
            geoSpatialConfiguration.DSTSwitchHour=self.DSTSwitchHour;
            geoSpatialConfiguration.Azimuth=self.Azimuth;
            geoSpatialConfiguration.Elevation=self.Elevation;
            geoSpatialConfiguration.MapStyle=self.MapStyle;
            geoSpatialConfiguration.AdditionalAssetIDs=self.AdditionalAssetIDs;
        end
    end
end

