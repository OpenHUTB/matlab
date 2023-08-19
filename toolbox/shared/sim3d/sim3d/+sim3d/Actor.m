classdef Actor < sim3d.AbstractActor

    properties ( Hidden )
        Material( 1, 1 )sim3d.internal.MaterialAttributes;
        Physical( 1, 1 )sim3d.internal.PhysicalAttributes;
        DynamicMesh( 1, 1 )sim3d.internal.DynamicMeshAttributes;
        Selected( 1, 1 )logical = false;
        UpdateImpl = [  ];
        OutputImpl = [  ];
    end

    properties
        UserData = [  ];
    end

    properties ( Dependent )

        Faces;
        Vertices;
        Normals;
        TextureCoordinates;
        VertexColors;

        Color;
        Transparency;
        Shininess;
        Metallic;
        Flat;
        Tessellation;
        VertexBlend;
        Shadows;
        Texture;
        TextureMapping;
        TextureTransform;

        LinearVelocity;
        AngularVelocity;
        Mass;
        CenterOfMass;
        Gravity;
        Physics;
        Collisions;
        LocationLocked;
        RotationLocked
    end


    properties ( Dependent, Hidden )
        Inertia( 1, 3 )double;
        Force( 1, 3 )double;
        Torque( 1, 3 )double;
        ContinuousMovement( 1, 1 )logical;
        Friction( 1, 1 )double
        Restitution( 1, 1 )double;
        PreciseContacts( 1, 1 )logical;

        Masked( 1, 1 )logical;
        TwoSided( 1, 1 )logical;
        Refraction( 1, 1 )double;
        Hidden( 1, 1 )logical;
        ConstantAttributes( 1, 1 )logical;

    end


    properties ( Access = protected )
        GenericActorSubscriber = [  ];
    end


    methods

        function self = Actor( varargin )

            sim3d.World.validateLicense(  );

            r = sim3d.Actor.parseInputs( varargin{ : } );
            actorName = r.ActorName;
            self@sim3d.AbstractActor( actorName,  ...
                r.ParentActor,  ...
                single( r.Translation ),  ...
                single( r.Rotation ),  ...
                single( r.Scale ),  ...
                'ActorClassId', uint16( r.ActorClassId ),  ...
                'Mesh', r.Mesh,  ...
                'Mobility', r.Mobility,  ...
                'Visibility', r.Visibility,  ...
                'HiddenInGame', r.HiddenInGame,  ...
                'SimulatePhysics', r.SimulatePhysics,  ...
                'EnableGravity', r.EnableGravity,  ...
                'CastShadow', r.CastShadow ...
                );
            self.OutputImpl = r.Output;
            self.UpdateImpl = r.Update;
            self.Material = sim3d.internal.MaterialAttributes(  );
            self.DynamicMesh = sim3d.internal.DynamicMeshAttributes(  );
            self.Physical = sim3d.internal.PhysicalAttributes(  );
            self.Physical.Mobility = r.Mobility;
        end

    end


    methods ( Access = public, Hidden )

        function setup( self )
            setup@sim3d.AbstractActor( self );
            self.GenericActorSubscriber = sim3d.io.Subscriber( self.getTag(  ) );
        end

        function reset( self )
            reset@sim3d.AbstractActor( self );
            self.write(  );
        end

        function output( self )
            if ~isempty( self.OutputImpl )
                self.OutputImpl( self );
            end
            self.write(  );
        end

        function update( self )
            if ~isempty( self.UpdateImpl )
                self.UpdateImpl( self );
            end
        end

        function actorType = getActorType( ~ )

            actorType = sim3d.utils.ActorTypes.BaseDynamic;
        end

        function actorS = getAttributes( self )
            actorS.Base = getAttributes@sim3d.AbstractActor( self );
            actorS.DynamicMesh = self.DynamicMesh.getAttributes(  );
            actorS.Material = self.Material.getAttributes(  );
            actorS.Physical = self.Physical.getAttributes(  );
            actorS.Selected = self.Selected;

        end

        function setAttributes( self, actorS )
            setAttributes@sim3d.AbstractActor( self, actorS.Base );
            self.DynamicMesh.setAttributes( actorS.DynamicMesh );
            self.Material.setAttributes( actorS.Material );
            self.Physical.setAttributes( actorS.Physical );
            self.Selected = actorS.Selected;
        end

        function translation = getTranslation( self )
            [ translation, ~, ~ ] = self.readTransform(  );
            if ~isempty( translation )
                self.Transform.setTranslation( translation );
            else
                translation = self.Transform.getTranslation(  );
            end
        end

        function rotation = getRotation( self )
            [ ~, rotation, ~ ] = self.readTransform(  );
            if ~isempty( rotation )
                self.Transform.setRotation( rotation );
            else
                rotation = self.Transform.getRotation(  );
            end
        end

        function scale = getScale( self )
            [ ~, ~, scale ] = self.readTransform(  );
            if ~isempty( scale )
                self.Transform.setScale( scale );
            else
                scale = self.Transform.getScale(  );
            end
        end

        function [ translation, rotation, scale ] = readTransform( self )

            if ~isempty( self.TransformReader )
                [ translation, rotation, scale ] = self.TransformReader.read(  );
            else
                translation = [  ];
                rotation = [  ];
                scale = [  ];
            end
        end

        function rotateAround( objs, Axis, Angle, Incremental )

            R36
            objs( 1, : )sim3d.Actor
            Axis( 1, 3 )double
            Angle( 1, 1 )double
            Incremental( 1, 1 )logical = true
        end

        for obj = objs

            Axis = sim3d.utils.Math.posToUnreal( Axis, 'vrml' );
            Ra = sim3d.utils.Math.mat2unr( sim3d.utils.Math.rotAA( Axis, Angle ) );
            if Incremental
                Ru = sim3d.utils.Math.rot321( obj.Rotation );
                obj.Rotation = sim3d.utils.Math.decomp321( Ra * Ru );
            else
                obj.Rotation = sim3d.utils.Math.decomp321( Ra );
            end
        end
    end

