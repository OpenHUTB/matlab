classdef ( Abstract )PluginBaseWithInterface < downstream.plugin.PluginBase

    properties ( Access = protected )

        DeviceTree = '';
        IsDeviceTreeCompiled = false;
        IsDeviceTreeOverlay = false;
        DeviceTreeIncludeDirs string
    end

    properties ( Access = protected )
        hRAWInterfaceList = [  ];
        isAXI4SlaveInterfaceRequired = false;
    end

    properties ( Hidden )
        PluginFileName = '';
        PluginPath = '';
        PluginPackage = '';
    end

    methods

        function obj = PluginBaseWithInterface(  )

            obj.hRAWInterfaceList = hdlturnkey.interface.InterfaceListBase(  );
        end

    end


    methods
        function addDeviceTree( obj, devTree, devTreeOptions )
            arguments
                obj
                devTree{ hdlturnkey.plugin.PluginBaseWithInterface.validateDeviceTree }
                devTreeOptions.IsOverlay logical = false;
            end

            if ~isempty( obj.DeviceTree )
                error( message( 'hdlcommon:plugin:DuplicateDeviceTree' ) );
            end

            obj.DeviceTree = devTree;
            obj.IsDeviceTreeCompiled = obj.isDeviceTreeCompiled( devTree );
            obj.IsDeviceTreeOverlay = devTreeOptions.IsOverlay;
        end

        function addDeviceTreeIncludeDirectory( obj, includeDirs )
            arguments
                obj
                includeDirs{ mustBeText }
            end


            obj.DeviceTreeIncludeDirs = [ obj.DeviceTreeIncludeDirs, includeDirs ];
        end
    end

    methods ( Hidden )
        function [ devTree, isCompiled, isOverlay ] = getDeviceTree( obj )
            isCompiled = obj.IsDeviceTreeCompiled;
            isOverlay = obj.IsDeviceTreeOverlay;

            if isCompiled


                devTree = fullfile( obj.getPluginPath, obj.DeviceTree );
            else


                devTree = obj.DeviceTree;
            end
        end

        function [ includeDirs, validateCell ] = getDeviceTreeIncludeDirs( obj, cmdDisplay )
            if nargin < 2
                cmdDisplay = true;
            end
            validateCell = {  };

            includeDirs = string.empty;
            for dirPath = obj.DeviceTreeIncludeDirs
                if isfolder( fullfile( dirPath ) )

                    dirPathFull = dirPath;
                elseif isfolder( fullfile( obj.getPluginPath, dirPath ) )


                    dirPathFull = fullfile( obj.getPluginPath, dirPath );
                else

                    msg = message( 'hdlcommon:plugin:DeviceTreeIncludeDirMissing', dirPath, obj.PluginFileName );
                    if cmdDisplay
                        warning( msg );
                    else
                        validateCell{ end  + 1 } = hdlvalidatestruct( 'Warning', msg );%#ok<AGROW>
                    end


                    continue ;
                end
                includeDirs( end  + 1 ) = dirPathFull;%#ok<AGROW>
            end


            includeDirs = [ includeDirs, obj.getPluginPath ];
        end
    end


    methods ( Hidden = true )



        function addInterface( obj, hInterface )

            hInterface.validateInterface;


            obj.hRAWInterfaceList.addInterface( hInterface );
        end
        function hInterface = getInterface( obj, InterfaceID )
            hInterface = obj.hRAWInterfaceList.getInterface( InterfaceID );
        end
        function list = getInterfaceIDList( obj )
            list = obj.hRAWInterfaceList.getInterfaceIDList;
        end


        function propVal = getInterfaceProperty( obj, interfaceID, varargin )
            propVal = obj.hRAWInterfaceList.getInterfaceProperty( interfaceID, varargin{ : } );
        end


        function list = getInputInterfaceIDList( obj )
            list = obj.hRAWInterfaceList.getInputInterfaceIDList;
        end
        function list = getOutputInterfaceIDList( obj )
            list = obj.hRAWInterfaceList.getOutputInterfaceIDList;
        end
        function populateRAWINOUTInterfaceIDList( obj )
            obj.hRAWInterfaceList.populateRAWINOUTInterfaceIDList;
        end

    end


    methods ( Access = protected )
        function pluginPath = getPluginPath( obj )

            pluginPath = obj.PluginPath;
        end
    end

    methods ( Static, Access = protected )
        function validateDeviceTree( devTree )


            if ~( downstream.tool.isTextScalar( devTree ) || isa( devTree, 'devicetree' ) )
                error( message( 'hdlcommon:plugin:InvalidDeviceTree' ) );
            end


            if downstream.tool.isTextScalar( devTree )
                [ ~, ~, ext ] = fileparts( devTree );
                if ~ismember( ext, [ ".dts", ".dtsi", ".dtb" ] )
                    error( message( 'hdlcommon:plugin:InvalidDeviceTreeExtension', devTree ) );
                end
            end
        end

        function isCompiled = isDeviceTreeCompiled( devTree )

            isCompiled = false;
            if downstream.tool.isTextScalar( devTree )
                [ ~, ~, ext ] = fileparts( devTree );
                isCompiled = strcmp( ext, ".dtb" );
            end
        end
    end
end


