classdef ActorTypes



    properties(Constant=true)
        PassVehicle='Sim3dPassVeh'
        PhysVehicle='Sim3dPhysVehicle'
        Pedestrian='Sim3dPedestrian'
        Bicyclist='Sim3dBicyclist'
        Motorcycle='Sim3dMotorcycle'
        Tractor='Sim3dTractor'
        Trailer='Sim3dTrailer'
        Dolly='Sim3dDolly'
        QuadRotorUAV='Sim3dQuadRotor'
        FixedWingUAV='Sim3dFixedWing'
        SkyHogg='Sim3dSkyHogg'
        MWAirliner='Sim3dMWAirliner'
        GeneralAviation='Sim3dGeneralAviation'
        AirTransport='Sim3dAirTransport'
        FixedWing='Sim3dAircraft'
        BaseStatic='Sim3dStaticMeshActor'
        BaseDynamic='Sim3dGenericActor'
        DeformableStatic=''
        DeformableDynamic=''
        SplineTrack='Sim3dRoadGen'
        Empty=''
        Custom=''
        TriggerVolume=''
        PostProcessVolume=''
        MainCamera='Sim3dMainCamera'
        IdealCamera='Sim3dSceneCap'
        Camera='Sim3dCamera'
        FisheyeCamera='Sim3dFisheyeCamera'
        Lidar='Sim3dLidar'
        Radar=''
        RadarGroundTruth='Sim3dTruthSensor'
        RangeSensor='Sim3dRangeSensor'
        Sonar=''
        DepthSensor='Sim3dDepth'
        VisionGroundTruth=''
        SemanticSegmentation='Sim3dSemantic'
        RayTraceSensor='Sim3dRayTraceSensor'
        TerrainSensor='Sim3dMultipointTerrainSensor'
        GroundTruth='Sim3dGroundTruth'
        WeatherController='Sim3dWeather'
        GeoSpatialActor='Sim3dGeoSpatial'
    end




end
