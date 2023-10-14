classdef ( Sealed = true, Hidden = true )CellData

    properties ( SetAccess = immutable, GetAccess = private )
        BlockPath string{ mustBeTextScalar } = ""
        ComponentPath string{ mustBeTextScalar } = ""
        ControlParameters table
        BlockSchema simscape.schema.ComponentSchema{ mustBeA( BlockSchema, "simscape.schema.ComponentSchema" ) } = simscape.schema.ComponentSchema.empty
    end

    properties ( Access = private )
        groupMessageMapping = dictionary( string( { getString( message( 'physmod:battery:shared_library:gui:table_battery:tab_Main' ) ),  ...
            getString( message( 'physmod:battery:shared_library:gui:table_battery:tab_Dynamics' ) ),  ...
            getString( message( 'physmod:battery:shared_library:gui:table_battery:tab_Fade' ) ),  ...
            getString( message( 'physmod:battery:shared_library:gui:table_battery:tab_CalendarAging' ) ),  ...
            getString( message( 'physmod:battery:shared_library:gui:table_battery:tab_Thermal' ) ) } ),  ...
            [ "physmod:battery:shared_library:gui:table_battery:tab_Main", "physmod:battery:shared_library:gui:table_battery:tab_Dynamics",  ...
            "physmod:battery:shared_library:gui:table_battery:tab_Fade", "physmod:battery:shared_library:gui:table_battery:tab_CalendarAging",  ...
            "physmod:battery:shared_library:gui:table_battery:tab_Thermal" ] );
    end

    properties ( Access = private, Constant )
        AlwaysDefaultParameters = [ "SOC_port" ];
    end

    methods
        function obj = CellData( cellModelBlock )

            arguments
                cellModelBlock( 1, 1 )simscape.battery.builder.CellModelBlock{ mustBeA( cellModelBlock, "simscape.battery.builder.CellModelBlock" ) };
            end
            obj.BlockPath = cellModelBlock.CellModelBlockPath;


            controlParameterNames = string( fieldnames( cellModelBlock.BlockParameters ) );
            controlParameterValues = struct2cell( cellModelBlock.BlockParameters );
            controlParameterValueStrings = cellfun( @( controlParameter )string( class( controlParameter ) ) + "." + controlParameter.string, controlParameterValues, 'UniformOutput', false );
            obj.ControlParameters = table( controlParameterNames, controlParameterValues, [ controlParameterValueStrings{ : } ]', VariableNames = [ "Name", "Value", "ValueString" ] );



            splitBlockPath = split( obj.BlockPath, "/" );
            libraryName = splitBlockPath( 1 );
            if ~bdIsLoaded( libraryName )
                load_system( libraryName );
                cleanup = onCleanup( @(  )bdclose( libraryName ) );
            else

            end


            obj.BlockSchema = physmod.schema.internal.blockComponentSchema( obj.BlockPath );
        end

        function controlParameters = getControlParameterStringValue( obj )

            controlParameters = [ obj.ControlParameters.Name, obj.ControlParameters.ValueString ];
        end

        function dotPath = getComponentDotPath( obj )

            dotPath = string( obj.BlockSchema.info.DotPath );
        end

        function visibleParameters = getVisibleParameters( obj )

            controlData = obj.getControlData( obj.BlockSchema );
            schemaInfo = obj.BlockSchema.info(  );
            allParameters = schemaInfo.Members.Parameters;
            visibilityIdx = simscape.schema.internal.visible( { allParameters.ID }, obj.BlockSchema, controlData );
            rawVisibleParameters = allParameters( visibilityIdx );


            parameterId = string( { rawVisibleParameters.ID } )';
            parameterLabel = obj.getLabel( parameterId );

            defaultParameters = [ rawVisibleParameters.Default ];
            defaultParameterValues = string( { defaultParameters.Value }' );
            defaultParameterUnits = string( { defaultParameters.Unit }' );

            groupString = string( { rawVisibleParameters.Group } )';
            groupMessageId = obj.groupMessageMapping( groupString );
            parameterGroup = arrayfun( @( x )string( getString( message( x ), matlab.internal.i18n.locale( 'en_US' ) ) ), groupMessageId );
            scaling = repmat( "1", size( parameterId ) );

            visibleParameters = simscape.battery.builder.internal.export.ComponentParameters(  );
            visibleParameters = visibleParameters.addParameters( parameterId, parameterLabel,  ...
                defaultParameterValues, defaultParameterUnits, parameterGroup, scaling );



            visibleParameters = visibleParameters.removeParametersWithId( [ obj.ControlParameters.Name;obj.AlwaysDefaultParameters ] );
        end

        function visibleVariables = getVisibleVariables( obj )

            controlData = obj.getControlData( obj.BlockSchema );
            schemaInfo = obj.BlockSchema.info(  );
            allVariables = schemaInfo.Members.Variables;
            visibilityIdx = simscape.schema.internal.visible( { allVariables.ID }, obj.BlockSchema, controlData );
            rawVisibleVariables = allVariables( visibilityIdx );


            variableIds = string( { rawVisibleVariables.ID } )';
            variableLabels = obj.getLabel( variableIds );
            defaultVariable = [ rawVisibleVariables.Default ];
            defaultPriority = string( { defaultVariable.Priority }' );
            defaultData = [ defaultVariable.Value ];
            defaultValues = string( { defaultData.Value }' );
            defaultSize = repmat( "1", size( defaultValues ) );
            defaultUnits = string( { defaultData.Unit }' );

            visibleVariables = simscape.battery.builder.internal.export.ComponentVariables;
            visibleVariables = visibleVariables.addVariables( variableIds, variableLabels, defaultValues, defaultSize, defaultUnits, defaultPriority );
        end
    end

    methods ( Access = private )
        function controlData = getControlData( obj, blockSchema )

            defaultControlData = blockSchema.defaultControls(  );
            defaultControlDataIds = string( { defaultControlData.ID } );

            for controlParameterIdx = 1:height( obj.ControlParameters )
                controlDataIdx = obj.ControlParameters.Name( controlParameterIdx ) == defaultControlDataIds;
                defaultControlData( controlDataIdx ).Value = simscape.Value( obj.ControlParameters.Value{ controlParameterIdx } );
            end
            controlData = defaultControlData;
        end
    end

    methods ( Access = private, Static )
        function label = getLabel( ids )

            messageID = "physmod:battery:shared_library:comments:table_battery:" + ids;
            label = arrayfun( @( x )string( getString( message( x ), matlab.internal.i18n.locale( 'en_US' ) ) ), messageID );
        end
    end
end

