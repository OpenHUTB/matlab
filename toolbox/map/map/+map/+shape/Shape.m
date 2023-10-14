classdef ( Hidden, AllowedSubclasses = { ?map.shape.GeographicShape, ?map.shape.MapShape } )Shape ...
        < matlab.mixin.indexing.RedefinesParen ...
        & matlab.mixin.CustomCompactDisplayProvider ...

    properties ( Hidden )
        InternalData
    end

    properties ( Abstract, Constant, Access = protected )
        CRSPropertyName
    end


    methods ( Abstract, Hidden )
        S = shapeToStructure( obj )
        S = exportShapeData( obj )
    end


    methods ( Hidden )
        function tf = hasNoCoordinateData( obj )
            tf = hasNoCoordinateData( obj.InternalData );
        end
    end


    methods ( Abstract, Access = protected )
        crs = getCRS( obj )
        obj = setCRS( obj, crs )
        obj = makeHeterogeneous( obj )
        obj = updateShape( obj, data )
        heterogeneousType = heterogeneousShapeType( obj )
    end


    methods ( Access = protected )
        function validateConstructorInput( ~, input1, input2, varname1, varname2 )



            if ~isequal( size( input1 ), size( input2 ) )
                throwAsCaller( MException( message( "map:shape:MismatchedInputSizes", varname1, varname2 ) ) )
            end
            if isnumeric( input1 )
                if ~isnumeric( input2 )
                    throwAsCaller( MException( message( "map:shape:MustBeNumericOrCell", varname1, varname2 ) ) )
                elseif ~isequal( isnan( input1 ), isnan( input2 ) )
                    throwAsCaller( MException( message( "map:shape:MismatchedNanValues", varname1, varname2 ) ) )
                end
            elseif iscell( input1 )
                if ~iscell( input2 )
                    throwAsCaller( MException( message( "map:shape:MustBeNumericOrCell", varname1, varname2 ) ) )
                else
                    if ~isempty( input1 )
                        if all( cellfun( @isnumeric, input1 ), "all" )
                            if ~all( cellfun( @isnumeric, input2 ) )
                                throwAsCaller( MException( message( "map:shape:CellsMustContainNumericValues", varname1, varname2 ) ) )
                            else
                                for k = 1:numel( input1 )
                                    in1 = input1{ k };
                                    in2 = input2{ k };
                                    if ~isempty( in1 ) || ~isempty( in2 )
                                        if ~isrow( in1 ) || ~isrow( in2 )
                                            throwAsCaller( MException( message( "map:shape:CellsMustContainRowVectors", varname1, varname2 ) ) )
                                        elseif ~isequal( length( in1 ), length( in2 ) )
                                            throwAsCaller( MException( message( "map:shape:MismatchedVectorLengthsInCells", varname1, varname2 ) ) )
                                        elseif ~isequal( isnan( in1 ), isnan( in2 ) )
                                            throwAsCaller( MException( message( "map:shape:MismatchedNanValues", varname1, varname2 ) ) )
                                        end
                                    end
                                end
                            end
                        else
                            throwAsCaller( MException( message( "map:shape:CellsMustContainNumericValues", varname1, varname2 ) ) )
                        end
                    end
                end
            else
                throwAsCaller( MException( message( "map:shape:MustBeNumericOrCell", varname1, varname2 ) ) )
            end
        end


        function validateVectorOrEmpty( ~, input1, input2, varname1, varname2 )
            if ( ~isempty( input1 ) && ~isvector( input1 ) ) || ( ~isempty( input2 ) && ~isvector( input2 ) )
                throwAsCaller( MException( message( "map:shape:MustBeVectorOrEmpty", varname1, varname2 ) ) )
            end
        end
    end


    methods
        function tf = isempty( obj )
            tf = isemptyArray( obj.InternalData );
        end


        function len = length( obj )
            len = arrayLength( obj.InternalData );
        end


        function varargout = size( obj, dim )
            arguments
                obj map.shape.Shape
            end
            arguments( Repeating )
                dim( 1, : )double{ mustBeInteger, mustBePositive }
            end
            sz = arraySize( obj.InternalData, dim );
            if nargout < 2
                varargout{ 1 } = sz;
            else
                n = max( 1, nargout );
                varargout = num2cell( sz( 1, 1:n ) );
                m = length( sz );
                if m > n
                    varargout{ end  } = prod( sz( n:m ) );
                end
            end
        end


        function obj = vertcat( objects )
            arguments( Repeating )
                objects map.shape.Shape
            end
            try
                obj = cat( 1, objects{ : } );
            catch e
                throwAsCaller( e )
            end
        end


        function obj = horzcat( objects )
            arguments( Repeating )
                objects map.shape.Shape
            end
            try
                obj = cat( 2, objects{ : } );
            catch e
                throwAsCaller( e )
            end
        end


        function obj = cat( dim, objects )
            arguments
                dim( 1, 1 )double{ mustBeInteger, mustBePositive }
            end
            arguments( Repeating )
                objects map.shape.Shape
            end
            obj = objects{ 1 };
            if ~isscalar( objects )
                try
                    if ~all( cellfun( @( shape )isa( shape, heterogeneousShapeType( obj ) ), objects ) )

                        throwAsCaller( MException( message( 'map:shape:ConcatenationWithMismatchedCSType' ) ) )
                    end


                    type = cellfun( @( obj )class( obj ), objects, "UniformOutput", false );
                    if length( type ) > 1 && ~isequal( type{ : } )
                        obj = makeHeterogeneous( obj );
                        objects = cellfun( @makeHeterogeneous, objects, "UniformOutput", false );
                    end






                    crs = cellfun( @( obj )getCRS( obj ), objects, 'UniformOutput', false );
                    crs = crs( ~cellfun( @isempty, crs ) );
                    if length( crs ) > 1 && ~isequal( crs{ : } )
                        throwAsCaller( MException( message( 'map:shape:ConcatenationWithMismatchedCRS', obj.CRSPropertyName ) ) )
                    end
                    if ~isempty( crs )
                        obj = setCRS( obj, crs{ 1 } );
                    else
                        obj = setCRS( obj, [  ] );
                    end

                    data = cellfun( @( obj )obj.InternalData, objects, 'UniformOutput', false );
                    obj.InternalData = catArray( dim, data{ : } );
                catch e
                    throwAsCaller( e )
                end
            end
        end


        function obj = reshape( obj, sz )
            arguments
                obj map.shape.Shape
            end
            arguments( Repeating )
                sz( 1, : )double{ mustBeInteger, mustBeNonnegative }
            end
            try
                obj.InternalData = reshapeArray( obj.InternalData, sz );
            catch e
                throw( e )
            end
        end
    end


    methods
        function tf = ismultipoint( obj )
            tf = ismultipoint( obj.InternalData );



        end
    end


    methods ( Access = protected )
        function varargout = parenReference( obj, S )



            try
                if isscalar( S )

                    subobj = parenReferenceShape( obj, S.Indices );
                    varargout = { subobj };
                else


                    subobj = parenReferenceShape( obj, S( 1 ).Indices );
                    [ varargout{ 1:nargout } ] = subobj.( S( 2:end  ) );
                end
            catch e
                throwAsCaller( e )
            end
        end


        function obj = parenReferenceShape( obj, subs )
            data = parenReferenceArray( obj.InternalData, subs );
            if obj.Geometry == "heterogeneous"
                obj = updateShape( obj, data );
            else
                obj.InternalData = data;
            end
        end


        function obj = parenAssign( obj, S, rhs )





            if isequal( obj, [  ] )





                obj = rhs.empty;
                obj = setCRS( obj, getCRS( rhs ) );
            end

            if isscalar( S )



                if ~isa( rhs, "map.shape.Shape" )
                    throwAsCaller( MException( message( "map:shape:UnableToConvert", class( rhs ), heterogeneousShapeType( obj ) ) ) )
                elseif ( rhs.CoordinateSystemType ~= obj.CoordinateSystemType )
                    throwAsCaller( MException( message( "map:shape:AssignmentWithMismatchedCSType" ) ) )
                end


                if ~isempty( getCRS( rhs ) ) && ~isequal( getCRS( rhs ), getCRS( obj ) )
                    error( message( "map:shape:PropertyAssignmentWithMismatchedCRS" ) )
                end
                obj = parenAssignShape( obj, S.Indices, rhs );
            else

                if S( 2 ).Name == obj.CRSPropertyName


                    throwAsCaller( MException( message( "map:shape:SubArrayPropertyAssignment",  ...
                        obj.CRSPropertyName, class( obj ) ) ) )
                end
                subobj = parenReferenceShape( obj, S( 1 ).Indices );
                subobj.( S( 2:end  ) ) = rhs;
                obj = parenAssignShape( obj, S( 1 ).Indices, subobj );
            end
        end


        function obj = parenAssignShape( obj, subs, rhs )
            if obj.Geometry == "heterogeneous"
                rhs = makeHeterogeneous( rhs );
                data = parenAssignArray( obj.InternalData, subs, rhs.InternalData );






                obj = updateShape( obj, data );
            else
                if isa( rhs, class( obj ) )

                    try
                        obj.InternalData = parenAssignArray( obj.InternalData, subs, rhs.InternalData );
                    catch e
                        throw( e )
                    end
                else

                    obj = parenAssignShape( makeHeterogeneous( obj ), subs, rhs );
                end
            end
        end


        function obj = parenDelete( obj, S )




            data = parenDeleteArray( obj.InternalData, S.Indices );

            if obj.Geometry == "heterogeneous"
                obj = updateShape( obj, data );
            else
                obj.InternalData = data;
            end
        end


        function n = parenListLength( ~, ~, ~ )
            n = 1;
        end
    end


    methods ( Hidden )
        function obj = homogenize( obj )


            data = obj.InternalData;
            if isHomogeneous( data )
                obj = updateShape( obj, data );
            end
        end


        function str = string( obj )


            str = string( arrayfun( @( shape )class( shape ), obj( : ), "UniformOutput", false ) );
            str = reshape( str, size( obj ) );
        end


        function displayRep = compactRepresentationForColumn( obj, displayConfiguration, availableWidth )

            [ displayRep, ~ ] = widthConstrainedDataRepresentation( obj, displayConfiguration, availableWidth );
        end


        function displayRep = compactRepresentationForSingleLine( obj, displayConfiguration, availableWidth )


            displayRep = compactRepresentationForSingleLine@matlab.mixin.CustomCompactDisplayProvider(  ...
                obj, displayConfiguration, availableWidth );
        end


        function S = saveobj( obj )
            S = encodeInStructure( obj.InternalData );
            S.CoordinateReferenceSystem = getCRS( obj );
            S.Version = "R2021b";
        end
    end


    methods
        function obj = transpose( obj )
            obj.InternalData = transposeArray( obj.InternalData );
        end


        function obj = ctranspose( obj )
            obj.InternalData = transposeArray( obj.InternalData );
        end


        function obj = flip( obj, dim )
            arguments
                obj map.shape.Shape
                dim double{ mustBeInteger, mustBePositive, mustBeScalarOrEmpty } = [  ];
            end
            obj.InternalData = flipArray( obj.InternalData, dim );
        end
    end


    methods ( Hidden )
        function B = permute( varargin )
            B = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "permute", varargin{ : } ) )
        end

        function A = ipermute( varargin )
            A = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "ipermute", varargin{ : } ) )
        end

        function Y = circshift( varargin )
            Y = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "circshift", varargin{ : } ) )
        end

        function [ B, m ] = shiftdim( varargin )
            B = [  ];%#ok<NASGU>
            m = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "shiftdim", varargin{ : } ) )
        end

        function B = squeeze( A )
            B = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "squeeze", A ) )
        end

        function B = rot90( varargin )
            B = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "rot90", varargin{ : } ) )
        end

        function Y = pagetranspose( X )
            Y = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "pagetranspose", X ) )
        end

        function Y = pagectranspose( X )
            Y = [  ];%#ok<NASGU>
            throwAsCaller( unsupported( "pagectranspose", X ) )
        end
    end


    methods ( Access = private )
        function me = unsupported( operation, varargin )

            if length( varargin ) > 1
                k = find( cellfun( @( obj )isa( obj, "map.shape.Shape" ), varargin ), 1 );
                obj = varargin{ k };
            else
                obj = varargin{ 1 };
            end
            me = MException( message( "map:shape:UnsupportedOperation", operation, class( obj ) ) );
        end
    end
end