end


methods ( Access = protected )

function createGameActor( self )

if ~isempty( self.ParentWorld ) && self.ParentWorld.IsMockWorld(  )
    self.CreateActor = MockUnrealActor( self );
else
    createGameActor@sim3d.AbstractActor( self );
end
self.DynamicMesh.setup( self.Name );
self.Material.setup( self.Name );
self.Physical.setup( self.Name );
end

function write( self )

self.DynamicMesh.publish(  );
self.Material.publish(  );
self.Physical.publish(  );
end

end

methods


function delete( self )

delete@sim3d.AbstractActor( self );
if ~isempty( self.GenericActorSubscriber )
    self.GenericActorSubscriber = [  ];
end
end

function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.Actor
other( 1, 1 )sim3d.Actor
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end


self.DynamicMesh.copy( other.DynamicMesh );
self.Physical.copy( other.Physical );
self.Material.copy( other.Material );


self.Selected = other.Selected;


copy@sim3d.AbstractActor( self, other, CopyChildren, UseSourcePosition );

end

function createShape( objs, Type, varargin )

R36
objs( 1, : )sim3d.Actor
Type( 1, : )char
end
R36( Repeating )
varargin
end

for obj = objs
    Type = lower( Type );
    if any( contains( sim3d.utils.Geometry.AvailablePrimitives, Type ) )
        [ V, N, F, T, C ] = sim3d.utils.Geometry.( Type )( varargin{ : } );
        obj.createMesh( V, N, F, T, C );
    else
        error( message( 'shared_sim3d:sim3dActor:methodnotfound', Type, 'sim3d.utils.Geometry' ) );
    end
end
end

function createMesh( self, Vertices, Normals, Faces, TCoords, VColors )

R36
self( 1, : )sim3d.Actor
Vertices( :, 3 )double
Normals( :, 3 )double
Faces( :, 3 )double
TCoords( :, 2 )double = [  ]
VColors( :, 3 )double = [  ]
end

self.DynamicMesh.createMesh( Vertices, Normals, Faces, TCoords, VColors );
self.DynamicMesh.IsValid = true;
end


function addMesh( self, Vertices, Normals, Faces, TCoords, VColors )

R36
self( 1, : )sim3d.Actor
Vertices( :, 3 )double
Normals( :, 3 )double
Faces( :, 3 )double
TCoords( :, 2 )double = [  ]
VColors( :, 3 )double = [  ]
end

self.DynamicMesh.addMesh( Vertices, Normals, Faces, TCoords, VColors );
self.DynamicMesh.IsValid = true;
end

function load( objs, Source, varargin )

