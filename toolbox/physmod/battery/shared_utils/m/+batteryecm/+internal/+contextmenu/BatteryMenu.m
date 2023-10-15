classdef BatteryMenu




    methods ( Static )
        function schema = mainMenu( callbackInfo )

            schema = sl_container_schema;
            schema.label = getString( message( 'physmod:battery:shared_utils:BatteryMenu:label_Battery' ) );
            schema.tag = 'batteryecm:BatteryMenu';
            schema.state = 'Hidden';
            schema.autoDisableWhen = 'Busy';
            if batteryecm.internal.contextmenu.BatteryMenu.selectionIsQuickPlotSupported( callbackInfo )
                schema.state = 'Enabled';
                schema.childrenFcns = { @batteryecm.internal.contextmenu.BatteryMenu.quickPlotMenu };
            end
        end

        function schema = quickPlotMenu( callbackInfo )

            schema = sl_action_schema;
            schema.label = getString( message( 'physmod:battery:shared_utils:BatteryMenu:label_BasicCharacteristics' ) );
            schema.tag = 'batteryecm:QuickPlot';
            schema.state = 'Hidden';
            schema.callback = @batteryecm.internal.contextmenu.BatteryMenu.quickPlotCallback;
            schema.autoDisableWhen = 'Busy';
            if batteryecm.internal.contextmenu.BatteryMenu.selectionIsQuickPlotSupported( callbackInfo )
                schema.state = 'Enable';
            end
        end

        function quickPlotCallback( callbackInfo )

            selection = callbackInfo.getSelection;
            componentPath = selection.ComponentPath;
            switch componentPath
                case { 'batteryecm.battery', 'batteryecm.battery_instrumented' }
                    batteryecm.internal.contextmenu.BatteryMenu.batteryQuickPlot( selection.Handle );
                case { 'batteryecm.battery_thermal', 'batteryecm.battery_thermal_instrumented' }
                    batteryecm.internal.contextmenu.BatteryMenu.thermalBatteryQuickPlot( selection.Handle );
                case { 'batteryecm.table_battery' }
                    batteryecm.internal.contextmenu.BatteryMenu.tableBatteryQuickPlot( selection.Handle );
                otherwise
                    pm_error( 'physmod:battery:shared_utils:BatteryMenu:componentNotSupported' );
            end

        end

        function [ hFigure, hAxes, hLine, hLegend ] = batteryQuickPlot( blockHandle )

            prm_AH = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'prm_AH' ), '1' );

            if prm_AH == 2
                vnom = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'Vnom' ), 'V' );
                ah = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'AH' ), 'hr*A' );
                v1 = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'V1' ), 'V' );
                ah1 = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'AH1' ), 'hr*A' );


                if vnom <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:Vnom' ) ) );
                end
                if ah <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:AH' ) ) );
                end
                if ah1 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:AH1' ) ) );
                end
                if ah1 >= ah
                    pm_error( 'physmod:simscape:compiler:patterns:checks:LessThan', getString( message( 'physmod:battery:shared_library:comments:battery_base:AH1' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_base:AH' ) ) );
                end
                if v1 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:V1' ) ) );
                end
                if v1 >= vnom
                    pm_error( 'physmod:simscape:compiler:patterns:checks:LessThan', getString( message( 'physmod:battery:shared_library:comments:battery_base:V1' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_base:Vnom' ) ) );
                end


                beta = ( v1 * ah - vnom * ah1 ) / v1 / ( ah - ah1 );
                soc = linspace( 1, 0, 101 );
                voc = vnom * soc ./ ( 1 - beta * ( 1 - soc ) );
                [ hFigure, hAxes, hLine, hLegend ] = batteryecm.internal.contextmenu.BatteryMenu.createQuickPlot( blockHandle, 100 * soc, voc );
            else
                vnom = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'Vnom' ), 'V' );


                if vnom <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:Vnom' ) ) );
                end
                [ hFigure, hAxes, hLine, hLegend ] = batteryecm.internal.contextmenu.BatteryMenu.createQuickPlot( blockHandle, linspace( 100, 0, 101 ), vnom * ones( 1, 101 ) );
            end
        end

        function [ hFigure, hAxes, hLine, hLegend ] = thermalBatteryQuickPlot( blockHandle )

            import batteryecm.internal.contextmenu.BatteryMenu
            prm_AH = value( batteryecm.internal.contextmenu.BatteryMenu.getParamWithUnit( blockHandle, 'prm_AH' ), '1' );

            t1Raw = BatteryMenu.getParamWithUnit( blockHandle, 'Tmeas' );
            t2Raw = BatteryMenu.getParamWithUnit( blockHandle, 'Tmeas2' );
            t1Unit = t1Raw.unit;
            t2Unit = t2Raw.unit;
            t1 = value( t1Raw, t1Unit );
            t2 = value( t2Raw, t2Unit );
            if prm_AH == 2
                vnom = value( BatteryMenu.getParamWithUnit( blockHandle, 'Vnom' ), 'V' );
                vnom2 = value( BatteryMenu.getParamWithUnit( blockHandle, 'Vnom_T2' ), 'V' );
                ah = value( BatteryMenu.getParamWithUnit( blockHandle, 'AH' ), 'hr*A' );
                v1 = value( BatteryMenu.getParamWithUnit( blockHandle, 'V1' ), 'V' );
                v12 = value( BatteryMenu.getParamWithUnit( blockHandle, 'V1_T2' ), 'V' );
                ah1 = value( BatteryMenu.getParamWithUnit( blockHandle, 'AH1' ), 'hr*A' );
                t1K = value( BatteryMenu.getParamWithUnit( blockHandle, 'Tmeas' ), 'K' );
                t2K = value( BatteryMenu.getParamWithUnit( blockHandle, 'Tmeas2' ), 'K' );


                if vnom <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:Vnom' ) ) );
                end
                if t1K <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas' ) ) )
                end
                if t2K <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas2' ) ) )
                end
                if t2K == t1K
                    pm_error( 'physmod:simscape:compiler:patterns:checks:NotEqual', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas2' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas' ) ) )
                end
                if vnom2 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas2' ) ) );
                end
                if ah <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:AH' ) ) );
                end
                if ah1 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:AH1' ) ) );
                end
                if ah1 >= ah
                    pm_error( 'physmod:simscape:compiler:patterns:checks:LessThan', getString( message( 'physmod:battery:shared_library:comments:battery_base:AH1' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_base:AH' ) ) );
                end
                if v1 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:V1' ) ) );
                end
                if v1 >= vnom
                    pm_error( 'physmod:simscape:compiler:patterns:checks:LessThan', getString( message( 'physmod:battery:shared_library:comments:battery_base:V1' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_base:Vnom' ) ) );
                end
                if v12 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:V1_T2' ) ) );
                end
                if v12 >= vnom2
                    pm_error( 'physmod:simscape:compiler:patterns:checks:LessThan', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:V1_T2' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Vnom_T2' ) ) );
                end


                beta = ( v1 * ah - vnom * ah1 ) / v1 / ( ah - ah1 );
                beta2 = ( v12 * ah - vnom2 * ah1 ) / v12 / ( ah - ah1 );
                soc = linspace( 1, 0, 101 );
                voc = vnom * soc ./ ( 1 - beta * ( 1 - soc ) );
                voc2 = vnom2 * soc ./ ( 1 - beta2 * ( 1 - soc ) );
                leg{ 1 } = sprintf( '%g%s', t1, char( t1Unit ) );
                leg{ 2 } = sprintf( '%g%s', t2, char( t2Unit ) );
                [ hFigure, hAxes, hLine, hLegend ] = BatteryMenu.createQuickPlot( blockHandle, 100 * soc, [ reshape( voc, 1, [  ] );reshape( voc2, 1, [  ] ) ], 'Legend', leg );
            else
                vnom = value( BatteryMenu.getParamWithUnit( blockHandle, 'Vnom' ), 'V' );
                vnom2 = value( BatteryMenu.getParamWithUnit( blockHandle, 'Vnom_T2' ), 'V' );
                t1K = value( BatteryMenu.getParamWithUnit( blockHandle, 'Tmeas' ), 'K' );
                t2K = value( BatteryMenu.getParamWithUnit( blockHandle, 'Tmeas2' ), 'K' );


                if vnom <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_base:Vnom' ) ) );
                end
                if t1K <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas' ) ) )
                end
                if t2K <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas2' ) ) )
                end
                if t2K == t1K
                    pm_error( 'physmod:simscape:compiler:patterns:checks:NotEqual', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas2' ) ), getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Tmeas' ) ) )
                end
                if vnom2 <= 0
                    pm_error( 'physmod:simscape:compiler:patterns:checks:GreaterThanZero', getString( message( 'physmod:battery:shared_library:comments:battery_thermal:Vnom_T2' ) ) );
                end

                leg{ 1 } = sprintf( '%g%s', t1, char( t1Unit ) );
                leg{ 2 } = sprintf( '%g%s', t2, char( t2Unit ) );
                [ hFigure, hAxes, hLine, hLegend ] = BatteryMenu.createQuickPlot( blockHandle, linspace( 100, 0, 101 ), [ vnom * ones( 1, 101 );vnom2 * ones( 1, 101 ) ], 'Legend', leg );
            end
        end

        function [ hFigure, hAxes, hLine, hLegend ] = tableBatteryQuickPlot( blockHandle )

            import batteryecm.internal.contextmenu.BatteryMenu
            soc = value( BatteryMenu.getParamWithUnit( blockHandle, 'SOC_vec' ), '1' );
            if any( diff( soc ) <= 0 )
                pm_error( 'physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec', getString( message( 'physmod:battery:shared_library:comments:table_battery:SOC_vec' ) ) );
            end
            if any( soc < 0 )
                pm_error( 'physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqualZero', getString( message( 'physmod:battery:shared_library:comments:table_battery:SOC_vec' ) ) );
            end
            if any( soc > 1 )
                pm_error( 'physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual', getString( message( 'physmod:battery:shared_library:comments:table_battery:SOC_vec' ) ), '1' );
            end
            tDependence = value( BatteryMenu.getParamWithUnit( blockHandle, 'T_dependence' ), '1' );

            if tDependence == 1

                voltageMatrix = value( BatteryMenu.getParamWithUnit( blockHandle, 'V0_mat' ), 'V' );
                temperatureRaw = BatteryMenu.getParamWithUnit( blockHandle, 'T_vec' );
                temperatureUnit = temperatureRaw.unit;
                temperature = value( temperatureRaw, temperatureUnit );


                if any( diff( temperature ) <= 0 )
                    pm_error( 'physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec', getString( message( 'physmod:battery:shared_library:comments:table_battery:T_vec' ) ) );
                end
                if any( voltageMatrix( : ) < 0 )
                    pm_error( 'physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqualZero', getString( message( 'physmod:battery:shared_library:comments:table_battery:V0_mat' ) ) );
                end
                if any( size( voltageMatrix ) ~= [ length( soc ), length( temperature ) ] )
                    pm_error( 'physmod:simscape:compiler:patterns:checks:Size2DEqual', getString( message( 'physmod:battery:shared_library:comments:table_battery:V0_mat' ) ), getString( message( 'physmod:battery:shared_library:comments:table_battery:SOC_vec' ) ), getString( message( 'physmod:battery:shared_library:comments:table_battery:T_vec' ) ) );
                end


                leg = cell( 1, length( temperature ) );
                for ii = 1:length( temperature )
                    leg{ ii } = sprintf( '%g%s', temperature( ii ), char( temperatureUnit ) );
                end
                [ hFigure, hAxes, hLine, hLegend ] = BatteryMenu.createQuickPlot( blockHandle, 100 * soc, voltageMatrix', 'Legend', leg );
            else

                voltageVector = value( BatteryMenu.getParamWithUnit( blockHandle, 'V0_vec' ), 'V' );


                if any( voltageVector( : ) < 0 )
                    pm_error( 'physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqualZero', getString( message( 'physmod:battery:shared_library:comments:table_battery:V0_vec' ) ) );
                end
                if length( voltageVector ) ~= length( soc )
                    pm_error( 'physmod:simscape:compiler:patterns:checks:SizeEqualSize', getString( message( 'physmod:battery:shared_library:comments:table_battery:V0_vec' ) ), getString( message( 'physmod:battery:shared_library:comments:table_battery:SOC_vec' ) ) );
                end


                [ hFigure, hAxes, hLine, hLegend ] = BatteryMenu.createQuickPlot( blockHandle, 100 * soc, reshape( voltageVector, 1, [  ] ) );
            end
        end

        function [ hFigure, hAxes, hLine, hLegend ] = createQuickPlot( blockHandle, soc, ocv, plotInfo )

            arguments
                blockHandle
                soc
                ocv
                plotInfo.Legend cell = {  };
            end
            name = get_param( blockHandle, 'Name' );
            parent = get_param( blockHandle, 'Parent' );
            blockName = [ parent, '/', name ];
            hFigure = figure( 'Name', blockName );
            set( 0, 'CurrentFigure', hFigure );
            hAxes = axes;
            hLine = zeros( 1, height( soc ) );
            for curveIdx = 1:height( ocv )
                hLine( curveIdx ) = plot( hAxes, soc, ocv( curveIdx, : ), '-' );
                hold on;
            end
            hold off;
            set( hAxes, 'XDir', 'reverse' );


            xlab = getString( message( 'physmod:battery:shared_utils:BatteryMenu:label_StateOfCharge' ) );
            ylab = getString( message( 'physmod:battery:shared_utils:BatteryMenu:label_NoLoadVoltage' ) );
            xlabel( hAxes, xlab );
            ylabel( hAxes, ylab );


            if ~isempty( plotInfo.Legend )
                hLegend = legend( hAxes, plotInfo.Legend, 'Location', 'Best' );
                axis tight;
            else
                hLegend = [  ];
            end
        end
    end

    methods ( Static, Access = private )
        function isSupported = selectionIsQuickPlotSupported( callbackInfo )

            selection = callbackInfo.getSelection;
            if numel( selection ) == 1 &&  ...
                    strcmpi( selection.Type, 'block' ) &&  ...
                    strcmpi( selection.BlockType, 'SimscapeBlock' )

                componentPath = selection.ComponentPath;
                isSupported = any( strcmp( componentPath,  ...
                    { 'batteryecm.battery',  ...
                    'batteryecm.battery_instrumented',  ...
                    'batteryecm.battery_thermal',  ...
                    'batteryecm.battery_thermal_instrumented',  ...
                    'batteryecm.table_battery' } ) );
            else
                isSupported = false;
            end
        end

        function result = getParamWithUnit( handle, name )

            paramTable = foundation.internal.mask.getEvaluatedBlockParameters( handle, true );

            names = string( paramTable.Properties.RowNames );
            values = paramTable.Value;
            units = paramTable.Unit;

            idx = find( strcmpi( names, name ), 1 );

            if isempty( values{ idx } ) || ischar( values{ idx } )
                pm_error( 'physmod:battery:shared_utils:BatteryMenu:ParameterUndefined', name );
            end
            if isempty( units{ idx } )
                result = simscape.Value( values{ idx } );
            else
                result = simscape.Value( values{ idx }, units{ idx } );
            end
        end
    end
end


