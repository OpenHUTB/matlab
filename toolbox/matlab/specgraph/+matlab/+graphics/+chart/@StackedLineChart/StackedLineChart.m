classdef ( ConstructOnLoad, Sealed )StackedLineChart <  ...
        matlab.graphics.chart.internal.SubplotPositionableChart &  ...
        matlab.graphics.chartcontainer.mixin.internal.OuterPositionChangedEventMixin &  ...
        matlab.graphics.chartcontainer.mixin.ColorOrderMixin








    properties ( Transient, Hidden, SetAccess = protected, NonCopyable )
        Type = 'stackedplot'
    end

    properties ( Access = protected )
        ColorOrderInternalMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
    end









    properties ( Dependent, AffectsObject )


        SourceTable = timetable.empty




        XData = zeros( 1, 0 )





        YData = zeros( 0, 0 )





        DisplayVariables = zeros( 1, 0 )







        XVariable






        CombineMatchingNames
    end

    properties ( Dependent, AffectsObject )


        XLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString






        DisplayLabels



        Title matlab.internal.datatype.matlab.graphics.datatype.NumericOrString





        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = [ 0, 0.447, 0.741 ]





        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle = '-'





        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive = 0.5




        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle = 'none'





        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = 'none'





        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = [ 0, 0.447, 0.741 ]




        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive = 6





        LineProperties( :, 1 )matlab.graphics.chart.stackedplot.StackedLineProperties




        AxesProperties( :, 1 )matlab.graphics.chart.stackedplot.StackedAxesProperties




        LegendLabels = {  }










        LegendOrientation matlab.internal.datatype.matlab.graphics.chart.datatype.LegendOrientationType = 'horizontal'



        LegendVisible matlab.internal.datatype.matlab.graphics.datatype.on_off = 'off'
    end

    properties ( Dependent, AffectsObject )


        XLimits = [ 0, 1 ]
    end

    properties ( AffectsObject )


        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName = get( groot, 'FactoryAxesFontName' )




        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive = 8
    end

    properties ( AffectsObject, Resettable = false )



        Units = 'normalized'
    end

    properties



        GridVisible matlab.internal.datatype.matlab.graphics.datatype.on_off = 'off'
    end

    properties ( Hidden, AffectsObject )


        DisplayVariablesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
    end

    properties ( Hidden, Dependent )


        XLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
    end

    properties ( Hidden )


        XLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'



        DisplayLabelsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'

        XLimitsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'



        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'



        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'





        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'manual'



        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'



        LegendLabelsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'



        LegendVisibleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
    end

    properties ( Hidden )
        XLimits_I = [ 0, 1 ]



    end




    properties ( Hidden, Resettable = false )
        ActivePositionProperty_I matlab.graphics.chart.datatype.ChartActivePositionType = 'outerposition'
        PositionConstraint_I matlab.internal.datatype.matlab.graphics.datatype.PositionConstraint = 'outerposition';
    end

    properties ( Hidden, AffectsObject )
        SourceTable_I = timetable.empty
        XData_I
        YData_I
        Title_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString


        DisplayVariables_I = zeros( 1, 0 )
        XVariable_I
        CombineMatchingNames_I = true
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = [ 0, 0.447, 0.741 ]
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle = '-'
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive = 0.5
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle = 'none'
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = 'none'
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor = [ 0, 0.447, 0.741 ]
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive = 6
        DisplayLabels_I cell = cell( 1, 0 )
        XLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString = ''
        LineProperties_I( :, 1 )matlab.graphics.chart.stackedplot.StackedLineProperties
        AxesProperties_I( :, 1 )matlab.graphics.chart.stackedplot.StackedAxesProperties
        LegendLabels_I = {  }
        LegendLocation_I matlab.internal.datatype.matlab.graphics.datatype.LegendInsideLocationType = 'northwest'
        LegendVisible_I matlab.internal.datatype.matlab.graphics.datatype.on_off = 'off'
        LegendOrientation_I matlab.internal.datatype.matlab.graphics.chart.datatype.LegendOrientationType = 'horizontal'
    end

    properties ( Constant, Access = ?matlab.unittest.TestCase )
        LineStyleOrderInternal = setdiff( set( groot, 'DefaultLineLineStyle' ), 'none', 'stable' )'
    end

    properties ( Hidden, Dependent, NonCopyable,  ...
            Access = { ?matlab.graphics.chart.internal.stackedplot.StackedInteractionStrategy,  ...
            ?matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor,  ...
            ?tConstruction,  ...
            ?tProperties,  ...
            ?tWorkflow,  ...
            ?tTooManyVarsToDisplay,  ...
            ?tStackedplotInteractions } )
        Axes
    end

    properties ( Hidden, Transient, NonCopyable )
        Axes_I
    end



    properties ( Hidden, Transient, NonCopyable, AbortSet )
        LegendHandle matlab.graphics.illustration.Legend
        ChartLegendHandle matlab.graphics.illustration.Legend
    end

    properties ( Access = ?matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor,  ...
            Transient, NonCopyable )
        Plots cell
    end

    properties ( Hidden, Transient, NonCopyable, Access = { ?tTooManyVarsToDisplay, ?tProperties, ?tStackedplotInteractions } )
        MessageHandle matlab.graphics.shape.TextBox
    end

    properties ( Access = private, Transient, NonCopyable )
        Presenter matlab.graphics.chart.internal.stackedplot.Presenter
        OldState = [  ]
    end

    properties ( Access = private, Transient, NonCopyable )
        XLabelHandle matlab.graphics.primitive.Text
        TitleHandle matlab.graphics.primitive.Text
        DisplayLabelsHandle matlab.graphics.primitive.Text
        ZoomInteraction matlab.graphics.interaction.uiaxes.ScrollZoom
        PanInteraction matlab.graphics.interaction.uiaxes.Pan
        MarkedCleanListener
        LinePropertiesListener
        AxesPropertiesListener

        UnitsCache matlab.internal.datatype.matlab.graphics.datatype.Units = 'normalized'
        OuterPositionPixelsCache matlab.internal.datatype.matlab.graphics.datatype.Position
        ChartLegendWidthPixelsCache = 0
        AxesVisibleCache( 1, : )logical
        Reupdate( 1, 1 )double = 0
        IsPrinting( 1, 1 )logical = false
        JustCreated( 1, 1 )logical = true
        Constructed( 1, 1 )logical = false
    end

    properties ( Access = { ?matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor,  ...
            ?matlab.graphics.chart.internal.stackedplot.StackedInteractionStrategy,  ...
            ?tStackedplotInteractions }, Transient, NonCopyable )
        DataCursor
    end


    properties ( Access = private )






        VariableIndex





        InnerVariableIndex
    end

    properties ( Access = private )
        LooseInset_I matlab.internal.datatype.matlab.graphics.datatype.Inset = get( groot, 'FactoryAxesLooseInset' )
    end

    properties ( Access = private, Constant )



        MaxNumAxes = 25




        MinAxesHeight = 20



        GapBetweenAxes = 0.1
    end

    properties ( Access = ?matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor,  ...
            Dependent )
        NumPlotsInAxes double
    end


    properties ( Dependent, AffectsObject, SetObservable, Resettable = false )





        OuterPosition = [ 0, 0, 1, 1 ]






        InnerPosition






        Position
    end

    properties ( Dependent, AffectsObject, SetObservable, Resettable = false, NeverAmbiguous )



        PositionConstraint
    end

    properties ( Dependent, AffectsObject, SetObservable, Resettable = false, Hidden )



        ActivePositionProperty matlab.graphics.chart.datatype.ChartActivePositionType
    end

    properties ( SetAccess = private, AffectsObject, SetObservable, Hidden, Resettable = false )
        InnerPosition_I = [ 0, 0, 1, 1 ]


        OuterPosition_I = [ 0, 0, 1, 1 ]
    end

    properties ( Dependent, SetObservable, Hidden )


        Position_I
    end

    properties ( Dependent, SetAccess = private, Hidden )


        LooseInset = get( groot, 'FactoryAxesLooseInset' )
    end

    properties ( SetAccess = private, Hidden, Dependent, SetObservable )
        TightInset
    end

    properties ( Dependent, Hidden )




        ChartDecorationInset
    end

    properties ( Hidden )
        ChartDecorationInset_I matlab.internal.datatype.matlab.graphics.datatype.Inset = [ 0, 0, 0, 0 ];







        MaxInsetForSubplotCell = [ 0, 0, 0, 0 ];



        SubplotCellOuterPosition = [ 0, 0, 0, 0 ];
    end

    properties ( Access = protected, NonCopyable )


        SavedInVersion( 1, 1 )string = missing
    end

    properties ( Access = protected, Transient, NonCopyable )



        SavedInVersion_I( 1, 1 )string = missing
    end

    methods
        function hObj = StackedLineChart( varargin )
            import matlab.internal.datatypes.parseArgs


            hObj.Description = 'StackedLineChart';
            hObj.Presenter = createPresenter( hObj );

            try







                [ hObj.Parent, hObj.SourceTable, ~, varargin ] = parseArgs( { 'Parent', 'SourceTable' }, { hObj.Parent, hObj.SourceTable }, varargin{ : } );


                matlab.graphics.chart.internal.ctorHelper( hObj, varargin );
            catch e

                hObj.Parent = [  ];
                throwAsCaller( e );
            end


            hObj.setupPrintBehavior(  );


            hObj.addDependencyConsumed( { 'ref_frame', 'resolution' } );


            hObj.MarkedCleanListener = addlistener( hObj, 'MarkedClean',  ...
                @( ~, ~ )markedCleanCallback( hObj ) );

            hObj.JustCreated = true;
            hObj.Constructed = true;
            hObj.Presenter.clearWarnings(  );
        end

        function delete( hObj )

            delete( hObj.MessageHandle );
        end

        function set.SourceTable_I( hObj, T )
            hObj.Presenter.SourceTable_I = T;%#ok<MCSUP>




            if hObj.LegendLabelsMode == "auto" %#ok<MCSUP>
                hObj.LegendLabels_I = {  };%#ok<MCSUP> %
            end
        end

        function T = get.SourceTable_I( hObj )
            T = hObj.Presenter.SourceTable;
        end

        function T = get.SourceTable( hObj )
            try
                T = hObj.SourceTable_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.SourceTable( hObj, T )
            try
                hObj.Presenter.SourceTable = T;




                if hObj.LegendLabelsMode == "auto"
                    hObj.LegendLabels_I = {  };
                end
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.XData_I( hObj, xdata )
            hObj.Presenter.XData_I = xdata;%#ok<MCSUP>
        end

        function xdata = get.XData_I( hObj )
            xdata = hObj.Presenter.XData;
        end

        function xdata = get.XData( hObj )
            try
                xdata = hObj.Presenter.XData;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.XData( hObj, xdata )
            try
                hObj.Presenter.XData = xdata;
            catch ME
                throwAsCaller( ME );
            end
        end

        function ydata = get.YData_I( hObj )
            ydata = hObj.Presenter.YData;
        end

        function set.YData_I( hObj, ydata )
            hObj.Presenter.YData_I = ydata;%#ok<MCSUP>




            if hObj.LegendLabelsMode == "auto" %#ok<MCSUP>
                hObj.LegendLabels_I = {  };%#ok<MCSUP> %
            end
        end

        function ydata = get.YData( hObj )
            try
                ydata = hObj.YData_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.YData( hObj, ydata )
            try
                hObj.Presenter.YData = ydata;
            catch ME
                throwAsCaller( ME );
            end
        end

        function vars = get.DisplayVariables( hObj )
            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'DisplayVariables' );
                end
                vars = hObj.DisplayVariables_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.DisplayVariables( hObj, vars )
            try
                hObj.Presenter.DisplayVariables = vars;
                mapProperties( hObj );
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.DisplayVariables_I( hObj, vars )
            hObj.Presenter.DisplayVariables_I = vars;%#ok<MCSUP>
        end

        function vars = get.DisplayVariables_I( hObj )
            vars = hObj.Presenter.DisplayVariables;
        end

        function mode = get.DisplayVariablesMode( hObj )
            mode = hObj.Presenter.DisplayVariablesMode;
        end

        function set.DisplayVariablesMode( hObj, mode )
            hObj.Presenter.DisplayVariablesMode = mode;%#ok<MCSUP>
        end

        function xvar = get.XVariable_I( hObj )
            xvar = hObj.Presenter.XVariable;
        end

        function set.XVariable_I( hObj, xvar )
            hObj.Presenter.XVariable_I = xvar;%#ok<MCSUP>
        end

        function xvar = get.XVariable( hObj )
            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'XVariable' );
                end
                xvar = hObj.Presenter.XVariable;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.XVariable( hObj, xvar )
            try
                hObj.Presenter.XVariable = xvar;
                mapProperties( hObj );
            catch ME
                throwAsCaller( ME );
            end
        end

        function cnames = get.CombineMatchingNames_I( hObj )
            cnames = hObj.Presenter.CombineMatchingNames;
        end

        function set.CombineMatchingNames_I( hObj, cnames )
            hObj.Presenter.CombineMatchingNames_I = cnames;%#ok<MCSUP>
        end

        function cnames = get.CombineMatchingNames( hObj )
            try
                cnames = hObj.Presenter.CombineMatchingNames;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.CombineMatchingNames( hObj, cnames )
            try
                hObj.Presenter.CombineMatchingNames = cnames;
                mapProperties( hObj );
            catch ME
                throwAsCaller( ME );
            end
        end

        function xl = get.XLimits( hObj )

            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'XLimits' );
                end
                if ~isempty( hObj.Axes_I ) && strcmp( hObj.Axes_I( 1 ).Visible, 'on' )
                    hObj.XLimits_I = hObj.Axes_I( 1 ).XLim;
                end
                xl = hObj.XLimits_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.XLimits( hObj, xl )
            try
                validateattributes( xl, { 'datetime', 'duration', 'numeric', 'logical' },  ...
                    { 'numel', 2 }, class( hObj ), 'XLimits' );
                if ~( xl( 2 ) >= xl( 1 ) )
                    error( message( 'MATLAB:stackedplot:XLimitsNonIncreasing' ) );
                end


                forceFullUpdate( hObj, 'all', 'XLimits' );


                if ~isempty( hObj.Axes_I )
                    visibleindex = strcmp( { hObj.Axes_I.Visible }, 'on' );
                    visibleaxes = hObj.Axes_I( visibleindex );
                    set( visibleaxes, 'XLim', xl );
                end

                hObj.XLimits_I = xl;
                hObj.XLimitsMode_I = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function xl = xlim( hObj, limits )














            markFigure = false;
            if nargin < 2

                xl = hObj.XLimits;
            elseif ( ischar( limits ) || isStringScalar( limits ) ) &&  ...
                    ismember( lower( limits ), { 'auto', 'manual', 'mode' } )
                if strcmpi( limits, 'mode' )

                    xl = hObj.XLimitsMode;
                elseif nargout > 0

                    error( message( 'MATLAB:nargoutchk:tooManyOutputs' ) );
                else

                    hObj.XLimitsMode = limits;
                    markFigure = true;
                end
            elseif nargout > 0

                error( message( 'MATLAB:nargoutchk:tooManyOutputs' ) );
            else

                hObj.XLimits = limits;
                markFigure = true;
            end


            if markFigure
                matlab.graphics.internal.markFigure( hObj );
            end
        end

        function set.XLimitsMode( hObj, mode )
            if string( hObj.XLimitsMode ) ~= mode
                hObj.XLimits_I = hObj.Presenter.getXLimits(  );
                if ~isempty( hObj.Axes_I )
                    visibleindex = strcmp( { hObj.Axes_I.Visible }, 'on' );
                    visibleaxes = hObj.Axes_I( visibleindex );
                    set( visibleaxes, 'XLim', hObj.XLimits_I );
                end
                hObj.XLimitsMode_I = mode;
            end
        end

        function mode = get.XLimitsMode( hObj )
            forceFullUpdate( hObj, 'all', 'XLimitsMode' );
            mode = hObj.XLimitsMode_I;
        end

        function c = get.Color( hObj )
            try
                if strcmpi( get( hObj, 'ColorMode' ), 'auto' )
                    forceFullUpdate( hObj, 'all', 'Color' );
                end
                c = hObj.Color_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.Color( hObj, c )
            try
                hObj.Color_I = c;

                [ hObj.LineProperties_I.Color ] = deal( c );
                hObj.ColorMode = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.ColorMode( hObj, val )
            if string( hObj.ColorMode ) ~= val
                hObj.ColorMode = val;
                [ hObj.LineProperties_I.ColorMode ] = deal( val );%#ok<MCSUP>
            end
        end

        function ls = get.LineStyle( hObj )
            try
                ls = hObj.LineStyle_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LineStyle( hObj, ls )
            try
                hObj.LineStyle_I = ls;

                [ hObj.LineProperties_I.LineStyle ] = deal( ls );
                hObj.LineStyleMode = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LineStyleMode( hObj, val )
            if string( hObj.LineStyleMode ) ~= val
                hObj.LineStyleMode = val;
                [ hObj.LineProperties_I.LineStyleMode ] = deal( val );%#ok<MCSUP>
            end
        end

        function lw = get.LineWidth( hObj )
            try
                lw = hObj.LineWidth_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LineWidth( hObj, lw )
            try
                hObj.LineWidth_I = lw;

                [ hObj.LineProperties_I.LineWidth ] = deal( lw );
            catch ME
                throwAsCaller( ME );
            end
        end

        function c = get.MarkerFaceColor( hObj )
            try
                if strcmpi( get( hObj, 'MarkerFaceColorMode' ), 'auto' )
                    forceFullUpdate( hObj, 'all', 'MarkerFaceColor' );
                end
                c = hObj.MarkerFaceColor_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.MarkerFaceColor( hObj, c )
            try
                hObj.MarkerFaceColor_I = c;

                [ hObj.LineProperties_I.MarkerFaceColor ] = deal( c );
                hObj.MarkerFaceColorMode = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.MarkerFaceColorMode( hObj, c )
            if string( hObj.MarkerFaceColorMode ) ~= c
                hObj.MarkerFaceColorMode = c;
                [ hObj.LineProperties_I.MarkerFaceColorMode ] = deal( c );%#ok<MCSUP>
            end
        end

        function c = get.MarkerEdgeColor( hObj )
            try
                if strcmpi( get( hObj, 'MarkerEdgeColorMode' ), 'auto' )
                    forceFullUpdate( hObj, 'all', 'MarkerEdgeColor' );
                end
                c = hObj.MarkerEdgeColor_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.MarkerEdgeColor( hObj, c )
            try
                hObj.MarkerEdgeColor_I = c;

                [ hObj.LineProperties_I.MarkerEdgeColor ] = deal( c );
                hObj.MarkerEdgeColorMode = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.MarkerEdgeColorMode( hObj, val )
            if string( hObj.MarkerEdgeColorMode ) ~= val
                try
                    hObj.MarkerEdgeColorMode = val;
                    [ hObj.LineProperties_I.MarkerEdgeColorMode ] = deal( val );%#ok<MCSUP>
                catch ME
                    throwAsCaller( ME );
                end
            end
        end

        function m = get.Marker( hObj )
            try
                m = hObj.Marker_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.Marker( hObj, m )
            try
                hObj.Marker_I = m;

                [ hObj.LineProperties_I.Marker ] = deal( m );
            catch ME
                throwAsCaller( ME );
            end
        end

        function ms = get.MarkerSize( hObj )
            try
                ms = hObj.MarkerSize_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.MarkerSize( hObj, ms )
            try
                hObj.MarkerSize_I = ms;

                [ hObj.LineProperties_I.MarkerSize ] = deal( ms );
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.FontName( hObj, fontname )
            try
                if ~isempty( hObj.Axes_I )%#ok<MCSUP>

                    set( hObj.Axes_I, 'FontName', fontname );%#ok<MCSUP>
                    if ~isempty( hObj.LegendHandle )%#ok<MCSUP>
                        set( hObj.LegendHandle, 'FontName', fontname );%#ok<MCSUP>
                    end
                    if ~isempty( hObj.MessageHandle )%#ok<MCSUP>
                        hObj.MessageHandle.FontName = fontname;%#ok<MCSUP>
                    end
                end
                hObj.FontName = fontname;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.FontSize( hObj, fontsize )
            try
                if ~isempty( hObj.Axes_I )%#ok<MCSUP>

                    set( hObj.Axes_I, 'FontSize', fontsize );%#ok<MCSUP>
                    if ~isempty( hObj.LegendHandle )%#ok<MCSUP>
                        set( hObj.LegendHandle, 'FontSize', fontsize );%#ok<MCSUP>
                    end
                    if ~isempty( hObj.MessageHandle )%#ok<MCSUP>

                        hObj.MessageHandle.FontSize = fontsize * 1.1;%#ok<MCSUP>
                    end
                end
                hObj.FontSize = fontsize;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.OuterPosition( hObj, pos )
            try


                if ~isequal( hObj.Units, hObj.UnitsCache )
                    forceFullUpdate( hObj, 'all', 'OuterPosition' );
                end
                hObj.OuterPosition_I = pos;
                hObj.PositionConstraint_I = 'outerposition';

                firePostSetOuterPositionEvent( hObj, pos );
            catch ME
                throwAsCaller( ME );
            end
        end

        function pos = get.OuterPosition( hObj )
            try
                if strcmp( hObj.PositionConstraint_I, 'outerposition' )


                    if ~isequal( hObj.Units, hObj.UnitsCache )
                        forceFullUpdate( hObj, 'all', 'OuterPosition' );
                    end
                    pos = hObj.OuterPosition_I;
                else


                    forceFullUpdate( hObj, 'all', 'OuterPosition' );
                    if ~isempty( hObj.Axes_I ) && any( strcmp( { hObj.Axes_I.Visible }, 'on' ) )
                        visibleaxes = hObj.Axes_I( strcmp( { hObj.Axes_I.Visible }, 'on' ) );


                        innersaved = get( visibleaxes, 'InnerPosition' );
                        if ~iscell( innersaved )
                            innersaved = { innersaved };
                        end
                        set( visibleaxes, 'InnerPosition', hObj.InnerPosition_I );

                        outer = get( visibleaxes, 'OuterPosition' );
                        if iscell( outer )
                            outer = reshape( [ outer{ : } ], 4, [  ] );
                        else
                            outer = reshape( outer, 4, [  ] );
                        end


                        top = outer( 2, 1 ) + outer( 4, 1 );
                        bottom = outer( 2, end  );


                        left = min( outer( 1, : ) );
                        right = max( outer( 1, : ) + outer( 3, : ) );

                        if ~isempty( hObj.MessageHandle ) && strcmp( hObj.MessageHandle.Visible, 'on' )
                            bottom = min( bottom, hObj.MessageHandle.Position( 2 ) );
                        end
                        pos = [ left, bottom, right - left, top - bottom ];

                        for i = 1:numel( visibleaxes )
                            visibleaxes( i ).InnerPosition = innersaved{ i };
                        end
                    else

                        pos = hObj.InnerPosition_I;
                    end
                end
                if ~isempty( hObj.Parent )
                    if hObj.isInLayout(  )
                        pos = hObj.getRelativePosition( hObj.Parent, pos, hObj.Units );
                    end
                end
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.InnerPosition( hObj, pos )
            try


                if ~isequal( hObj.Units, hObj.UnitsCache )
                    forceFullUpdate( hObj, 'all', 'InnerPosition' );
                end

                hObj.PositionConstraint_I = 'innerposition';
                hObj.InnerPosition_I = pos;
            catch ME
                throwAsCaller( ME );
            end
        end

        function pos = get.InnerPosition( hObj )
            try
                if strcmp( hObj.PositionConstraint_I, 'innerposition' )


                    if ~isequal( hObj.Units, hObj.UnitsCache )
                        forceFullUpdate( hObj, 'all', 'InnerPosition' );
                    end
                    pos = hObj.InnerPosition_I;
                else


                    forceFullUpdate( hObj, 'all', 'InnerPosition' );
                    if ~isempty( hObj.Axes_I )

                        visibleaxes = hObj.Axes_I( strcmp( { hObj.Axes_I.Visible }, 'on' ) );
                        if ~isempty( visibleaxes )
                            pos = visibleaxes( end  ).InnerPosition;
                            pos1 = visibleaxes( 1 ).InnerPosition;
                            pos( 4 ) = pos1( 2 ) + pos1( 4 ) -  ...
                                pos( 2 );
                        else

                            pos = hObj.OuterPosition_I;
                        end
                    else

                        pos = hObj.OuterPosition_I;
                    end
                end
                if ~isempty( hObj.Parent ) && hObj.isInLayout(  )
                    pos = hObj.getRelativePosition( hObj.Parent, pos, hObj.Units );
                end
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.Position( hObj, pos )
            try
                hObj.InnerPosition = pos;
            catch ME
                throwAsCaller( ME );
            end
        end

        function pos = get.Position( hObj )
            try
                pos = hObj.InnerPosition;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LooseInset( hObj, pos )


            if ~isequal( hObj.Units, hObj.UnitsCache )
                forceFullUpdate( hObj, 'all', 'LooseInset' );
            end
            hObj.LooseInset_I = pos;
        end

        function pos = get.LooseInset( hObj )

            if ~isequal( hObj.Units, hObj.UnitsCache )
                forceFullUpdate( hObj, 'all', 'LooseInset' );
            end
            pos = hObj.LooseInset_I;
        end

        function pos = get.TightInset( hObj )
            forceFullUpdate( hObj, 'all', 'TightInset' );
            pos = hObj.ChartDecorationInset_I;
        end

        function pos = get.PositionConstraint( hObj )
            try
                pos = hObj.PositionConstraint_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.PositionConstraint( hObj, val )
            try

                if strcmpi( val, 'OuterPosition' )
                    hObj.OuterPosition_I = hObj.OuterPosition;
                else
                    hObj.InnerPosition_I = hObj.InnerPosition;
                end
                hObj.PositionConstraint_I = val;

                if ~isempty( hObj.Axes_I )
                    set( hObj.Axes_I, 'PositionConstraint', val );
                end
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.ActivePositionProperty( hObj, app )

            hObj.PositionConstraint = char( app );
        end

        function app = get.ActivePositionProperty( hObj )

            app = matlab.graphics.chart.datatype.ChartActivePositionType( hObj.PositionConstraint );
        end

        function set.ActivePositionProperty_I( hObj, app )

            hObj.PositionConstraint_I = char( app );%#ok<MCSUP>
        end

        function app = get.ActivePositionProperty_I( hObj )


            app = hObj.PositionConstraint_I;
        end

        function set.Position_I( hObj, pos )
            hObj.InnerPosition_I = pos;
        end

        function pos = get.Position_I( hObj )
            pos = hObj.InnerPosition_I;
        end

        function set.ChartDecorationInset( hObj, ins )
            hObj.ChartDecorationInset_I = ins;
        end

        function ins = get.ChartDecorationInset( hObj )
            forceFullUpdate( hObj, 'all', 'ChartDecorationInsets' );
            ins = hObj.ChartDecorationInset_I;
        end

        function title = get.Title( hObj )
            try
                title = hObj.Title_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.Title( hObj, newtitle )
            try
                hObj.Title_I = newtitle;

                if isscalar( hObj.TitleHandle )
                    hObj.TitleHandle.String_I = newtitle;
                    hObj.TitleHandle.StringMode = 'manual';
                end
            catch ME
                throwAsCaller( ME );
            end
        end

        function tl = get.XLabel( hObj )
            try
                if hObj.XLabelMode == "auto"
                    forceFullUpdate( hObj, 'all', 'XLabel' );
                end
                tl = hObj.XLabel_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.XLabel( hObj, tl )
            try
                hObj.XLabel_I = tl;
                hObj.XLabelMode = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.XLabel_I( hObj, tl )
            hObj.XLabel_I = tl;
            if ~isempty( hObj.Axes_I )%#ok<MCSUP>
                set( hObj.XLabelHandle, 'StringMode', 'manual', 'String_I', tl );%#ok<MCSUP>
            end
        end

        function set.XLabelMode( hObj, mode )
            if string( hObj.XLabelMode ) ~= mode
                hObj.XLabelMode = mode;
                if strcmp( mode, 'auto' )

                    hObj.XLabel_I = hObj.Presenter.getXLabel(  );%#ok<MCSUP>
                end
            end
        end

        function vl = get.DisplayLabels( hObj )
            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'DisplayLabels' );
                end
                vl = hObj.DisplayLabels_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.DisplayLabels( hObj, vl )
            try
                validateattributes( vl, { 'cell', 'string' }, { 'vector', 'numel',  ...
                    hObj.getNumAxesCapped(  ) }, class( hObj ), 'DisplayLabels' );

                if isstring( vl )
                    vl = cellstr( vl );
                end
                mapProperties( hObj );
                try
                    for i = 1:numel( hObj.Axes_I )
                        vl{ i } = hgcastvalue( 'matlab.graphics.datatype.NumericOrString', vl{ i } );
                    end
                catch
                    error( message( 'MATLAB:stackedplot:InvalidDisplayLabels' ) );
                end
                hObj.DisplayLabels_I = vl( : );
                hObj.DisplayLabelsMode = 'manual';
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.DisplayLabels_I( hObj, vl )
            hObj.DisplayLabels_I = vl;
            if ~isempty( hObj.Axes_I )%#ok<MCSUP>

                [ hObj.DisplayLabelsHandle.String_I ] = vl{ : };%#ok<MCSUP>
                set( hObj.DisplayLabelsHandle, 'StringMode', 'manual' )%#ok<MCSUP>
            end
        end

        function set.DisplayLabelsMode( hObj, mode )
            if string( hObj.DisplayLabelsMode ) ~= mode
                hObj.DisplayLabelsMode = mode;
                if mode == "auto"
                    hObj.DisplayLabels_I = hObj.Presenter.getAxesLabels(  );%#ok<MCSUP>
                end
            end
        end

        function lp = get.LineProperties( hObj )
            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'LineProperties' );
                end
                lp = hObj.LineProperties_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LineProperties( hObj, lp )
            try
                numAxes = hObj.getNumAxesCapped(  );
                if numel( lp ) ~= numAxes
                    error( message( 'MATLAB:stackedplot:InvalidLineProperties' ) );
                end


                if numAxes ~= numel( hObj.Axes_I )
                    forceFullUpdate( hObj, 'all', 'LineProperties' );
                end


                lp = copy( lp );


                numPlotsInAxes = hObj.NumPlotsInAxes;
                for i = 1:numel( lp )
                    lp( i ).AxesIndex = i;
                    lp( i ).NumPlots = numPlotsInAxes( i );
                end


                for i = 1:numel( lp )
                    validate( lp( i ) );
                end


                lpOld = hObj.LineProperties;
                hObj.LineProperties_I = lp;
                recreate = false;
                for i = 1:numel( lp )

                    for j = 1:numPlotsInAxes( i )
                        if iscell( lpOld( i ).PlotType )
                            oldplottype = lpOld( i ).PlotType{ j };
                        else
                            oldplottype = lpOld( i ).PlotType;
                        end
                        if iscell( lp( i ).PlotType )
                            newplottype = lp( i ).PlotType{ j };
                        else
                            newplottype = lp( i ).PlotType;
                        end
                        if ~strcmp( newplottype, oldplottype )


                            recreate = true;
                            if strcmp( newplottype, 'scatter' )

                                if numPlotsInAxes( i ) == 1
                                    lp( i ).Marker = 'o';
                                else
                                    if ~iscell( lp( i ).Marker )
                                        lp( i ).Marker = repmat(  ...
                                            { lp( i ).Marker }, 1, numPlotsInAxes( i ) );
                                    end
                                    lp( i ).Marker{ j } = 'o';
                                end

                            elseif strcmp( oldplottype, 'scatter' )

                                if numPlotsInAxes( i ) == 1
                                    lp( i ).Marker = 'none';
                                else
                                    if ~iscell( lp( i ).Marker )
                                        lp( i ).Marker = repmat(  ...
                                            { lp( i ).Marker }, 1, numPlotsInAxes( i ) );
                                    end
                                    lp( i ).Marker{ j } = 'none';
                                end
                            end
                        end
                    end
                end
                hObj.LineProperties_I = lp;

                if recreate
                    createPlotObjects( hObj );


                    ap = hObj.AxesProperties;
                    for i = 1:numel( ap )
                        legendlabels = cellstr( ap( i ).LegendLabels );
                        for j = 1:numel( legendlabels )
                            hObj.Plots{ i }( j ).DisplayName =  ...
                                legendlabels{ j };
                        end
                    end
                end


                if ~isempty( hObj.LinePropertiesListener )
                    delete( hObj.LinePropertiesListener );
                end
                hObj.LinePropertiesListener = event.listener( hObj.LineProperties_I,  ...
                    'PropertiesChanged', @( ~, eventdata )reactToLinePropertiesChanges( hObj, eventdata ) );
            catch ME
                throwAsCaller( ME );
            end
        end

        function ap = get.AxesProperties( hObj )
            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'AxesProperties' );
                end
                ap = hObj.AxesProperties_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.AxesProperties( hObj, ap )
            try
                numAxes = hObj.getNumAxesCapped(  );
                if numel( ap ) ~= numAxes
                    error( message( 'MATLAB:stackedplot:InvalidAxesProperties' ) );
                end


                if numAxes ~= numel( hObj.Axes_I )
                    forceFullUpdate( hObj, 'all', 'AxesProperties' );
                end


                ap = copy( ap );



                for i = 1:numel( ap )
                    ap( i ).AxesIndex = i;
                    ap( i ).Presenter = hObj.Presenter;
                    ap( i ).Axes = hObj.Axes_I( i );
                    validate( ap( i ) );
                end

                hObj.AxesProperties_I = ap;

                for i = 1:numel( ap )

                    if strcmp( ap( i ).CollapseLegendMode, 'auto' )
                        ap( i ).CollapseLegend_I = hObj.Presenter.getCollapseLegend( i );
                    end


                    if strcmp( ap( i ).LegendLabelsMode, 'auto' )
                        legendlabels = cellstr( hObj.Presenter.getLegendLabels( i ) );
                        ap( i ).LegendLabels_I = legendlabels;
                    else
                        legendlabels = cellstr( ap( i ).LegendLabels );
                    end
                    for j = 1:numel( legendlabels )
                        hObj.Plots{ i }( j ).DisplayName =  ...
                            legendlabels{ j };
                    end


                    if strcmp( ap( i ).LegendVisibleMode, 'auto' )
                        nplots = hObj.NumPlotsInAxes( i );
                        if nplots > 1
                            ap( i ).LegendVisible_I = 'on';
                        else
                            ap( i ).LegendVisible_I = 'off';
                        end
                    end


                    if strcmp( ap( i ).YLimitsMode, 'auto' )
                        hObj.Axes_I( i ).YAxis.LimitsMode = 'auto';
                    else
                        hObj.Axes_I( i ).YAxis.Limits = ap( i ).YLimits;
                    end


                    hObj.Axes_I( i ).YScale = ap( i ).YScale;
                end


                if ~isempty( hObj.AxesPropertiesListener )
                    delete( hObj.AxesPropertiesListener );
                end
                hObj.AxesPropertiesListener = event.listener( hObj.AxesProperties_I,  ...
                    'PropertiesChanged', @( ~, eventdata )reactToAxesPropertiesChanges( hObj, eventdata ) );
            catch ME
                throwAsCaller( ME );
            end
        end

        function labels = get.LegendLabels( hObj )
            try
                if isvalid( hObj )
                    forceFullUpdate( hObj, 'all', 'LegendLabels' );
                end
                labels = hObj.LegendLabels_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LegendLabels( hObj, labels )
            if ~( iscellstr( labels ) || isstring( labels ) )
                error( message( 'MATLAB:stackedplot:LegendLabelsInvalidType' ) );
            end
            if numel( labels ) ~= 0
                if ~isvector( labels )
                    error( message( 'MATLAB:stackedplot:SourceTableLegendLabelsInvalidSize' ) );
                end
            end
            labels = cellstr( reshape( labels, 1, [  ] ) );
            hObj.LegendLabels_I = labels;
            hObj.LegendLabelsMode = 'manual';
        end

        function set.LegendLabelsMode( hObj, mode )
            hObj.LegendLabelsMode = mode;
            if mode == "auto"
                hObj.LegendLabels_I = hObj.Presenter.getChartLegendLabels(  );%#ok<MCSUP>
            end
        end













        function visible = get.LegendVisible( hObj )
            try
                visible = hObj.LegendVisible_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LegendVisible( hObj, visible )
            hObj.LegendVisible_I = visible;
            hObj.LegendVisibleMode = 'manual';
        end

        function set.LegendVisibleMode( hObj, mode )
            hObj.LegendVisibleMode = mode;
            if mode == "auto"
                hObj.LegendVisible_I = hObj.Presenter.getChartLegendVisible(  );%#ok<MCSUP>
            end
        end

        function orientation = get.LegendOrientation( hObj )
            try
                orientation = hObj.LegendOrientation_I;
            catch ME
                throwAsCaller( ME );
            end
        end

        function set.LegendOrientation( hObj, orientation )
            hObj.LegendOrientation_I = orientation;
        end

        function set.GridVisible( hObj, visible )
            try

                for i = 1:numel( hObj.Axes_I )%#ok<MCSUP>
                    set( hObj.Axes_I( i ), 'XGrid', visible, 'YGrid', visible );%#ok<MCSUP>
                end

                hObj.GridVisible = visible;
            catch ME
                throwAsCaller( ME );
            end
        end

        function ax = get.Axes( hObj )
            forceFullUpdate( hObj, 'all', 'Axes' );
            ax = hObj.Axes_I;
        end

        function set.Axes( hObj, ax )
            for i = 1:numel( ax )
                if isempty( ax( i ).Parent )
                    ax( i ) = ax( i );
                else

                    ax( i ) = copy( ax( i ) );
                end
                hObj.addNode( ax( i ) );
            end
            hObj.Axes_I = ax;
        end

        function set.Plots( hObj, hPlots )
            for i = 1:numel( hPlots )
                set( hPlots{ i }, 'Parent', hObj.Axes_I( i ) );
            end
            hObj.Plots = hPlots;
        end

        function set.LegendHandle( hObj, hleg )
            hObj.LegendHandle = hleg;
            for i = 1:numel( hleg )
                addNode( hObj, hleg( i ) );
            end
        end

        function set.ChartLegendHandle( hObj, hleg )
            hObj.ChartLegendHandle = hleg;
            addNode( hObj, hleg );
        end



        function n = get.NumPlotsInAxes( hObj )
            numAxes = hObj.getNumAxesCapped(  );
            n = zeros( numAxes, 1 );
            for i = 1:numAxes
                n( i ) = sum( hObj.getNumColumnsPerVariableInAxes( i ) );
            end
        end

        function ver = get.SavedInVersion( hObj )

            ver = getSavedInVersion( hObj );
        end

        function set.SavedInVersion( hObj, ver )


            setSavedInVersion( hObj, ver );
        end

        function varIndex = get.VariableIndex( hObj )
            varIndex = hObj.Presenter.getVariableIndex(  );
        end

        function innerVarIdx = get.InnerVariableIndex( hObj )
            innerVarIdx = hObj.Presenter.getInnerVariableIndex(  );
        end
    end

    methods ( Hidden )
        doUpdate( hObj, updateState )

        function actualValue = setParentImpl( obj, proposedParent )

            isColorOrderModeAuto = isa( proposedParent, 'matlab.graphics.internal.GraphicsPropertyHandler' ) &&  ...
                isempty( obj.Parent ) && strcmp( obj.ColorOrderInternalMode, 'auto' );
            if isColorOrderModeAuto
                colors = get( proposedParent, 'DefaultAxesColorOrder' );
                obj.ColorOrderInternal = colors;
                obj.setColorOrderInternal( colors );
            end

            actualValue = obj.setParentImpl@matlab.graphics.chart.internal.SubplotPositionableChart( proposedParent );
        end

        function ignore = mcodeIgnoreHandle( ~, ~ )

            ignore = true;
        end


        function resetCallback( hObj )
            hObj.XLimitsMode = 'auto';
            [ hObj.AxesProperties.YLimitsMode ] = deal( 'auto' );
        end
    end

    methods ( Hidden, Access = { ?matlab.graphics.mixin.internal.Copyable,  ...
            ?matlab.graphics.internal.CopyContext } )
        function cpObj = copyElement( hObj )


            mapProperties( hObj );
            cpObj = copyElement@matlab.graphics.mixin.internal.Copyable( hObj );
        end


        function connectCopyToTree( hObj, hCopy, hCopyParent, hContext )
            connectCopyToTree@matlab.graphics.chart.internal.SubplotPositionableChart( hObj,  ...
                hCopy, hCopyParent, hContext );


            hCopy.UnitsCache = hCopy.Units;









            for i = 1:numel( hCopy.AxesProperties_I )
                hCopy.AxesProperties_I( i ).YLimits_I = hObj.AxesProperties_I( i ).YLimits;
                hCopy.AxesProperties_I( i ).YScale_I = hObj.AxesProperties_I( i ).YScale;
                hCopy.AxesProperties_I( i ).LegendLocation_I = hObj.AxesProperties_I( i ).LegendLocation;
                hCopy.AxesProperties_I( i ).LegendVisible_I = hObj.AxesProperties_I( i ).LegendVisible;
                hCopy.AxesProperties_I( i ).LegendLabels_I = hObj.AxesProperties_I( i ).LegendLabels;
            end


            hCopy.Presenter.View = hCopy;


            hCopy.OldState = hObj.Presenter.copyState(  );
        end
    end

    methods ( Access = protected, Hidden )
        function groups = getPropertyGroups( hObj )
            groups = hObj.Presenter.getPropertyGroups(  );
        end
    end

    methods ( Access = protected )

        function setColorOrderInternal( hObj, activeColorOrder )
            hObj.ColorOrderInternalMode = 'manual';





            updateAutoColorProperties( hObj, activeColorOrder );
        end

        function v = getSavedInVersion( ~ )

            v = version;
        end

        function setSavedInVersion( obj, v )


            obj.SavedInVersion_I = v;
        end
    end

    methods ( Static, Hidden )
        function varargout = doloadobj( hObj )


            hObj.UnitsCache = hObj.Units;


            if ~isempty( hObj.AxesProperties_I ) && ~isempty( hObj.LineProperties_I )
                hObj.OldState = hObj.Presenter.copyState(  );
            end
            varargout{ 1 } = hObj;









            if ismissing( hObj.SavedInVersion_I )
                if all( strcmp( { hObj.LineProperties.ColorMode }, 'manual' ) )
                    hObj.ColorMode = 'manual';
                end

                if all( strcmp( { hObj.LineProperties.MarkerEdgeColorMode }, 'manual' ) )
                    hObj.MarkerEdgeColorMode = 'manual';
                end




            end







            if ismissing( hObj.SavedInVersion_I ) ||  ...
                    extract( hObj.SavedInVersion_I, regexpPattern( "R\d\d\d\d[ab]" ) ) < "R2022b"
                if ~isequal( hObj.LineStyle_I, '-' )
                    hObj.LineStyleMode = 'manual';
                end
                if ~isempty( hObj.LineProperties_I )
                    for i = 1:numel( hObj.LineProperties_I )
                        if ~isequal( hObj.LineProperties_I( i ).LineStyle, '-' )
                            hObj.LineProperties_I( i ).LineStyleMode = 'manual';
                        end
                    end
                end
            end
        end
    end

    methods ( Access = private )
        logWarning( hObj, varargin )
        createGraphicsObjects( hObj, oldState )
        createPlotObjects( hObj )
        createDisplayLabels( hObj, axesmapping, plotmapping )
        createLineProperties( hObj, axesmapping, plotmapping )
        createAxesProperties( hObj, axesmapping, plotmapping )
        doLayout( hObj, updateState )
        updateAutoColorProperties( hObj, activeColorOrder )


        reactToLinePropertiesChanges( hObj, eventdata )
        reactToAxesPropertiesChanges( hObj, eventdata )
        markedCleanCallback( hObj )

        function hideAxes( hObj, varargin )



            hObj.setAxesVisibility( 'off', varargin{ : } );
        end

        function showAxes( hObj, varargin )



            hObj.setAxesVisibility( 'on', varargin{ : } );
        end

        function setAxesVisibility( hObj, visibility, axesIndices )
            arguments
                hObj
                visibility
                axesIndices = 1:numel( hObj.Axes_I );
            end
            if isempty( axesIndices )
                return
            end


            set( [ hObj.Axes_I.XAxis ], 'Visible', 'off' );
            if visibility == "on"
                hObj.Axes_I( max( axesIndices ) ).XAxis.Visible = 'on';
            end


            if visibility == "off"
                if ~isempty( hObj.LegendHandle )
                    set( hObj.LegendHandle, 'Visible', 'off' );
                end
            end


            axesIndexLast = numel( hObj.Axes_I );
            [ hideLastAxes, locb ] = ismember( axesIndexLast, axesIndices );
            if hideLastAxes
                axesIndices( locb ) = [  ];
                hObj.Axes_I( end  ).Visible = visibility;
                set( hObj.Plots{ end  }, 'Visible', visibility );
            end
            set( hObj.Axes_I( axesIndices ), 'Visible', visibility, 'ContentsVisible', visibility );
        end


        function color = getAutoColor( hObj, nplots, seriesIndices, property )


            mode = get( hObj, property + "Mode" );
            if nplots > 1 || mode == "auto"
                color = hObj.ColorOrderInternal( rem( seriesIndices - 1, size( hObj.ColorOrderInternal, 1 ) ) + 1, : );
            else
                color = get( hObj, property + "_I" );
            end
        end

        function n = getNumAxesTotal( hObj )

            n = hObj.Presenter.getNumAxes(  );
        end

        function n = getNumAxesCapped( hObj )

            n = min( hObj.getNumAxesTotal(  ), hObj.MaxNumAxes );
        end



        function nColumns = getNumColumnsPerVariableInAxes( hObj, axesIndex )
            yData = hObj.Presenter.getAxesYData( axesIndex );
            nColumns = zeros( 1, numel( yData ) );
            for i = 1:numel( yData )
                nColumns( i ) = size( yData{ i }( :, : ), 2 );
            end
        end

        function setupPrintBehavior( hObj )


            addBehaviorProp( hObj )
            hBehavior = hggetbehavior( hObj, 'print' );
            hBehavior.PrePrintCallback = @( hObj, callbackName )hObj.printEvent( callbackName );
            hBehavior.PostPrintCallback = @( hObj, callbackName )hObj.printEvent( callbackName );
        end

        function addBehaviorProp( hObj )

            behaviorProp = findprop( hObj, 'Behavior' );
            if isempty( behaviorProp )
                behaviorProp = addprop( hObj, 'Behavior' );
                behaviorProp.Hidden = true;
                behaviorProp.Transient = true;
            end
        end

        function printEvent( hObj, callbackName )

            switch callbackName
                case 'PrePrintCallback'
                    if ~isempty( hObj.DataCursor )
                        hObj.DataCursor.prePrintCallback(  );
                    end
                    hObj.IsPrinting = true;
                case 'PostPrintCallback'
                    if ~isempty( hObj.DataCursor )
                        hObj.DataCursor.postPrintCallback(  );
                    end
                    hObj.IsPrinting = false;
            end
        end
    end

    methods ( Hidden = true, Access = { ?ChartUnitTestFriend,  ...
            ?matlab.graphics.chart.Chart,  ...
            ?matlab.internal.editor.figure.ChartAccessor,  ...
            ?matlab.plottools.service.accessor.ChartAccessor } )


        function hXLabel = getXlabelHandle( hObj )

            if ~isempty( hObj.Axes_I )
                visibleaxes = hObj.Axes_I( strcmp( { hObj.Axes_I.Visible }, 'on' ) );
                hXLabel = visibleaxes( end  ).XAxis.Label_IS;
            else
                hXLabel = [  ];
            end
        end


        function hYLabel = getYlabelHandle( ~ )


            hYLabel = [  ];
        end
    end
end

function presenter = createPresenter( hObj )
chartData = createChartData(  );
model = matlab.graphics.chart.internal.stackedplot.Model( chartData, @hObj.logWarning );
presenter = matlab.graphics.chart.internal.stackedplot.Presenter( model, hObj );
model.Presenter = presenter;
end

function chartData = createChartData(  )
chartData = matlab.graphics.chart.internal.stackedplot.ChartData(  ...
    "SourceTable", timetable.empty,  ...
    "XData", zeros( 1, 0 ),  ...
    "YData", [  ],  ...
    "DisplayVariables", zeros( 1, 0 ),  ...
    "DisplayVariablesMode", "auto",  ...
    "CombineMatchingNames", true ...
    );
end

function mapProperties( hObj )
hObj.doUpdate( [  ] );
end
