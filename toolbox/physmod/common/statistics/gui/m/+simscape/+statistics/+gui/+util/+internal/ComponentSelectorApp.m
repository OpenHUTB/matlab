classdef ComponentSelectorApp < handle
    properties ( Access = private )
        LayoutMap = containers.Map
    end
    properties
        Container
        Selector
        SelectionListener
        SelectionPanel
        Refresher( 1, 1 )function_handle = @( varargin )[  ];
    end
    properties ( Dependent )
        Visible
    end
    methods

        function obj = ComponentSelectorApp( refresher, args )
            arguments
                refresher( 1, 1 )function_handle = @( varargin )[  ];
                args.InitialTree( 1, : )simscape.statistics.gui.util.internal.ComponentTree
            end
            import simscape.statistics.gui.util.internal.ComponentSelector
            import matlab.ui.internal.FigurePanel
            import matlab.ui.container.internal.AppContainer


            obj.Refresher = refresher;
            if isfield( args, 'InitialTree' )
                obj.Selector = ComponentSelector( args.InitialTree );
            else
                obj.Selector = ComponentSelector(  );
            end


            obj.Container = AppContainer;
            obj.Container.CanCloseFcn = @( varargin )cacheLayout( obj );


            selectionPanel = FigurePanel( 'Title', 'Selection', 'Tag', 'SelectionPanel' );
            obj.Container.add( selectionPanel );
            obj.SelectionPanel = selectionPanel;
            m.( obj.Selector.Tags ) = selectionPanel.Figure;
            obj.Selector.render( m );


            obj.SelectionListener =  ...
                addlistener( obj.Selector, "SelectionChanged", @( varargin )showSelection( obj ) );


            obj.Container.add( toolstrip( RefreshCallback = @( varargin )obj.refresh(  ) ) );
        end
        function refresh( obj, args )
            arguments
                obj( 1, 1 )
                args.ComponentTree( 1, : )simscape.statistics.gui.util.internal.ComponentTree
            end


            obj.Container.Busy = true;
            c = onCleanup( @(  )set( obj.Container, 'Busy', false ) );


            if isfield( args, 'ComponentTree' )
                obj.Selector.setComponentTree( args.ComponentTree );
            else
                obj.Selector.setComponentTree( obj.Refresher(  ) );
            end


            m.( obj.Selector.Tags ) = obj.SelectionPanel.Figure;
            obj.Selector.render( m );
            obj.showSelection(  );
        end
        function set.Visible( obj, s )
            arguments
                obj( 1, 1 )
                s( 1, 1 )logical
            end
            obj.Container.Visible = s;
        end
        function out = get.Visible( obj )
            out = obj.Container.Visible;
        end
    end
    methods ( Access = private )
        function showSelection( obj )
            group = obj.Selector.Selection;
            obj.hideOthers( group );
            if ~ismissing( group )
                cmp = obj.Selector.component(  );
                if ~obj.Container.hasDocumentGroup( group )
                    obj.Container.add( matlab.ui.internal.FigureDocumentGroup( "Tag", group ) );
                    if ~isKey( obj.LayoutMap, group )
                        obj.LayoutMap( group ) = lDocumentLayout( cmp.Layout, group );
                    end
                end

                layout = obj.LayoutMap( group );
                if ~strcmp( obj.Container.DocumentLayout, layout )
                    obj.Container.DocumentLayout = obj.LayoutMap( group );
                end

                fg = lFetchFigures( cmp, obj, group );
                for idx = 1:numel( fg )
                    figMap.( fg( idx ).Tag ) = fg( idx ).Figure;
                end
                arrayfun( @( fd )set( fd, 'Visible', true ), fg );
                cmp.render( figMap );

            end

            function fg = lFetchFigures( cmp, obj, group )
                figureTags = cmp.Tags;
                for iTag = 1:numel( figureTags )
                    if obj.Container.hasDocument( group, figureTags{ iTag } )
                        fd = obj.Container.getDocument( group, figureTags{ iTag } );
                    else
                        fd = matlab.ui.internal.FigureDocument(  ...
                            "Tag", figureTags{ iTag },  ...
                            "DocumentGroupTag", group,  ...
                            "Title", cmp.label( figureTags{ iTag } ),  ...
                            'Closable', false );
                        obj.Container.add( fd );
                    end
                    fg( iTag ) = fd;%#ok<AGROW>
                end
            end
        end

        function out = cacheLayout( obj )
            out = true;
            try %#ok<TRYNC>
                fd = obj.Container.getDocuments(  );

                if ~isempty( fd )
                    obj.LayoutMap( fd{ 1 }.DocumentGroupTag ) = obj.Container.DocumentLayout;
                end
            end
        end

        function hideOthers( obj, group )
            fd = obj.Container.getDocuments(  );


            if ~isempty( fd )
                cacheLayout( obj );
            end

            cellfun( @( dg )lHideIfNotInGroup( dg, group ), fd );
            function lHideIfNotInGroup( dg, group )
                if ~strcmp( dg.DocumentGroupTag, group )
                    dg.Visible = false;
                end
            end
        end
    end
end



function out = lDocumentLayout( layout, parentTag )
arguments
    layout( 1, 1 )simscape.statistics.gui.util.internal.Layout
    parentTag( 1, 1 )string{ lMustBeValidPath }
end
out = struct;
out.gridDimensions.w = numel( layout.ColumnWidth );
out.gridDimensions.h = numel( layout.RowHeight );
[ tileID, ~, tileCoverage ] = unique( layout.Tiling, 'stable' );
out.tileCount = numel( tileID );
out.columnWeights = layout.ColumnWidth;
out.rowWeights = layout.RowHeight;
out.tileCoverage = reshape( tileCoverage, out.gridDimensions.h, out.gridDimensions.w );

out.tileOccupancy = struct( 'children', num2cell( struct( 'id', num2cell( strcat( parentTag, '_', tileID ) ) ) ) );
end

function tg = toolstrip( options )
arguments
    options.RefreshCallback( 1, 1 )function_handle = @( varargin )[  ]
end
b = matlab.ui.internal.toolstrip.Button;
b.Icon = lIconPath( 'refresh_24.png' );
b.Text = 'Refresh';
b.ButtonPushedFcn = @( varargin )options.RefreshCallback(  );
c = matlab.ui.internal.toolstrip.Column;
c.add( b );
s = matlab.ui.internal.toolstrip.Section;
s.Title = 'DATA';
s.add( c );
t = matlab.ui.internal.toolstrip.Tab;
t.Title = 'STATISTICS';
t.add( s );
tg = matlab.ui.internal.toolstrip.TabGroup;
tg.Tag = 'MainTabs';
tg.add( t );
    function str = lIconPath( iconFile )
        str = fullfile( matlabroot,  ...
            'toolbox/physmod/common/statistics/gui/m/resources', iconFile );
    end
end

function lMustBeValidPath( p )
lValidVariableNames( strsplit( p, '.' ) );
end

function lValidVariableNames( str )
arrayfun( @mustBeValidVariableName, str );
end