for obj = objs
    if ischar( Source ) || isstring( Source )
        Source = strtrim( char( Source ) );
        if isfile( Source )
            resolvedSource = Source;
        else
            resolvedSource = which( Source );
        end
        if isfile( resolvedSource )
            [ ~, ~, ext ] = fileparts( resolvedSource );
            if isempty( obj.ParentWorld ) && ( strcmpi( ext, '.f3d' ) ...
                    || strcmpi( ext, '.mat' ) ...
                    || strcmpi( ext, '.fbx' ) )
                error( message( 'shared_sim3d:sim3dActor:LoadNotSupported', obj.getTag(  ) ) );
            end
            switch lower( ext )
                case '.f3d'
                    sim3d.utils.Impex.importFromF3DFile( obj, resolvedSource, varargin{ : } );
                case '.mat'
                    sim3d.utils.Impex.importFromMATFile( obj, resolvedSource );
                case '.stl'
                    sim3d.utils.Impex.importSTL( obj, resolvedSource, varargin{ : } );
                case { '.fbx', '.dae', '.sdf', '.urdf' }
                    wst = warning( 'off', 'sl3d:interface:engineerr' );
                    wcl = onCleanup( @(  )warning( wst ) );
                    [ ~, w ] = vrimport( resolvedSource, 'solid', strcmpi( ext, '.fbx' ) );
                    clear( 'wcl' );
                    sim3d.utils.Impex.importX3D( obj, w, varargin{ : } );
                case { '.wrl', '.x3d', '.x3dv' }
                    sim3d.utils.Impex.importX3D( obj, resolvedSource, varargin{ : } );
                otherwise
                    error( message( 'shared_sim3d:sim3dActor:UnsupportedFileImport', resolvedSource ) );
            end
        else
            error( message( 'shared_sim3d:sim3dActor:FileNotFound', Source ) );
        end
    elseif isobject( Source )
        switch class( Source )
            case 'matlab.graphics.primitive.Patch'
                sim3d.utils.Impex.importPatch( obj, Source, varargin{ : } );
            case 'matlab.graphics.chart.primitive.Surface'
                sim3d.utils.Impex.importSurf( obj, Source, varargin{ : } );
            case 'rigidBodyTree'
                sim3d.utils.Impex.importRBT( obj, Source, varargin{ : } );
            otherwise
                error( message( 'shared_sim3d:sim3dActor:UnsupportedClassImport', class( Source ) ) );
        end
    end
end
end


function save( objs, FileName )

isMultiple = numel( objs ) > 1;
for obj = objs

    [ dir, file, ext ] = fileparts( char( FileName ) );
    if isempty( ext )
        ext = '.mat';
    end
    if isMultiple
        fileName = [ fullfile( dir, file ), '_', obj.Name, ext ];
    else
        fileName = [ fullfile( dir, file ), ext ];
    end

    switch lower( ext )
        case '.mat'
            sim3d.utils.Impex.exportToMATFile( obj, fileName );
        otherwise
            error( message( 'shared_sim3d:sim3dActor:UnsupportedFileExport', FileName ) );
    end
end
end


function propagate( self, PropName, PropValue, Condition )

R36
self( 1, : )sim3d.AbstractActor
PropName( 1, : )char
PropValue
Condition{ mustBeMember( Condition, { 'all', 'children', 'selected', 'unselected' } ) } = 'all'
end
propagate@sim3d.AbstractActor( self, PropName, PropValue, Condition );
end


function Result = gather( self, PropName, IncludeChildren )

R36
self( 1, 1 )sim3d.AbstractActor
PropName
IncludeChildren( 1, 1 )logical = true
end
Result = gather@sim3d.AbstractActor( self, PropName, IncludeChildren );
end
end


methods

function faces = get.Faces( self )
faces = self.DynamicMesh.Faces;
end

function set.Faces( self, faces )
self.DynamicMesh.Faces = faces;
end

function vertices = get.Vertices( self )
vertices = self.DynamicMesh.Vertices;
end

function set.Vertices( self, vertices )
self.DynamicMesh.Vertices = vertices;
end

function normals = get.Normals( self )
normals = self.DynamicMesh.Normals;
end

function set.Normals( self, normals )
self.DynamicMesh.Normals = normals;
end

function textureCoordinates = get.TextureCoordinates( self )
textureCoordinates = self.DynamicMesh.TextureCoordinates;
end

function set.TextureCoordinates( self, textureCoordinates )
self.DynamicMesh.TextureCoordinates = textureCoordinates;
end

