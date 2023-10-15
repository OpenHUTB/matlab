classdef DynamicMeshAttributes < sim3d.internal.BaseAttributes

    properties
        IsValid( 1, 1 )logical = false;
        Vertices( :, 3 )double = [  ];
        Normals( :, 3 )double = [  ];
        Faces( :, 3 )double = [  ];
        TextureCoordinates( :, 2 )double = [  ];
        VertexColors( :, 3 )double = [  ];
    end


    properties ( Hidden, Constant )
        VerticesID = 1;
        NormalsID = 2;
        FacesID = 3;
        TextureID = 4;
        VertexColorID = 5;
        Full = 5;
        Suffix_Out = 'DynamicMesh_OUT';
        Suffix_In = 'DynamicMesh_IN';
    end


    methods

        function self = DynamicMeshAttributes( varargin )
            r = sim3d.internal.DynamicMeshAttributes.parseInputs( varargin{ : } );
            self@sim3d.internal.BaseAttributes(  );
            self.createMesh( r.Vertices, r.Normals, r.Faces,  ...
                r.TextureCoordinates, r.VertexColors );
        end


        function setup( self, actorName )
            messageTopic = [ actorName, self.Suffix_Out ];
            setup@sim3d.internal.BaseAttributes( self, messageTopic );
        end


        function DynamicMesh = getAttributes( self )
            DynamicMesh = self.createDynamicMesh( self );
        end


        function setAttributes( self, DynamicMeshStruct )

            if ( isfield( DynamicMeshStruct, 'Vertices' ) )
                self.Vertices = DynamicMeshStruct.Vertices;
            end
            if ( isfield( DynamicMeshStruct, 'Normals' ) )
                self.Normals = DynamicMeshStruct.Normals;
            end
            if ( isfield( DynamicMeshStruct, 'Faces' ) )
                self.Faces = DynamicMeshStruct.Faces;
            end
            if ( isfield( DynamicMeshStruct, 'TextureCoordinates' ) )
                self.TextureCoordinates = DynamicMeshStruct.TextureCoordinates;
            end
            if ( isfield( DynamicMeshStruct, 'VertexColors' ) )
                self.VertexColors = DynamicMeshStruct.VertexColors;
            end

        end


        function createMesh( self, Vertices, Normals, Faces, TCoords, VColors )

            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
                Vertices( :, 3 )double
                Normals( :, 3 )double
                Faces( :, 3 )double
                TCoords( :, 2 )double = [  ]
                VColors( :, 3 )double = [  ]
            end

            self.Vertices = Vertices;
            self.Normals = Normals;
            self.Faces = Faces;
            self.TextureCoordinates = TCoords;
            self.VertexColors = VColors;

        end


        function addMesh( self, Vertices, Normals, Faces, TCoords, VColors )

            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
                Vertices( :, 3 )double
                Normals( :, 3 )double
                Faces( :, 3 )double
                TCoords( :, 2 )double = [  ]
                VColors( :, 3 )double = [  ]
            end

            faceOffset = size( self.Vertices, 1 );
            self.Vertices = vertcat( self.Vertices, Vertices );
            self.Normals = vertcat( self.Normals, Normals );
            self.Faces = vertcat( self.Faces, Faces + faceOffset );
            self.VertexColors = vertcat( self.VertexColors, VColors );
            self.TextureCoordinates = vertcat( self.TextureCoordinates, TCoords );
        end


        function reduceMesh( self, Ratio )
            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
                Ratio( 1, 1 )double
            end

            V = self.Vertices;
            N = self.Normals;
            F = self.Faces;
            T = self.TextureCoordinates;
            C = self.VertexColors;
            F = F + 1;

            if true
                [ V, i, j ] = unique( V, 'rows' );
                j( end  + 1 ) = nan;
                F( isnan( F ) ) = length( j );
                if size( F, 1 ) == 1
                    F = j( F )';
                else
                    F = j( F );
                end

                if ~isempty( N )
                    N = N( i, : );
                end
                if ~isempty( T )
                    T = T( i, : );
                end
                if ~isempty( C )
                    C = C( i, : );
                end
            end

            [ F, newV ] = reducepatch( F, V, Ratio, 'fast' );
            F = F - 1;

            [ ~, id ] = ismember( newV, V, 'rows' );
            V = newV;

            if ~isempty( N )
                N = N( id, : );
            end
            if ~isempty( T )
                T = T( id, : );
            end
            if ~isempty( C )
                C = C( id, : );
            end
            self.createMesh( V, N, F, T, C );
        end


        function transformMesh( self, T )

            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
                T double
            end

            if ~isempty( self.Vertices )
                s = size( T );
                s = 10 * s( 1 ) + s( 2 );
                switch s
                    case 11

                        self.Vertices = self.Vertices * T;
                    case 13

                        self.Vertices = self.Vertices + T;
                    case 33

                        self.Vertices = self.Vertices * T;
                        self.Normals = self.Normals * T;
                    case 44

                        self.Vertices = self.Vertices * T( 1:3, 1:3 ) + T( 1:3, 4 )';
                        self.Normals = self.Normals * T( 1:3, 1:3 );
                end
            end
        end


        function updateMesh( self, Vertices, Normals )

            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
                Vertices( :, 3 )double
                Normals( :, 3 )double = [  ];
            end
            self.Vertices = Vertices;
            if ~isempty( Normals )
                self.Normals = Normals;
            end
        end


        function invertSurface( self, invertFaces, invertNormals )

            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
                invertFaces( 1, 1 )logical = true
                invertNormals( 1, 1 )logical = true
            end

            if invertFaces
                f = self.Faces( :, [ 1, 3, 2 ] );
            else
                f = self.Faces;
            end
            if invertNormals
                n =  - self.Normals;
            else
                n = self.Normals;
            end
            self.createMesh( self.Vertices, n, f, self.TextureCoordinates, self.VertexColors );
        end


        function clearMesh( self )
            arguments
                self( 1, : )sim3d.internal.DynamicMeshAttributes
            end
            self.createMesh( [  ], [  ], [  ], [  ], [  ] );
        end


        function copy( self, other )
            self.Vertices = other.Vertices;
            self.Normals = other.Normals;
            self.Faces = other.Faces;
            self.TextureCoordinates = other.TextureCoordinates;
            self.VertexColors = other.VertexColors;

        end


        function set.Faces( self, Faces )
            self.Faces = Faces;
            self.add2Buffer( self.FacesID )
        end


        function Faces = get.Faces( self )
            Faces = self.Faces;
        end


        function set.Vertices( self, Vertices )
            self.Vertices = Vertices;
            self.add2Buffer( self.VerticesID )
        end


        function Vertices = get.Vertices( self )
            Vertices = self.Vertices;
        end


        function set.Normals( self, Normals )
            self.Normals = Normals;
            self.add2Buffer( self.NormalsID )
        end


        function Normals = get.Normals( self )
            Normals = self.Normals;
        end


        function set.TextureCoordinates( self, TextureCoordinates )
            self.TextureCoordinates = TextureCoordinates;
            self.add2Buffer( self.TextureID )
        end


        function set.VertexColors( self, VertexColors )
            self.VertexColors = VertexColors;
            self.add2Buffer( self.VertexColorID );
        end
    end


    methods ( Static )

        function defaultAttribs = getDefaultAttributes(  )
            defaultAttribs = struct(  ...
                'Vertices', [  ],  ...
                'Normals', [  ],  ...
                'Faces', [  ],  ...
                'TextureCoordinates', [  ],  ...
                'VertexColors', [  ] ...
                );
        end
    end


    methods ( Access = private, Static )

        function r = parseInputs( varargin )
            defaultValues = sim3d.internal.DynamicMeshAttributes.getDefaultAttributes();

            parser = inputParser;
            parser.addParameter( 'Vertices', defaultValues.Vertices );
            parser.addParameter( 'Faces', defaultValues.Faces );
            parser.addParameter( 'Normals', defaultValues.Normals );
            parser.addParameter( 'TextureCoordinates', defaultValues.TextureCoordinates );
            parser.addParameter( 'VertexColors', defaultValues.VertexColors );

            parser.parse( varargin{ : } );
            r = parser.Results;
        end


        function DynamicMesh = createDynamicMesh( self )
            DynamicMesh = struct(  ...
                'Vertices', self.Vertices,  ...
                'Normals', self.Normals,  ...
                'Faces', self.Faces,  ...
                'TextureCoordinates', self.TextureCoordinates,  ...
                'VertexColors', self.VertexColors ...
                );
        end

    end


    methods ( Hidden )

        function totalAttributes = getTotalAttributes( self )
            totalAttributes = self.Full;
        end


        function selectedAttributes = getSelectedAttributes( self, messageIds )
            selectedAttributes = struct(  );
            if ( messageIds( self.Full ) == 1 )

                selectedAttributes = self.getAttributes(  );
                return ;
            end

            if ( messageIds( self.VerticesID ) == 1 )
                selectedAttributes.Vertices = self.Vertices;
            end
            if ( messageIds( self.FacesID ) == 1 )
                selectedAttributes.Faces = self.Faces;
            end
            if ( messageIds( self.NormalsID ) == 1 )
                selectedAttributes.Normals = self.Normals;
            end
            if ( messageIds( self.TextureID ) == 1 )
                selectedAttributes.TextureCoordinates = self.TextureCoordinates;
            end
            if ( messageIds( self.VertexColorID ) == 1 )
                selectedAttributes.VertexColors = self.VertexColors;
            end

        end

    end


end




