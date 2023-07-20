classdef AttachedAsset<matlabshared.satellitescenario.internal.Asset %#codegen





    properties(Dependent)






MountingLocation










MountingAngles
    end

    properties(Hidden,Dependent,SetAccess=...
        {?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AssetWrapper})
Position
PositionHistory
Velocity
VelocityHistory
Attitude
AttitudeHistory
    end

    properties(Hidden,SetAccess={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.Access,...
        ?satcom.satellitescenario.internal.Link})



Parent
    end

    properties(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.Asset})
        ParentSimulatorID=0
        ParentType=0
    end

    properties(Hidden)
        VisibilityMode{mustBeMember(VisibilityMode,{'inherit','manual'})}='inherit'
    end

    properties(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.ScenarioGraphic,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAssetWrapper,...
        ?matlabshared.satellitescenario.ConicalSensor,?matlabshared.satellitescenario.internal.Gimbal,...
        ?satcom.satellitescenario.Transmitter,...
        ?satcom.satellitescenario.Receiver})
Graphic
    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAssetWrapper,...
        ?matlabshared.satellitescenario.ConicalSensor,?matlabshared.satellitescenario.internal.Gimbal,...
        ?satcom.satellitescenario.Transmitter,...
        ?satcom.satellitescenario.Receiver})