function vertexColors = get.VertexColors( self )
vertexColors = self.DynamicMesh.VertexColors;
end

function set.VertexColors( self, vertexColors )
self.DynamicMesh.VertexColors = vertexColors;
end



function color = get.Color( self )
color = self.Material.Color;
end

function set.Color( self, color )
self.Material.Color = color;
end

function masked = get.Masked( self )
masked = self.Material.Masked;
end

function set.Masked( self, masked )
self.Material.Masked = masked;
end

function transparency = get.Transparency( self )
transparency = self.Material.Transparency;
end

function set.Transparency( self, transparency )
self.Material.Transparency = transparency;
end

function twoSided = get.TwoSided( self )
twoSided = self.Material.TwoSided;
end

function set.TwoSided( self, twoSided )
self.Material.TwoSided = twoSided;
end

function set.Texture( self, texture )

self.Material.Texture = texture;

end

function texture = get.Texture( self )
texture = self.Material.Texture;
end

function shininess = get.Shininess( self )
shininess = self.Material.Shininess;
end

function set.Shininess( self, shininess )
self.Material.Shininess = shininess;
end

function textureMapping = get.TextureMapping( self )
textureMapping = self.Material.TextureMapping;
end

function set.TextureMapping( self, textureMapping )

self.Material.TextureMapping = textureMapping;
end

function textureTransform = get.TextureTransform( self )
textureTransform = self.Material.TextureTransform;
end

function set.TextureTransform( self, textureTransform )
self.Material.TextureTransform = textureTransform;
end

function metallic = get.Metallic( self )
metallic = self.Material.Metallic;
end

function set.Metallic( self, metallic )
self.Material.Metallic = metallic;
end

function refraction = get.Refraction( self )
refraction = self.Material.Refraction;
end

function set.Refraction( self, refraction )
self.Material.Refraction = refraction;
end

function flat = get.Flat( self )
flat = self.Material.Flat;
end

function set.Flat( self, flat )
self.Material.Flat = flat;
end

function tessellation = get.Tessellation( self )
tessellation = self.Material.Tessellation;
end

function set.Tessellation( self, tessellation )
self.Material.Tessellation = tessellation;
end

function vertexBlend = get.VertexBlend( self )
vertexBlend = self.Material.VertexBlend;
end

function set.VertexBlend( self, vertexBlend )
self.Material.VertexBlend = vertexBlend;
end

function shadows = get.Shadows( self )
shadows = self.Material.Shadows;
end

function set.Shadows( self, shadows )
self.Material.Shadows = shadows;
end


function linearVelocity = get.LinearVelocity( self )
linearVelocity = self.Physical.LinearVelocity;
end

function set.LinearVelocity( self, linearVelocity )
self.Physical.LinearVelocity = linearVelocity;
end

function angularVelocity = get.AngularVelocity( self )
angularVelocity = self.Physical.AngularVelocity;
end

function set.AngularVelocity( self, angularVelocity )
self.Physical.AngularVelocity = angularVelocity;
end

function mass = get.Mass( self )
mass = self.Physical.Mass;
end

function set.Mass( self, mass )
self.Physical.Mass = mass;
end

function inertia = get.Inertia( self )
inertia = self.Physical.Inertia;
end

function set.Inertia( self, inertia )
self.Physical.Inertia = inertia;
end

function force = get.Force( self )
force = self.Physical.Force;
end

function set.Force( self, force )
self.Physical.Force = force;
end

function torque = get.Torque( self )
torque = self.Physical.Torque;
end

function set.Torque( self, torque )
self.Physical.Torque = torque;
end

function CenterOfMass = get.CenterOfMass( self )
CenterOfMass = self.Physical.CenterOfMass;
end

function set.CenterOfMass( self, CenterOfMass )
self.Physical.CenterOfMass = CenterOfMass;
end

function gravity = get.Gravity( self )
gravity = self.Physical.Gravity;
end

function set.Gravity( self, gravity )
self.Physical.Gravity = gravity;
end

function physics = get.Physics( self )
physics = self.Physical.Physics;
end

function set.Physics( self, physics )
self.propagatePhysicsIfEmpty( physics );
end

function continuousMovement = get.ContinuousMovement( self )
continuousMovement = self.Physical.ContinuousMovement;
end

function set.ContinuousMovement( self, continuousMovement )
self.Physical.ContinuousMovement = continuousMovement;
end

