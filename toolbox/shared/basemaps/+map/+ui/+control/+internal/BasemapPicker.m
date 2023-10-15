classdef ( Sealed, ConstructOnLoad, UseClassDefaultsOnLoad )BasemapPicker <  ...
        matlab.ui.componentcontainer.ComponentContainer

    properties ( Dependent )
        BasemapNames( :, 1 )string = "auto"
        DisplayNames( :, 1 )string = "auto"
        BasemapIcons( :, 1 )string{ map.internal.basemaps.mustBeIcons } = "auto"
        NumColumns( 1, 1 )double = 2
        Toolbar matlab.ui.controls.AxesToolbar = matlab.ui.controls.AxesToolbar.empty
        Value( 1, 1 )string = ""
        ValueChangedFcn function_handle = function_handle.empty
    end


    properties ( Access = public )
        BasemapNamesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
        DisplayNamesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
        BasemapIconsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
        NumColumnsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
        ToolbarMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
        ValueMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
        ValueChangedFcnMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual = 'auto'
    end


    properties ( Access = private )
        BasemapNames_I( :, 1 )string = "auto"
        DisplayNames_I( :, 1 )string = "auto"
        BasemapIcons_I( :, 1 )string = "auto"
        NumColumns_I( 1, 1 )double = 2
        Toolbar_I matlab.ui.controls.AxesToolbar = matlab.ui.controls.AxesToolbar.empty
        Value_I( 1, 1 )string = ""
        ValueChangedFcn_I function_handle = function_handle.empty
    end


    properties ( Access = public, Hidden )
        BasemapSource
        DefaultBasemapNames( :, 1 )string = matlab.graphics.chart.internal.maps.basemapNames
        DefaultDisplayNames( :, 1 )string = matlab.graphics.chart.internal.maps.basemapNames
        DefaultBasemapIcons( :, 1 )string = map.internal.basemaps.basemapIcons
    end


    properties ( Access = protected, Transient, NonCopyable, UsedInUpdate = false )
        BasemapPickerButtonGroup( 1, 1 )matlab.ui.container.ButtonGroup
        GridLayout( 1, 1 )matlab.ui.container.GridLayout

        ButtonNames string = ""
        BasemapButtons matlab.ui.control.Button
        UpdateButtonGroup( 1, 1 )logical = false
    end


    properties ( Access = protected, Dependent, NonCopyable, UsedInUpdate = false )
        ToolbarButton
    end

    properties ( Access = protected, Transient, NonCopyable, UsedInUpdate = false )
        ToolbarButton_I
    end


    properties ( Access = protected, NonCopyable )
        DataStorage
    end


    properties ( Access = protected, Transient, NonCopyable, UsedInUpdate = false )
        ObjectRequiresReset( 1, 1 )logical = false
    end


    properties ( Access = protected, Transient, NonCopyable, UsedInUpdate = false )
        BasemapSourceSizeChangedListener = [  ]
        WindowMousePressListener = [  ]
        ParentChangedListener = [  ]
        DeleteListener = [  ]
    end


    properties ( Constant, Hidden )
        DefaultWidth = 210
        DefaultHeight = 260

        IconPath = fullfile( toolboxdir( "shared" ), "basemaps",  ...
            "resources", "icons" );
        IconName = "basemap_icon.png"
        Icon = fullfile(  ...
            map.ui.control.internal.BasemapPicker.IconPath,  ...
            map.ui.control.internal.BasemapPicker.IconName )


        AppDataName = "mapbutton_basemap"

        Title = string( message( 'shared_basemaps:BasemapPicker:Title' ).getString )
        Tooltip = string( message( 'shared_basemaps:BasemapPicker:Tooltip' ).getString(  ) )


        IconSize = 80


        LabelHeight = 35


        RowSpacing = 0


        BorderOnTop = 25


        OrderedBasemaps = [  ...
            "satellite";"streets"; ...
            "streets-dark";"streets-light";"topographic" ];
    end

    methods
        function obj = BasemapPicker( NameValueArgs )
            arguments

                NameValueArgs.Parent = [  ]
                NameValueArgs.BasemapNames string
                NameValueArgs.DisplayNames string
                NameValueArgs.BasemapIcons string{ map.internal.basemaps.mustBeIcons }
                NameValueArgs.NumColumns( 1, 1 )double = 2
                NameValueArgs.Toolbar( 1, 1 )matlab.ui.controls.AxesToolbar
            end


            NameValueArgs.Internal = true;
            NameValueArgs.HandleVisibility = "off";
            NameValueArgs.Visible = "off";
            if isfield( NameValueArgs, "Toolbar" ) && isvalid( NameValueArgs.Toolbar ) ...
                    && isempty( NameValueArgs.Parent )
                NameValueArgs.Parent = ancestor( NameValueArgs.Toolbar, "figure" );
            end






            parent = NameValueArgs.Parent;
            NameValueArgs.Parent = [  ];
            obj@matlab.ui.componentcontainer.ComponentContainer( NameValueArgs );
            obj.Parent = parent;



            setDefaultProperties( obj )
        end


        function delete( obj )
            if ~isempty( obj.BasemapSourceSizeChangedListener ) ...
                    && isvalid( obj.BasemapSourceSizeChangedListener )
                delete( obj.BasemapSourceSizeChangedListener )
            end

            if ~isempty( obj.WindowMousePressListener ) ...
                    && isvalid( obj.WindowMousePressListener )
                delete( obj.WindowMousePressListener )
            end

            if ~isempty( obj.ParentChangedListener ) ...
                    && isvalid( obj.ParentChangedListener )
                delete( obj.ParentChangedListener )
            end

            if ~isempty( obj.BasemapPickerButtonGroup ) ...
                    && isvalid( obj.BasemapPickerButtonGroup )
                delete( obj.BasemapPickerButtonGroup )
            end
        end


        function set.Toolbar( obj, tb )
            obj.Toolbar_I = tb;
            obj.ToolbarMode = "manual";




            btns = tb.Children;
            appdataname = obj.AppDataName;
            hasButton = false;
            k = 1;
            while k < length( btns ) && ~hasButton
                hasButton = isappdata( btns( k ), appdataname );
                k = k + 1;
            end
            if hasButton
                k = k - 1;
                oldPicker = getappdata( btns( k ), appdataname );
                delete( oldPicker )
                btn = btns( k );
            else
                btn = axtoolbarbtn( tb, 'state' );
            end


            btn.Icon = obj.Icon;
            btn.ValueChangedFcn = @( s, e )basemapPickerCallback( obj, s, e );
            btn.DeleteFcn = @( s, e )delete( obj );
            btn.Tooltip = obj.Tooltip;
            btn.Tag = "basemappicker";
            obj.ToolbarButton = btn;
            setappdata( btn, appdataname, obj )


            gx = tb.Parent;
            if isa( gx, 'matlab.graphics.axis.GeographicAxes' )
                obj.BasemapSource = gx;
            end
        end


        function value = get.Toolbar( obj )
            value = obj.Toolbar_I;
        end


        function set.BasemapNames( obj, value )

            obj.UpdateButtonGroup = obj.UpdateButtonGroup || ~isequal( value, obj.BasemapNames_I );
            obj.BasemapNames_I = value;
            obj.BasemapNamesMode = "manual";
        end


        function value = get.BasemapNames( obj )
            value = obj.BasemapNames_I;
        end


        function value = get.BasemapNames_I( obj )
            if matches( string( obj.BasemapNames_I ), "auto", "IgnoreCase", true )
                value = obj.DefaultBasemapNames;
            else
                value = obj.BasemapNames_I;
            end
        end


        function set.DisplayNames( obj, value )

            obj.UpdateButtonGroup = obj.UpdateButtonGroup || ~isequal( value, obj.DisplayNames_I );
            obj.DisplayNames_I = value;
            obj.DisplayNamesMode = "manual";
        end


        function value = get.DisplayNames( obj )
            value = obj.DisplayNames_I;
        end


        function value = get.DisplayNames_I( obj )
            if matches( obj.DisplayNames_I, "auto", "IgnoreCase", true )
                value = obj.DefaultDisplayNames;
            else
                value = obj.DisplayNames_I;
            end
        end


        function set.BasemapIcons( obj, value )
            value = convertCharsToStrings( value );

            obj.UpdateButtonGroup = obj.UpdateButtonGroup || ~isequal( value, obj.DisplayNames_I );
            obj.BasemapIcons_I = value;
            obj.BasemapIconsMode = "manual";
        end


        function value = get.BasemapIcons( obj )
            value = obj.BasemapIcons_I;
        end


        function value = get.BasemapIcons_I( obj )
            if matches( obj.BasemapIcons_I, "auto", "IgnoreCase", true )
                value = obj.DefaultBasemapIcons;
            else
                value = obj.BasemapIcons_I;
            end
        end


        function set.NumColumns( obj, value )
            obj.NumColumns_I = value;
            obj.NumColumnsMode = "manual";
            obj.UpdateButtonGroup = true;
        end


        function value = get.NumColumns( obj )
            value = obj.NumColumns_I;
        end


        function set.Value( obj, value )
            obj.ValueMode = "manual";
            obj.Value_I = value;
        end


        function value = get.Value( obj )
            if ~isempty( obj.BasemapSource ) && isprop( obj.BasemapSource, 'Basemap' )
                value = obj.BasemapSource.Basemap;
            else
                value = obj.Value_I;
            end
        end


        function set.ValueChangedFcn( obj, value )
            obj.ValueChangedFcnMode = "manual";
            obj.ValueChangedFcn_I = value;
        end


        function value = get.ValueChangedFcn( obj )
            value = obj.ValueChangedFcn_I;
        end


        function set.ToolbarButton( obj, value )
            obj.ToolbarButton_I = value;
        end

        function value = get.ToolbarButton( obj )
            if ~isempty( obj.ToolbarButton_I )
                value = obj.ToolbarButton_I;
            else
                value = [  ];
                if ~isempty( obj.Toolbar ) && isvalid( obj.Toolbar )
                    btns = obj.Toolbar.Children;
                    appdataname = obj.AppDataName;
                    hasButton = false;
                    k = 1;
                    while k < length( btns ) && ~hasButton
                        hasButton = isappdata( btns( k ), appdataname );
                        k = k + 1;
                    end
                    if hasButton
                        k = k - 1;
                        value = btns( k );
                    end
                end
            end
        end

        function set.DataStorage( obj, data )



            obj.ObjectRequiresReset = data.ObjectRequiresReset;%#ok<MCSUP>
        end


        function data = get.DataStorage( obj )


            obj.ObjectRequiresReset = false;
            data.ObjectRequiresReset = true;
        end
    end

    methods ( Hidden, Sealed )
        function basemapPickerCallback( obj, src, event )


            if obj.ObjectRequiresReset

                obj.ObjectRequiresReset = false;
                reattachListeners( obj )
            end

            gx = event.Axes;
            switch src.Value
                case 'off'
                    disableBasemapPicker( obj )

                case 'on'
                    if isempty( obj.BasemapSourceSizeChangedListener ) ...
                            || ~isvalid( obj.BasemapSourceSizeChangedListener )
                        addListeners( obj );
                    end
                    enableBasemapPicker( obj )
                    updatePosition( obj, gx )
            end
        end
    end

    methods ( Access = protected )
        function setDefaultProperties( obj )

            defaultBasemapNames = matlab.graphics.chart.internal.maps.basemapNames;
            defaultBasemapIcons = map.internal.basemaps.basemapIcons;


            orderedBasemaps = obj.OrderedBasemaps;
            index = matches( defaultBasemapNames, orderedBasemaps );
            orderedBasemaps = [ orderedBasemaps;defaultBasemapNames( ~index, : ) ];


            defaultDisplayNames = arrayfun(  ...
                @( x )getPreferredDisplayName( x ), orderedBasemaps );


            index = cellfun( @( x )find( x == defaultBasemapNames ), orderedBasemaps );


            obj.DefaultBasemapNames = orderedBasemaps;
            obj.DefaultDisplayNames = defaultDisplayNames;
            obj.DefaultBasemapIcons = defaultBasemapIcons( index );
        end


        function setup( obj )



            if matches( obj.PositionMode, 'auto' )
                obj.Position_I( 3:4 ) = getPreferredSize( obj );
            end


            bg = matlab.ui.container.ButtonGroup(  ...
                "Parent", obj,  ...
                "FontWeight", "bold",  ...
                "Units", "pixels",  ...
                "Visible", "off",  ...
                "Title", obj.Title,  ...
                "Position", [ 1, 1, obj.Position( 3:4 ) ],  ...
                "FontSize", 8 );
            obj.BasemapPickerButtonGroup = bg;


            layout = uigridlayout( bg );
            layout.RowHeight = {  };
            obj.GridLayout = layout;
            obj.UpdateButtonGroup = true;
        end


        function update( obj )
            if isempty( obj.BasemapSourceSizeChangedListener )
                gx = obj.BasemapSource;
                if ~isempty( gx ) && isvalid( gx ) && ishandle( gx )
                    addListeners( obj );
                end
            end

            if obj.UpdateButtonGroup
                if any( strlength( obj.BasemapNames_I ) > 0 )
                    obj.UpdateButtonGroup = false;
                    btn = makeButtonsAndLabels( obj );
                    obj.BasemapButtons = btn;
                end
            end

            obj.Position( 3:4 ) = getPreferredSize( obj );
            obj.BasemapPickerButtonGroup.Visible = obj.Visible;
            obj.BasemapPickerButtonGroup.Position = [ 1, 1, obj.Position( 3:4 ) ];
        end


        function btn = makeButtonsAndLabels( obj )



            layout = obj.GridLayout;
            layout.RowHeight = {  };
            delete( layout.Children )



            basemapNames = obj.BasemapNames_I;
            displayNames = obj.DisplayNames_I;
            icons = obj.BasemapIcons_I;


            defaultIcon = fullfile( obj.IconPath, 'missing.png' );
            defaultBasemapNames = obj.DefaultBasemapNames;



            hasNone = any( matches( basemapNames, "none" ) );
            if hasNone
                defaultBasemapNames = [ defaultBasemapNames;"none" ];
                if matches( obj.DisplayNamesMode, "auto" )
                    displayNames = [ displayNames;"none" ];
                end
                if matches( obj.BasemapIconsMode, "auto" )
                    icons = [ icons;defaultIcon ];
                end
            end



            index = matches( defaultBasemapNames, basemapNames );
            sortedBasemapNames = defaultBasemapNames( index );



            hasDuplicates = ~isempty( sortedBasemapNames ) &&  ...
                length( basemapNames ) ~= length( unique( basemapNames ) );


            if length( basemapNames ) ~= length( displayNames ) &&  ...
                    matches( obj.DisplayNamesMode, "auto" )
                displayNames = displayNames( index );
            end


            if length( basemapNames ) ~= length( icons ) &&  ...
                    matches( obj.BasemapIconsMode, "auto" )
                icons = icons( index );
            end



            if matches( obj.DisplayNamesMode, "auto" )
                bg = matlab.internal.maps.BasemapSettingsGroup;
                grp = readGroup( bg );
                for k = 1:length( grp )
                    displayName = grp( k ).DisplayName;
                    if strlength( displayName ) > 0
                        index = matches( sortedBasemapNames, grp( k ).BasemapName );
                        displayNames( index ) = displayName;
                    end
                end
            end



            rowHeight = { obj.IconSize, obj.LabelHeight };
            if isscalar( icons ) && strlength( icons ) == 0




                defaultIcon = '';
                rowHeight = { obj.IconSize * .75, 5 };
            end

            if isscalar( displayNames ) && strlength( displayNames ) == 0


                rowHeight{ 2 } = 5;
            end



            layout.RowHeight = repmat( rowHeight, 1, length( basemapNames ) );
            numColumns = min( length( basemapNames ), obj.NumColumns );
            layout.ColumnWidth = repmat( { obj.IconSize }, 1, numColumns );
            layout.Tooltip = { char( obj.Tooltip ) };
            layout.Scrollable = 'on';
            layout.RowSpacing = obj.RowSpacing;


            btn( length( basemapNames ) ) = matlab.graphics.GraphicsPlaceholder;
            if strlength( basemapNames ) ~= 0
                row = 1;
                column = 1;
                gridSize = [ round( length( basemapNames ) / 2 ), obj.NumColumns ];

                defaultDisplayName = "";
                for index = 1:length( basemapNames )
                    basemap = basemapNames( index );
                    k = basemap == sortedBasemapNames;
                    displayName = getValue( index, k, displayNames,  ...
                        obj.DisplayNamesMode, defaultDisplayName, hasDuplicates );
                    icon = getValue( index, k, icons,  ...
                        obj.BasemapIconsMode, defaultIcon, hasDuplicates );

                    btn( index ) = makeButtonAndLabel( layout, basemap, displayName, row, column, icon );
                    btn( index ).ButtonPushedFcn = @( s, e )setBasemap( obj, basemap, e );

                    column = column + 1;
                    if column > gridSize( 2 )
                        column = 1;
                    end
                    if column == 1
                        row = row + 2;
                    end
                end
                obj.ButtonNames = basemapNames;
            end
        end


        function setBasemap( obj, basemap, evt )
            obj.Value = basemap;
            if ~isempty( obj.ValueChangedFcn ) && nargin > 2
                src = obj;
                obj.ValueChangedFcn( src, evt );
            end

            basemapObject = obj.BasemapSource;
            if ~isempty( basemapObject ) && isvalid( basemapObject )
                set( basemapObject, 'Basemap', basemap )
            end

            obj.ToolbarButton.Value = 'off';
            obj.Visible = 'off';
            if ~isempty( obj.BasemapSourceSizeChangedListener ) ...
                    && ishandle( obj.BasemapSourceSizeChangedListener )
                obj.BasemapSourceSizeChangedListener.Enabled = false;
            end
        end


        function updatePosition( obj, gx )


            if obj.Visible && ~isempty( gx ) && isvalid( gx ) && ishandle( gx )

                toUnits = obj.Units;
                gxPosition = getPlotboxRelativeToFigure( gx, toUnits );


                fig = ancestor( gx, 'figure' );
                figPosition = convertPosition( fig, toUnits );

                obj.Position( 3:4 ) = getPreferredSize( obj );
                pos1 = gxPosition( 1 ) + gxPosition( 3 ) - 1;
                pos2 = gxPosition( 2 ) + gxPosition( 4 ) - 1;


                min3 = max( min( figPosition( 3 ), gxPosition( 3 ) ), figPosition( 3 ) );
                if pos1 > min3
                    pos1 = min3;
                end

                min4 = max( min( figPosition( 4 ), gxPosition( 4 ) ), figPosition( 4 ) );
                if pos2 > min4
                    pos2 = min4;
                end



                obj.Position( 1 ) = pos1 - obj.Position( 3 );
                obj.Position( 2 ) = pos2 - obj.Position( 4 ) - obj.BorderOnTop;
                obj.BasemapPickerButtonGroup.Position = [ 1, 1, obj.Position( 3:4 ) ];
            end
        end


        function disableBasemapPicker( obj )
            obj.BasemapPickerButtonGroup.Visible = 'off';
            obj.Visible = 'off';

            if ~isempty( obj.ToolbarButton ) && isvalid( obj.ToolbarButton )
                obj.ToolbarButton.Value = 'off';
            end

            if ~isempty( obj.BasemapSourceSizeChangedListener ) ...
                    && isvalid( obj.BasemapSourceSizeChangedListener )
                obj.BasemapSourceSizeChangedListener.Enabled = false;
            end

            if ~isempty( obj.WindowMousePressListener ) && isvalid( obj.WindowMousePressListener )
                obj.WindowMousePressListener.Enabled = false;
            end
        end


        function enableBasemapPicker( obj )
            obj.BasemapPickerButtonGroup.Visible = 'on';
            obj.Visible = 'on';

            if ~isempty( obj.BasemapSourceSizeChangedListener ) ...
                    && isvalid( obj.BasemapSourceSizeChangedListener )
                obj.BasemapSourceSizeChangedListener.Enabled = true;
            end

            if ~isempty( obj.WindowMousePressListener ) && isvalid( obj.WindowMousePressListener )
                obj.WindowMousePressListener.Enabled = true;
            end
        end


        function sz = getPreferredSize( obj )



            if obj.NumColumns_I < 2 || isscalar( obj.BasemapNames_I )
                sz = [ obj.DefaultWidth - 100, obj.DefaultHeight ];
            else
                sz = [ obj.DefaultWidth, obj.DefaultHeight ];
            end

            if length( obj.BasemapNames_I ) <= obj.NumColumns_I
                sz( 2 ) = sz( 2 ) - 110;
            end
        end


        function reattachListeners( obj )


            delete( obj.BasemapSourceSizeChangedListener );
            delete( obj.WindowMousePressListener )
            delete( obj.ParentChangedListener )
            delete( obj.DeleteListener )

            if ~isempty( obj.BasemapSource ) && isvalid( obj.BasemapSource )
                parent = ancestor( obj.BasemapSource, 'figure' );
                if ~matlab.ui.internal.isUIFigure( parent )





                    obj.Parent = [  ];



                    if ~isempty( obj.Toolbar_I ) && isvalid( obj.Toolbar_I )
                        ax = obj.Toolbar.Parent_I;
                        obj.ParentChangedListener = addlistener(  ...
                            ax, 'Parent', 'PostSet', @( o, e )reattachListeners( obj ) );
                    end




                    obj.DeleteListener = addlistener( obj.BasemapSource,  ...
                        "ObjectBeingDestroyed", @( s, e )delete( obj ) );
                else
                    obj.Parent_I = parent;
                    addListeners( obj )
                end
            end
        end


        function addListeners( obj )






            if ~isempty( obj.BasemapSource ) && isvalid( obj.BasemapSource )

                obj.BasemapSourceSizeChangedListener = addlistener(  ...
                    obj.BasemapSource, 'SizeChanged', @( o, e )handleSizeChanged( obj ) );
            end





            parent = ancestor( obj, 'figure' );
            if ~isempty( parent ) && isvalid( parent )
                obj.WindowMousePressListener = addlistener(  ...
                    parent, 'ButtonDown', @( s, e )disableBasemapPicker( obj ) );
                obj.WindowMousePressListener.Enabled = false;
            end

            gx = obj.BasemapSource;
            if ~isempty( gx ) && isvalid( gx )

                obj.ParentChangedListener = addlistener(  ...
                    gx, 'Parent', 'PostSet', @( o, e )reattachListeners( obj ) );

                obj.DeleteListener = addlistener( gx,  ...
                    "ObjectBeingDestroyed", @( s, e )delete( obj ) );
            end
        end


        function handleSizeChanged( obj )
            if isvalid( obj ) && ~isempty( obj.BasemapSource ) ...
                    && ishandle( obj.BasemapSource )
                updatePosition( obj, obj.BasemapSource )
            end
        end
    end
