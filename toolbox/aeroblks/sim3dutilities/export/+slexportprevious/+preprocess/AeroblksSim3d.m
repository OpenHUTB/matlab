function AeroblksSim3d( obj )

if isR2022aOrEarlier( obj.ver )
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<Mesh|"Sky Hogg":repval SkyHogg>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<MeshPathAT:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<MeshPathGA:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<CustomLeftLandingLightLocation:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<CustomLeftLandingLightOrientation:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<CustomRightLandingLightLocation:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<CustomRightLandingLightOrientation:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<CustomTaxiLightLocation:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<CustomTaxiLightOrientation:remove>>>' );
end


if isR2021bOrEarlier( obj.ver )
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<MeshPath:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<LightsConfig:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<LandingLightIntensity:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<LandingLightConeAngle:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<TaxiLightIntensity:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<TaxiLightConeAngle:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<NavLightIntensity:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<PositionLightIntensity:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<StrobeLightIntensity:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<WingtipStrobePeriod:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<WingtipStrobePulseWidth:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<TailStrobePeriod:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<TailStrobePulseWidth:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<BeaconLightIntensity:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<BeaconPeriod:remove>>>' );
    obj.appendRule( '<Block<BlockType|"Reference"><SourceBlock|"aerolibsim3d/Simulation 3D Aircraft"><InstanceData<BeaconPulseWidth:remove>>>' );
end


if isR2021aOrEarlier( obj.ver )
    scenesBlk = locFindBlock( obj.modelName, 'ReferenceBlock', 'sim3dlib/Simulation 3D Scene Configuration' );
    cameraBlk = locFindBlock( obj.modelName, 'ReferenceBlock', 'sim3dlib/Simulation 3D Camera Get' );
    msgSetBlk = locFindBlock( obj.modelName, 'ReferenceBlock', 'sim3dlib/Simulation 3D Message Set' );
    msgGetBlk = locFindBlock( obj.modelName, 'ReferenceBlock', 'sim3dlib/Simulation 3D Message Get' );
    actSetBlk = locFindBlock( obj.modelName, 'ReferenceBlock', 'sim3dlib/Simulation 3D Actor Transform Set' );
    actGetBlk = locFindBlock( obj.modelName, 'ReferenceBlock', 'sim3dlib/Simulation 3D Actor Transform Get' );
    sharedBlks = [ scenesBlk', cameraBlk', msgSetBlk', msgGetBlk', actSetBlk', actGetBlk' ];
    if ~isempty( sharedBlks )
        for i = 1:length( sharedBlks )
            amode = get_param( sharedBlks{ i }, 'aMode' );
            if strcmp( amode, '0' )
                obj.replaceWithEmptySubsystem( sharedBlks{ i } );
            end
        end
    end
end

end

function foundBlocks = locFindBlock( modelName, varargin )

arguments
    modelName( 1, 1 )string
end
arguments( Repeating )
    varargin
end

foundBlocks = find_system( modelName,  ...
    'LookUnderMasks', 'on',  ...
    'MatchFilter', @Simulink.match.allVariants,  ...
    'IncludeCommented', 'on',  ...
    varargin{ : } );
end