function friction = get.Friction( self )
friction = self.Physical.Friction;
end

function set.Friction( self, friction )
self.Physical.Friction = friction;
end

function restitution = get.Restitution( self )
restitution = self.Physical.Restitution;
end

function set.Restitution( self, restitution )
self.Physical.Restitution = restitution;
end

function preciseContacts = get.PreciseContacts( self )
preciseContacts = self.Physical.PreciseContacts;
end

function set.PreciseContacts( self, preciseContacts )
self.Physical.PreciseContacts = preciseContacts;
end

function collisions = get.Collisions( self )
collisions = self.Physical.Collisions;
end

function set.Collisions( self, collisions )
self.propagateCollisionsIfEmpty( collisions );
end

function locationLocked = get.LocationLocked( self )
locationLocked = self.Physical.LocationLocked;
end

function set.LocationLocked( self, locationLocked )
self.Physical.LocationLocked = locationLocked;
end

function rotationLocked = get.RotationLocked( self )
rotationLocked = self.Physical.RotationLocked;
end

function set.RotationLocked( self, rotationLocked )
self.Physical.RotationLocked = rotationLocked;
end

function set.Hidden( self, hidden )
self.Physical.Hidden = hidden;
end

function hidden = get.Hidden( self )
hidden = self.Physical.Hidden;
end

function constantAttributes = get.ConstantAttributes( self )
constantAttributes = self.Physical.ConstantAttributes;
end

function set.ConstantAttributes( self, constantAttributes )
self.Physical.ConstantAttributes = constantAttributes;
end

function setGenericActorMobility( self, mobility )
self.Physical.Mobility = mobility;
end
end


methods ( Access = private )

function propagatePhysicsIfEmpty( self, physics )
self.Physical.Physics = physics;
if ~isempty( self.Children ) && isempty( self.Vertices )
    childList = struct2cell( self.Children );
    for i = 1:numel( childList )
        childList{ i }.propagatePhysicsIfEmpty( physics );
    end
end
end

function propagateCollisionsIfEmpty( self, collisions )
self.Physical.Collisions = collisions;
if ~isempty( self.Children ) && isempty( self.Vertices )
    childList = struct2cell( self.Children );
    for i = 1:numel( childList )
        childList{ i }.propagateCollisionsIfEmpty( collisions );
    end
end
end
end


methods ( Access = private, Static )

function r = parseInputs( varargin )

defaultParams = struct(  ...
    'Translation', single( zeros( 1, 3 ) ),  ...
    'Rotation', single( zeros( 1, 3 ) ),  ...
    'Scale', single( ones( 1, 3 ) ),  ...
    'ParentActor', 'Scene Origin',  ...
    'ActorName', '',  ...
    'Mesh', '',  ...
    'ActorClassId', uint16( sim3d.utils.SemanticType.None ),  ...
    'Mobility', int32( sim3d.utils.MobilityTypes.Static ),  ...
    'Visibility', true,  ...
    'HiddenInGame', false,  ...
    'SimulatePhysics', false,  ...
    'EnableGravity', true,  ...
    'CastShadow', false,  ...
    'Output', [  ],  ...
    'Update', [  ] );


parser = inputParser;
parser.addParameter( 'Translation', defaultParams.Translation );
parser.addParameter( 'Rotation', defaultParams.Rotation );
parser.addParameter( 'Scale', defaultParams.Scale );
parser.addParameter( 'ParentActor', defaultParams.ParentActor );
parser.addParameter( 'ActorName', defaultParams.ActorName );
parser.addParameter( 'Mesh', defaultParams.Mesh );
parser.addParameter( 'ActorClassId', defaultParams.ActorClassId );
parser.addParameter( 'Mobility', defaultParams.Mobility );
parser.addParameter( 'Visibility', defaultParams.Visibility );
parser.addParameter( 'HiddenInGame', defaultParams.HiddenInGame );
parser.addParameter( 'SimulatePhysics', defaultParams.SimulatePhysics );
parser.addParameter( 'EnableGravity', defaultParams.EnableGravity );
parser.addParameter( 'CastShadow', defaultParams.CastShadow );
parser.addParameter( "Output", defaultParams.Output );
parser.addParameter( "Update", defaultParams.Update );


parser.parse( varargin{ : } );
r = parser.Results;
end
end

end

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2JkFdH.p.
% Please follow local copyright laws when handling this file.

