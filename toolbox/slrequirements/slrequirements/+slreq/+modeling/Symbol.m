classdef Symbol < handle




    properties ( Dependent )
        Complexity
        InitialValue
        Name
        Scope
        Size
        Type
        IsDesignOutput
    end

    properties ( Access = private )
        InternalSymbol
    end

    methods ( Access = { ?slreq.modeling.RequirementsTable } )
        function obj = Symbol( chartH, options )
            if nargin == 0
                obj.InternalSymbol = [  ];
                return ;
            end

            if isfield( options, 'IsDesignOutput' )
                if ~isfield( options, 'Scope' ) || ~strcmp( options.Scope, 'Input' )
                    options = rmfield( options, 'IsDesignOutput' );
                    warning( 'Slvnv:reqmgt:specBlock:InvalidDesignOutputProperty',  ...
                        DAStudio.message( 'Slvnv:reqmgt:specBlock:InvalidDesignOutputProperty' ) );
                end
            end

            if isfield( options, 'Name' ) && strcmp( options.Name, 'X' )
                error( 'Stateflow:requirementstable:Headercellshorthand',  ...
                    DAStudio.message( 'Stateflow:requirementstable:Headercellshorthand' ) );
            end

            data = Stateflow.Data( chartH );
            if isfield( options, 'Scope' )
                data.Scope = options.Scope;
                if isfield( options, 'IsDesignOutput' )
                    data.ModelOutput = options.IsDesignOutput;
                end
            end

            if isfield( options, 'Name' )
                data.Name = options.Name;
            end
            if isfield( options, 'InitialValue' )
                data.Props.InitialValue = options.InitialValue;
            end
            if isfield( options, 'Size' )
                data.Props.Array.Size = options.Size;
            end
            if isfield( options, 'Complexity' )
                data.Props.Complexity = options.Complexity;
            end
            if isfield( options, 'Type' )
                data.DataType = options.Type;
            end
            obj.InternalSymbol = data;
        end
    end

    methods
        function out = get.IsDesignOutput( obj )
            if strcmp( obj.Scope, 'Input' )
                out = logical( ( obj.InternalSymbol.ModelOutput ) );
            else
                out = [  ];
            end
        end

        function set.IsDesignOutput( obj, val )
            if strcmp( obj.Scope, 'Input' )
                mustBeNumericOrLogical( val );
                mustBeNonempty( val );
                obj.InternalSymbol.ModelOutput = logical( val );
            else
                error( 'Slvnv:reqmgt:specBlock:InvalidDesignOutputProperty',  ...
                    DAStudio.message( 'Slvnv:reqmgt:specBlock:InvalidDesignOutputProperty' ) );
            end
        end

        function out = get.Name( obj )
            out = obj.InternalSymbol.Name;
        end

        function set.Name( obj, newValue )
            arguments
                obj
                newValue{ mustBeNonzeroLengthText }
            end
            obj.InternalSymbol.Name = newValue;
        end

        function out = get.Scope( obj )
            out = obj.InternalSymbol.Scope;
        end

        function set.Scope( obj, newValue )
            arguments
                obj
                newValue{ mustBeMember( newValue, { 'Input', 'Output', 'Local', 'Constant', 'Parameter' } ) }
            end
            oldValue = obj.InternalSymbol.Scope;
            obj.InternalSymbol.Scope = newValue;
            if strcmp( oldValue, 'Input' ) && ~strcmp( newValue, 'Input' )
                obj.InternalSymbol.ModelOutput = false;
            end
            obj.InternalSymbol.Scope = newValue;
        end

        function out = get.Type( obj )
            out = obj.InternalSymbol.DataType;
        end

        function set.Type( obj, newValue )
            arguments
                obj
                newValue{ mustBeNonzeroLengthText }
            end
            obj.InternalSymbol.DataType = newValue;
        end

        function set.InitialValue( obj, newValue )
            arguments
                obj
                newValue{ mustBeNonzeroLengthText }
            end
            obj.InternalSymbol.Props.InitialValue = strtrim( newValue );
        end

        function out = get.InitialValue( obj )
            out = obj.InternalSymbol.Props.InitialValue;
        end

        function out = get.Size( obj )
            out = obj.InternalSymbol.Props.Array.Size;
        end

        function set.Size( obj, newValue )
            obj.InternalSymbol.Props.Array.Size = newValue;
        end

        function out = get.Complexity( obj )
            out = obj.InternalSymbol.Props.Complexity;
        end

        function set.Complexity( obj, newValue )
            arguments
                obj
                newValue char{ mustBeMember( newValue, { 'On', 'Off', 'Inherited' } ) }
            end
            obj.InternalSymbol.Props.Complexity = newValue;
        end
    end

    methods ( Static, Hidden )
        function symbol = wrap( internalSymbol )
            symbol = slreq.modeling.Symbol(  );
            symbol.InternalSymbol = internalSymbol;
        end
    end
end


