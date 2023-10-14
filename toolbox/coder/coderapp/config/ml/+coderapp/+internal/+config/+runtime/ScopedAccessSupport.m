classdef ( Sealed, Hidden )ScopedAccessSupport < handle

    properties ( Dependent, SetAccess = immutable )
        Key char
    end

    properties ( Dependent )
        Node
    end

    properties ( Access = private, Transient )
        Values struct = struct.empty(  )
    end

    properties
        AssertHasNode logical = true
    end

    properties ( GetAccess = private, SetAccess = immutable )
        ExportValues
    end

    properties ( Access = private, Transient )
        NodeObject
    end

    methods
        function this = ScopedAccessSupport( exportValues )
            arguments
                exportValues logical = false
            end
            this.ExportValues = exportValues;
        end

        function depKeys = keys( this )
            if ~isempty( this.Node )
                depKeys = { this.Node.Dependencies.Key };
            else
                depKeys = {  };
            end
        end

        function varargout = value( this, varargin )


            values = this.Node.getDependencyView( this.ExportValues );
            if nargin > 1
                cellInput = iscell( varargin{ 1 } );
                if cellInput
                    keys = cellstr( varargin{ 1 } );
                else
                    keys = cellstr( varargin );
                end
            else
                varargout{ 1 } = struct2cell( values );
                return
            end

            if ~isempty( keys )
                found = isfield( values, keys );
            else
                found = false( 0, 0 );
            end
            if ~all( found ) && ~all( strcmp( keys( ~found ), this.Key ) )
                found( ~found ) = strcmp( keys( ~found ), this.Key );
                error( 'Dependency keys %s either do not exist or are not declared dependencies of %s',  ...
                    strjoin( keys( ~found ), ', ' ), this.Key );
            end

            varargout = cell( 1, numel( keys ) );
            for i = 1:numel( keys )
                if found( i )
                    varargout{ i } = values.( keys{ i } );
                else
                    varargout{ i } = this.Node.ReferableValue;
                end
            end
            if cellInput
                varargout = { varargout };
            end
        end

        function nodeAdapters = nodes( this, keys )
            if nargin > 1
                allNodes = [ this.Node;this.Node.Dependencies ];
                [ found, idx ] = ismember( keys, { allNodes.Key } );
                if ~all( found )
                    error( 'Dependency keys %s either do not exist or are not declared dependencies of %s',  ...
                        strjoin( keys( ~found ), ', ' ), this.Key );
                end
                nodeAdapters = allNodes( idx );
            else
                nodeAdapters = [ this.Node;this.Node.Dependencies ];
            end
        end

        function value = metadata( this, metadataProp )
            if ~isempty( this.Node )
                value = this.Node.getMetadata( metadataProp );
            else
                value = [  ];
            end
        end

        function yes = hasMetadata( this, metadataProp )
            arguments
                this
                metadataProp char
            end
            yes = this.Node.hasMetadata( metadataProp );
        end

        function node = get.Node( this )
            node = this.NodeObject;
            if isempty( node ) && this.AssertHasNode
                error( 'The graph cannot be accessed in the current state' );
            end
        end

        function set.Node( this, node )
            if ~isempty( node )
                assert( isempty( this.NodeObject ) || node == this.NodeObject, 'Already associated with a prior invocation' );
                this.NodeObject = node;
            else
                this.NodeObject = coderapp.internal.config.runtime.ParamNodeAdapter.empty(  );
            end
        end

        function key = get.Key( this )
            if ~isempty( this.Node )
                key = this.Node.Key;
            else
                key = '';
            end
        end
    end
end