end


function toPosition = convertPosition( obj, toUnits )
viewport = matlab.graphics.general.UnitPosition;
viewport.ScreenResolution = get( groot, 'ScreenPixelsPerInch' );
if isa( obj, 'matlab.ui.Figure' )
    g = groot;
    ref = g.ScreenSize;
else
    ref = obj.Position;
end

fromUnits = obj.Units;
fromPosition = obj.Position;
viewport.RefFrame = ref;
viewport.Units = fromUnits;
viewport.Position = fromPosition;
viewport.Units = toUnits;
toPosition = viewport.Position;
end


function plotbox = getPlotboxRelativeToFigure( ax, toUnits )




layout = GetLayoutInformation( ax );
plotbox = layout.PlotBox;




if strcmpi( toUnits, 'pixels' )
    PB.Units = 'pixels';
    PB.Position = plotbox;
    plotbox = convertPosition( PB, toUnits );
end




parent = getParentAncestor( ax );
if ~( isa( parent, 'matlab.ui.container.GridLayout' ) ...
        || isa( parent, 'matlab.graphics.layout.TiledChartLayout' ) )


    pos = convertPosition( parent, toUnits );

    if sum( plotbox( 1:2:end  ) ) > pos( 3 )

        plotbox( 3 ) = pos( 3 ) - plotbox( 1 );
    end

    if sum( plotbox( 2:2:end  ) ) > pos( 4 )

        plotbox( 4 ) = pos( 4 ) - plotbox( 2 );
    end
