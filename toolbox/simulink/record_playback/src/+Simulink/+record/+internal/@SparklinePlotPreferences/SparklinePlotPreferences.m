classdef SparklinePlotPreferences < Simulink.record.internal.TimePlotPreferences



    properties


        SubPlotID


        TimeLabelsDisplay


        minHeight

    end

    methods


        function obj = SparklinePlotPreferences( plotIndex )
            if nargin > 0
                obj.SubPlotID = plotIndex;
            end
            obj.TicksColor = [ 0, 0, 0 ];
            obj.PlotColor = [ 1, 1, 1 ];
            obj.GridColor = [ 0.815, 0.823, 0.827 ];
            obj.TicksPosition = 'Inside';
            obj.TimeLabelsDisplay = 'lastSparkline';
            obj.TickLabels = 'All';
            obj.LegendPosition = 'InsideLeft';
            obj.Markers = 'Hide';
            obj.GridLines = 'All';
            obj.PlotBorder = 'Show';
            obj.UpdateMode = 'Wrap';
            obj.TimeSpan = 'Auto';
            obj.TLimits = [ 0, 100 ];
            obj.minHeight = 60;
        end


        function obj = set.minHeight( obj, minHeight )
            arguments
                obj
                minHeight{ mustBeInteger, mustBePositive }
            end
            validateattributes( minHeight, { 'numeric' }, { '>=', 50, '<', 750 } );
            obj.minHeight = minHeight;
        end


        function obj = set.TimeLabelsDisplay( obj, timeLabelsDisplay )
            labelSelectionValid = strcmpi( timeLabelsDisplay, obj.TIME_LABELS_DISPLAY );
            if any( labelSelectionValid )
                labelSelection( 1 ) = find( labelSelectionValid );
                obj.TimeLabelsDisplay = obj.TIME_LABELS_DISPLAY{ labelSelection };
            else
                throwAsCaller( MException( 'record_playback:errors:InvalidTimeLabelsDisplay',  ...
                    DAStudio.message( 'record_playback:errors:InvalidTimeLabelsDisplay' ) ) );
            end
        end


        function obj = set.SubPlotID( obj, plotIndex )
            Simulink.record.internal.verifySubPlot( plotIndex );
            obj.SubPlotID = plotIndex;
        end

    end

    methods ( Static )

        function sparklineObj = createSparklinePrefsFromDataModel( subPlotID, sparklineSettings )
            arguments
                subPlotID
                sparklineSettings SdiVisual.SparklineSettings
            end


            subPlotID = Simulink.record.internal.verifySubPlot( subPlotID );


            sparklineObj = Simulink.record.internal.SparklinePlotPreferences( subPlotID );

            sparklineObj.TicksColor = utils.toolstrip.getColorAsMxArrayFromHexStr( sparklineSettings.axisColor );
            sparklineObj.PlotColor = utils.toolstrip.getColorAsMxArrayFromHexStr( sparklineSettings.plotAreaColor );
            sparklineObj.GridColor = utils.toolstrip.getColorAsMxArrayFromHexStr( sparklineSettings.gridColor );
            sparklineObj.TicksPosition = utils.preferenceUtils.getTickPositionStr( sparklineSettings.tickPos );
            sparklineObj.TimeLabelsDisplay = utils.preferenceUtils.getTimeLabelsDisplayStr( sparklineSettings.timeLabelsDisplay );
            sparklineObj.TickLabels = utils.preferenceUtils.getTickLabelStr( sparklineSettings.Ticklabels );
            sparklineObj.LegendPosition = utils.preferenceUtils.getLegendPositionStr( sparklineSettings.legendPos );
            sparklineObj.Markers = utils.preferenceUtils.getVisibilityStr( sparklineSettings.markers );
            sparklineObj.GridLines = utils.preferenceUtils.getGridDisplayStr( sparklineSettings.gridDisplay );
            sparklineObj.UpdateMode = utils.preferenceUtils.getUpdateModeStr( sparklineSettings.updateMode );
            sparklineObj.PlotBorder = utils.preferenceUtils.getVisibilityStr( sparklineSettings.axisBorder );
            sparklineObj.TimeSpan = utils.preferenceUtils.getTimeSpanStr( sparklineSettings.xAxisLimits );
            sparklineObj.TLimits = [ sparklineSettings.xAxisLimits.minimum, sparklineSettings.xAxisLimits.maximum ];
            sparklineObj.minHeight = sparklineSettings.minHeight;

        end

    end


    properties ( Constant, Access = protected )

        TIME_LABELS_DISPLAY = { DAStudio.message( 'record_playback:params:ShowLastSparkline' ),  ...
            DAStudio.message( 'record_playback:params:ShowAllSparklines' ) }
    end
end

