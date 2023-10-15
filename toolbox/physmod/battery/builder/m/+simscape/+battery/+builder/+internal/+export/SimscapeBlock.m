classdef ( Sealed = true, Hidden = true )SimscapeBlock < simscape.battery.builder.internal.export.Block




    properties ( Constant )
        BlockType = "SimscapeBlock";
    end

    properties ( GetAccess = public, SetAccess = immutable )
        PackageName string{ mustBeTextScalar( PackageName ) } = "";
    end

    properties ( Dependent )
        BlockPath
        ComponentPath
    end

    properties ( Access = private )
        LibraryNameIsSet( 1, 1 )logical{ mustBeA( LibraryNameIsSet, "logical" ) } = false;
        LibraryName string{ mustBeTextScalar( LibraryName ) } = "";
        IsBuilt( 1, 1 )logical{ mustBeA( IsBuilt, "logical" ) } = false;
    end

    methods
        function obj = SimscapeBlock( identifier, blockParameters, blockInputs, blockVariables, packageName )

            obj.Identifier = identifier;
            obj.BlockParameters = blockParameters;
            obj.BlockInputs = blockInputs;
            obj.BlockVariables = blockVariables;
            obj.PackageName = packageName;
        end

        function obj = setBatteryType( obj, batteryType )

            arguments
                obj( 1, 1 ){ mustBeA( obj, "simscape.battery.builder.internal.export.SimscapeBlock" ) }
                batteryType string{ mustBeMember( batteryType, [ "ParallelAssembly", "Module" ] ) }
            end
            obj.BatteryType = batteryType;
        end

        function blockPath = get.BlockPath( obj )

            packages = strsplit( obj.PackageName, '.' );
            packages( 1 ) = obj.LibraryName;
            splitBlockPath = [ packages, obj.Identifier ];
            blockPath = strjoin( splitBlockPath, '/' );
        end

        function componentPath = get.ComponentPath( obj )

            componentPath = obj.PackageName.append( '.', obj.Identifier );
        end

        function obj = setSimulinkLibraryName( obj, libraryName )
            [ obj( : ).LibraryName ] = deal( libraryName );
        end
    end
end
