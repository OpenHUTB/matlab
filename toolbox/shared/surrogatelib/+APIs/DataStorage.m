classdef DataStorage

    methods

        function names = getResponseNames( obj )
            if ~isscalar( obj )
                error( message( "shared_surrogatelib:DataStorage:MethodCallOnVector" ) );
            end
            names = obj.getResponseNamesImpl(  );
            if ~isvector( names )
                error( message( "shared_surrogatelib:DataStorage:ResponseNamesMustBeVector" ) );
            end
        end


        function names = getIndependentVariableNames( obj )
            if ~isscalar( obj )
                error( message( "shared_surrogatelib:DataStorage:MethodCallOnVector" ) );
            end
            names = obj.getIndependentVariableNamesImpl(  );
            if ~isvector( names )
                error( message( "shared_surrogatelib:DataStorage:IndependentVariableNamesMustBeVector" ) );
            end
        end


        function names = getIndependentVariableNamesImpl( obj )%#ok<MANU,STOUT>
            error( message( "shared_surrogatelib:DataStorage:IndependentVariableNamesNotSupported" ) );
        end


        function x = getIndependentVariable( obj, independentVariableIndicators, options )
            arguments
                obj( 1, 1 )
                independentVariableIndicators{ mustBeVector } = double.empty( 0, 1 )
                options.Groups{ mustBeVector } = string.empty( 0, 1 )
            end
            obj.validateGroups( options.Groups );
            if ~isempty( options.Groups )
                groups = { options.Groups };
            else
                groups = {  };
            end
            x = obj.getIndependentVariableImpl( independentVariableIndicators, groups{ : } );
        end


        function varargout = getResponses( obj, responseIndicators, options )
            arguments
                obj( 1, 1 )
                responseIndicators{ mustBeVector } = double.empty( 0, 1 )
                options.Groups string{ mustBeVector } = string.empty( 0, 1 )
            end
            obj.validateGroups( options.Groups );
            if ~isempty( options.Groups )
                groups = { options.Groups };
            else
                groups = {  };
            end
            varargout = cell( 1, max( nargout, 1 ) );
            if isempty( responseIndicators )
                [ varargout{ : } ] = obj.getResponsesImpl( obj.getResponseNamesImpl(  ), groups{ : } );
            else
                [ varargout{ : } ] = obj.getResponsesImpl( responseIndicators, groups{ : } );
            end
        end


        function groups = getGroups( obj )
            if ~isscalar( obj )
                error( message( "shared_surrogatelib:DataStorage:MethodCallOnVector" ) );
            end
            groups = obj.getGroupsImpl(  );
            assert( isvector( groups ), "Group information must be a column vector." );
        end
    end


    methods ( Abstract )

        names = getResponseNamesImpl( obj );

        x = getIndependentVariableImpl( obj, names, groups );

        varargout = getResponsesImpl( obj, names, groups );
    end


    methods ( Access = protected )
        function groups = getGroupsImpl( obj )%#ok<MANU,STOUT>
            error( message( "shared_surrogatelib:DataStorage:GroupsNotSupported" ) );
        end
    end


    methods ( Access = private )
        function validateGroups( obj, groups )
            if isempty( groups )
                return ;
            end
            existingGroups = obj.getGroupsImpl(  );
            for i = 1:numel( groups )
                tfValidGroup = false;
                for j = 1:numel( existingGroups )
                    if isequal( groups( i ), existingGroups( j ) )
                        tfValidGroup = true;
                        break ;
                    end
                end
                if ~tfValidGroup
                    error( message( "shared_surrogatelib:DataStorage:InvalidGroup" ) );
                end
            end
        end
    end
end

