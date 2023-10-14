classdef ( Sealed )SubObjectMetadataIndex < handle





    properties ( Dependent, SetAccess = immutable )
        ProductionKey


        ObjectClasses{ mustBeText( ObjectClasses ) }

        MappedProperties




        UnimplementedProperties




        IgnoredProperties


        DeprecatedProperties





        UnaccountedProperties


        SubObjects
    end

    properties ( Dependent, SetAccess = immutable, Hidden )





        NewOnlyProperties


        MappedOldKeys


        OrderedOldKeys


        DefinedIn
    end

    properties ( GetAccess = private, SetAccess = immutable )
        Owner coderapp.internal.coderconfig.ConfigMetadataIndex
        Spec( 1, 1 )struct
        Data( 1, 1 )struct
    end

    methods ( Access = ?coderapp.internal.coderconfig.ConfigMetadataIndex )
        function this = SubObjectMetadataIndex( owner, spec, data )
            arguments
                owner( 1, 1 )coderapp.internal.coderconfig.ConfigMetadataIndex
                spec( 1, 1 )struct
                data( 1, 1 )struct
            end

            this.Owner = owner;
            this.Spec = spec;
            this.Data = normalizeEmpties( data,  ...
                'unimplementedProperties',  ...
                'ignoredProperties',  ...
                'deprecatedProperties' );
        end
    end

    methods
        function newKeys = propToNewKey( this, prop )
            arguments
                this( 1, 1 )
                prop{ mustBeTextScalar( prop ) }
            end

            if isfield( this.Data.propToNew, prop )
                newKeys = this.Data.propToNew.( prop );
            else
                newKeys = {  };
            end
        end

        function props = newKeyToProp( this, newKey )
            arguments
                this( 1, 1 )
                newKey{ mustBeTextScalar( newKey ) }
            end

            if isfield( this.Data.newToProp, newKey )
                props = this.Data.newToProp.( newKey );
            else
                props = {  };
            end
        end

        function oldKeys = propToOldKeys( this, prop )
            arguments
                this( 1, 1 )
                prop{ mustBeTextScalar( prop ) }
            end

            newKeys = this.propToNewKey( prop );
            if ~isempty( newKeys )
                if ischar( newKeys )
                    oldKeys = this.Owner.newToOld( newKeys );
                else
                    oldKeys = cellfun( @( k )this.Owner.newToOld( k ), newKeys, 'UniformOutput', false );
                    oldKeys = vertcat( {  }, oldKeys{ : } );
                end
            else
                oldKeys = {  };
            end
        end

        function props = oldKeyToProp( this, oldKey )
            arguments
                this( 1, 1 )
                oldKey{ mustBeText( oldKey ) }
            end

            newKeys = this.Owner.oldToNew( oldKey );
            if ~isempty( newKeys )
                if iscell( newKeys )
                    props = cellfun( @( k )this.newKeyToProp( k ), newKeys, UniformOutput = false );
                else
                    props = this.newKeyToProp( newKeys );
                end
            else
                props = {  };
            end
        end

        function classes = get.ObjectClasses( this )
            classes = cellstr( this.Data.objectClasses );
        end

        function props = get.MappedProperties( this )
            props = fieldnames( this.Data.propToNew );
        end

        function keys = get.OrderedOldKeys( this )
            keys = cellfun( @( p )this.propToOldKeys( p ), this.MappedProperties, UniformOutput = false );
            keys = vertcat( {  }, keys{ : } );
            [ ~, ~, order ] = intersect( this.Owner.OrderedOldKeys, keys, 'stable' );
            keys = keys( order );
        end

        function props = get.UnimplementedProperties( this )
            props = this.Data.unimplementedProperties;
        end

        function props = get.IgnoredProperties( this )
            props = this.Data.ignoredProperties;
        end

        function props = get.DeprecatedProperties( this )
            props = this.Data.deprecatedProperties;
        end

        function props = get.UnaccountedProperties( this )
            allProps = cellfun( @( c )coderapp.internal.coderconfig.ConfigMetadataIndex.getMutablePublicProperties( c ),  ...
                this.ObjectClasses, 'UniformOutput', false );
            allProps = unique( [ allProps{ : } ] );
            props = setdiff( allProps, [
                fieldnames( this.Data.propToNew )
                this.Data.ignoredProperties
                this.Data.unimplementedProperties
                ] );
        end

        function props = get.NewOnlyProperties( this )
            newKeys = fieldnames( this.Data.newToProp );
            hasOld = false( size( newKeys ) );
            for i = 1:numel( newKeys )
                hasOld( i ) = ~isempty( this.Owner.newToOld( newKeys{ i } ) );
            end
            props = struct2cell( this.Data.newToProp );
            props( hasOld ) = [  ];
        end

        function keys = get.MappedOldKeys( this )
            keys = cellfun( @this.propToOldKeys, this.MappedProperties, 'UniformOutput', false );
            keys = vertcat( {  }, keys{ : } );
        end

        function key = get.ProductionKey( this )
            key = this.Spec.productionKey;
        end

        function subs = get.SubObjects( this )
            subs = this.Owner.SubObjects;
            subs = subs( ismember( { subs.ProductionKey }, fieldnames( this.Data.newToProp ) ) );
        end

        function file = get.DefinedIn( this )
            file = this.Spec.file;
        end
    end
end


function structVal = normalizeEmpties( structVal, varargin )
for i = 1:numel( varargin )
    if isempty( structVal.( varargin{ i } ) )
        structVal.( varargin{ i } ) = {  };
    end
end
end


