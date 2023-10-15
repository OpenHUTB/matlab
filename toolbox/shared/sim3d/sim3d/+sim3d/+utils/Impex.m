classdef Impex < handle

    methods ( Static )

        function exportToMATFile( inActor, FileName )
            Actors = inActor.exportAsStruct();

            World = inActor.ParentWorld;
            Textures = World.exportTexture();

            Info.Version = 20220315;
            Info.Date = datetime;
            Info.Author = getenv( 'username' );

            if ~isempty( FileName )
                save( FileName, '-mat', 'Info', 'Actors', 'Textures' );
            end
        end


        function importFromMATFile( Actor, FileName )

            data = load( FileName, '-mat' );
            if ~sim3d.utils.Impex.checkSim3dActorStruct( data )
                error( message( 'shared_sim3d:sim3dActor:UnsupportedFileImport', FileName ) );
            end
            World = Actor.ParentWorld;
            if ( isfield( data, 'Textures' ) )

                textureMap = World.importTexture( data.Textures );
            end

            Actor.importFromStruct( data.Actors );
            children = fieldnames( World.Actors );
            for idx = 1:numel( children )
                a = World.Actors.( children{ idx } );
                if ( isa( a, 'sim3d.Actor' ) && isfield( textureMap, a.Texture ) )

                    a.Texture = data.Textures.( a.Texture ).Data;
                end
            end
        end


        function importFromF3DFile( Actor, FileName, Scale, Model, textureNameMap )
            if nargin < 4

                data = load( FileName, '-mat' );
                if ~sim3d.utils.Impex.checkSim3dActorStruct( data )
                    error( message( 'shared_sim3d:sim3dActor:UnsupportedFileImport', FileName ) );
                end
                Model = data.Actors;
                World = Actor.ParentWorld;
                textureNameMap = [  ];
                if ~isempty( data.Textures )

                    newTextures = fieldnames( data.Textures );
                    for idx = 1:numel( newTextures )
                        textureName = World.addTexture( data.Textures.( newTextures{ idx } ), newTextures{ idx } );
                        textureNameMap.( newTextures{ idx } ) = textureName;
                    end
                end
            end
            if nargin < 3
                Scale = 1;
            end

            if ( Model.ActorID >  - 1 ) && ~( strcmp( Model.Name, 'DefaultViewpoint' ) && ~isa( Actor, 'sim3d.internal.RootObject' ) )

                nName = sim3d.utils.Impex.fixName( Model.Name );
                NewActor = sim3d.Actor( 'ActorName', nName );
                NewActor.Parent = Actor;
                NewActor.ParentWorld = Actor.ParentWorld;
                Fields = fieldnames( Model );
                Fields = Fields( ~ismember( Fields, { 'ActorID', 'Children', 'Name', 'States', 'Tag', 'TheInertia',  ...
                    'Light', 'ViewpointName', 'TheViewpointLocation', 'TheViewpointRotation' } ) );
                OtherFields = { 'TextureTransform', 'TextureMapping' };
                for i = 1:numel( Fields )
                    fieldName = Fields{ i };
                    if ( isprop( NewActor, fieldName ) && ~any( contains( OtherFields, fieldName ) ) )
                        NewActor.( fieldName ) = Model.( fieldName );
                    else
                        switch fieldName
                            case 'VertColors'
                                NewActor.VertexColors = Model.VertColors;
                            case 'TexCoords'
                                NewActor.TextureCoordinates = Model.TexCoords;
                            case 'TheVertices'
                                NewActor.Vertices = Model.TheVertices * 0.01;
                            case 'TheNormals'
                                NewActor.Normals = Model.TheNormals;
                            case 'TheLocation'
                                NewActor.Translation = Model.TheLocation .* 0.01;
                            case 'TheRotation'
                                NewActor.Rotation = deg2rad( Model.TheRotation );
                            case 'TheFaces'
                                NewActor.Faces = Model.TheFaces;
                            case 'TheLinearVelocity'
                                NewActor.LinearVelocity = Model.TheLinearVelocity .* Scale;
                            case 'TheAngularVelocity'
                                NewActor.AngularVelocity = Model.TheAngularVelocity;
                            case 'TheMass'
                                NewActor.Mass = Model.TheMass;
                            case 'TheForce'
                                NewActor.Force = Model.TheForce;
                            case 'TheTorque'
                                NewActor.Torque = Model.TheTorque;
                            case 'TheCenterOfMass'
                                NewActor.CenterOfMass = Model.TheCenterOfMass;
                            case 'TheTextureFile'
                                FileName = Model.TheTextureFile;
                                oldTextureName = matlab.lang.makeValidName( FileName( max( end  - 31, 1 ):end  ) );
                                if ( isfield( textureNameMap, oldTextureName ) )
                                    w = NewActor.ParentWorld;
                                    textureData = w.getTextureData( textureNameMap.( oldTextureName ) );
                                    NewActor.Texture = textureData;
                                end
                            case 'TextureMapping'
                                NewActor.TextureMapping.Blend = Model.TextureMapping.Blend;
                                NewActor.TextureMapping.Displacement = Model.TextureMapping.Displacement;
                                NewActor.TextureMapping.Bumps = Model.TextureMapping.Bumps;
                                NewActor.TextureMapping.Roughness = Model.TextureMapping.Roughness;
                            case 'TextureTransform'
                                NewActor.TextureTransform.Position = Model.TextureTransform.Position;
                                NewActor.TextureTransform.Velocity = Model.TextureTransform.Velocity;
                                NewActor.TextureTransform.Scale = Model.TextureTransform.Scale;
                                NewActor.TextureTransform.Angle = Model.TextureTransform.Angle;

                            otherwise
                                warning( message( 'shared_sim3d:sim3dActor:MissingPropertyForImport', fieldName ) );
                        end
                    end
                end
            else
                NewActor = Actor;
            end

            if ~isempty( Model.Children )
                children = struct2cell( Model.Children );
                for i = 1:numel( children )
                    sim3d.utils.Impex.importFromF3DFile( NewActor, '', Scale, children{ i }, textureNameMap );
                end
            end

            States = NewActor.getSnapshotStates(  );

            for j = 1:size( States, 1 )
                data = States{ j, 4 };
                for k = 1:size( data, 1 )
                    data{ k, 1 } = NewActor.ParentActor.findBy( 'Name', data{ k, 1 }, 'first' );
                end
                States{ j, 4 } = data;
            end
            if ~isempty( States )
                NewActor.setSnapshotState( States );
            end

        end


        function importSurf( Actor, S, Scale )
            arguments
                Actor( 1, 1 )sim3d.Actor
                S( 1, 1 )matlab.graphics.chart.primitive.Surface
                Scale( 1, 3 )double = [ 1, 1, 1 ]
            end

            [ V, N, F, T ] = sim3d.utils.Geometry.surf( S.XData, S.YData, S.ZData );

            if isequal( size( S.CData ), size( S.XData ) )
                cmap = colormap;
                cmin = min( S.CData( : ) );
                cmax = max( S.CData( : ) );
                Ci = fix( ( S.CData - cmin ) / ( cmax - cmin ) * length( cmap ) ) + 1;
                Ci = Ci( : );
                C = zeros( size( V ) );
                for i = 1:length( C )
                    [ r, g, b ] = ind2rgb( Ci( i ), cmap );
                    C( i, : ) = [ r, g, b ];
                end

                Actor.createMesh( V .* Scale, N, F, T, C );
                Actor.VertexBlend = 1;
                Actor.TwoSided = true;
            else
                Actor.createMesh( V .* Scale, N, F, T );
                Actor.VertexBlend = 0;
                Actor.TwoSided = true;
            end
        end


        function importPatch( Actor, P, Scale )
            arguments
                Actor( 1, 1 )sim3d.Actor
                P( 1, 1 )matlab.graphics.primitive.Patch
                Scale( 1, 3 )double = [ 1, 1, 1 ]
            end

            V = P.Vertices;
            N = V;
            if size( P.Vertices, 2 ) == 2

                V( end , 3 ) = 0;
                N = zeros( size( V ) );
                N( :, 3 ) = 1;
            end

            FaceLen = size( P.Faces, 2 );
            F = [  ];
            for i = 3:FaceLen
                f = P.Faces( :, [ 1, i, i - 1 ] ) - 1;
                F = vertcat( F, f );%#ok<AGROW> source face count may vary
            end

            if size( P.CData, 1 ) == FaceLen

                if ndims( P.CData ) == 3
                    if numel( P.CData ) == numel( V )

                        C = reshape( P.CData, size( V ) );
                    else
                        C = [  ];
                    end
                else

                    cmap = colormap;
                    cmin = min( P.CData( : ) );
                    cmax = max( P.CData( : ) );
                    Ci = fix( ( P.CData' - cmin ) / ( cmax - cmin ) * length( cmap ) ) + 1;
                    C = zeros( size( V ) );
                    for i = 1:size( P.Faces, 1 )
                        vid = P.Faces( i, : );
                        [ r, g, b ] = ind2rgb( Ci( i, 1:FaceLen ), cmap );
                        C( vid( 1:FaceLen ), : ) = [ r', g', b' ];
                    end
                end
                Actor.createMesh( V .* Scale, N, F, [  ], C );
                Actor.TwoSided = true;
                Actor.VertexBlend = 1;
            else

                Actor.createMesh( V .* Scale, N, F );
                Actor.TwoSided = true;
            end
        end


        function importRBT( Actor, RBT, Scale )
            arguments
                Actor( 1, 1 )sim3d.Actor
                RBT( 1, 1 )rigidBodyTree
                Scale( 1, 3 )double = [ 1, 1, 1 ]
            end

            readNode( RBT.Base, Actor );

            function readNode( RBTNode, ParentActor )
                Reader = sim3d.internal.RBTReader;
                [ translation, rotation ] = Reader.getTransform( RBTNode );
                Visuals = Reader.getVisuals( RBTNode );

                nName = sim3d.utils.Impex.fixName( RBTNode.Name );
                newActor = sim3d.Actor( 'ActorName', nName );
                newActor.Parent = ParentActor;
                newActor.Translation = translation .* Scale;
                newActor.Rotation = deg2rad( [  - rotation( :, 1 ), rotation( :, 2:3 ) ] );
                if ~isempty( Visuals )
                    for j = 1:length( Visuals )
                        if ~isempty( Visuals{ j }.Vertices )
                            loc = Visuals{ j }.Tform( 1:3, 4 )';
                            rot = Visuals{ j }.Tform( 1:3, 1:3 );
                            V = ( Visuals{ j }.Vertices * rot' + loc ) .* Scale;
                            TR = triangulation( double( Visuals{ j }.Faces ), double( V ) );
                            N =  - vertexNormal( TR );
                            F = Visuals{ j }.Faces - 1;
                            newActor.addMesh( V, N, F );
                        end
                    end
                    newActor.Color = Visuals{ 1 }.Color( 1:3 );
                    newActor.Transparency = 1 - Visuals{ 1 }.Color( 4 );
                end
                newActor.TwoSided = true;

                for j = 1:length( RBTNode.Children )
                    readNode( RBTNode.Children{ j }, newActor );
                end
            end
        end


        function importSTL( Actor, FileName, Scale )
            arguments
                Actor( 1, 1 )sim3d.Actor
                FileName( 1, : )char
                Scale( 1, 3 )double = [ 1, 1, 1 ]
            end

            STL = stlread( FileName );
            V = STL.Points;
            N = STL.vertexNormal;
            F = STL.ConnectivityList;

            x = V( :, 1 );
            y = V( :, 2 );
            xr = [ min( x ), max( x ) ];
            yr = [ min( y ), max( y ) ];
            T = [ ( x - xr( 1 ) ) / ( xr( 2 ) - xr( 1 ) ), ( y - yr( 1 ) ) / ( yr( 2 ) - yr( 1 ) ) ];

            Actor.createMesh( V .* Scale, N, fliplr( F - 1 ), T );
        end


        function importX3D( Actor, SourceWorld, Scale, SkipEmpty, EnableCollisions )
            arguments
                Actor( 1, 1 )sim3d.Actor
                SourceWorld
                Scale( 1, 3 )double = [ 1, 1, 1 ]
                SkipEmpty( 1, 1 )logical = false
                EnableCollisions( 1, 1 )logical = true
            end

            worldCreated = ~isa( SourceWorld, 'vrworld' );
            if worldCreated
                World = vrworld( SourceWorld, 'new' );
            else
                World = SourceWorld;
            end

            WID = get( World, 'id' );
            WorkDir = fileparts( get( World, 'FileName' ) );
            if ~isempty( WorkDir )
                WorkDir = [ WorkDir, '/' ];
            end

            open( World );
            rootName = vrsfunc( 'GetRootNode', get( World, 'id' ) );
            wNodes = World.( rootName ).children;
            for j = 1:length( wNodes )
                readNode( wNodes( j ), Actor );
            end
            close( World );
            if worldCreated
                delete( World );
            end


            function readNode( VRNode, ParentActor )
                nType = get( VRNode, 'Type' );
                nName = strip( get( VRNode, 'Name' ), '_' );
                nName = sim3d.utils.Impex.fixName( nName );
                switch nType
                    case 'Inline'
                        NewActor = sim3d.Actor( 'ActorName', nName );
                        ParentActor.ParentWorld.add( NewActor, ParentActor );
                        NewActor.UserData.Name = nName;
                        NewActor.UserData.Type = nType;
                        sim3d.util.Impex.importX3D( NewActor, clearPath( VRNode.url{ : } ), Scale, SkipEmpty, EnableCollisions );
                    case { 'Group', 'Anchor' }
                        nChildren = VRNode.children;
                        for i = 1:length( nChildren )
                            readNode( nChildren( i ), ParentActor );
                        end
                    case 'Switch'
                        id = readVRProp( VRNode, 'whichChoice',  - 1 ) + 1;
                        if id >= 1
                            nChildren = readVRProp( VRNode, 'choice', [  ] );
                            if id <= length( nChildren )
                                readNode( nChildren( id ), ParentActor );
                            end
                        end
                    case 'Transform'
                        if SkipEmpty && isequal( [ VRNode.translation, VRNode.rotation( 4 ), VRNode.scale ], [ 0, 0, 0, 0, 1, 1, 1 ] )
                            NewActor = ParentActor;
                        else
                            NewActor = sim3d.Actor( 'ActorName', nName );
                            ParentActor.ParentWorld.add( NewActor, ParentActor );
                            NewActor.UserData.Name = nName;
                            NewActor.UserData.Type = nType;

                            NewActor.Scale = VRNode.scale;
                            NewActor.rotateAround( VRNode.rotation( 1:3 ), VRNode.rotation( 4 ), false );
                            R = sim3d.utils.Math.rotAA( VRNode.rotation( 1:3 ), VRNode.rotation( 4 ) );
                            translation = ( VRNode.translation + ( VRNode.center - ( VRNode.center .* VRNode.scale ) * R' ) ) .* Scale;
                            NewActor.Translation = translation * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                        end
                        nChildren = VRNode.children;
                        for i = 1:length( nChildren )
                            readNode( nChildren( i ), NewActor );
                        end
                    case 'DirectionalLight'
                        NewActor = sim3d.Actor( 'ActorName', nName );
                        ParentActor.ParentWorld.add( NewActor, ParentActor );
                        NewActor.UserData.Name = nName;
                        NewActor.UserData.Type = nType;
                        NewActor.lookAt( VRNode.direction );
                        NewActor.Light.Color = VRNode.color * VRNode.intensity;
                        NewActor.Light.Angle = pi;
                    case 'PointLight'
                        NewActor = sim3d.Actor( 'ActorName', nName );
                        ParentActor.ParentWorld.add( NewActor, ParentActor );
                        NewActor.UserData.Name = nName;
                        NewActor.UserData.Type = nType;
                        NewActor.Translation = VRNode.location .* Scale;
                        NewActor.Light.Color = VRNode.color * VRNode.intensity;
                        NewActor.Light.Angle = 2 * pi;
                    case 'SpotLight'
                        NewActor = sim3d.Actor( 'ActorName', nName );
                        ParentActor.ParentWorld.add( NewActor, ParentActor );
                        NewActor.UserData.Name = nName;
                        NewActor.UserData.Type = nType;
                        NewActor.Translation = VRNode.location .* Scale;
                        NewActor.lookAt( VRNode.direction );
                        NewActor.Light.Color = VRNode.color * VRNode.intensity;
                        NewActor.Light.Angle = VRNode.cutOffAngle;
                    case 'Viewpoint'
                        NewActor = ParentActor.ParentWorld.createViewport(  );
                        NewActor.Translation = VRNode.position .* Scale * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                        AAR = VRNode.orientation;
                        Axis = sim3d.utils.Math.posToUnreal( AAR( 1:3 ), 'vrml' );
                        Ra = sim3d.utils.Math.mat2unr( sim3d.utils.Math.rotAA( Axis, AAR( 4 ) ) );
                        NewActor.Rotation = sim3d.utils.Math.decomp321( Ra );
                        locY = [ 0, 1, 0 ] * sim3d.utils.Math.rotAA( AAR( 1:3 ), AAR( 4 ) )';
                        Axis = sim3d.utils.Math.posToUnreal( locY, 'vrml' );
                        Ra = sim3d.utils.Math.mat2unr( sim3d.utils.Math.rotAA( Axis, pi / 2 ) );
                        Ru = sim3d.utils.Math.rot321( NewActor.Rotation );
                        NewActor.Rotation = sim3d.utils.Math.decomp321( Ra * Ru );
                    case 'Shape'
                        nGeom = VRNode.geometry;
                        if ~isempty( nGeom )
                            nMat = VRNode.appearance.material;
                            nTex = VRNode.appearance.texture;
                            nTexTr = VRNode.appearance.textureTransform;
                            NewShape = sim3d.Actor( 'ActorName', nName );
                            ParentActor.ParentWorld.add( NewShape, ParentActor );
                            NewShape.UserData.Name = nName;
                            NewShape.UserData.Type = nType;
                            if ~EnableCollisions
                                NewShape.Collisions = false;
                            end

                            if length( nGeom ) == 1
                                [ vrV, vrN, vrF, vrT, vrC ] = sim3d.utils.Geometry.getMeshDataUnreal( WID, getfield( struct( nGeom( 1 ) ), 'Name' ) );
                                vrV = vrV .* Scale * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                                vrN = vrN * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                                vrF = vrF * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                                NewShape.createMesh( vrV, vrN, vrF, vrT, vrC );
                            else
                                for i = 1:length( nGeom )
                                    [ vrV, vrN, vrF, vrT, vrC ] = sim3d.utils.Geometry.getMeshDataUnreal( WID, getfield( struct( nGeom( i ) ), 'Name' ) );
                                    vrV = vrV .* Scale * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                                    vrN = vrN * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                                    vrF = vrF * [ 1, 0, 0;0, 0, 1;0, 1, 0 ];
                                    NewShape.addMesh( vrV, vrN, vrF, vrT, vrC );
                                end
                                NewShape.createMesh;
                            end

                            switch get( nGeom( 1 ), 'Type' )
                                case 'Extrusion'
                                    NewShape.Flat = nGeom( 1 ).creaseAngle < 0.1;
                                case 'IndexedFaceSet'
                                    NewShape.Flat = nGeom( 1 ).creaseAngle < 0.1;
                                    NewShape.TwoSided = ~nGeom( 1 ).solid;
                                    if ~isempty( vrC )
                                        NewShape.VertexBlend = 1;
                                    end
                            end

                            if ~isempty( nMat )
                                NewShape.Color = nMat.diffuseColor;
                                if nMat.transparency > 0
                                    NewShape.Transparency = nMat.transparency;
                                end
                                NewShape.Shininess = nMat.shininess;
                            end

                            TexUrl = readVRProp( nTex, 'url', [  ] );
                            if ~isempty( TexUrl ) && numel( TexUrl ) > 0
                                try
                                    NewShape.Texture = string( pwd ) + "/" + string( clearPath( TexUrl{ : } ) );
                                catch ME
                                    warning( ME.message );
                                end
                                NewShape.TextureMapping.Blend = 1;
                            end

                            if ~isempty( nTexTr )
                                NewShape.TextureTransform.Position = readVRProp( nTexTr, 'translation', [ 0, 0 ] );
                                NewShape.TextureTransform.Scale = 1 ./ readVRProp( nTexTr, 'scale', [ 1, 1 ] );
                                NewShape.TextureTransform.Angle = readVRProp( nTexTr, 'rotation', 0 );
                            end
                        end
                end
            end


            function Path = clearPath( Path )
                if startsWith( Path, '*sl3dlib' )
                    Path = [ matlabroot, '/toolbox/sl3d/library', Path( 9:end  ) ];
                else
                    Path = [ WorkDir, Path ];
                end
            end


            function Result = readVRProp( VRObj, PropName, DefValue )
                try
                    Result = VRObj.( PropName );
                catch
                    Result = DefValue;
                end
            end
        end

    end


    methods ( Access = private, Static )

        function Valid = checkSim3dActorStruct( Data )
            Valid = isfield( Data, 'Info' ) &&  ...
                isfield( Data.Info, 'Version' ) &&  ...
                isfield( Data, 'Actors' );
        end


        function FixedName = fixName( nName )
            if strcmp( nName, '' )
                FixedName = nName;
                return ;
            end
            if length( nName ) > 63
                nName = nName( end  - 50:end  );
            end
            FixedName = matlab.lang.makeValidName( nName );
        end
    end

end