end






location = [ 0, 0 ];
while ~( isa( parent, 'matlab.ui.Figure' ) ...
        || isa( parent, 'matlab.ui.container.GridLayout' ) ...
        || isa( parent, 'matlab.graphics.layout.TiledChartLayout' ) )


    pos = convertPosition( parent, toUnits );


    location( 1:2 ) = pos( 1:2 ) + location;
    parent = getParentAncestor( parent );
end
plotbox( 1:2 ) = plotbox( 1:2 ) + location;
end


function parent = getParentAncestor( target )

if isprop( target, 'Parent' ) && ~isa( target, 'matlab.ui.Figure' )
    parent = target.Parent;
else
    parent = [  ];
end
if isempty( parent )
    parent = ancestor( target, 'figure' );
end
end


function btn = makeButtonAndLabel( layout, basemap, displayName, row, column, icon )
btn = uibutton( layout, 'push' );
btn.Layout.Row = row;
btn.Layout.Column = column;
btn.Icon = icon;
btn.IconAlignment = 'center';
btn.Tooltip = basemap;

if strlength( icon ) == 0

    btn.Text = displayName;
    btn.FontWeight = 'bold';
    btn.FontSize = 10;
    btn.WordWrap = true;
    btn.HorizontalAlignment = 'center';
else
    btn.Text = '';
end

row = row + 1;
label = uilabel( layout );
label.Layout.Row = row;
label.Layout.Column = column;
label.Text = displayName;
label.FontWeight = 'bold';
label.WordWrap = true;
label.HorizontalAlignment = 'center';
label.VerticalAlignment = 'top';
label.FontSize = 10;
end


function value = getValue( index, k, values, valuesMode, defaultValue, hasDuplicates )
if index <= length( values )
    if matches( valuesMode, "auto" )
        if any( k )
            value = values( k );
        else
            value = defaultValue;
        end
    else
        value = values( index );
    end
elseif hasDuplicates
    if any( k ) && any( strlength( values ) > 0 )
        value = values( k );
    else
        value = defaultValue;
    end
else
    value = defaultValue;
end
end


function displayName = getPreferredDisplayName( basemapName )


try
    msgid = "shared_basemaps:BasemapPicker:" ...
        + replace( basemapName, '-', '' ) + "DisplayName";
    displayName = string( message( msgid ) );
catch
    displayName = basemapName;
end
end