pMarkerColor
        pMarkerSize=5
    end

    methods
        function mountingLocation=get.MountingLocation(asset)


            coder.allowpcode('plain');

            simulator=asset.Simulator;
            assetIdx=getIdxInSimulatorStruct(asset);
            switch asset.Type
            case 3
                mountingLocation=...
                simulator.ConicalSensors(assetIdx).MountingLocation;
            case 4
                mountingLocation=...
                simulator.Gimbals(assetIdx).MountingLocation;
            case 5
                mountingLocation=...
                simulator.Transmitters(assetIdx).MountingLocation;
            otherwise
                mountingLocation=...
                simulator.Receivers(assetIdx).MountingLocation;
            end
        end

        function set.MountingLocation(asset,mountingLocation)


            coder.allowpcode('plain');


            validateattributes(mountingLocation,{'double'},...
            {'nonempty','vector','numel',3,'real','finite'},...
            'set.MountingLocation','MountingLocation');


            simulator=asset.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
            'shared_orbit:orbitPropagator:UnablePropertySetIncorrectSimStatus',...
            'MountingLocation');


            assetIdx=getIdxInSimulatorStruct(asset);
            assetType=asset.Type;
            switch assetType
            case 3
                originalMountingLocation=...
                simulator.ConicalSensors(assetIdx).MountingLocation;
            case 4
                originalMountingLocation=...
                simulator.Gimbals(assetIdx).MountingLocation;
            case 5
                originalMountingLocation=...
                simulator.Transmitters(assetIdx).MountingLocation;
            otherwise
                originalMountingLocation=...
                simulator.Receivers(assetIdx).MountingLocation;
            end



            if~isequal(originalMountingLocation,mountingLocation)
                switch assetType
                case 3
                    simulator.ConicalSensors(assetIdx).MountingLocation=...
                    reshape(mountingLocation,3,1);
                case 4
                    simulator.Gimbals(assetIdx).MountingLocation=...
                    reshape(mountingLocation,3,1);
                case 5
                    simulator.Transmitters(assetIdx).MountingLocation=...
                    reshape(mountingLocation,3,1);
                otherwise
                    simulator.Receivers(assetIdx).MountingLocation=...
                    reshape(mountingLocation,3,1);
                end


                advance(simulator,simulator.Time);



                simulator.NeedToSimulate=true;



                if simulator.SimulationMode==1
                    updateStateHistory(simulator,true);
                end

                if coder.target('MATLAB')&&isa(asset.Scenario,'satelliteScenario')
                    asset.Scenario.NeedToSimulate=true;
                    updateViewers(asset,asset.Scenario.Viewers,false,true);
                end
            end
        end

        function mountingAngles=get.MountingAngles(asset)


            coder.allowpcode('plain');

            simulator=asset.Simulator;
            assetIdx=getIdxInSimulatorStruct(asset);

            switch asset.Type
            case 3
                mountingAngles=...
                simulator.ConicalSensors(assetIdx).MountingAngles;
            case 4
                mountingAngles=...
                simulator.Gimbals(assetIdx).MountingAngles;
            case 5
                mountingAngles=...
                simulator.Transmitters(assetIdx).MountingAngles;
            otherwise
                mountingAngles=...
                simulator.Receivers(assetIdx).MountingAngles;
            end
        end

        function set.MountingAngles(asset,mountingAngles)


            coder.allowpcode('plain');


            validateattributes(mountingAngles,{'double'},...
            {'nonempty','vector','numel',3,'real','finite'},...
            'set.MountingAngles','MountingAngles');


            simulator=asset.Simulator;


            coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
            'shared_orbit:orbitPropagator:UnablePropertySetIncorrectSimStatus',...
            'MountingAngles');


            assetIdx=getIdxInSimulatorStruct(asset);
            assetType=asset.Type;
            switch assetType
            case 3
                originalMountingAngles=...
                simulator.ConicalSensors(assetIdx).MountingAngles;
            case 4
                originalMountingAngles=...
                simulator.Gimbals(assetIdx).MountingAngles;
            case 5
                originalMountingAngles=...
                simulator.Transmitters(assetIdx).MountingAngles;
            otherwise
                originalMountingAngles=...
                simulator.Receivers(assetIdx).MountingAngles;
            end



            if~isequal(originalMountingAngles,mountingAngles)
                switch assetType
                case 3
                    simulator.ConicalSensors(assetIdx).MountingAngles=reshape(mountingAngles,3,1);
                case 4
                    simulator.Gimbals(assetIdx).MountingAngles=reshape(mountingAngles,3,1);
                case 5
                    simulator.Transmitters(assetIdx).MountingAngles=reshape(mountingAngles,3,1);
                otherwise
                    simulator.Receivers(assetIdx).MountingAngles=reshape(mountingAngles,3,1);
                end


                advance(simulator,simulator.Time);



                simulator.NeedToSimulate=true;



                if simulator.SimulationMode==1
                    updateStateHistory(simulator,true);
                end

                if coder.target('MATLAB')&&isa(asset.Scenario,'satelliteScenario')
                    asset.Scenario.NeedToSimulate=true;
                    updateViewers(asset,asset.Scenario.Viewers,false,true);
                end
            end
        end

        function p=get.Position(asset)


            coder.allowpcode('plain');

            p=asset.pPosition;
        end

        function p=get.PositionHistory(asset)


            coder.allowpcode('plain');

            p=asset.pPositionHistory;
        end

        function p=get.Velocity(asset)


            coder.allowpcode('plain');

            p=asset.pVelocity;
        end

        function p=get.VelocityHistory(asset)


            coder.allowpcode('plain');

            p=asset.pVelocityHistory;
        end

        function p=get.Attitude(asset)


            coder.allowpcode('plain');

            p=asset.pAttitude;
        end

        function p=get.AttitudeHistory(asset)


            coder.allowpcode('plain');

            p=asset.pAttitudeHistory;
        end
    end

    methods(Static,Access={?matlabshared.satellitescenario.internal.Simulator})
        [positionITRF,positionGeographic,attitude,...
        itrf2BodyTransform]=getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransform,...
        parentPositionITRF,parentNed2BodyTransform)
        [positionITRF,positionGeographic,attitude,...
        itrf2BodyTransform]=cg_getPositionAndOrientation(...
        mountingLocation,mountingAngles,parentItrf2BodyTransform,...
        parentPositionITRF,parentNed2BodyTransform)
    end
end

